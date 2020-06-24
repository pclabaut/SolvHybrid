from __future__ import division
import sys
from numpy.linalg import inv
import numpy as np


#Transform a VASP file (CONTCAR) in a PDB file to help leap reading it later
#

openold = open(sys.argv[1],"r") # Open the original file in read mode
opensurface = open(sys.argv[1]+'.pdb',"w") # Create a new file with writing rights 
rline = openold.readlines() #Create a readlines object containing all the lines of the input file

facteur = float((rline[1].split())[0]) #Read the scaling factor of the matrix
#Create a matrix object for the transfer matrix from cubic coordinate to those of the cristaline cell
mat = ([[0, 0, 0],[0, 0, 0],[0, 0, 0]])
for i in range(2,5):
 coor = rline[i].split()
 for j in range(0,len(coor)):
   mat[i-2][j]=facteur*float(coor[j])

tr = np.transpose(mat)

#Read the nature of the atoms and their respectiv number
listatoms = rline[5].split()
listnbatoms = rline[6].split()

lastlineread = 9 #Initiate the reading of coordinate to the first line containing atom in the CONTCAR
nbatomread = 0 #Initiate the readed number of atom of the surface to 0


#Line by line, convert the coordinates of the atom in the cubic base, determine its nature by the number of already readed atoms (with listatoms and nbatoms) and write the new coordinates in the pdb format
for i in range(0,len(listatoms)):
  for line in rline[int(lastlineread):(int(lastlineread)+int(listnbatoms[i]))]:
    coordinate = line.split()
    vector = ([[float(coordinate[0])],[float(coordinate[1])],[float(coordinate[2])]])
    vectortruebase = np.dot(tr,vector)
    nbatomread += 1
    opensurface.write("ATOM  "+str("{:5d} {:^4s} {:3s}  {:4d}    {:8.3f}{:8.3f}{:8.3f}".format(nbatomread, listatoms[i], listatoms[i], nbatomread, float(vectortruebase[0][0]), float(vectortruebase[1][0]), float(vectortruebase[2][0])))+"  0.00  0.00\n")

  lastlineread = lastlineread + int(listnbatoms[i])


#Close all the files
opensurface.close()
openold.close()

