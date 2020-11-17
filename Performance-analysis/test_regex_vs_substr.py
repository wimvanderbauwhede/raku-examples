import re
import sys
niters = 10_000_000
VER=int(sys.argv[1])

def remove_leading_chars (cstr1,tstr1) :
    if (tstr1[0:len( cstr1)] == cstr1) :
        return tstr1[len(cstr1):]
    else :
        return tstr1


# say '<'~str1~'>'
count =0
str1 = '    no content'
if (VER<=3) : 

    for iter in range (1,niters+1 ):
        str1 = '    no content'
        if VER==0 :
            while (str1[0] == ' ') :
                str1 = str1[1:]
            count=count+1
        elif (VER==1) :
                count=count+1
        elif (VER==2) :
            m = re.match('^\s+',str1)
            if (m!=None) :
                str1 = re.sub(r'^\s+','',str1)
                count=count+1
    # print(count)



# say str1
# say count
# exit
else :
    for iter in range (1,niters+1 ):
        # say _
        str1 = '(no content)'
        str2 = 'no (content)'
        if VER==4 :

            str1 = remove_leading_chars('(',str1)
            str2 = remove_leading_chars('(',str2)
        elif VER==5 :
            if str1[0] == '(' :
                str1=str1[1:]
                count=count+1

            if str2[0] == '(' :
                str2=str2[1:]
                count=count+1

        else :
            m1 = re.match('^\(',str1)
            if (m1!=None) :
                str1 = re.sub(r'^\(','',str1)
                count=count+1
            m2 = re.match('^\(',str2)
            if (m2!=None) :
                str2 = re.sub(r'^\(','',str2)
                count=count+1

   


# say count


    

