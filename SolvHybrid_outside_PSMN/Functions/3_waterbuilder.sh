#!/bin/sh
#
# a -Solvate and extract a pdb file from the adsorbed molecule and the pristine surface with nothing on it.
#

tleap -f - <<_EOF
# Load the necessary AMBER force fields 
loadoff tip3pbox.off
source leaprc.gaff2
source Lib/leaprc.uff
loadoff tip3pbox.off

# Load the coordinates of the molecule alone and the surfaces and re-adsorbe the molecule on the departure one
adsorba = loadpdb $1
surface = loadpdb $2

# Save the non-solvated situations to compute gas phase simulations
saveamberparm adsorba Adsorbate_files/gas_phase_SP/uncharged_prmtop Adsorbate_files/gas_phase_SP/inpcrd
saveamberparm surface Surface_files/gas_phase_SP/uncharged_prmtop Surface_files/gas_phase_SP/inpcrd

# Solvate the adsorbate and extract pdb files
solvatebox adsorba TIP3PBOX $3
savepdb adsorba Adsorbate_files/solvated_adsorba.pdb

quit
_EOF


# NB: AMBER cannot create orthorombic water box, hence the trick.
# b -Reshape the water box at the same shape as the original surface cell in order to keep its periodicity and using the matrix information presents in the CONTCAR file. Then exchange the x and z axis in order to avoid slices along the z axis that could be totally frozen
# Also extract box informations 
#

cd Adsorbate_files
boxdata_surf=$(python ../Functions/aux_water_cuter.py solvated_adsorba.pdb extendedCONTCAR_ads)
echo $boxdata_surf > ../Input/box_data.txt
python ../Functions/aux_rotator.py hex_solvated_adsorba.pdb
mkdir water_equilibrium_calculation
cd ../Surface_files  
python ../Functions/aux_rotator.py extendedCONTCAR_surf.pdb 
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

# Load the properly solvated adsorbate 
adsorba = loadpdb Adsorbate_files/rotated_hex_solvated_adsorba.pdb

# Creates the boxes and extract amber-type files necessary to perform a first minimization of the water box
setbox adsorba vdw
saveamberparm adsorba Adsorbate_files/water_equilibrium_calculation/uncharged_prmtop Adsorbate_files/water_equilibrium_calculation/inpcrd

quit
_EOF



