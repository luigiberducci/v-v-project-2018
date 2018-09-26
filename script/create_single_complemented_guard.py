#!/usr/bin/python
import argparse
import os
import shutil
import re

MAIN_DIR                = "../model/"
MAIN_MODEL_FILENAME     = "twin_sldemo_autotrans.mdl"
REG_MODEL_FILENAME      = "regular_subsystem.mdl"
DIST_MODEL_FILENAME     = "disturbed_subsystem.mdl"
WORKSPACE_FILENAME      = "workspace.m"
OUTPUT_DIR_NAME         = "out/"

OUT_SUBDIR_NAME         = "complemented_guard_"

MAIN_MODEL_FILEPATH     = MAIN_DIR + MAIN_MODEL_FILENAME
REG_MODEL_FILEPATH      = MAIN_DIR + REG_MODEL_FILENAME
DIST_MODEL_FILEPATH     = MAIN_DIR + DIST_MODEL_FILENAME
WORKSPACE_FILEPATH      = MAIN_DIR + WORKSPACE_FILENAME
OUT_DIR                 = MAIN_DIR + OUTPUT_DIR_NAME

#Input parsing
parser = argparse.ArgumentParser(description="Simple script to create disturbed models with mutation on Control Logic (complemented guard)")
parser.add_argument('n', action='store', type=int, help='Identifier of guard which will be complemented')
args = parser.parse_args()

#Takes the identifier of guard which will be complemented
MUTABLE_GUARDS=[0,1,2,3,4,5]
N = args.n

result=True
if (N not in MUTABLE_GUARDS):
    result=False
    print "[Info]\tInject mutation in the original model . . ."
    print ""
    print "[Error]\tThe input guard (%s) is out of domain (%s)" %(str(N), str(MUTABLE_GUARDS))
    print "[Out]\tAbort"
    exit()

#Read original model
with open(DIST_MODEL_FILEPATH, 'r') as model:
    model_lines = model.readlines()

# and copy the first part of model file
out_model_lines = []

#Find all the guards
pattern = '\[\w* [><]=? \w*\]'  #Regex to match a guard
guards_lines = []
for (l,line) in enumerate(model_lines):
    if(re.search(pattern, line)):
        guards_lines.append(l)

for (l, line) in enumerate(model_lines):
    if l==guards_lines[N]:
        out_model_lines.append( line.replace("[", "[!(").replace("]", ")]") )   #Complement the condition
    else:
        out_model_lines.append(line)

#Create dirs structure
DIR_NAME = OUT_DIR  + OUT_SUBDIR_NAME + "%d/" %N
os.mkdir( DIR_NAME )
os.mkdir( DIR_NAME + "out" )
os.mkdir( DIR_NAME + "err" )
os.mkdir( DIR_NAME + "res" )

#Read original MainModel and change references to dist/reg submodels
with open(MAIN_MODEL_FILEPATH, 'r') as main_model:
    main_model_lines = main_model.readlines()
main_model_lines = ''.join(main_model_lines)
main_model_lines = main_model_lines.replace(REG_MODEL_FILENAME, REG_MODEL_FILENAME.replace(".mdl", "_g_%d.mdl" %N))
main_model_lines = main_model_lines.replace(DIST_MODEL_FILENAME, DIST_MODEL_FILENAME.replace(".mdl", "_g_%d.mdl" %N))

with open( DIR_NAME+ "main_model_g_%d.mdl" %N , 'w') as main_output:
    for line in main_model_lines:
        main_output.write(line)

#Copy regular submodel to output dir
shutil.copy ( REG_MODEL_FILEPATH, DIR_NAME + REG_MODEL_FILENAME.replace(".mdl", "_g_%d.mdl" %N) )
#Copy workspace of disturbed submodel
shutil.copy ( WORKSPACE_FILEPATH, DIR_NAME + WORKSPACE_FILENAME.replace(".m", "_g_%d.m" %N) )

#Copy the first part of disturbed submodel to output dir
OUT_NAME = DIR_NAME + DIST_MODEL_FILENAME.replace(".mdl", "_g_%d.mdl" %N)
with open( OUT_NAME , 'w') as output:
    for line in out_model_lines:
        if(WORKSPACE_FILENAME in line):
            line=line.replace(WORKSPACE_FILENAME, WORKSPACE_FILENAME.replace(".m", "_g_%d.m" %N))
        output.write(line)

#Print information
print "[Info]\tInject mutation in the original model . . ."
print "[Info]\tOriginal line:\t%s" %(model_lines[guards_lines[N]])
print "[Info]\tDisturbed line:\t%s" %(out_model_lines[guards_lines[N]])
print ""
print "[Info]\tOriginal model:\t%s"    %str( MAIN_MODEL_FILEPATH )
print "[Info]\tOutput dir:\t%s"  %str( DIR_NAME )
print "[Out]\tResult:\t\t %s"       %str( result )
