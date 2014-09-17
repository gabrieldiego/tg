#!/usr/bin/python

import sys

test = "foreman"

org = open("frac_search_org.txt","w")
cur = open("frac_search_cur.txt","w")
mv = open("frac_search_mv.txt","w")

input_file = open("foreman_qp_22.dump","r")

while(True):
  l = input_file.readline()
  if l == '':
    break

  line = l.rstrip('\n')

  if line == "pixels_org":
    for i in range(8):
      l = input_file.readline()
      org.write(l)
  elif line == "pixels_cur":
    for i in range(8):
      l = input_file.readline()
      cur.write(l)
  elif line == "mv":
    l = input_file.readline()
    mv.write(l)
