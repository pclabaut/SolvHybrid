#!/bin/bash

#All-out purpose tool to create and submit thermodynamics integration calculations

basedir=$(pwd)
step=$1
scalefactor=$2

#Gas phase single points
if [ $step = SP_adsorbate ]; then
	cp Lib/SP.tmpl Adsorbate_files/gas_phase_SP/mdin
	cd Adsorbate_files/gas_phase_SP
	sander.MPI -O 
        echo "SP for adsorba in gas phase" $(grep "EPtot      =" mdout | head -1 | awk -v sf=$scalefactor 'NR==1{print $3/(sf*sf)}') >> ../../analyse.dat
	cd -
        exit
fi 
if [ $step = SP_surface ]; then
	cp Lib/SP.tmpl Surface_files/gas_phase_SP/mdin
	cd Surface_files/gas_phase_SP
	sander.MPI -O 
        echo "SP for surface in gas phase" $(grep "EPtot      =" mdout | head -1 | awk -v sf=$scalefactor 'NR==1{print $3/(sf*sf)}') >> ../../analyse.dat
	cd -
        exit
fi 

#Options of the mdin input file
decharge0=" ifsc = 0,"
decharge1=" ifsc = 0, crgmask = '!:WAT',"
GALsoft0=" ifsc = 0, crgmask = '!:WAT',"
GALsoft1=" ifsc = 0, crgmask = '!:WAT',"
vdw_bonded0=" ifsc=1, scmask='!:WAT', crgmask='!:WAT'"
vdw_bonded1=" ifsc=1, scmask='!:WAT', crgmask='!:WAT'"
GALunsoft0=" ifsc = 0, crgmask = '!:WAT',"
GALunsoft1=" ifsc = 0, crgmask = '!:WAT',"
recharge0=" ifsc = 0, crgmask = '!:WAT',"
recharge1=" ifsc = 0,"

cd TI_surface
mkdir TI_computation 2>/dev/null
cd TI_computation

step=$1
mkdir $step
cd $step

#0 for initial state, 1 for final
FE0=$(eval "echo \${${step}0}")
FE1=$(eval "echo \${${step}1}")

#Where it must find the files for prmtop, inpcrd and mdin depending on the step of the computation, plus define the windows spacing
ext0=""
ext1=""
if [ $step = decharge ]; then 
  windows=$(echo "0.005" $(seq 0.1 0.1 0.9) "0.995")
  cp ${basedir}/TI_surface/base_files/prmtop0 .
  cp ${basedir}/TI_surface/base_files/inpcrd0 .
  cp ${basedir}/TI_surface/base_files/prmtop0 ./prmtop1
  cp ${basedir}/TI_surface/base_files/inpcrd0 ./inpcrd1
fi
if [ $step = GALsoft ]; then 
  windows=$(python3 -c "import numpy as np; print(('{:05.3f} '*11).format(*(1-np.logspace(np.log2(0.995),np.log2(0.005),11,base=2))))")
  ext1="_sGAL"
  cp ${basedir}/TI_surface/base_files/prmtop0 .
  cp ${basedir}/TI_surface/base_files/inpcrd0 .
  cp ${basedir}/TI_surface/base_files_soft/prmtop0 ./prmtop1
  cp ${basedir}/TI_surface/base_files_soft/inpcrd0 ./inpcrd1
fi
if [ $step = vdw_bonded ]; then 
  windows=$(echo "0.005" $(seq 0.1 0.1 0.9) "0.995")
  ext0="_sGAL"
  ext1="_sGAL"
  cp ${basedir}/TI_surface/base_files_soft/prmtop0 .
  cp ${basedir}/TI_surface/base_files_soft/inpcrd0 .
  cp ${basedir}/TI_surface/base_files_soft/prmtop1 .
  cp ${basedir}/TI_surface/base_files_soft/inpcrd1 .
fi
if [ $step = GALunsoft ]; then 
  windows=$(python3 -c "import numpy as np; print(('{:05.3f} '*11).format(*np.logspace(np.log2(0.005),np.log2(0.995),11,base=2)))")
  ext0="_sGAL"
  cp ${basedir}/TI_surface/base_files/prmtop1 .
  cp ${basedir}/TI_surface/base_files/inpcrd1 .
  cp ${basedir}/TI_surface/base_files_soft/prmtop1 ./prmtop0
  cp ${basedir}/TI_surface/base_files_soft/inpcrd1 ./inpcrd0
fi
if [ $step = recharge ]; then 
  windows=$(echo "0.005" $(seq 0.1 0.1 0.9) "0.995")
  cp ${basedir}/TI_surface/base_files/prmtop1 .
  cp ${basedir}/TI_surface/base_files/inpcrd1 .
  cp ${basedir}/TI_surface/base_files/prmtop1 ./prmtop0
  cp ${basedir}/TI_surface/base_files/inpcrd1 ./inpcrd0
fi


for w in $windows; do
  mkdir $w
  cd $w

  for sub_step in min heat equi ; do
   for nb in 0 1 ; do
    sed -e "s/%L%/$w/" -e "s/%FE%/$(eval "echo \${FE${nb}}")/" $basedir/Lib/${sub_step}$(eval "echo \${ext${nb}}").tmpl > ${sub_step}_${nb}.mdin #Assembling the mdin file
   done
  done

  cp ../prmtop0 .
  cp ../prmtop1 .
  cp $basedir/Lib/ambersub.j .

  #Here we complete the submission script template and submit it
  echo '  
  for i in min heat equi ;do
    mkdir ${i}
    if [ $i = min ]; then
       cp ../inpcrd0 ${i}_input_0
       cp ../inpcrd1 ${i}_input_1
       COEUR=2
    fi
  
    if [ $i = heat ]; then
       cp min_0.restrt ${i}_input_0
       cp min_1.restrt ${i}_input_1
       COEUR=4
    fi
  
    if [ $i = equi ]; then
       cp heat_0.restrt ${i}_input_0
       cp heat_1.restrt ${i}_input_1
       COEUR=8
  
    fi
  
    echo """
   -i ${i}_0.mdin -p prmtop0 -c ${i}_input_0 -ref ../inpcrd0 -inf ${i}_0.mdinfo -o ${i}_0.mdout -r ${i}_0.restrt -e ${i}_0.mden -x ${i}_0.mdcrd
   -i ${i}_1.mdin -p prmtop1 -c ${i}_input_1 -ref ../inpcrd1 -inf ${i}_1.mdinfo -o ${i}_1.mdout -r ${i}_1.restrt -e ${i}_1.mden -x ${i}_1.mdcrd
" > ${i}.group

    mpirun -np $COEUR $AMBERHOME/bin/sander.MPI -ng 2 -groupfile ${i}.group
  
  done
  for i in min heat equi ;do
    mv ${i}* ${i}/ 2> /dev/null
  done
  ' >> ambersub.j
  qsub ambersub.j
  cd ..  
done

cd $basedir

