#!/bin/bash

#Usefull tool to monitore progression of the computations

system=$1

cd ${system}/TI_computation 
for step in $(ls); do
  cd $step;
  for window in $(ls | grep "0\."); do
   if [ -f ${window}/min_0.mdin ]; then
    if [ -f ${window}/min_0.mdinfo ]; then
      if [ -f ${window}/heat_0.mdinfo ]; then
        if [ -f ${window}/equi_0.mdinfo ]; then
          echo $step "/" $window ": in equi, " $(grep "Estimated time remaining" ${window}/equi_0.mdinfo)
        else
          echo $step "/" $window ": in heat, " $(grep "Estimated time remaining" ${window}/heat_0.mdinfo)
        fi
      else 
        echo $step "/" $window ": in min, " $(grep "Estimated time remaining" ${window}/min_0.mdinfo)
      fi
    else 
      echo $step "/" $window " not started"
    fi
   else 
    echo $step "/" $window " over !" 
    cat ${window}/AmberRod.e*
   fi
  done
  cd ..
done
cd ../../

