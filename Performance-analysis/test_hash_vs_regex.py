import re
import sys
VER=int(sys.argv[1])

str = 'READ( 1, 2, ERR=8, END=9, IOSTAT=N ) X'.lower()
info={}

if re.search('read',str) :
    info['ReadCall']=1

count=0
# no cond: 3.1 s (Mac) 2.2s/1.9s (Linux, 5.30)
# regex: 10.1 (Mac) 7.5s/6.4s (Linux, 5.30)
# hash: 5.6 s (Mac) 4.3s/3.46s (Linux, 5.30)
# python3 v3.8.5 : dict 8.5 s
# regex:
# real	0m49.012s
# user	0m49.003s
# sys	0m0.004s
NITERS = 100_000_000
if VER==1 :
    for i in range(1,NITERS+1):
        # print(i)
        if re.search('read',str) :    
            count=count+i;
else:    
    for i in range(1,NITERS+1):
        if 'ReadCall' in info:
            count=count+i;

print(count)
