import re
import sys
str1='This means we need a stack per type of operation and run until the end of the expression'

chrs = list(str1)
niters = 1_000_000
# Still not good: need to substr1act the time to copy or populate the str1/array
#[wimhackbox Sketches] time perl test_regex_vs_fsm_perf.pl 0 (for) overhead 3 = 0.064
#3.5s
#[wimhackbox Sketches] time perl test_regex_vs_fsm_perf.pl 1 (while) overhead 4 = 2.7s, so really only 5.1s
#7.8 s
#[wimhackbox Sketches] time perl test_regex_vs_fsm_perf.pl 2 (regex) overhead 5 = 0.08s
#8.0s


# The regex version is 1.45s, the other version 3.25s (mean over 10 runs)
ver=int(sys.argv[1])

for iter in range(1,niters+1) :
    words=[]
    if (ver==0) :
        word=''
        for c in chrs  :
            if (c != ' ') :
                word=word+c
            else :
                words.append(word)
                word=''
        words.append(word)            
    elif (ver==1) :
        chrs_ = list(str1)
        word=''
        while (len(chrs_)>0) :
            c=  chrs_.pop(0)
            if (c != ' ') :
                word=word+c
            else :
                words.append(word)
                word=''
        words.append(word)
    elif(ver==2) :
        str1='This means we need a stack per type of operation and run until the end of the expression'

        while(len( str1 ) > 0) :
            m = re.match('^(\w+)',str1)
            if  m!= None :
                str1 = re.sub(r'^(\w+)','',str1)
                words.append(m.group(0) )
            
            else :
                str1 = re.sub(r'^(\s+)','',str1)                             
        
    elif (ver==3) :
        word=''
    elif (ver==4) :
        chrs_ = list(str1)
        word=''
    else : 
        str1='This means we need a stack per type of operation and run until the end of the expression'

        

    # print(words)    

