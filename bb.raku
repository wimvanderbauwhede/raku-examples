use v6;

# Simple examples of Böhm-Berarducci encoding of algebraic data types
# This is a way to encode an algebraic data type as a function
# In Raku I wrap these in a role 

# Boolean, the simplest sum type
say "\nBool:\n";

role BoolBB[\b] {
    has $.unBoolBB = b;
}

my \true  = -> \t,\f { t }
my \false = -> \t,\f { f }

# Make a BB bool
sub bbb(\tf) { BoolBB[ tf ].new };

my BoolBB \trueBB = bbb true; 
my BoolBB \falseBB = bbb false; 

# Turn the BB bool into an actual bool
sub bool(BoolBB \b --> Bool) { 
    b.unBoolBB.( True, False) 
}

say bool trueBB;
say bool falseBB;

# The Maybe type
say "\nMaybe:\n";

role MayBB[ \mb ] {
    has $.unMayBB = mb; #:: forall a .  (b -> a) -- Just a -> a -- Nothing -> a
}

# selectors
sub bbj( \x ) { -> \j,\n {j.(x)} }
sub bbn { -> \j,\n {n.()} }

# wrapper for the role constructor
sub mbb (\jm) {
    MayBB[ jm ].new;
}

# final type constructors
sub just(\v) {mbb( bbj v )}
sub nothing {mbb( bbn )}

sub testBB(MayBB \mb --> Str) {
    mb.unMayBB.( -> $x { "$x" }, -> { "NaN"} );
}

my MayBB \mbb = just 42;
my MayBB \mbbn = nothing;

say testBB mbb ;
say testBB mbbn;

# A pair, the simplest product type
say "\nPair:\n";

role PairBB[ \p ] {
    has $.unPairBB = p #:: forall a . (t1 -> t2 -> a) -> a
}

# To get the elements out of the pair
sub fst( \p ){ p.unPairBB.(true) }
sub snd( \p ){ p.unPairBB.(false) }

# Final pair constructor

sub pair(\x,\y --> PairBB) {
    PairBB[ -> \p { p.(x, y) } ].new;
}

my PairBB \bbp = pair 42,"forty-two";

say fst bbp ;
say snd bbp ;



