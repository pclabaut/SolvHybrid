from __future__ import division
import sys
from numpy.linalg import inv
import numpy as np

#Remove the water molecules that are not actually on top or bottom of the surface cell to avoid periodic problems with it.
#

openold = open(sys.argv[1],"r") #Get the name of the file to read
openvasp = open(sys.argv[2],"r") #Get the name of original CONTCAR file to get the transfer matrix from cristaline to cubic coordinates
opennew = open("hex_"+ sys.argv[1],"w") # Create a new file with writing rights

rline = openold.readlines() #Create a readlines object containing all the lines of the input file
rlinevasp = openvasp.readlines() #Create a readlines object containing all the lines of the vasp file

# As in 2, determine the scalling factor and transfer matrix from cristal coordinate to cubic.
facteur = float((rlinevasp[1].split())[0])
mat = ([[0, 0, 0],[0, 0, 0],[0, 0, 0]])
for i in range(2,5):
 coor = rlinevasp[i].split()
 for j in range(0,len(coor)):
   mat[i-2][j]=facteur*float(coor[j])

#Create the transposed matrix and reverse of it in order to be able to transfer the coordinate from cubic to cristalines
tr = np.transpose(mat)
change = inv(tr)
changetr = np.transpose(change)

#Define the angle between the original cell vectors and the vector length in order to extract the box informations
matrix = mat
normx=np.sqrt(mat[0][0]*mat[0][0]+mat[0][1]*mat[0][1])
normy=np.sqrt(mat[1][0]*mat[1][0]+mat[1][1]*mat[1][1])
prodscal=mat[0][0]*mat[1][0]+mat[1][1]*mat[0][1]
angle=np.arccos(prodscal/(normy*normx))
angledeg = float(round(angle*180/np.pi,0))

print(str("{:2.7f}".format(normx)),str("{:2.7f}".format(normy)),str("{:2.7f}".format(angledeg)))


#In order to determine the translation of origin induced by leap while solvating the cell, it gets the coordinates of the first point of the surface and apply them the transfer matrix. Then it gets the coordinates of the same atom in the solvated file and compare them to the previous point. The difference betwen theses two gives the translation vector beetwen the corrdinate system before and after solvatation. Here P referes to the point, R to the coordinate system nature and O to the origin.
coordonnepoint1vasp = rlinevasp[9].split()
vectorP1R1 = ([[float(coordonnepoint1vasp[0])],[float(coordonnepoint1vasp[1])],[float(coordonnepoint1vasp[2])]])
vectorP1R2O1 = np.dot(tr,vectorP1R1)
coordonnepoint1solv = rline[1].split()
vectorP1R2O2 = ([[float(coordonnepoint1solv[5])],[float(coordonnepoint1solv[6])],[float(coordonnepoint1solv[7])]])

VT = np.subtract(vectorP1R2O1,vectorP1R2O2)

#This function apply the translation vector and then the reverse transfer matrix to have the coordinate of a point of the pdb file in the cristaline coordinates
def translate (line,VT,mat): 
   coorsolv = rline[line].split()
   vectR2O2 = ([[float(coorsolv[5])],[float(coorsolv[6])],[float(coorsolv[7])]])
   vectR2O1 = np.add(vectR2O2,VT)
   vectR1 = np.dot(change,vectR2O1)
   return vectR1


#Read the sucessives lines. If it finds a water molecule, it translate the coordinates of each of its atoms on the cristaline coordinates and verify if its projection on z=0 belong to the original extended CONTCAR cell. It only prints the water molecule in the output file if it is the case. If it is not a water molecule, it just rewrites it.

i=0
while i < len(rline):
  line = rline[i].split()
  if len(line)>1 and line[3]=='WAT':
    inspace = 1
    for j in range(0,3):
      hexvector = translate(j+i,VT,mat)
      if hexvector[0]>1 or hexvector[0]<0 or hexvector[1]>1 or hexvector[1]<0 :
         inspace = 0
    if inspace :
       opennew.write(rline[i]+rline[i+1]+rline[i+2]+rline[i+3])
       #openwateronly.write(rline[i]+rline[i+1]+rline[i+2]+rline[i+3])
    i += 4
  else :
    opennew.write(rline[i])
    i += 1

#Close all the files
openvasp.close()
opennew.close()
openold.close()




