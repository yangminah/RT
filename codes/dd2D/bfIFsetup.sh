#!/bin/bash
#SBATCH --job-name setupIF9
#SBATCH --qos=blanca-appm
#SBATCH --nodes 1
#SBATCH --ntasks 16
#SBATCH --time 00:10:00  
#SBATCH --mail-type=all
#SBATCH --mail-user=luya7574@colorado.edu

cd /projects/luya7574/RT/codes/dd2D/

module purge
module load matlab
matlab -nodesktop -nodisplay -r "dd2D_IFsetup;exit"
sbatch bfIF.sh




