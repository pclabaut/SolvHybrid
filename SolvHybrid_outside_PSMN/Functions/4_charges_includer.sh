#!/bin/bash

# Modify the charges information in the prmtop of each situation using the charges information obtained with VASP and presents in the OUTCAR files 
#


cd Input
mkdir charges_info

for file in ads surf; do
  # Extract the Hirshfeld charges from the OUTCARs and shape it for cm5
  python ../Functions/aux_charge_converter.py CONTCAR_${file} OUTCAR_${file}
  mv CONTCAR_${file}_cm5input charges_info/
  # Uses cm5 to recalculate the charges with cm5 algorhytme
  cm5pac.exe 3 < charges_info/CONTCAR_${file}_cm5input> charges_info/CONTCAR_${file}_cm5output 
done
cd ..

# Adapt and include the newly calculated charges in the prmtop files
python ./Functions/aux_charge_include.py Adsorbate_files/water_equilibrium_calculation/uncharged_prmtop Input/charges_info/CONTCAR_ads_cm5output $1
mv Adsorbate_files/water_equilibrium_calculation/uncharged_prmtop_charged Adsorbate_files/water_equilibrium_calculation/prmtop
python ./Functions/aux_charge_include.py Adsorbate_files/gas_phase_SP/uncharged_prmtop Input/charges_info/CONTCAR_ads_cm5output $1
mv Adsorbate_files/gas_phase_SP/uncharged_prmtop_charged Adsorbate_files/gas_phase_SP/prmtop
python ./Functions/aux_charge_include.py Surface_files/gas_phase_SP/uncharged_prmtop Input/charges_info/CONTCAR_surf_cm5output $1
mv Surface_files/gas_phase_SP/uncharged_prmtop_charged Surface_files/gas_phase_SP/prmtop

