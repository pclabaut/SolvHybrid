#!/bin/bash
#$ -S /bin/bash
#$ -N AmberRod
#$ -q  E5*,SSD*,CL*
#####$ -q  x5650lin24ibA,x5650lin24ibB,x5650lin24ibC
#$ -pe mpi8_debian 8
#$ -V
#$ -cwd

module purge
source  /home/pclabaut/bin/amber.sh


