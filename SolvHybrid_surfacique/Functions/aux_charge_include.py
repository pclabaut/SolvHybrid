from __future__ import division
import sys

#
#

openprm = open(sys.argv[1],"r") #Get the name of the imput file
opencm5 = open(sys.argv[2] ,"r") #Get the atomic nature of the surface
openchar = open(sys.argv[1]+'_charged',"w") # Create a new file with writing rights for the surface only
scalefactor = int(sys.argv[3])

rlineprm = openprm.readlines() 
rlinecm5 = opencm5.readlines() 


chargelinecm5 = 0
for i in range(0,len(rlinecm5)-1):
  words =rlinecm5[i].split()
  if len(words)>2 and words[2] == 'Charge':
    chargelinecm5 = i + 2

listecharge=[]
totalcharge=0
for i in range(chargelinecm5, len(rlinecm5)-1):
  for j in range(0,scalefactor*scalefactor):
    listecharge.append(float((rlinecm5[i].split())[2]))
    totalcharge += float((rlinecm5[i].split())[2])

deviationcharge = totalcharge/len(listecharge)

for i in range(0,len(listecharge)):
  listecharge[i] -= deviationcharge
  listecharge[i] = listecharge[i]*18.2223*1.27

nbmodifiedline = int(len(listecharge)/5)

initialiationecriture = 0
i = 0
endofwrite = 0

while i < len(rlineprm):
  words =rlineprm[i].split()
  if len(words)>1 and words[1] == 'CHARGE':
    initialiationecriture = 1
    openchar.write(rlineprm[i])
    openchar.write(rlineprm[i+1])
    i += 2
  if initialiationecriture == 0:
    openchar.write(rlineprm[i])
  if initialiationecriture == 1:
    j = 0
    while 1:
      for k in range(0,5):
        openchar.write(str(" {:15.8E}".format(listecharge[j])))
        j += 1
        if j == len(listecharge):
          endofwrite = k
          initialiationecriture=0
          break
      if j == len(listecharge):
        break
      openchar.write('\n') 
    for l in range(endofwrite+1,5):
     if len(rlineprm[i + nbmodifiedline].split()) > l :
        openchar.write(str(" {:15.8E}".format(float((rlineprm[i + nbmodifiedline].split())[l]))))
    openchar.write('\n')
    if endofwrite == 4:
       i -= 1
    i +=nbmodifiedline

  i += 1
 


















