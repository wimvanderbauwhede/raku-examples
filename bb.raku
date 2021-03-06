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
    has Str $.var = v;
}
role Par [Str \p] does Term {
    has Str $.par = p;
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

# The BB encoding of Term
role TermBB[\f] {
    method unTermBB(
        \var,\par,\const,\pow,\add,\mult 
    ) {
        f.(var,par,const,pow,add,mult);
    }
}

# The little helpers
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
sub _pow( TermBB \t, Int \i --> TermBB) {
    TermBB[  sub (\v, \c, \n, \p, \a, \m) { 
        p.( t.unTermBB( v, c, n, p, a, m ), i);
    }
    ].new;
}
# Properly typed
sub _add( Array[TermBB] \ts --> TermBB) {
    TermBB[  sub (\v, \c, \n, \p, \a, \m) { 
        a.( map {$_.unTermBB( v, c, n, p, a, m )}, ts )
    }
    ].new;
}
# But this works as well
sub _mult(  @ts --> TermBB) {
    TermBB[  sub (\v, \c, \n, \p, \a, \m) { 
        m.( map {$_.unTermBB( v, c, n, p, a, m )}, @ts )
    }
    ].new;
}

sub typed-map (\T,\lst,&f) {
    Array[T].new(map {f($_) }, |lst )
}

# Turn a Term into a BB Term
multi sub termToBB(Var \t) { _var(t.var)}
multi sub termToBB(Par \c) { _par( c.par)}
multi sub termToBB(Const \n) {_cons(n.const)}
multi sub termToBB(Pow \pw){ _pow( termToBB(pw.term), pw.exp)}
# multi sub termToBB(Add \t){ _add( Array[TermBB].new(map {termToBB($_) }, |t.terms ))}
multi sub termToBB(Add \t){ _add( typed-map( TermBB, t.terms, &termToBB ))}
multi sub termToBB(Mult \t){ _mult(map {termToBB($_)}, |t.terms)}

# Example: 
#   a*x^2 + b*x + x    
my \qterm1 = Add[ 
    Array[Term].new(
    Mult[ Array[Term].new(Par[ "a"].new, Pow[ Var[ "x"].new, 2].new) 
        ].new,
    Mult[
        Array[Term].new(Par[ "b"].new, Var[ "x"].new) 
        ].new,
    Par[ "c"].new
    )
    ].new;
#   x^3 + 1    
my \qterm2 = Add[ 
    Array[Term].new(
    Pow[ Var[ "x"].new, 3].new, 
    Const[ 1].new
    )
    ].new;

#   qterm1 * qterm2    
my \qterm = Mult[ 
    Array[Term].new(
        qterm1, qterm2
    )
    ].new;


say qterm.raku;
my \qtermbb = termToBB( qterm);
say qtermbb.raku;

# A pretty-printer
sub ppTermBB(TermBB \t --> Str){ 
        sub var( \x ) { x }
        sub par( \x ) { x }
        sub const( $x ) { "$x" }
        sub pow( \t, $m ) { t ~ "^$m" } 
        sub add( \ts ) { "("~join( " + ", ts)~")" }
        sub mult( \ts ) { join( " * ", ts) }
        t.unTermBB( &var, &par, &const, &pow, &add, &mult);
}

# evalTermBB :: H.Map String Int -> H.Map String Int -> TermBB -> Int
sub evalTermBB( %vars,  %pars, \t) {
    t.unTermBB( 
        -> \x {%vars{x}}, 
        -> \x {%pars{x}},
        -> \x {x},
        -> \t,\m { t ** m},
        -> \ts { [+] ts},
        -> \ts { [*] ts}
    );
}


# Now let's combine them!
sub evalAndppTermBB(%vars,  %pars, TermBB \t ){ 
    t.unTermBB( 
        -> \x {[%vars{x},x]}, 
        -> \x {[%pars{x},x]},
        -> \x {[x,"{x}"]},
        -> \t,\m {[t[0] ** m, t[1] ~ "^{m}"] },
        -> \ts { 
            my \p = reduce { 
                [ $^a[0] + $^b[0], 
                $^a[1] ~ " + " ~ $^b[1]] 
            }, ts[0],  |ts[1..*];
            [ p[0], "("~p[1]~")" ]; 
        }, 
        -> \ts { 
            reduce { 
                [ $^a[0] * $^b[0], 
                $^a[1] ~ " * " ~ $^b[1]] 
                }, ts[0],  |ts[1..*]
            }
    )
}

say ppTermBB( qtermbb);
say evalTermBB(
    {"x" => 2}, {"a" =>2,"b"=>3,"c"=>4},  qtermbb
);
say evalAndppTermBB(
    {"x" => 2}, {"a" =>2,"b"=>3,"c"=>4},  qtermbb
);

# This is for parsing into AST, the link between Term and the TaggedEntry
role TaggedEntry {}
role Val[Str @v] does TaggedEntry {
	has Str @.val=@v;
} 
# valmap :: [(String,TaggedEntry)]
role ValMap [  @vm] does TaggedEntry { #String \k, TaggedEntry \te,
	has @.valmap = @vm; 
}

multi sub taggedEntryToTerm (["Var", TaggedEntry \val_strs]) { Var[ val_strs.val.head].new }
multi sub taggedEntryToTerm (["Par", TaggedEntry \par_strs]) { Par[par_strs.val.head].new }
multi sub taggedEntryToTerm (["Const", TaggedEntry \const_strs]) {Const[ Int(const_strs.val.head)].new } 
multi sub taggedEntryToTerm (["Pow", TaggedEntry \pow_strs]) {
  my (\vt, \et)   = pow_strs.valmap;
  Pow[ taggedEntryToTerm(vt), Int(et.[1].val)].new
}        
multi sub taggedEntryToTerm (["Add", TaggedEntry \hmap]) { 
  my \res = map {taggedEntryToTerm($_)}, |hmap.valmap;
  Add[ Array[Term].new(res)].new
}
multi sub taggedEntryToTerm (["Mult", TaggedEntry \hmap]) {  
  my \res = map {taggedEntryToTerm($_)}, |hmap.valmap;
  Mult[ Array[Term].new(res)].new
}

my Str @val_strs = "42";
my \v = taggedEntryToTerm(Const, Val[@val_strs].new);
say v.raku; 