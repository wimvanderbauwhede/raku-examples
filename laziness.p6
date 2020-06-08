use v6;

# Examples of Seq
my Seq \s1 = 'laziness.p6'.IO.lines;
for s1 -> \line {
    say line
}
say s1.head(3); # Fails, Seq iteration consumes values

my Seq \evens = (loop { (1..100).roll });
say evens.pick(10); # Fails, can't randomly pick from infinite lazy Seq

# Exampls of List:
my List \l1 = 1,2,3,4,5;
my List \l2 = 'hello', True, 22/7, 42, 'world';

# Turn Seq this into List:
my List \squares = map( sub (Int \x --> Int) { x² }, 1 .. *).list;
say 'squares:',squares.WHAT.perl;

# Still lazy
say squares.pick(10); # Fails, can't randomly pick from infinite lazy List
say squares.head(100).pick(10); # OK
say evens.head(100).pick(10); # OK
say evens.head(100).pick(10); # Fails, Seq iteration consumes values
say squares.head(100).pick(10); # OK, List keeps its values

# Arrays
my Array \a1 = 1,2,3,4,5; # Fails, this is a List!
my Array \a2 = [1,2,3,4,5]; # OK
my Array \a3 = Array.new(1,2,3,4,5); # same:
say a2~~a3; #OK
my Array \a4 = squares.Array; 
my Array \a5 = (1..*).Array;
say a5.eager.pick(10); # OK but you'll wait forever


