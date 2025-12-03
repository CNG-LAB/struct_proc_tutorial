# Welcome to the proc_structural tutorial
### Structural processing tutorial - from pre-processing to plotting

In this repository we will go over how to run preprocesing for structural MRI data using **Micapipe**. 
### Micapipe is a full neuroimaging pipeline from the MICA-lab that automatically preprocesses structural, functional, and diffusion MRI to generate high-quality, standardized connectomes. 
*Full documentation is available here:* 🔗 https://micapipe.readthedocs.io


The tutorials here are designed to direct ypu to the infromation you need in order to understand and run your preprocessing pipeline. We will go throught how to:
* Build your own proc_struct command line
* How to work with supermachine clusters
* Cortical thickness analysis and plotting 

 ### *Beginner Helpbook: covering basics behind the preprocessing. https://docs.google.com/document/d/124vj8qcqMOPo08Vdr2WBnE_DB4Gj52aAv_VVVzE9dLE/edit?usp=sharing*
 in this file you will find fundamentals in order to absorb the information on running the proc_structural better. 











### draft (writting it currently properly will move it ot the notebook to be found in the step by step folder) :


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
