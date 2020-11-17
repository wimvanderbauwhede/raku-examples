
if (0) :
    if (0) :
        if (0) :
# perl 1.5 s
# python  
# real	0m2.300s
# user	0m2.121s
# sys	0m0.180s

            res=[]
            src=[]

            for elt in range(1,10_000_001) :
                src.append(elt)
            

            for elt in src :
                res.append(2*elt+1) 
            # print(res)

        else :
            
# perl 2.0s
# python 
# real	0m1.367s
# user	0m1.263s
# sys	0m0.104s

            src = map(lambda x:x, range(1, 10_000_001))
            res = list(map(lambda x:2*x+1, src))

            # print(res)
    else :
        if (1) :
# perl 2.1 s
# python
# real	0m2.869s
# user	0m2.697s
# sys	0m0.172s

            res=[0] * 10_000_000
            src=[0] * 10_000_000
            # print(src[111])
            for idx in range(0,10_000_000)  :
                elt=idx+1
                src[idx] = elt            

            for idx in range(0,10_000_000)  :
                elt=src[idx]
                res[idx] = 2*elt+1
            
        else :
        # 4.4s
        # no python equivalent
            res=[0] * 10_000_000
            src=[0] * 10_000_000
            idx=0
            # loop (idx=0idx < 10_000_000++idx) :
            #     elt=idx+1
            #     src[idx] = elt
            
            # idx=0
            # loop (idx=0idx < 10_000_000++idx) :
            #     elt=src[idx]
            #     res[idx] = 2*elt+1
            
        
    
else :
    # perl 1.45s for suffix for
    # python  
# real	0m1.214s
# user	0m0.995s
# sys	0m0.211s

    # src = []
    # res=[]
    src = [ x for x in range(1,10_000_001) ]
    res = [2*x+1 for x in src]
    # say res


# 000 suffix for
# real	0m22.814s
# user	0m22.225s
# sys	0m0.788s

# 100 loop/idx
# real	1m5.340s
# user	1m4.796s
# sys	0m0.772s

# 101 for/idx

# real	0m46.769s
# user	0m46.032s
# sys	0m0.932s

# 110 map

# real	0m34.109s/32.5
# user	0m33.175s/31.7
# sys	0m1.120s

# 111 for/push
# real	0m46.713s
# user	0m46.146s
# sys	0m0.772s


