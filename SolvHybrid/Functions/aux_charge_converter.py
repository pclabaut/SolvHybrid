import sys
from numpy.linalg import inv
import numpy as np
from periodic.table import element

#Prepare the input file for cm5 from the Hirsgfeld charges of VASP
#

opencon = open(sys.argv[1],"r") #Get the name of the imput file
openout = open(sys.argv[2],"r") #Get the atomic nature of the surface
openchar = open(sys.argv[1]+'_cm5input',"w") # Create a new file with writing rights for the surface only

rlinecon = opencon.readlines() 
rlineout = openout.readlines() 

#Read the nature of the atoms and their respectiv number
listatoms = rlinecon[5].split()
nbatoms = rlinecon[6].split()

Hirshfeldline = 0
for i in range(0,len(rlineout)-1):
  words =rlineout[i].split()
  if len(words)>0 and words[0] == 'Hirshfeld-DOM':
    Hirshfeldline = i + 3

openchar.write(rlinecon[0] + rlinecon[1]+ rlinecon[2] +rlinecon[3] +rlinecon[4] + 'Direct\n')


lastlineread = 9 #Initiate the reading of coordinate to the first line containing atom in the CONTCAR
#Line by line, convert the coordinates of the atom in the cubic base, determine its nature by the number of already readed atoms (with listatoms and nbatoms) and write the new coordinates in the appropriate file.
for i in range(0,len(listatoms)):
  for line in rlinecon[int(lastlineread):(int(lastlineread)+int(nbatoms[i]))]:
    openchar.write(str(element(listatoms[i]).atomic) + line[:-10] +'\n')
 
  lastlineread = lastlineread + int(nbatoms[i])

openchar.write('----\n')

for i in range(0,len(listatoms)):
  for line in rlineout[int(Hirshfeldline):(int(Hirshfeldline)+int(nbatoms[i]))]:
    openchar.write(str((line.split())[3])+'\n')
 
  Hirshfeldline += int(nbatoms[i])


#Close all the files
opencon.close()
openout.close()
openchar.close()
