#!/bin/bash

mkdir -p Molecule_files > /dev/null #Directory for initial state
mkdir -p Molecule_files/gas_phase_SP > /dev/null 
rm -f leap.log

echo '1 - Extending the cell and converting CONTCAR files to pdb...'
#Convert in pdf format
cd Input 
python ../Functions/2_converter_V2.py CONTCAR_mol
cp CONTCAR_mol ../Molecule_files/
mv CONTCAR_mol.pdb ../Molecule_files/
cd ..

echo '2 - Building a water box around the molecule...'
#The last argument is the water box size in each direction.
./Functions/3_waterbuilder_bulk.sh Molecule_files/CONTCAR_mol.pdb 15.0 > /dev/null

echo '3 - Adding the charges calculated by VASP in the amber files...'
./Functions/4_charges_includer_bulk.sh 1 > /dev/null

echo '4 - Minimizing the energy of the water box around the molecule and extract a copy of the equilibrated water box...'
# Short equilibration of the water box around the frozen ads@surf and copying the water box only to put it later on top of the pristine surface
cd Molecule_files/water_equilibrium_calculation/
../../Functions/5_minimizer.sh > /dev/null
python ../../Functions/6_strip.py equilibrated.pdb
cd ../..

echo '5 - Establishing the previous water as the final state of the alchemical transformation...'
./Functions/7_rebuild.sh $scalefactor > /dev/null

echo '6 - Prepare and launch all TIs...'
for i in decharge vdw_bonded SP_mol; do ./Functions/8_heated_TI_bulk.sh $i ; done


#To check the calculations during the run
#./Functions/9_Heated_TI_surveilliance.sh TI_bulk

#In the end, to gather results
#./Functions/10_analyse.sh TI_bulk 1

#Results will be in analyse.dat
