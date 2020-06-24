#!/bin/sh
#
# use the python function getdvld to gather the mean energy over the step for each lambda and integrate it over the lambda to get the free Gibbs energy variation for each steps and for the sum of theses steps.
#

###################################
scale_f=$1   #In-plane cell scaling factor
###################################

basedir=$(pwd)
getdvdl=$basedir/Functions/getdvdl.py


cd TI_surface/TI_computation
result=0.0

for step in $(ls); do
  cd $step
  python $getdvdl 2000 equi_0.mden [01].* > dvdl.dat
  dG=$(tail -n 1 dvdl.dat | awk '{print $4}')
  echo "GAL17/${step}: ${dG}" >> ${basedir}/analyse.dat
  result=$(echo $dG + $result | bc)
  if [ $step = vdw_bonded ]; then
    res_vdw=$dG
  fi
  cd ..
done
cd $basedir

result_GAL=$result

cd TI_surface/TI_computation_LJ
result=0.0

for step in $(ls); do
  cd $step
  python $getdvdl 2000 equi_0.mden [01].* > dvdl.dat
  dG=$(tail -n 1 dvdl.dat | awk '{print $4}')
  echo "GAL17/$step: $dG" >> ${basedir}/analyse.dat
  result=$(echo $dG + $result | bc)
  cd ..
done
cd $basedir


result_f=$(echo "(${result_GAL} - ${result}/2 - ${res_vdw}/2)/(${scale_f}*${scale_f})" | bc -l)
echo '--------------------------------'
echo "Delta G solvation for thc complete submitted surface (unscaled) in kcal/mol = ${result_f}" >> analyse.dat


