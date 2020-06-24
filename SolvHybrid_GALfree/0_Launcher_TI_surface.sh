#!/bin/bash

scalefactor=3

module purge
source /home/pclabaut/bin/amber.sh
#export AMBERHOME="/home/pclabaut/bin/AMBER17/amber"
export AMBERHOME="/home/ssteinma/softs/AMBER16/amber"
export PATH="${AMBERHOME}/bin:${PATH}"
export PATH="/home/pclabaut/bin/cm5pac_v2015:${PATH}"

mkdir -p Adsorbate_files > /dev/null #Directory for initial state
mkdir -p Adsorbate_files/gas_phase_SP > /dev/null 
mkdir -p Surface_files > /dev/null #Directory for final state
mkdir -p Surface_files/gas_phase_SP > /dev/null
rm -f leap.log

echo '1 - Extending the cell and converting CONTCAR files to pdb...'
#Scale the initial cell in x and y direction to obtain a larger box size and convert in pdb format
cd Input 
python ../Functions/1_cell_widening.py CONTCAR_ads $scalefactor #Adsorbate@Surface
python ../Functions/2_converter_V2.py extendedCONTCAR_ads
mv extendedCONTCAR_ads* ../Adsorbate_files/
python ../Functions/1_cell_widening.py CONTCAR_surf $scalefactor #Pristine Surface
python ../Functions/2_converter_V2.py extendedCONTCAR_surf 
mv extendedCONTCAR_surf* ../Surface_files/
cd ..

echo '2 - Building a water box at the shape of the cell around the adsorbate...'
#The last argument is the water box height. Here, build the box and recut-it to slab shape.
./Functions/3_waterbuilder.sh Adsorbate_files/extendedCONTCAR_ads.pdb Surface_files/extendedCONTCAR_surf.pdb 30.0 > /dev/null

echo '3 - Adding the scaled Hirshfeld charges in the amber files...'
./Functions/4_charges_includer.sh $scalefactor > /dev/null

echo '4 - Minimizing the energy of the water box around the frozen adsorbated molecule and extract a copy of the equilibrated water box...'
# Short equilibration of the water box around the frozen ads@surf and copying the water box only to put it later on top of the pristine surface
cd Adsorbate_files/water_equilibrium_calculation/
../../Functions/5_minimizer.sh > /dev/null
python ../../Functions/6_strip.py equilibrated.pdb
cd ../../Surface_files/
python ../Functions/6_recenter.py rotated_extendedCONTCAR_surf.pdb ../Adsorbate_files/water_equilibrium_calculation/equilibrated.pdb
cd ..

echo '5 - Sticking the previous water box on top of the pristine surface, so that the initial and final state of the alchemical transformation share the same water box...'
./Functions/7_rebuild.sh $scalefactor > /dev/null

export AMBERHOME="/home/pclabaut/bin/AMBER17/amber"
export PATH="${AMBERHOME}/bin:${PATH}"


echo '6 - Prepare and launch all TIs...'
for i in decharge vdw_bonded recharge SP_adsorbate SP_surface; do ./Functions/8_heated_TI.sh $i $scalefactor; done


#To check the calculations during the run
#./Functions/9_Heated_TI_surveilliance.sh TI_surface

#In the end, to gather results
#./Functions/10_analyse.sh TI_surface $scalefactor

#Results will be in analyse.dat
