#!/bin/sh
#
# use the python function getdvld to gather the mean energy over the step for each lambda and integrate it over the lambda to get the free Gibbs energy variation for each steps and for the sum of theses steps.
#

###################################
system=$1
scale_f=$2   #In-plane cell scaling factor
###################################

basedir=$(pwd)
getdvdl=$basedir/Functions/getdvdl.py


cd $system/TI_computation
result=0.0

for step in $(ls); do
  cd $step
  python $getdvdl 2000 equi_0.mden [01].* > dvdl.dat
  dG=$(tail -n 1 dvdl.dat | awk '{print $4}')
  echo "${system}/${step}: ${dG}" >> ${basedir}/analyse.dat
  result=$(echo $dG + $result | bc)
  cd ..
done
cd $basedir


res_1_Molecule=$(echo "${result}/(${scale_f}*${scale_f})" | bc -l)
echo '--------------------------------'
echo "Delta G TI in $system for one molecule in kcal/mol = ${res_1_Molecule}" >> analyse.dat


