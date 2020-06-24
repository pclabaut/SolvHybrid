#!/bin/sh
#
# a - Use the solvent box from the lone molecule to create the arrival situation of the alchemical transformation of de-solvating a lone molecule. Then recombine the solvent box from the adsorbed molecule situation with the nude arrival surface to create the arrival situation of the alchemical transformation of de-solvating an adsorbated molecule. Finally, extract the amber files for all the departure and arrival situations
#

mkdir TI_bulk
mkdir TI_bulk/base_files #Here we will put the amber files for the TI

tleap -f - <<_EOF
# Load the necessary AMBER force fields 
loadoff tip3pbox.off
source leaprc.gaff2
source Lib/leaprc.uff
loadoff tip3pbox.off

# Create all the relevant leap object from the pdb files
solvent = loadpdb Molecule_files/water_equilibrium_calculation/equilibrated_box.pdb
mol = loadpdb Molecule_files/water_equilibrium_calculation/equilibrated.pdb

# Re-create the box lost in pdb translation and save the incprd and prmtop files in the appropriate folders
setbox solvent vdw  
saveamberparm solvent TI_bulk/base_files/prmtop1  TI_bulk/base_files/inpcrd1 

setbox mol vdw  
saveamberparm mol TI_bulk/base_files/uncharged_prmtop0  TI_bulk/base_files/inpcrd0

quit
_EOF

#Put the right charges
python ./Functions/aux_charge_include.py TI_bulk/base_files/uncharged_prmtop0 Input/charges_info/CONTCAR_mol_cm5output 1
#Proper renaming
mv TI_bulk/base_files/uncharged_prmtop0_charged TI_bulk/base_files/prmtop0

