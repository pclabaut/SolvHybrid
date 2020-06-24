#!/bin/sh
#
# a - Use the solvent box from the lone molecule to create the arrival situation of the alchemical transformation of de-solvating a lone molecule. Then recombine the solvent box from the adsorbed molecule situation with the nude arrival surface to create the arrival situation of the alchemical transformation of de-solvating an adsorbated molecule. Finally, extract the amber files for all the departure and arrival situations
#

#Retrieve previously stored box informations and scalling factor
scalefactor=$1
angle=$(cat Input/box_data.txt | awk -F "', '" '{if(NR==1){print $3}}' | sed "s#')##g" | sed "s#('##g")
maxx=$(cat Input/box_data.txt | awk -F "', '" '{if(NR==1){print $1}}' | sed "s#')##g" | sed "s#('##g")
maxy=$(cat Input/box_data.txt | awk -F "', '" '{if(NR==1){print $2}}' | sed "s#')##g" | sed "s#('##g")
maxz=$(cat Input/box_data.txt | awk -F "', '" '{if(NR==2){print $0}}')

mkdir trash
mkdir TI_surface
mkdir TI_surface/base_files #Here we will store the amber files with GAL17 LJ values
mkdir TI_surface/base_files_soft #And here with sGAL17 LJ values

tleap -f - <<_EOF
# Load the necessary AMBER force fields 
loadoff tip3pbox.off
source leaprc.gaff2
source Lib/leaprc.uff
loadoff tip3pbox.off

# Create all the relevant leap object from the pdb files
solvant = loadpdb Adsorbate_files/water_equilibrium_calculation/equilibrated_box.pdb
surface = loadpdb Surface_files/centered_surface.pdb
# Combine the pristine surface with the water box of ads@surf to have exactly the same water molecule position in the starting and final step of the alchemical transformation
surfsolv = combine {surface solvant}
molsurfsol = loadpdb Adsorbate_files/water_equilibrium_calculation/equilibrated.pdb

# Re-create the box lost in pdb translation and save the incprd and prmtop files in the appropriate folders
#Need to save the coordinate before amber build the box information or it will randomly translate everything in the box and then unaligned the pristine surface and the ads@surf

saveamberparm surfsolv trash/4 TI_surface/base_files/inpcrd1  
setbox surfsolv vdw  #But still need to do this command to have the information of having a box in the prmtop
saveamberparm surfsolv TI_surface/base_files/uncharged_prmtop1 trash/5  

saveamberparm molsurfsol trash/6 TI_surface/base_files/inpcrd0
setbox molsurfsol vdw
saveamberparm molsurfsol TI_surface/base_files/uncharged_prmtop0 trash/7

quit
_EOF

#Exact same thing for sGAL17
tleap -f - <<_EOF
# Load the necessary AMBER force fields 
loadoff tip3pbox.off
source leaprc.gaff2
source Lib/leaprc_soft.uff
loadoff tip3pbox.off

# create all the relevant leap object from the pdb files
solvant = loadpdb Adsorbate_files/water_equilibrium_calculation/equilibrated_box.pdb
#surface = loadpdb Surface_files/water_equilibrium_calculation/centered_surface.pdb
surface = loadpdb Surface_files/centered_surface.pdb
# Combine the pristine surface with the water box of ads@surf to have exactly the same water molecule position in the starting and final step of the alchemical transformation
surfsolv = combine {surface solvant}
molsurfsol = loadpdb Adsorbate_files/water_equilibrium_calculation/equilibrated.pdb


#re-create the box lost in pdb translation and save the incprd and prmtop files in the appropriate folders
setbox surfsolv vdw
saveamberparm surfsolv TI_surface/base_files_soft/uncharged_prmtop1 trash/5

setbox molsurfsol vdw
saveamberparm molsurfsol TI_surface/base_files_soft/uncharged_prmtop0 trash/7

quit
_EOF

#Put the true box information in the inpcrd files
echo '  '$maxz'  '$maxx ' '$maxy'  '$angle'  90.0000000  90.0000000' >> TI_surface/base_files/inpcrd1
echo '  '$maxz'  '$maxx ' '$maxy'  '$angle'  90.0000000  90.0000000' >> TI_surface/base_files/inpcrd0
#Also for the gas phase calculations
echo '  '$maxx'  '$maxy ' '$maxz'  90.0000000  90.0000000  '$angle >> Adsorbate_files/gas_phase_SP/inpcrd
echo '  '$maxx'  '$maxy ' '$maxz'  90.0000000  90.0000000  '$angle >> Surface_files/gas_phase_SP/inpcrd

#And the right charges
python ./Functions/aux_charge_include.py TI_surface/base_files/uncharged_prmtop0 Input/charges_info/CONTCAR_ads_cm5output $scalefactor
python ./Functions/aux_charge_include.py TI_surface/base_files/uncharged_prmtop1 Input/charges_info/CONTCAR_surf_cm5output $scalefactor
#Proper renaming
mv TI_surface/base_files/uncharged_prmtop0_charged TI_surface/base_files/prmtop0
mv TI_surface/base_files/uncharged_prmtop1_charged TI_surface/base_files/prmtop1
#For the soft ones 
python ./Functions/aux_charge_include.py TI_surface/base_files_soft/uncharged_prmtop0 Input/charges_info/CONTCAR_ads_cm5output $scalefactor
python ./Functions/aux_charge_include.py TI_surface/base_files_soft/uncharged_prmtop1 Input/charges_info/CONTCAR_surf_cm5output $scalefactor
#Rename and place
mv TI_surface/base_files_soft/uncharged_prmtop0_charged TI_surface/base_files_soft/prmtop0
mv TI_surface/base_files_soft/uncharged_prmtop1_charged TI_surface/base_files_soft/prmtop1

cp TI_surface/base_files/inpcrd0 TI_surface/base_files_soft/
cp TI_surface/base_files/inpcrd1 TI_surface/base_files_soft/

rm -rf trash

