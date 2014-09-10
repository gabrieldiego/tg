#!/usr/bin/python

import matplotlib.pyplot as pyplot

cfg_names = ["basketballdrill", "basketballpass", "traffic",  "foreman"]

qps = [22, 27, 32, 37]

brlist = []
psnrlist=[]

new_param = []
old_param = []
none_param = []

newbr = []
newpsnr = []

oldbr = []
oldpsnr = []

nonebr = []
nonepsnr = []

def read_cfg(lines):
  while(1==1):
    line = lines[0]

    if(len(lines) == 1):
      break

    lines = lines[1:]

    if(line[:7] == "SUMMARY"):
      line = lines[1].split()

      bitrate = float(line[2])
      psnr = float(line[3])

      brlist.append(bitrate)
      psnrlist.append(psnr)

#      print bitrate, ",", psnr
      return [bitrate,psnr]

  return []

def print_cfg(cfg_name, qps):

  brlist = []
  psnrlist=[]

  new_param = []
  old_param = []
  none_param = []

  newbr = []
  newpsnr = []

  oldbr = []
  oldpsnr = []

  nonebr = []
  nonepsnr = []


  for qp in qps:
    cfg_summary = cfg_name + "_qp_" + str(qp)
    cfg_summary_new = cfg_summary + "_new.summary"
    cfg_summary_old = cfg_summary + "_old.summary"
    cfg_summary_none= cfg_summary + "_none.summary"

    summary_new = open(cfg_summary_new).readlines()
    summary_old = open(cfg_summary_old).readlines()
    summary_none= open(cfg_summary_none).readlines()

    new_param.append(read_cfg(summary_new))
    old_param.append(read_cfg(summary_old))
    none_param.append(read_cfg(summary_none))

#print new_param
#print old_param
#print none_param

  print "new"
  for p in new_param:
    print "%.2f kbps" % p[0]
    newbr.append(p[0])
  for p in new_param:
    print "%.2f dB" % p[1]
    newpsnr.append(p[1])

  print "old"
  for p in old_param:
    print "%.2f kbps" % p[0]
    oldbr.append(p[0])
  for p in old_param:
    print "%.2f dB" % p[1]
    oldpsnr.append(p[1])

  print "none"
  for p in none_param:
    print "%.2f kbps" % p[0]
    nonebr.append(p[0])
  for p in none_param:
    print "%.2f dB" % p[1]
    nonepsnr.append(p[1])

  pyplot.plot(oldbr,oldpsnr, label='original')
  pyplot.plot(newbr,newpsnr, label='proposto')
  pyplot.plot(nonebr,nonepsnr, label='full-pixel')

  pyplot.title(cfg_name)
  pyplot.legend(loc=0)
  pyplot.xlabel('bitrate (kbps)')
  pyplot.ylabel('PSNR (dB)')

  pyplot.savefig(cfg_name + '.png')
  pyplot.clf()
  print "Finished"

for cfg_name in cfg_names:
  print cfg_name
  print_cfg(cfg_name,qps)
