#!/usr/bin/python

from sys import stdin
import matplotlib.pyplot as pyplot

lines = stdin.readlines()

brlist = []
psnrlist=[]

while(1==1):
  line = lines[0]

  if(len(lines) == 1):
    break

  lines = lines[1:]

  if(line[:7] == "SUMMARY"):
    line = lines[1]
    bitrate = line[19:30]
    psnr = line[30:40]

    bitrate = float(bitrate)
    psnr = float(psnr)

    brlist.append(bitrate)
    psnrlist.append(psnr)

    print bitrate, "        ", psnr
#    print psnr

pyplot.plot(brlist,psnrlist)

pyplot.savefig('grafico.png')
print "Finished"
