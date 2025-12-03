#!/bin/bash

# create directory to save log files
logs_dir="/data/p_03140/logs"

#run job
sub="000"
ses="01"

sbatch --error "${logs_dir}/${sub}_${ses}".err \
    --output "${logs_dir}/${sub}_${ses}".out \
    /data/p_03140/scripts/1_struct_micapipe_proc_struct.sh  "${sub}" "${ses}"
