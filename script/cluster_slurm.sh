#!/bin/bash
#SBATCH --nodes=24
#SBATCH --ntasks-per-node=1
#SBATCH --time=08:00:00
#SBATCH --output=./out/log/execution.log
#SBATCH --error=./out/log/execution.err
#SBATCH --job-name=sens
#SBATCH --mem=118000

mpirun -np 1 bash cluster_matlab_script0.sh : -np 1 bash cluster_matlab_script1.sh : -np 1 bash cluster_matlab_script2.sh : -np 1 bash cluster_matlab_script3.sh : -np 1 bash cluster_matlab_script4.sh : -np 1 bash cluster_matlab_script5.sh : -np 1 bash cluster_matlab_script6.sh : -np 1 bash cluster_matlab_script7.sh : -np 1 bash cluster_matlab_script8.sh : -np 1 bash cluster_matlab_script9.sh : -np 1 bash cluster_matlab_script10.sh : -np 1 bash cluster_matlab_script11.sh : -np 1 bash cluster_matlab_script12.sh : -np 1 bash cluster_matlab_script13.sh : -np 1 bash cluster_matlab_script14.sh : -np 1 bash cluster_matlab_script15.sh : -np 1 bash cluster_matlab_script16.sh : -np 1 bash cluster_matlab_script17.sh : -np 1 bash cluster_matlab_script18.sh : -np 1 bash cluster_matlab_script19.sh : -np 1 bash cluster_matlab_script20.sh : -np 1 bash cluster_matlab_script21.sh
