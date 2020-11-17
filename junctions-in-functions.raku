use v6;
=begin pod
This issue is a request for an additional method for the Junction class, .collapse() 
This method would return the value inside a junction if all stored values are the same.

The purpose is to recover values that are turned into junctions as a side effect. 

The little program below illustrates the issue

=end pod
# This little program illustrates an issue with junctions: they inadvertently turn other arguments of functions into junctions.
 
enum RGB <R G B>;
# Pair Constructor: the arguments of pair() are captured in a closure that is returned
sub pair(Int \x, RGB \y) {
    -> &p { p(x, y) } 
}
# Pair Selectors, to get the values from the closure
my sub fst (&p) {p(-> \x,\y {x})}
my sub snd (&p) {p(-> \x,\y {y})}

# Example instance
my Callable \p1 = pair 42,R;

if ( 42 == fst p1) {
    say snd p1;	#=> says OK
}

# Example instance with junction

my Junction \p1j = pair (42^43),R;

if ( 42 == fst p1j) {
# The original argument 'OK' has irrevocably been turned into a junction with itself 
    say snd p1j; #=> any(OK, OK)
}

# Proposed solution: allow to collapse these inadvertent junction values into their original values

if ( 42 == fst p1j) {
# The original argument 'OK' has irrevocably been turned into a junction with itself 
    say collapse(snd p1j) ~~ R; #=> OK
}
say 'Negate: ',!(snd p1j); # Why?
if (snd p1j) {
    say 'T'
} else {
    say 'F'
}
sub collapse(Junction \j) {    
    my @vvs;
    -> Any \s { push @vvs, s }.(j);    
    my $v =  shift @vvs;        
    my @ts = grep {!($_ ~~ $v)}, @vvs;
    if (@ts.elems==0) {  
        $v
    } else {
        die "Can't collapse this Junction: elements are not identical: {$v,@vvs}";
    }
}
