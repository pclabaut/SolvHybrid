#!/bin/sh

#Usefull tool the clean the directory and let it ready for a new computation

confirmation=0

if [ $# -eq 0 ]
then
echo "You will delete all not original input files, functions and libraries. Are you sure ? (y/n)"
read confirmation
fi

if [ $confirmation = y ] || ([ $# -eq 1 ] && [ $1 = y ])
then

  rm -rf *files 
  rm -rf TI* 
  rm -rf trash
  rm leap.log
  rm analyse.dat
  cd Input
  rm box_data.txt
  rm -rf charges_info
  cd ..
else

  echo "Supression aborted"

fi
