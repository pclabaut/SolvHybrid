from __future__ import division
import sys

#Extend the original VASP cell by a specified scalling factor to work on a larger area with Amber
#

openold = open(sys.argv[1],"r")  # Open the original file in read mode
opennew = open('extended'+sys.argv[1],"w") # Create a new file with writing rights
rline = openold.readlines() #Create a readlines object containing all the lines of the input file

scalefactor = int(sys.argv[2]) #Get the factor by wich the cell must be multiplied
opennew.writelines(rline[0] + rline[1]) #Write the unchanged header

#Multiplie the cell x and y vectors by the scalling factor
for i in range(2,4):
 coor = rline[i].split()
 opennew.write(str("     {:10.16f}    {:10.16f}   {:10.16f}\n".format(float(coor[0])*scalefactor,float(coor[1])*scalefactor,float(coor[2])*scalefactor)))

#Multiplie the number of each kind of atoms in the cell by the square of the scalling factor (because it extend in both x and y direction)
line6=''
nbatoms=0
for number in rline[6].split():
 line6 += '\t' + str(int(number)*scalefactor*scalefactor)
 nbatoms += int(number)

#Write the unchanged lines and the modified number of atoms line
opennew.write(rline[4] + rline[5] + str(line6) + '\n' + rline[7] + rline[8])

#For each former lines of coordinates, replicate it as many times as the scalling factor in each planar direction
for i in range(9,nbatoms+9):
  coor = rline[i].split()
  for j in range(0,scalefactor):
    for k in range(0,scalefactor):
      opennew.write(str("     {:10.17f}\t{:10.17f}\t{:10.17f}".format((float(coor[0])+j)/scalefactor,(float(coor[1])+k)/scalefactor,float(coor[2]))))
      opennew.write('\t'+coor[3]+'\t'+coor[4]+'\t'+coor[5]+'\n')


#Close all the files
openold.close()
openold.close()
