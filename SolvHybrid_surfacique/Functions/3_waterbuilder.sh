#!/bin/sh
#
# a -Solvate and extract a pdb file from the pristine surface with nothing on it.
#

tleap -f - <<_EOF
# Load the necessary AMBER force fields 
loadoff tip3pbox.off
source leaprc.gaff2
source Lib/leaprc.uff
loadoff tip3pbox.off

# Load the coordinates of the molecule alone and the surfaces and re-adsorbe the molecule on the departure one
surface = loadpdb $1

# Save the non-solvated situations to compute gas phase simulations
saveamberparm surface Surface_files/gas_phase_SP/uncharged_prmtop Surface_files/gas_phase_SP/inpcrd

# Solvate separately all the situations and extract pdb files
solvatebox surface TIP3PBOX $2

# Save the solvated situations for the TI
savepdb surface Surface_files/solvated_surface.pdb

quit
_EOF


# NB: AMBER cannot create orthorombic water box, hence the trick.
# b -Reshape the water box at the same shape as the original surface cell in order to keep its periodicity and using the matrix information presents in the CONTCAR file. Then exchange the x and z axis in order to avoid slices along the z axis that could be totally frozen
# Also extract box informations 
#


cd Surface_files
boxdata_surf=$(python ../Functions/aux_water_cuter.py solvated_surface.pdb extendedCONTCAR_surf)
echo $boxdata_surf > ../Input/box_data.txt
python ../Functions/aux_rotator.py hex_solvated_surface.pdb
mkdir water_equilibrium_calculation
cd ..

#
# c -Re-load all the modified files in order to get amber-type files corresponding to the modified water box.
#

tleap -f - <<_EOF
# Load the necessary AMBER force fields 
loadoff tip3pbox.off
source leaprc.gaff2
source Lib/leaprc.uff
loadoff tip3pbox.off

# Load the the situations modified files 
surface = loadpdb Surface_files/rotated_hex_solvated_surface.pdb

# Creates the boxes and extract amber-type files necessary to perform a first minimization of the water box
setbox surface vdw
saveamberparm surface Surface_files/water_equilibrium_calculation/uncharged_prmtop Surface_files/water_equilibrium_calculation/inpcrd

quit
_EOF



