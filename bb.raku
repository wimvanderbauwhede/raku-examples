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

#  Now let's try something like a*x^2+b*x+c
role Term {}
role Var [Str \v] does Term {
    has Str $.var = v
}
role Par [Str \p] does Term {
    has Str $.par = p
}
role Const [Int \c] does Term {
    has Int $.const = c;
}
role Pow [Term \t, Int \n] does Term {
    has Term $.term = t;
    has Int $.exp = n;
}
role Add [Array[Term] \ts] does Term {
    has Array[Term] $.terms = ts;
}
role Mult [Array[Term] \ts] does Term {
    has Array[Term] $.terms = ts;
}

#  The questions are: 
#  (1) what is the BB encoding 
#  (2) how do we go from the type to the BB encoding

role TermBB[\f] {
    method unTermBB(
        \var,\par,\const,\pow,\add,\mult 
    ) {
        f.(var,par,const,pow,add,mult);
    }
}

sub _var(Str \s --> TermBB) { 
    TermBB[ 
        sub (\v, \c, \n, \p, \a, \m) { v.(s) }
    ].new;
    }
sub _par(Str \s --> TermBB) { 
    TermBB[ 
        sub (\v, \c, \n, \p, \a, \m) { c.(s) }
    ].new;
    }

sub _cons(Int \i --> TermBB) { 
    TermBB[ 
        sub (\v, \c, \n, \p, \a, \m) { n.(i) }
    ].new;
    }    

# pow :: TermBB -> Int -> TermBB
# sub _pow t i  =TermBB $ \v c n p a m -> p (unTermBB t v c n p a m) i
sub _pow( TermBB \t, Int \i) {
    TermBB[  sub (\v, \c, \n, \p, \a, \m) { 
        p.( t.unTermBB( v, c, n, p, a, m ), i);
    }
    ].new;
}
# add :: [TermBB] -> TermBB
# sub _add ts = TermBB $ \v c n p a m -> a ( map (\t -> unTermBB t v c n p a m ) ts )
sub _add( @ts) {
    TermBB[  sub (\v, \c, \n, \p, \a, \m) { 
        a.( map {$_.unTermBB( v, c, n, p, a, m )}, @ts )
    }
    ].new;
}
# mult  :: [TermBB] -> TermBB
sub _mult( @ts) {
    TermBB[  sub (\v, \c, \n, \p, \a, \m) { 
        m.( map {$_.unTermBB( v, c, n, p, a, m )}, @ts )
    }
    ].new;
}
multi sub termToBB(Var \t) { _var(t.var)}
multi sub termToBB(Par \c) { _par( c.par)}
multi sub termToBB(Const \n) {_cons(n.const)}
# multi sub termToBB(Pow \pw ->  pow (termToBB t1) n

multi sub termToBB(Pow \pw){ 
    _pow( termToBB(pw.term), pw.exp);
    }
# multi sub termToBB(Add ts -> add (map termToBB ts)

multi sub termToBB(Add \t){ 
    # say 'HERE:' ~ t.terms.raku;
    # say t.terms.elems;
     my \bbt = map {termToBB($_) }, |(t.terms);
    # say 'HERE: ',bbt.raku;exit;
    _add(bbt)
    }
multi sub termToBB(Mult \t){ 
     _mult(map {termToBB($_)}, |t.terms)
    }

#   a*x^2 + b*x + x    
# qterm :: Term
my \qterm = Add[ 
    Array[Term].new(
    Mult[ Array[Term].new(Par[ "a"].new, Pow[ Var[ "x"].new, 2].new) 
        ].new,
    Mult[
        Array[Term].new(Par[ "b"].new, Var[ "x"].new) 
        ].new,
    Par[ "c"].new
    )
    ].new;
say qterm.raku;
my \qtermbb = termToBB( qterm);
say qtermbb.raku;

# ppTermBB :: TermBB -> String
sub ppTermBB(TermBB \t ){ 
#     where
        sub var( \x) { x }
        sub par( \x) { x }
        sub const( $x) { "$x" }
        sub pow( \t,  $m) { t ~ "^$m" }
        sub add(@ts) { join( " + ", @ts) }
        sub mult(@ts) { join( " * ", @ts) }
        t.unTermBB( &var, &par, &const, &pow, &add, &mult);
}

# evalTermBB :: H.Map String Int -> H.Map String Int -> TermBB -> Int
# sub evalTermBB vars pars t = unTermBB t var par const pow add mult
#     where
#         var x = H.findWithDefault 0 x vars
#         par x = H.findWithDefault 0 x pars
#         const c = c
#         pow t m = t ^ m
#         add = sum 
#         mult  = product

say ppTermBB( qtermbb);
# say evalTermBB (H.fromList [("x",2)]) (H.fromList [("a",2),("b",3),("c",4)])  qtermbb;
