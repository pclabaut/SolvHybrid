import sys

#Extract only the solvant box from an input file
#
openold = open(sys.argv[1],"r") # Open the original file in read mode
openwateronly = open((sys.argv[1])[:-4] + '_box.pdb',"w") # Open a file coresponding to the solvatation box only

rline = openold.readlines() #Create a readlines object containing all the lines of the input file

#Only keep the water molecules from the imput file to obtaine the water box
openwateronly.write(rline[0])
i=0
while i < len(rline):
  line = rline[i].split()
  if len(line)>1 and line[3]=='WAT':
    openwateronly.write(rline[i]+rline[i+1]+rline[i+2]+rline[i+3])
    i += 3
  i += 1

#Close all the files
openwateronly.close()
openold.close()




