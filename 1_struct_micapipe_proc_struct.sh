#!/bin/bash

#SBATCH -c 10
#SBATCH --mem 15G
#SBATCH --time 5:00:00
#SBATCH --job-name struct
#SBATCH --partition=standard

# cores
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# define tmp
job_tmp_dir=$TMPDIR/$SLURM_JOB_ID
mkdir $job_tmp_dir

# params
sub=$1
ses=$2

micapipe_img=/data/p_SoftwareServiceLinux_micapipe/0.2.3/singularity/
bids=/data/p_03140/BIDS_spacetop
out=/data/p_03140/BIDS_spacetop/derivatives
fs_lic=/data/p_03140/resources/license.txt

# run
singularity run --cleanenv --writable-tmpfs --containall \
    -B ${bids}:/bids \
	-B ${out}:/out \
	-B ${job_tmp_dir}:/tmp \
	-B ${fs_lic}:/opt/licence.txt \
	${micapipe_img} \
	-bids /bids -out /out -fs_licence /opt/licence.txt -threads ${OMP_NUM_THREADS} -sub ${sub} -ses ${ses} \
    -proc_structural

# Clean up the temporary data at the end of the job.
rm -fr $job_tmp_dir

check_ComputeClusterSlurm_memory-usage

