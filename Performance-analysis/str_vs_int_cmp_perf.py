
#perl, int
#real    0m2.973s
#user    0m2.969s
#sys 0m0.004s

#perl, str
#real    0m3.347s
#user    0m3.346s
#sys 0m0.001s

#raku, int
#real    0m23.858s
#user    0m23.872s
#sys 0m0.036s

#raku, str
#real    0m23.818s
#user    0m23.827s
#sys 0m0.044s


#python, str
#real    0m10.153s
#user    0m10.149s
#sys 0m0.004s
#python, int
#real    0m10.424s
#user    0m10.416s
#sys 0m0.008s

str = '*'
c=42
count=0
# int: 4.6 string: 5.3
for i in range(1,100000001):
#    if str == '*':
     if c == 42:
    #    if (1) 3.1
        count=count+i
print(count)
