#!/bin/bash

# Check number of input parameters
if [ $# -ne 4 ]
then
    echo "[Error] Not enough argument to invoke $0."
    echo ""
    echo -e "Usage:\t$0 output_dir model_dir model_main_file index_id"
    exit 1
fi

# Input extraction
script_dir=$1
model_directory=$2
main_file=$3
curr_exec=$4
script_prefix="cluster_matlab_script"
output_script="${script_dir}/${script_prefix}${curr_exec}.sh"

# If output directory doesn't exist, create it
mkdir -p $script_dir

# Write Shabang
echo "#!/bin/bash" > ${output_script}
echo "" >> ${output_script}

# Append Matlab command
# echo "matlab -nojvm -nodisplay -nosplash -r \"global MODEL_DIRECTORY; global MODEL_NAME; MODEL_DIRECTORY='${model_directory}/'; MODEL_NAME='${main_file}'; run; exit;\" &>${model_directory}/err/exec_${curr_exec}.out" >> ${output_script}
echo "matlab -nojvm -nodisplay -nosplash -r \"global MODEL_DIRECTORY; global MODEL_NAME; MODEL_DIRECTORY='${model_directory}/'; MODEL_NAME='${main_file}'; run; exit;\"" >> ${output_script}
