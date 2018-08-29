#!/bin/bash
# run_parallel_sensitivity_estimation(  e: real in [0,1],
#                                       d: real in [0,1],
#                                       INPUT_DIR: filepath,
#                                       OUTPUT_FILE: filepath): void
#
# PRE:  mutated models already created in the INPUT_DIR according to the structure defined by the scripts
# POST: exists OUTPUT_FILE with data of each execution and final result

# Degine Header message
function header
{
    echo "This script runs a parallel hypotesis testing based on MonteCarlo for model's sensitivity estimation."
    echo ""
}
# Define Usage
function usage()
{
    echo -e "Usage:\t./run_parallel_sensitivity_estimation epsilon delta input-dir-path output-file-path"
    echo -e "\tepsilon\t\t\terror in MonteCarlo hypotesis testing"
    echo -e "\tdelta\t\t\tconfidence in MonteCarlo hypotesis testing"
    echo -e "\tinput-dir-path\t\tpath to the starting directory containing all models directories"
    echo -e "\toutput-file-path\tpath to output file in which write the result"
    #TODO: parametrization of epsilon2, delta2 for OAA directly from this script
}

# Define Not enough input arguments
function not_enough_args()
{
    echo -e "Error:\tnot enough input arguments"
    echo ""
    usage
}

function too_many_args()
{
    echo -e "Error:\ttoo many input arguments"
    echo ""
    usage
}

function illegal_type_arg()
{
    echo -e "Error:\tillegal type for input parameter $1 (Expected a $2 value)"
    echo ""
    usage
}

function print_init_warning()
{
    echo -e "[Info] Input parameters are correct."
    echo -e "[Info] Notice that the output file $OUTPUT_FILE will be overwritten, if it exists."
    echo ""
}

function print_input_params()
{
    echo -e "[Info] The parameters are the following:"
    echo -e "\tepsilon\t\t\t${EPSILON}"
    echo -e "\tdelta\t\t\t${DELTA}"
    echo -e "\tinput-dir\t\t${INPUT_DIR}"
    echo -e "\toutput-file\t\t${OUTPUT_FILE}"
    echo ""
}

function ceil()
{
    echo "$1" | perl -nl -MPOSIX -e 'print ceil($_);'
}

function floor()
{
    echo "$1" | perl -nl -MPOSIX -e 'print floor($_);'
}

# Global parameters
TIME_SUFFIX=`date | sed 's/ //g' | tr , _`
DEFAULT_OUTPUT_FILE="./out/result_${TIME_SUFFIX}.out"
FILTER_INPUT_DIR="complemented_guard_[0-9]"
PREFIX_MODEL_MAIN_FILE="^main"
RESULT_FILEPATH="res/result.csv"
NUM_PARALLELISM=2

# Check number of input parameters
if [ $# -lt 3 ]
then
    not_enough_args
    exit 1
fi

if [ $# -gt 4 ]
then
    too_many_args
    exit 1
fi

# Check type of input parameters
EPSILON=$1
DELTA=$2
INPUT_DIR=$3
OUTPUT_FILE=$4

decimal_regex="0*[0-1]\.[0-9][0-9]*"    #Real in [0,1]
linux_path_regex="^(/[^/ ]*)+/?$"             #Path without blank spaces

if [[ ! $EPSILON =~ $decimal_regex ]]
then
    illegal_type_arg $EPSILON "real"
    exit 1
fi

if [[ ! $DELTA =~ $decimal_regex ]]
then
    illegal_type_arg $DELTA "real"
    exit 1
fi

if [ ! -d $INPUT_DIR ]
then
    illegal_type_arg $INPUT_DIR "string"
    exit 1
fi

if [[ $OUTPUT_FILE == "" ]]
then
    OUTPUT_FILE=$DEFAULT_OUTPUT_FILE
fi

OUTPUT_DIR=`dirname $OUTPUT_FILE`
if [ ! -d $OUTPUT_DIR ]
then
    illegal_type_arg $OUTPUT_FILE "string"
    exit 1
fi

# Print input data and warning
print_input_params
print_init_warning

# Define N as number of mutated models in INPUT_DIR
model_dirs=`ls -v $INPUT_DIR | grep $FILTER_INPUT_DIR`
N=`echo $model_dirs | sed 's/ /\n/g' | wc -l`

# Compute M using MonteCarlo, the computed value is rounded up
expression="l($DELTA)/l(1-$EPSILON)"
M=`echo $expression | bc -l`

# Create M random numbers in [1,N],
# each random number represents a model in INPUT_DIR according to the order of `ls`
MIN=1
MAX=$N
random_indexes=""
echo MAX $MAX
for i in `seq 0 $M`
do
    r=`shuf -i $MIN-$MAX -n 1`    #random number between [1,N]
    if [ $i -eq 0 ]
    then
        random_indexes+="$r"
    else
        random_indexes+=" $r"
    fi
done

# Create command string, each row contains a command associated with one of the M random models
# Iterate on models in INPUT_DIR
commands=""
fetch_from_files=""
i=0
for model_index in $random_indexes
do
    model_dir=$INPUT_DIR/`echo $model_dirs | cut -d ' ' -f $model_index`
    model_main_file=`ls $model_dir | grep ${PREFIX_MODEL_MAIN_FILE}`
    model_result_file="$model_dir/$RESULT_FILEPATH"
    commands+="matlab -nodisplay -nosplash -r \"global MODEL_DIRECTORY; global MODEL_NAME; MODEL_DIRECTORY='${model_dir}'; MODEL_NAME='${model_main_file}'; run; exit;\"\n"
    #DEBUG#commands+="echo $i >> $model_result_file\n"
    fetch_from_files+="$model_result_file\n"
    i=$((i+1))
done

# Run parallel executions
echo -e $commands | parallel -P $NUM_PARALLELISM

# Fetch output data from each execution and write them in OUTPUT_FILE
fetch_from_files="${fetch_from_files::-2}"    #delete last '\n'
for file in `echo -e $fetch_from_files`
do
    echo $file
    tail $file -n 1 >> $OUTPUT_FILE
    head -n -1 $file > $file.tmp ;
    mv $file.tmp $file
done

# Compute the final result and write it in OUTPUT_FILE
#TODO
