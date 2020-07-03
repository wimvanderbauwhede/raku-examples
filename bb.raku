use v6;

# Simple examples of Böhm-Berarducci encoding of algebraic data types
# This is a way to encode an algebraic data type as a function
# In Raku I wrap these in a role 

# Boolean, the simplest sum type
say "\nBool:\n";

role BoolBB[\b] {
    has $!unBoolBB = b;
    method unBoolBB_(\t,\f) {
        b.(t,f)
    }
}

my \true  = -> \t,\f { t }
my \false = sub (\t,\f) { f }

# Make a BB bool
sub bbb(\tf --> BoolBB) { BoolBB[ tf ].new };

my BoolBB \BBTrue = bbb true;
my BoolBB \BBFalse = bbb false;

my BoolBB \trueBB = BBTrue;
my BoolBB \falseBB = BBFalse; 

# Turn the BB bool into an actual bool
sub bool(BoolBB \b --> Bool) { 

    b.unBoolBB_( True, False) 
    #    b.unBoolBB.( True, False) 
}

say bool BBTrue;
say bool BBFalse;
say bool trueBB;
say bool falseBB;

# The Maybe type
say "\nMaybe:\n";

role MayBB[ \mb ] {
    has $.unMayBB = mb; #:: forall a .  (b -> a) -- Just a -> a -- Nothing -> a
    method unMayBB_(\j,\n) {
        mb.(j,n);
    }
}

# selectors
sub bbj( \x ) { -> \j,\n {j.(x)} }
sub bbn { -> \j,\n {n.()} }

# wrapper for the role constructor
sub mbb (\jm) {
    MayBB[ jm ].new;
}

# final type constructors
sub Just(\v) {mbb( bbj v )}
sub Nothing {mbb( bbn )}

sub testBB(MayBB \mb --> Str) {
    #mb.unMayBB.( -> $x { "$x" }, -> { "NaN"} );
    mb.unMayBB_( -> $x { "$x" }, -> { "NaN"} );
}

my MayBB \mbb = Just 42;
my MayBB \mbbn = Nothing;

say testBB mbb ;
say testBB mbbn;

# A pair, the simplest product type
say "\nPair:\n";

role PairBB[ \p ] {
    has $.unPairBB = p; #:: forall a . (t1 -> t2 -> a) -> a
    method unPairBB_(\p_) {
        p.(p_);
    }
}

# To get the elements out of the pair
sub fst( \p ){ p.unPairBB_(true) }
sub snd( \p ){ p.unPairBB.(false) }

# Final pair constructor

sub pair(\x,\y --> PairBB) {
    PairBB[ -> \p { p.(x, y) } ].new;
}

my PairBB \bbp = pair 42,"forty-two";

say fst bbp ;
say snd bbp ;



