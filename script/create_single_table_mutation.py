#!/usr/bin/python
import random as rand
import argparse
import os
import shutil

MAIN_DIR                = "../model/"
MAIN_MODEL_FILENAME     = "twin_sldemo_autotrans.mdl"
REG_MODEL_FILENAME      = "regular_subsystem.mdl"
DIST_MODEL_FILENAME     = "disturbed_subsystem.mdl"
WORKSPACE_FILENAME      = "workspace.m"
OUTPUT_DIR_NAME         = "out/"

OUT_SUBDIR_NAME         = "table_change_"

MAIN_MODEL_FILEPATH     = MAIN_DIR + MAIN_MODEL_FILENAME
REG_MODEL_FILEPATH      = MAIN_DIR + REG_MODEL_FILENAME
DIST_MODEL_FILEPATH     = MAIN_DIR + DIST_MODEL_FILENAME
WORKSPACE_FILEPATH     = MAIN_DIR + WORKSPACE_FILENAME
OUT_DIR                 = MAIN_DIR + OUTPUT_DIR_NAME

#Mutation parameter
MIN_MUT = 0
MAX_MUT = 160
PERCENTAGE_MUT = 0.05
MUT_VAL = PERCENTAGE_MUT*(MAX_MUT-MIN_MUT)

MUTABLE_TABLES=["UP_TABLE", "DOWN_TABLE"]
MUTABLE_ROWS=[0,1,2,3,4,5]
MUTABLE_COLS=[0,1,2,3]

#Input parsing
parser = argparse.ArgumentParser(description="Simple script to create disturbed models with mutation on Control Logic (table mutation)")

parser.add_argument('table', action="store")
parser.add_argument('row', action="store", type=int)
parser.add_argument('column', action="store", type=int)
parser.add_argument('--inc', action="store_true", default=False)

args = parser.parse_args()

#Takes input parameters
TABLE   = args.table
ROW     = args.row
COL     = args.column
INC     = args.inc        #Increment/decrement TABLE[ROW][COL] by MUT_VAL

NAME_EXTENSION = "%s_%d_%d_%s_%d" %(TABLE, ROW, COL, INC, MUT_VAL)    #Change for generate all disturbance
OUT_SUBDIR_NAME = OUT_SUBDIR_NAME + NAME_EXTENSION

#Check input correctness
result = True
if(TABLE not in MUTABLE_TABLES or ROW not in MUTABLE_ROWS or COL not in MUTABLE_COLS):
    result=False
    #Print information
    print "[Info]\tInject mutation in the original model . . ."
    print ""
    print "[Error]\tOne of the input parameter is out of domain."
    print "[Out]\tAbort"
    exit()

#Read original model
with open(WORKSPACE_FILEPATH, 'r') as model:
    workspace_lines = model.readlines()

pre_out_workspace_lines = []
post_out_workspace_lines = []
section_to_change   = []
before_section      = True
after_section       = False
for (i,line) in enumerate(workspace_lines):
    if before_section and not( TABLE in line ):
        pre_out_workspace_lines.append(line)
    elif after_section:
        post_out_workspace_lines.append(line)
    elif not(line=="\n"):
        before_section=False
        section_to_change.append(line)
    else:
        after_section=True
        post_out_workspace_lines.append(line)

table_name, table_content = ''.join(section_to_change).split(" = ...\n")
table_rows = table_content.replace("[","").replace("]","").replace(";","").split("\n")[:-1]

out_workspace_lines = pre_out_workspace_lines
out_workspace_lines.append(table_name + " = ...\n")
out_workspace_lines.append("  [")
for (i,r) in enumerate(table_rows):
    new_row=""
    if i==0:
        r=r.lstrip()
    if not(i==ROW):
        new_row+=r
        if i==len(table_rows)-1:
            new_row+="]"
    else:
        new_row+="   "
        for (j,c) in enumerate(r.lstrip().split(" ")):
            if not(j==COL):
                new_row += "%s " %c
            else:
                old_val = float(c)
                if INC:
                    new_val = old_val + MUT_VAL
                else:
                    new_val = old_val - MUT_VAL
                new_row += "%s " %str(new_val)
    out_workspace_lines.append(new_row + ";\n")
out_workspace_lines.extend(post_out_workspace_lines)

print ""
print ""
print ''.join(out_workspace_lines)

DIR_NAME = OUT_DIR  + OUT_SUBDIR_NAME + "/"
os.mkdir( DIR_NAME )
os.mkdir( DIR_NAME + "out" )
os.mkdir( DIR_NAME + "err" )
os.mkdir( DIR_NAME + "res" )

#Read original MainModel and change references to dist/reg submodels
with open(MAIN_MODEL_FILEPATH, 'r') as main_model:
    main_model_lines = main_model.readlines()
main_model_lines = ''.join(main_model_lines)
main_model_lines = main_model_lines.replace(REG_MODEL_FILENAME, REG_MODEL_FILENAME.replace(".mdl", "_%s.mdl" %NAME_EXTENSION))
main_model_lines = main_model_lines.replace(DIST_MODEL_FILENAME, DIST_MODEL_FILENAME.replace(".mdl", "_%s.mdl" %NAME_EXTENSION))
with open( DIR_NAME+ "main_model_%s.mdl" %NAME_EXTENSION , 'w') as main_output:
    for line in main_model_lines:
        main_output.write(line)

#Copy regular submodel to output dir
shutil.copy ( REG_MODEL_FILEPATH, DIR_NAME + REG_MODEL_FILENAME.replace(".mdl", "_%s.mdl" %NAME_EXTENSION) )
shutil.copy ( DIST_MODEL_FILEPATH, DIR_NAME + DIST_MODEL_FILENAME.replace(".mdl", "_%s.mdl" %NAME_EXTENSION) )

#Copy the first part of disturbed submodel to output dir
OUT_NAME = DIR_NAME + WORKSPACE_FILENAME
with open( OUT_NAME , 'w') as output:
    for line in out_workspace_lines:
        output.write(line)

#Print information
print "[Info]\tInject mutation in the original model . . ."
print "[Info]\tOriginal line:\t"
print "[Info]\tDisturbed line:\t"
print ""
print "[Info]\tOriginal model:\t%s" %str( MAIN_MODEL_FILEPATH )
print "[Info]\tOutput dir:\t%s"     %str( DIR_NAME )
print "[Out]\tResult:\t\t %s"       %str( result )
