import sys

#Just rotate the system by 90deg around y by inverting permuting x,y and z coordinates

openold = open(sys.argv[1],"r") # Open the original file in read mode
opennew = open('rotated_'+sys.argv[1],"w") # Create a new file for the adsorbed molecules only
rline = openold.readlines() #Create a readlines object containing all the lines of the input file

for line in rline:
  words = line.split()
  if words[0]=='ATOM':
    opennew.write("ATOM  "+str("{:5d} {:^4s} {:3s}  {:>5}   {:8.3f}{:8.3f}{:8.3f}".format(int(words[1]), words[2], words[3], int(words[4]), float(words[7]), float(words[5]), float(words[6])))+"  0.00  0.00\n")
  else :
    opennew.write(line)

#Close all the files
opennew.close()
openold.close()

