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
    echo -e "\tepsilon\t\terror in MonteCarlo hypotesis testing"
    echo -e "\tdelta\t\tconfidence in MonteCarlo hypotesis testing"
    echo -e "\tinput-dir-path\t\tpath to the starting directory containing all models directories"
    echo -e "\toutput-file-path\t\tpath to output file in which write the result"
    #TODO: parametrization of epsilon2, delta2 for OAA directly from this script
}

# Define Not enough input arguments
function not_enough_args()
{
    echo "Error:\tnot enough input arguments"
    echo ""
    usage
}

function too_many_args()
{
    echo "Error:\ttoo many input arguments"
    echo ""
    usage
}

# Check number of input parameters
if [ $#@ -lt 3 ]
then
    not_enough_args
    exit 1
fi

if [ $#@ -gt 4 ]
then
    too_many_args
    exit 1
fi

# Check type of input parameters

while [ "$1" != "" ]
do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --environment)
            ENVIRONMENT=$VALUE
            ;;
        --db-path)
            DB_PATH=$VALUE
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done



# Check existance of OUTPUT_FILE, eventually overwrite

# Define N as number of mutated models in INPUT_DIR

# Compute M using MonteCarlo

# Create M random numbers in [0,N-1],
# each random number represents a model in INPUT_DIR according to the order of `ls`

# Create command string, each row contains a command associated with one of the M random models
# Iterate on models in INPUT_DIR

# Run parallel executions

# Fetch output data from each execution

# Write final result on OUTPUT_FILE
