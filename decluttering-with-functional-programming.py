
def square(x):
    return x*x

# anonymous subroutine 
anon_square = lambda x: x*x

list1 = list((1,2,3)) #=> a list from a tuple
list2 = [1,2,3]; #=> a list, because of the '[...]'

range1 = range(1,11) #=> a range 1 .. 10
list3 = list(range(1,11)); #=> a list from a range

tuple1 = 1,2,3; #=> a tuple
tuple2 = tuple([1,2,3]) #=> a tuple from a list
tuple3 = tuple(range(1,11)) #=> creates a tuple from a range

## A function, by any other name -- functions as values

def choose (t, f, d):
  if d:
    return t 
  else:
    return f

tstr = "True!"
fstr = "False!"

res_str = choose(tstr,fstr,True)

print(res_str) #=> says "True!"

def tt(s):
  print( "True "+s+"!")
def ff(s):  
  print( "False"+s+"!")

res_f = choose(tt,ff,True)

print(res_f) #=> says <function tt at 0x7f829c3aa310>
res_f("rumour") #=> says "False rumour!"

## Functions don't need a name

tt = lambda s : print( "True "+s+"!" )
ff = lambda s : print( "False "+s+"!" )

res_f = choose(tt, ff, True);

print( res_f) #=> says <function <lambda> at 0x7f829b298b80>
res_f("story") #=> says "True story!"

## Examples: `map`, `grep` and `reduce`


### `map` : applying a function to all elements of a list

res = tuple( map( lambda x : x*x , range(1,11)))

res = []
for x in range(1,11):
	res.append(x*x)

### `filter` : filtering a list

res = tuple(filter( lambda x : x % 5 == 0 ,range(1,31)))

res = []
for x in range(1,31): 
  if (x % 5 == 0):
    res.append(x)

res = tuple(filter( lambda x : x % 5 == 0 ,map( lambda x : x*x ,tuple(range(1,31)))))

### `reduce` : combining all elements of a list into a single value

from functools import reduce

sum = reduce(lambda acc,elt: acc+elt, range(1,11))

print( sum); #=> says 55

### Writing your own

assoc_func = lambda x,y: x+y
non_assoc_func = lambda x,y: x+y if x<y else x

#### Left fold

def foldll (f, iacc, lst):
  acc = iacc
  for elt in lst:
    acc = f(acc,elt)  
  return acc

def foldl (f, acc, lst):
  if lst == (): 
    return acc 
  else:
  # Python's way of splitting a tuple in the first elt and the rest
  # rest will be a list, not a tuple, but we'll let that pass
   (elt,*rest) = lst 
   # The actual recursion
   return foldl( f, f(acc, elt), rest)

#### Right fold

def foldlr (f, iacc, lst):
  acc = iacc
  for elt in lst.reverse():
    acc = f(acc,elt)  
  return acc

def foldr (f, acc, lst):
  if lst == (): 
    return acc 
  else:
   (*rest,elt) = lst 
   return foldr( f, f(acc, elt), rest)


#### `map` and `grep` are folds

def map_ (f,lst):
    return foldl( 
      lambda acc,elt:(*acc, f(elt))
      ,()
      ,lst
    )

def filter_ (f,lst):
    return foldl( 
      lambda acc,elt:
        (*acc,elt) if f(elt) else acc
      , (), lst)


## Functions returning functions

def add_1 (x) : return x+1
def add_2 (x) : return x+2
def add_3 (x) : return x+3
def add_4 (x) : return x+4
def add_5 (x) : return x+5

print( add_1(4)) #=> says 5

add = (
lambda x : x+1,
lambda x : x+2,
lambda x : x+3,
lambda x : x+4,
lambda x : x+5
)
print( add[0](4)) #=> says 5

add = []
for n in range(0,6):
  add.append(lambda x: x+n)

def gen_add(n):  
  return lambda x : x+n

add = tuple(map( gen_add, range(0,6)))

print( add[1](4)) #=> says 5

## Function composition

res_chain = map( lambda x : x + 5, map( lambda x : x*x, range(1,31)))
def compose(f,g):
    return lambda x: f(g(x))
