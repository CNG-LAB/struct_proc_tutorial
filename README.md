# Welcome to the proc_structural tutorial
### Structural processing tutorial - from pre-processing to plotting

In this repository we will go over how to run preprocesing for structural MRI data using **Micapipe**. This tutorial is designed to direct ypu to the infromation you need in order to understand and run your preprocessing pipeline. 

### Micapipe is a full neuroimaging pipeline from the MICA-lab that automatically preprocesses structural, functional, and diffusion MRI to generate high-quality, standardized connectomes. 
*Full documentation is available here:* 🔗 https://micapipe.readthedocs.io


 ### *Beginner Helpbook: covering basics behind the preprocessing. https://docs.google.com/document/d/124vj8qcqMOPo08Vdr2WBnE_DB4Gj52aAv_VVVzE9dLE/edit?usp=sharing*
 in this file you will find fundamentals in order to absorb the information on running the proc_structural better. 

## Structural Processing with Micapipe begins!
*Micapipe’s structural pipeline provides a comprehensive and standardized framework for transforming raw T1-weighted MRI data into high-quality cortical surfaces, anatomical segmentations, and morphometric features. This processing stream integrates established neuroimaging tools with optimized workflows to ensure reproducibility and reliability across participants and studies.*

This section explains how to run the **proc_structural workflow**, how the SLURM submission works, how to interpret each part of the script, and where to find your outputs.
You can find the command for running proc_structural below: 
```
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

```



This is a wrapper that will call the command line above: 
```
#!/bin/bash

# create directory to save log files
logs_dir="/data/p_03140/logs"

#run job
sub="0001"
ses="01"

sbatch --error "${logs_dir}/${sub}_${ses}".err \
    --output "${logs_dir}/${sub}_${ses}".out \
    /data/p_03140/scripts/1_struct_micapipe_proc_struct.sh  "${sub}" "${ses}"
```

Now lets pay attention at each line of command and what it stands for: 

### draft (writting it currently properly) :
mention how does memory work on the cluster. 

The Temporary Working Directory and The SLURM. *(if you are not familiar with the SLURM you can find information on it int the helpbook document mention in the beginning of this file)*

The *tmp* line defines the temporary working directory on the compute node. This is required on SLURM because each compute node has its own local space. Using local scratch improves speed and prevents network storage overload.
(screenshot )
Submitting the Job on a SLURM Cluster
We now run the command through a compute node on the SLURM-based cluster system.
To request a compute node, run:
getserver -sb 
As soon as you run it, you will see something like:
( screenshot )
Side Note: What getserver Does: hetserver contacts the SLURM scheduler and requests an available compute node.
sb = submit + batch mode, meaning a job script is automatically prepared.
If you run only:
getserver 
you will enter an interactive mode, where you can manually choose the cluster node, CPUs, and RAM.
Interactive mode is useful for testing commands.
( screenshot)
after you saw the available node you can choose and activate it by using the command: ssh and the putting the name of the node next to it. 
screenshot 
After Submitting the Job
Once submitted, SLURM gives you a job ID.
Useful commands:

```
squeue -u $USER       
squeue -j JOBID       
scancel JOBID         
```
​


What each means:
Job ID – a unique identifier for the submitted job
squeue – displays job status (pending, running, failed, completed)
scancel – ends the job if needed
When SLURM starts the job, your script will typically create a temporary directory:



mkdir /tmp/jobID/


This is where intermediate files are stored during processing. Temporary files are removed automatically at the end unless you choose to keep them.
 Explanation of Parameters
sub
 and ses
These define the subject and session labels in your BIDS dataset.
Example format:
sub-001
ses-01

​
micapipe_img
This is the Micapipe Singularity/Apptainer image, e.g.:
micapipe_v0.2.3.sif

​
Why you need it:
Contains all required software (FreeSurfer, FSL, ANTs, MRtrix3)
Guarantees reproducibility
Ensures the correct Micapipe version
How to get it:
Download from the official release page
Or build it locally using the Micapipe recipe
potential error: If the image is missing or not correctly bound, the job will fail before structural processing begins.
bids=
Path to your raw BIDS dataset, e.g.:
bids=/path/to/BIDS

​
Must include:
sub-XXX/anat/sub-XXX_T1w.nii.gz

​
(check BIDS structure.)
out=
This defines where the derivatives will be written:
out=/path/to/derivatives

​
Micapipe will automatically create:
derivatives/micapipe/sub-XXX/

​
Output in Derivatives
Recall from your out=
 line:
Micapipe writes all results into the folder defined there.
(derivatives screenshots)
Handling Errors
If the processing fails:
Check SLURM .err
 and .out
 logs
cat is the command to see the how the processing run: 
screenshot 
Confirm micapipe .sif
 image exists
Confirm FreeSurfer license is mounted
Check BIDS format integrity
(screenshot )
Calling Commands in the Terminal
To navigate your BIDS dataset:
ls sub-*/anat/
tree sub-001

​
 Running the Structural Job
This is the main execution step inside the SLURM job script:
bash 
​
Loads the module/environment, Runs Micapipe with selected flags, Uses the compute node’s CPU/RAM, Writes final files to the derivatives folder. 
 Clean Up
After the job finishes:Temporary directories in /tmp/
 are cleared. Only the derivatives output remains. Logs remain in SLURM submit directory.
Cluster Memory Considerations: 
If memory is too low: SLURM will kill the job, logs will show “Out of memory” errors
Always request adequate memory in your SLURM header.
