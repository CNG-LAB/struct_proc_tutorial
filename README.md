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

### Now lets break down example command for running proc_structural on a SLURM: all the ingredients that we need are:


```
#!/bin/bash

#SBATCH -c 10
#SBATCH --mem 15G
#SBATCH --time 5:00:00
#SBATCH --job-name struct
#SBATCH --partition=standard
```

1. The first line requests 10 CPU cores for your job (-c10). It tells the cluster that your program should run using 10 parallel threads.
2. Next is the
Memory (-mem 15G). This requests 15 GB of RAM. SLURM will only place your job on a compute node that has at least this much free memory.
If your job uses more memory than you requested, it may be killed, so this value is important to set correctly.
3. Runtime Limit (-time 5:00:00). This sets the maximum allowed runtime for the job to 5 hours.
If the job exceeds this limit, the scheduler automatically cancels it.Useful for preventing jobs from running indefinitely.
4. Job Name (-job-name struct). This assigns a custom name to your job—for example, “struct”.
It helps you easily identify your job when checking the queue or your job history.
5. Partition (-partition=standard) This selects the cluster partition (queue) where the job should run.
Clusters usually offer partitions like “standard”, “high-memory”, “GPU”, etc. The partition controls priority, hardware type, and resource limits. The higher priority, the faster cluster starts the submitted job.





```
# cores
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
```
This export command ensures that your software uses the same number of threads as the CPU cores you requested.





```
# define tmp
job_tmp_dir=$TMPDIR/$SLURM_JOB_ID
mkdir $job_tmp_dir
```

The Temporary Working Directory and The SLURM. *(if you are not familiar with the SLURM you can find information on it int the helpbook document mention in the beginning of this file)*
The tmp line defines the temporary working directory on the compute node. This is required on SLURM because each compute node has its own local space. Using local scratch improves speed and prevents network storage overload




```
# params
sub=$1
ses=$2
```
Parameters define the **subject** and **session** labels in your BIDS dataset.



```
micapipe_img=/data/p_SoftwareServiceLinux_micapipe/0.2.3/singularity/
bids=/data/your/BIDS
out=/data/your/BIDS/derivatives
fs_lic=/data/your/resources/license.txt
```

micapipe_img = This is the Micapipe Singularity/Apptainer image, e.g.:
micapipe_v0.2.3.sif

​
*Why you need it:*
Contains all required software (FreeSurfer, FSL, ANTs, MRtrix3)
Guarantees reproducibility. Ensures the correct Micapipe version. How to get it:
Download from the official release page. Or build it locally using the Micapipe recipe. Potential error: If the image is missing or not correctly bound, the job will fail before structural processing begins.




```
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
logs_dir="/data/your/logs"

#run job
sub="0001"
ses="01"

sbatch --error "${logs_dir}/${sub}_${ses}".err \
    --output "${logs_dir}/${sub}_${ses}".out \
    /data/your/scripts/1_struct_micapipe_proc_struct.sh  "${sub}" "${ses}"
```

In order to run the script we have constructed above (you can see the script used for the Spacetop Dataset preprocessing: 1_struct_micapipe_proc_struct.sh in the repo) we can wrap it using the wrapper calling sript: (example: 1_struct_sbatch_wrapper.sh) What we do from now is that we send our wrapper script to a submission node.


### draft (writting it currently properly) :


## Submitting the Job on a SLURM Cluster
Now we have build the command line, and we are ready and excited to run it:
We run the command through a compute node on the SLURM-based cluster system.
To request a compute node, run:

```
getserver -sb
```

As soon as you run it, you will see something like:
<img width="797" height="512" alt="SUBMISSIONnode" src="https://github.com/user-attachments/assets/02b46d7f-7f05-4fd0-8607-734e492eb763" />


*Side Note: What getserver Does: hetserver contacts the SLURM scheduler and requests an available compute node.*

sb = submit + batch mode, meaning a job script is automatically prepared.
If you run only:
```
getserver
```
you will enter an interactive mode, where you can manually choose the cluster node, CPUs, and RAM.
Interactive mode is useful for testing commands.


<img width="796" height="65" alt="getserver" src="https://github.com/user-attachments/assets/0f3ac9ad-8c91-4181-9766-44f32b54f454" />



after you saw the available node you can choose and activate it by using the command: ssh and the putting the name of the node next to it. 
<img width="801" height="475" alt="postSSH" src="https://github.com/user-attachments/assets/ae9357cd-7387-443a-90c3-2d613ed64280" />



How to submit after being in the Submission node: 

```
/data/your/location/example_sbatch_wrapper_proc_struct.sh 
```
*note to adapt it according with your directory and script name*

<img width="765" height="44" alt="jobid" src="https://github.com/user-attachments/assets/61ad28bb-ef12-49bc-b675-8e1b36c6130f" />





### After submitting the job
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



Path to your raw BIDS dataset, e.g.:
bids=/path/to/BIDS

​
Must include:
sub-.../anat/sub-..._T1w.nii.gz

​
(check BIDS structure.)
out=
This defines where the derivatives will be written:
out=/path/to/derivatives

​
Micapipe will automatically create:
derivatives/micapipe/sub-.../

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
 Running the structural job
This is the main execution step inside the SLURM job script:
bash /data/your/location/example_proc_struct.sh 
​
Loads the module/environment, runs Micapipe with selected flags, Uses the compute node’s CPU/RAM, Writes final files to the derivatives folder. 
 Clean up
after the job finishes:Temporary directories in /tmp/
 are cleared. Only the derivatives output remains. Logs remain in SLURM submit directory.
Cluster memory note: 
If memory is too low: SLURM will kill the job, logs will show “Out of memory” errors.
Always request adequate memory in your SLURM header.
