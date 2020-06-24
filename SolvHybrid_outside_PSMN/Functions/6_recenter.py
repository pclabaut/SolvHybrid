import sys
import numpy as np

#Used to align the pdb file of the pristine surface with the one of the solvated adsorbate that has been recentered by cpptraj
#

openold = open(sys.argv[1],"r") # Open the pdb file of the pristine surface
open2 = open(sys.argv[2],"r") # Open the adsorbed geometry to have a reference for the first atom of the slab 
opencentered = open('centered_surface.pdb',"w") # Open the futur recentered file for the pristine surface
rline = openold.readlines() 
line_2 = open2.readlines()

#Compute translation vector
vec_O_postalchemy = np.array([float(rline[0].split()[5]),float(rline[0].split()[6]),float(rline[0].split()[7])])
vec_O_prealchemy = np.array([float(line_2[1].split()[5]),float(line_2[1].split()[6]),float(line_2[1].split()[7])])
translate_vector = vec_O_prealchemy-vec_O_postalchemy

opencentered.write(rline[0])
i=0
while i < len(rline):
  line = rline[i].split()
  if  len(line)>1 and line[0]=='ATOM':
    opencentered.write("ATOM  "+str("{:5d} {:^4s} {:3s}  {:4d}    {:8.3f}{:8.3f}{:8.3f}".format(int(line[1]), line[2],line[3],int(line[4]),float(line[5])+translate_vector[0],float(line[6])+translate_vector[1],float(line[7])+translate_vector[2]))+"  0.00  0.00\n")
  else :
    opencentered.write(rline[i])
  i += 1


#Close all the files
opencentered.close()
open2.close()
openold.close()




