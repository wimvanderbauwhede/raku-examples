import re   
strs=[
    'READ( 1, 2, ERR=8, END=9, IOSTAT=N ) X, Y',
    'CLOSE( [ UNIT=] u [, STATUS= sta] [, IOSTAT= ios] [, ERR= s ] )',
    'WRITE( 1, REC=3, IOSTAT=N, ERR=8 ) V'
]
hits=[]
for iters in range (1,1000_000) : #1000_000
    hits=[]
    for str in strs :
        if (1) :
            if (0) :
# real	0m2.300s
# user	0m2.300s
# sys	0m0.000s


                m = re.match('(READ|ACCEPT|OPEN|CLOSE|PRINT|WRITE)',str) 
                if m != None:
                    # print()
                    hits.append(m.group(0))
                # exit()
            else :
# real	0m2.250s
# user	0m2.246s
# sys	0m0.004s
                m = re.search('(?:READ|ACCEPT|OPEN|CLOSE|PRINT|WRITE)',str) 
                if m != None:
                    # print()
                    hits.append(m.group(0))
        
    
        else :
            if (0) :
# real	0m6.055s
# user	0m6.046s
# sys	0m0.008s

                m = re.search('(READ)',str)
                if m == None:
                    m = re.search('(ACCEPT)',str)
                    if m == None:
                        m = re.search('(OPEN)',str)
                        if m == None:
                            m = re.search('(CLOSE)',str)
                            if m == None:
                                m = re.search('(PRINT)',str)
                                if m == None:
                                    m = re.search('(WRITE)',str)
                if m != None: 
                    hits.append(m.group(0))
            

            else :
# real	0m5.893s
# user	0m5.893s
# sys	0m0.000s


                m = re.search('READ',str)
                if m == None:
                    m = re.search('ACCEPT',str)
                    if m == None:
                        m = re.search('OPEN',str)
                        if m == None:
                            m = re.search('CLOSE',str)
                            if m == None:
                                m = re.search('PRINT',str)
                                if m == None:
                                    m = re.search('WRITE',str)
                if m != None: 
                    hits.append(m.group(0))
        
    


