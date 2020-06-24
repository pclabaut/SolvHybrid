#!/bin/bash

scalefactor=3

module purge
source /home/pclabaut/bin/amber.sh
#export AMBERHOME="/home/pclabaut/bin/AMBER17/amber"
export AMBERHOME="/home/ssteinma/softs/AMBER16/amber"
export PATH="${AMBERHOME}/bin:${PATH}"
export PATH="/home/pclabaut/bin/cm5pac_v2015:${PATH}"

mkdir -p Surface_files > /dev/null #Directory for final state
rm -f leap.log

echo '1 - Extending the cell and converting CONTCAR files to pdb...'
#Scale the initial cell in x and y direction to obtain a larger box size and convert in pdb format
cd Input 
python ../Functions/1_cell_widening.py CONTCAR_surf $scalefactor #Pristine Surface
python ../Functions/2_converter_V2.py extendedCONTCAR_surf 
mv extendedCONTCAR_surf* ../Surface_files/
cd ..

echo '2 - Building a water box at the shape of the cell...'
#The last argument is the water box height. Here, build the box and recut-it to slab shape.
./Functions/3_waterbuilder.sh Surface_files/extendedCONTCAR_surf.pdb 30.0 > /dev/null

echo '3 - Adding the charges calculated by VASP in the amber files...'
./Functions/4_charges_includer.sh $scalefactor > /dev/null

echo '4 - Minimizing the energy of the water box on the surface and extract it...'
# Short equilibration of the water box around the frozen ads@surf and copying the water box only to put it later on top of the pristine surface
cd Surface_files/water_equilibrium_calculation/
../../Functions/5_minimizer.sh > /dev/null
python ../../Functions/6_strip.py equilibrated.pdb
cd ../..

echo '5 - Establishing the previous water box as the final state of the alchemical transformation...'
./Functions/7_rebuild.sh $scalefactor > /dev/null

export AMBERHOME="/home/pclabaut/bin/AMBER17/amber"
export PATH="${AMBERHOME}/bin:${PATH}"


echo '6 - Prepare and launch all TIs...'
for i in decharge GALsoft sGALtoLJ vdw_bonded; do ./Functions/8_heated_TI.sh $i $scalefactor; done

for i in decharge LJsoft; do ./Functions/8_heated_TI_LJ.sh $i $scalefactor; done

#To check the calculations during the run
#./Functions/9_Heated_TI_surveilliance.sh TI_surface

#In the end, to gather results
#./Functions/10_analyse.sh $scalefactor

#Results will be in analyse.dat
