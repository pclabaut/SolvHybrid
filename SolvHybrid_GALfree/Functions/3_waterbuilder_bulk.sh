#!/bin/sh
#
# a -Solvate and extract a pdb file from the lone molecule.
#

mkdir Molecule_files/water_equilibrium_calculation

tleap -f - <<_EOF
# Load the necessary AMBER force fields 
loadoff tip3pbox.off
source leaprc.gaff2
source Lib/leaprc.uff
loadoff tip3pbox.off

# Load the coordinates of the molecule alone and the surfaces and re-adsorbe the molecule on the departure one
molecule = loadpdb $1

# Save the non-solvated situations to compute gas phase simulations
saveamberparm molecule Molecule_files/gas_phase_SP/uncharged_prmtop Molecule_files/gas_phase_SP/inpcrd

# Solvate ithe molecule extract pdb files for checking purpose
solvatebox molecule TIP3PBOX $2
savepdb molecule Molecule_files/solvated_mol.pdb

#Give box informations to amber and prepare amber files
setbox molecule vdw
saveamberparm molecule Molecule_files/water_equilibrium_calculation/uncharged_prmtop Molecule_files/water_equilibrium_calculation/inpcrd

quit
_EOF

#Copy the box information for the gas phase single point
tail -1  Molecule_files/water_equilibrium_calculation/inpcrd >> Molecule_files/gas_phase_SP/inpcrd

