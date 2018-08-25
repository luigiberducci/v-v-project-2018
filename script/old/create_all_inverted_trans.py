#!/usr/bin/python
import random as rand
import argparse
import os
import shutil

MAIN_DIR                = "../model/"
MAIN_MODEL_FILENAME     = "twin_sldemo_autotrans.mdl"
REG_MODEL_FILENAME      = "regular_subsystem.mdl"
DIST_MODEL_FILENAME     = "disturbed_subsystem.mdl"
WORKSPACE_FILENAME     = "workspace.m"
OUTPUT_DIR_NAME         = "out/"

OUT_SUBDIR_NAME         = "inverted_trans_"

MAIN_MODEL_FILEPATH     = MAIN_DIR + MAIN_MODEL_FILENAME
REG_MODEL_FILEPATH      = MAIN_DIR + REG_MODEL_FILENAME
DIST_MODEL_FILEPATH     = MAIN_DIR + DIST_MODEL_FILENAME
WORKSPACE_FILEPATH      = MAIN_DIR + WORKSPACE_FILENAME
OUT_DIR                 = MAIN_DIR + OUTPUT_DIR_NAME

#Input parsing
parser = argparse.ArgumentParser(description="Simple script to create disturbed models with mutation on Control Logic (inverted transitions)")
parser.add_argument('--debug', default=False, action='store_true',
                    help='run the script without disturbance injection, usefull for debug and check correctness')
args = parser.parse_args()

INJECT_DIST = not(args.debug)   #If enabled, inject disturbance otherwise it does not change the model

#Read original model
with open(DIST_MODEL_FILEPATH, 'r') as model:
    model_lines = model.readlines()

# and copy the first part of model file
out_model_lines = []

begin = 0
for (l,line) in enumerate(model_lines):
    #Copy the first part of model file
    if( not "transition {" in line ):
        out_model_lines.append(line)
    else:
        out_model_lines.append("  ")
        begin = l
        break
section_to_change = model_lines[begin:]

#Copy the last part of model file
tail_model_lines = []
end = 0
tail_reached = False
for (l,line) in enumerate(section_to_change):
    #Copy the last part of model file
    if( not tail_reached and "data {" in line ):
        tail_reached = True
        end = l
    if(tail_reached):
        tail_model_lines.append(line)

#Reduce the section to a unique string
section_to_change=''.join(section_to_change[:end])

#Find the transition's paragraph
transitions_par = section_to_change.split("transition")

#Create dirs structure
for i in range(1, len(transitions_par)+1):
    DIR_NAME = OUT_DIR  + OUT_SUBDIR_NAME + "%d/" %i
    os.mkdir( DIR_NAME )
    os.mkdir( DIR_NAME + "out" )
#    os.mkdir( DIR_NAME + "err" )
#    os.mkdir( DIR_NAME + "res" )

    #Read original MainModel and change references to dist/reg submodels
    with open(MAIN_MODEL_FILEPATH, 'r') as main_model:
        main_model_lines = main_model.readlines()
    main_model_lines = ''.join(main_model_lines)
    main_model_lines = main_model_lines.replace(REG_MODEL_FILENAME, REG_MODEL_FILENAME.replace(".mdl", "_%d.mdl" %i))
    main_model_lines = main_model_lines.replace(DIST_MODEL_FILENAME, DIST_MODEL_FILENAME.replace(".mdl", "_%d.mdl" %i))

    with open( DIR_NAME+ "main_model_%d.mdl" %i , 'w') as main_output:
        for line in main_model_lines:
            main_output.write(line)

    #Copy regular submodel to output dir
    shutil.copy ( REG_MODEL_FILEPATH, DIR_NAME + REG_MODEL_FILENAME.replace(".mdl", "_%d.mdl" %i) )
    #Copy workspace of disturbed submodel
    shutil.copy ( WORKSPACE_FILEPATH, DIR_NAME + WORKSPACE_FILENAME.replace(".m", "_%d.m" %i) )

    #Copy the first part of disturbed submodel to output dir
    OUT_NAME = DIR_NAME + DIST_MODEL_FILENAME.replace(".mdl", "_%d.mdl" %i)
    with open( OUT_NAME , 'w') as output:
        for line in out_model_lines:
            if(WORKSPACE_FILENAME in line):
                line=line.replace(WORKSPACE_FILENAME, WORKSPACE_FILENAME.replace(".m", "_%d.m" %i))
            output.write(line)

#Transition mutations
for (current_trans, transition) in enumerate(transitions_par):
    out_trans_lines = []
    src_begin   = 0
    src_end     = 0
    dst_begin   = 0
    dst_end     = 0
    src_block   = False
    dst_block   = False
    selected_trans_lines = transition.split("\n")
    for (l,line) in enumerate( selected_trans_lines ):
        if("src {" in line):
            src_begin = l
            src_block = True
        if(src_block and "}" in line):
            src_end = l
            src_block = False
        if("dst {" in line):
            dst_begin = l
            dst_block = True
        if(dst_block and "}" in line):
            dst_end = l
            dst_block = False

    #Arrow is invertible if it has a src and a dst. If the src block in the model file has fewer lines than
    #the dst block, then it is not invertible.
    CHECK_IF_INVERTIBLE = (src_end-src_begin) == (dst_end-dst_begin)
    #The first element of transition_par is empty, so we have to avoid to create such model because it will be identical to the original model
    CHECK_IF_EMPTY      = (current_trans==0)

    if ( INJECT_DIST and CHECK_IF_INVERTIBLE ):
        dist_trans = "\n".join( selected_trans_lines[:src_begin] ) + "\n"
        dist_trans += selected_trans_lines[src_begin] + "\n"
        dist_trans += "\n".join(selected_trans_lines[dst_begin+1:dst_end]) + "\n"
        dist_trans += selected_trans_lines[src_end] + "\n"
        dist_trans += selected_trans_lines[dst_begin] + "\n"
        dist_trans += "\n".join(selected_trans_lines[src_begin+1:src_end]) + "\n"
        dist_trans += "\n".join(selected_trans_lines[dst_end:])
    else:
        dist_trans = "\n".join(selected_trans_lines)

    #Debug: print disturbed transition
    print " ###########################################"
    print " # D i s t u r b e d   t r a n s i t i o n #"
    print " ###########################################"
    print dist_trans

    #Concatenate modified section
    for (t,trans) in enumerate(transitions_par):
        if(t==0):       #The first element is blank
            continue
        out_trans_lines.append("transition")
        if(t!=current_trans):
            out_trans_lines.append(trans)
        else:
            out_trans_lines.append(dist_trans)

    #Write to the output file
    DIR_NAME = OUT_DIR  + OUT_SUBDIR_NAME + "%d/" %(current_trans+1)
    OUT_NAME = DIR_NAME + DIST_MODEL_FILENAME.replace(".mdl", "_%d.mdl" %(current_trans+1))

    with open( OUT_NAME , 'a') as output:
        for line in out_trans_lines:
            output.write(line)
        for line in tail_model_lines:
            output.write(line)

    #If the arrow is not invertible then the mutation is not injected.
    #So remove all the dir relative this mutation
    if not(CHECK_IF_INVERTIBLE) or CHECK_IF_EMPTY:
        shutil.rmtree( OUT_DIR + OUT_SUBDIR_NAME + "%d/" %(current_trans+1))


#Print information
print "######################################################################"
print ">original model:\t%s"     %str( MAIN_MODEL_FILEPATH )
print ">output directory:\t%s"    %str( OUT_DIR )
print ">disturbed:\t\t%s"         %str( INJECT_DIST )
