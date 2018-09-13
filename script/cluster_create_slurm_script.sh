#!/bin/bash

input_number=9
if [ $# -ne $input_number ]
then
    echo "[Error] Not enough arguments to invoke $0."
    echo -e "\tUsage:\t$0 out_filepath nodes n_task timeout out_red err_red job_name mem num_scripts"
    exit 1
fi

script_filepath=$1
nodes=$2
n_task=$3
timeout=$4
output=$5
err=$6
job_name=$7
mem=$8
range_scripts=$9
script_prefix="cluster_matlab_script"

# Shabang
echo "#!/bin/bash" > $script_filepath
# Header
echo "#SBATCH --nodes=${nodes}" >> $script_filepath
echo "#SBATCH --ntasks-per-node=${n_task}" >> $script_filepath
echo "#SBATCH --time=${timeout}" >> $script_filepath
echo "#SBATCH --output=${output}" >> $script_filepath
echo "#SBATCH --error=${err}" >> $script_filepath
echo "#SBATCH --job-name=${job_name}" >> $script_filepath
echo "#SBATCH --mem=${mem}" >> $script_filepath
echo "" >> $script_filepath

# echo "module load quello_che_serve" >> $script_filepath
# echo "" >> $script_filepath

echo -n "mpirun -np 1 bash ${script_prefix}0.sh" >> $script_filepath
for j in `seq 1 $range_scripts`
do
    echo $j
    echo -n " : -np 1 bash ${script_prefix}${j}.sh" >> $script_filepath
done
echo "" >> $script_filepath

# Give permission
chmod +x $script_filepath
