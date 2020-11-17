use v6;

=begin pod
The problem with Junctions is that they destroy type information.

If I did it in Haskell I have

    any :: (a -> Bool) -> [a] -> Bool
    all :: (a -> Bool) -> [a] -> Bool

and I could do (flip any) xs :: (a -> Bool) -> Bool

But what I need is really

data JType = Any | All | One | None
type Junction a = Junction JType [a]

fmap :: (a -> b) -> f a -> f b 
class Functor Junction where
    fmap :: (a -> b) -> f a -> f b    
    fmap f (Junction jtype xs) = Junction jtype (map f xs)

Furthermore f needs to adhere to the following:
Identity
    fmap id == id
Composition
    fmap (f . g) == fmap f . fmap g

And then I would just do:

div :: Int -> (Int -> Rat) 
j1 :: Junction Int
fmap :: (Int -> (Int -> Rat)) -> Junction Int -> Junction (Int ->Rat)
pdivsj = fmap div j1 :: Junction (Int ->Rat)

which essentially is (jtype,map div j1)

j2 :: Junction Int

So I need to get the function out of this Junction


Let's see how this works for a simpler case of div with Ints


pdivs = map div xs1 
pdivs is a list of functions Int -> Rat

res = map (\x -> map (\f -> f x) pdivs) xs2

Now if instead of lists we have Junctions

pdivsj = fmap div j1

res = fmap (\x -> fmap (\(Junction f) -> f x) pdivsj) j2

=end pod
my Int @xs1 = 12,24,36;
my Array[Int] \xs2 = Array[Int](2,4,6);

# any :: a -> Junction a but unfortunatel the Raky signature is (|) and the Junction type does not take parameters
say &any.signature.raku; # => :(|)
my Junction \j1 = any @xs1;
my Junction \j2 = all xs2;

# div :: Int -> Int -> Rat
sub div( Int \x1, Int \x2 --> Rat) {
    x1/x2;
}
sub sq( Int \x --> Int) {
    x*x;
}

sub psq( Any \x --> Any) {
    x*x;
}


# If we pass in a Junction where any elt is not Int we get a type error
# But the type of j1 and j2 is simply 'Junction' so this would imply that
#  div_sum :: Junction -> Junction -> Junction 
#  which it is not
my Junction \j3 = div(j1,j2);
say j3;
my Junction \jres = ((6,12,18).any, (3,6,9).any, (2,4,6).any).all ;
say so j3 == jres;



sub hof( &f:(Int --> Int) , Int \v --> Int) {
    f(v);
}

sub phof( &f:(Any --> Any) , Any \v --> Any) {
    f(v);
}

# 
my Junction \res = hof(&sq,j1); 
say res;

my Junction \pres = phof(&psq,j1); 
say pres;

#<<<<<<< HEAD


my $ij = 11 | 22;
my Int $ivj = sq($ij); # Type error!
my $sj = '11' | '22';
say $sj.WHAT; #=>(Junction)

my Junction $svj = sq($sj); # Type error!
#=======
say "\nAre Junctions Lazy?\n";

my $ct=0;
sub show-sq(\v) {
    #    say v;
$ct++;
v*v;
}

my @vs = 1 ... 10000;
my \jvs = @vs.any;
say jvs.WHAT;
my \jsq = show-sq(jvs);

say  so 1 == jsq;

say $ct == @vs.elems ?? 'No' !! $ct==1 ?? 'Yes' !! 'Maybe' ;
#>>>>>>> 178691b687755a0ff09ed86cac29c5f670b20151
