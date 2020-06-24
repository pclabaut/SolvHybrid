#!/bin/bash

# Creates a minimization imput file, performs it and extract a pdb file from the last point of the minimization trajectory

echo $(tail -n 1 inpcrd | awk -F "  " '{print $2}')>> ../../Input/box_data.txt

echo """Minimize
  &cntrl
   imin=1,
   ntx=1,
   irest=0,
   maxcyc=2000,
   ncyc=1000,
   ntpr=100,
   ntwx=0,
   cut=8.0,
   ntc=2,
   ibelly=1,
   bellymask=':WAT'

 /
 """ > mdin

sander.MPI -O

cpptraj.MPI -p prmtop <<_EOF
trajin restrt

# Re-create a pdb file from the minimization's restart
outtraj equilibrated.pdb lastframe

_EOF

