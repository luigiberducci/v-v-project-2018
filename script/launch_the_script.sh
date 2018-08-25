#!/bin/bash
#PRE:   exists INPUT_DIR
#       exists ./tmp for storing partial execution
#       if exists MEMORY_PART_EXEC file, then it is correct and it contains only a number

INPUT_DIR="/home/luigi/Simulink/project/model/out/"
MEMORY_PART_EXEC="tmp/store_last_dist.txt"
DIR_PREFIX="complemented_guard_"

if [[ ${1} == "" ]]
then
    EXEC_ONLY_FIRST=0
else
    EXEC_ONLY_FIRST=1
fi

if [ ! -f ${MEMORY_PART_EXEC} ]; then
    echo "[Info] There are not any partial execution stored in memory."
    echo "[Warning] The script runs among all the disturbed model found in"
    echo "\t\t> ${INPUT_DIR}"
    echo ""
    echo "0">${MEMORY_PART_EXEC}
    LAST_EXEC=0
else
    LAST_EXEC=$(cat ${MEMORY_PART_EXEC})
    echo "[Info] Partial execution found."
    echo "[Warning] The script runs among the remaining models in lexicographic order (>= ${LAST_EXEC})."
    echo ""
fi

current_exec=0
for d in $(ls -v $INPUT_DIR | grep "${DIR_PREFIX}")
do
    dir="${INPUT_DIR}${d}/"
    models=$(ls ${dir}*main*.mdl)
    filename=$(basename ${models} | cut -d '.' -f 1)
    current_exec=$((current_exec+1))

    if [ $current_exec -ge $LAST_EXEC ]
    then
        echo "###############################################################################################"
        echo "[Info] Running on $dir$filename"

        #matlab -nojvm -nodisplay -nosplash -r "global MODEL_DIRECTORY; global MODEL_NAME; MODEL_DIRECTORY=\"${dir}\"; MODEL_NAME=\"${filename}\"; run; exit;"
        matlab -nodisplay -nosplash -r "global MODEL_DIRECTORY; global MODEL_NAME; MODEL_DIRECTORY=\"${dir}\"; MODEL_NAME=\"${filename}\"; run; exit;"

        echo $current_exec>$MEMORY_PART_EXEC
    fi

    #If flag enabled, after the execution of first, exit
    if [[ ${EXEC_ONLY_FIRST} == 1 ]]
    then
        break
    fi
done
