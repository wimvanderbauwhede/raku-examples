use v6;

# Peano numbers as a recursive sum type
role Nat{}    
role Z does Nat {}
role S[Nat $n] does Nat {}  

# Some instances
my Nat \zero = Z;
my Nat \one = S[Z];
my Nat \two = S[S[Z]];
my Nat \also-two = S[one];

# Testing
say two.raku; say also-two.raku;	
say two.WHAT; say also-two.WHAT;	
say two === also-two;
say two ~~ also-two;		
say two =:= also-two;
