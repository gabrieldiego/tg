#!/usr/bin/python

import matplotlib.pyplot as pyplot

#new
#199.24          33.6143
#298.008         35.6887
#498.88          38.0214

newbr=[199.24, 298.008, 498.88]
newpsnr=[33.6143, 35.6887, 38.0214]


#old
#199.112         33.9448
#298.216         35.929
#499.08          38.3219

oldbr=[199.112,298.216,499.08]
oldpsnr=[33.9448,35.929,38.3219]


#none
#199.784          32.6752
#299.408          34.3684
#499.696          36.3173

nonebr=[199.784,299.408,499.696]
nonepsnr=[32.6752,34.3684,36.3173]

x = [1,5,6]
y = [33,44,11]

pyplot.plot(newbr,newpsnr)
pyplot.plot(oldbr,oldpsnr)
pyplot.plot(nonebr,nonepsnr)

pyplot.savefig('example01.png')
