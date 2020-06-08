use v6;
# Compare with laziness.p6!
# Examples of Seq
my @s1 = 'laziness.p6'.IO.lines;
for @s1 -> $line {
    say $line
}
say 's1:',@s1.WHAT.perl;

say @s1.head(3); # Fails, Seq iteration consumes values

my @evens = (loop { (1..100).roll }).lazy;
#say @evens.pick(10); # Fails, can't randomly pick from infinite lazy Seq
say 'evens:',@evens.WHAT.perl;

# Exampls of List:

my @l1 = 1,2,3,4,5;
say 'l1:',@l1.WHAT.perl;

my @l2 = 'hello', True, 22/7, 42, 'world';
 say 'l2:',@l2.WHAT.perl;

# Turn Seq this into List:
my @squares = map( sub (Int \x --> Int) { x² }, 1 .. *).list;

# Still lazy
#say squares.pick(10); # Fails, can't randomly pick from infinite lazy List
say @squares.head(100).pick(10); # OK
say @evens.head(100).pick(10); # OK
#say evens.head(100).pick(10); # Fails, Seq iteration consumes values
say @squares.head(100).pick(10); # OK, List keeps its values

#my Array \a1 = 1,2,3,4,5; # Fails, this is a List!
my @a2 = [1,2,3,4,5]; # OK
my @a3 = Array.new(1,2,3,4,5); # same:
say @a2~~@a3; #OK
my @a4 = @squares.Array; 
my @a5 = (1..*).Array;
#say a5.eager.pick(10); # OK but you'll wait forever

say 'done';
