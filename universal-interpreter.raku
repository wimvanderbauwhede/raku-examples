use v6;

# Boolean, the simplest sum type

say "\nBool:\n";

role BoolBB[&b] {
    method unBoolBB(Any \t, Any \f --> Any) {
        b(t,f)
    }
    method bool_ { 
        self.unBoolBB( True, False) 
    }

}

my \true  = -> Any \t, Any \f --> Any { t }
my \false = sub (Any \t,Any \f --> Any ) { f }

# Make a BB bool
sub bbb(\tf --> BoolBB) { BoolBB[ tf ].new };

sub BBTrue_{bbb true}
sub BBFalse_{bbb false}

my BoolBB \BBTrue = bbb true;
my BoolBB \BBFalse = bbb false;

my BoolBB \trueBB = BBTrue;
my BoolBB \falseBB = BBFalse; 

my BoolBB \trueBB_ = BBTrue_;
my BoolBB \falseBB_ = BBFalse_; 

# Turn the BB bool into an actual bool
sub bool(BoolBB \b --> Bool) { 
    b.unBoolBB( True,False); 
}

say bool BBTrue_;
say bool BBFalse_;

say bool BBTrue;
say bool BBFalse;
say bool trueBB;
say bool falseBB;

say  BBTrue_.bool_; # => True
say  BBFalse_.bool_; # => False


sub boolBB (\tf){ tf ?? BBTrue !! BBFalse }


say bool boolBB( bool BBTrue);
say bool boolBB( bool BBFalse);

say boolBB(True).raku;
say boolBB(False).raku;

# The Maybe type
say "\nMaybe:\n";

role MayBB_[ &mb ] {#:((Any --> Any),(--> Any) --> Any)
    # has $.unMayBB = mb; 
    #:: forall a .  
    #(b -> a) -- Justgit  a 
    #-> a -- Nothing 
    #-> a
    method unMayBB(&j:(Any --> Any),&n:(-->Any) --> Any) {
        mb(&j,&n);
    }
}

role MayBB[ &mb ] {
    method unMayBB(&j:(Any --> Any),Any \n --> Any) {
        mb(&j,n);
    }
}

# selectors
sub bbj( \x ) { -> &j:(Any --> Any), Any \n --> Any { &j(x)} }
sub bbn { -> &j:(Any --> Any),Any \n --> Any {n} }

# wrapper for the role constructor
sub mbb (&jm --> MayBB) {#:((Any --> Any),(--> Any) --> Any)
    MayBB[ &jm ].new;
}

# final type constructors
sub Just(\v) {mbb( bbj( v) )}
sub Nothing {mbb( bbn )}

sub testBB(MayBB \mb --> Str) {
    mb.unMayBB( sub (Any \x --> Any) { ''~x },  "NaN" );
}

my MayBB \mbb = Just 42;
my MayBB \mbbn = Nothing;

say testBB mbb ;
say testBB mbbn;

my Junction \mbbj = Just (41|42|43);
say  so (42 == testBB mbbj);

# A pair, the simplest product type
say "\nPair:\n";

role PairBB[ \p ] {
    has $.unPairBB = p; #:: forall a . (t1 -> t2 -> a) -> a
    #:(Any,Any --> Any)
    method unPairBB_(Callable \p_  --> Any) {
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
say bbp.WHAT;

my \bbp2 = pair fst( bbp)+1,"forty-three";

say "({fst bbp},{snd bbp})";
say "({fst bbp2},{snd bbp2})";

say "\nJunctions\n";
my $sv = "forty-two-three";
my Junction \bbpj = pair (42|43),$sv;

say fst bbpj ;
my $sv2 = snd bbpj ;
say so $sv2 eq $sv;

my \bbpmj = pair 42,("forty-two"|"forty-three");
say bbpmj.WHAT;
#my Int \fst_val = fst bbpmj;
say (fst bbpmj).WHAT ;
say (snd bbpmj).WHAT ;


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
sub _add( Array[TermBB] \ts --> TermBB) {
    TermBB[  sub (\v, \c, \n, \p, \a, \m) { 
        a.( map {.unTermBB( v, c, n, p, a, m )}, ts )
    }
    ].new;
}
sub _mult( Array[TermBB] \ts --> TermBB) { 
    TermBB[  sub (\v, \c, \n, \p, \a, \m) { 
        m.( map {.unTermBB( v, c, n, p, a, m )}, ts ) 
        # @ts )
    }
    ].new;
}

# ::T does not work: Died with X::TypeCheck::Assignment
# \T does work but
# --> Array[T] is broken: Type check failed for return value; expected Array[Mu] but got Array[TermBB] (Array[TermBB].new(TermBB[Sub].new,...)
sub typed-map (\T,\lst,&f) { #  --> Array[T] 
    Array[T].new(map {f($_) }, |lst )
}

# Pretty-print a Term 
multi sub ppTerm(Var \t) { t.var }
multi sub ppTerm(Par \c) { c.par }
multi sub ppTerm(Const \n) { "{n.const}" }
multi sub ppTerm(Pow \pw){ ppTerm(pw.term) ~ '^' ~ "{pw.exp}" }
multi sub ppTerm(Add \t) { 
    my @pts = map {ppTerm($_)}, |t.terms;
    "("~join( " + ", @pts)~")"
}
multi sub ppTerm(Mult \t){ 
    my @pts = map {ppTerm($_)}, |t.terms;
    join( " * ", @pts)
}

# Evaluate a Term 
multi sub evalTerm(%vars,  %pars, Var \t) { %vars{t.var} }
multi sub evalTerm(%vars,  %pars,Par \c) { %pars{c.par} }
multi sub evalTerm(%vars,  %pars,Const \n) { n.const }
multi sub evalTerm(%vars,  %pars,Pow \pw){ 
    evalTerm(%vars,  %pars,pw.term) ** pw.exp 
}
multi sub evalTerm(%vars,  %pars,Add \t) { 
    my @pts = map {evalTerm(%vars,  %pars,$_)}, |t.terms;
    [+] @pts
}
multi sub evalTerm(%vars,  %pars,Mult \t){ 
    my @pts = map {evalTerm(%vars,  %pars,$_)}, |t.terms;
    [*] @pts
}

# Evaluate a Term 
sub evalTerm_(%vars,  %pars, Term \t) {
    given t {
        when Var { %vars{t.var} }
        when Par { %pars{t.par} }
        when Const { t.const }
        when Pow { evalTerm(%vars,  %pars,t.term) ** t.exp }
        when Add {
            my @pts = map {evalTerm(%vars,  %pars,$_)}, |t.terms;
            [+] @pts
        }
        when Mult { 
            my @pts = map {evalTerm(%vars,  %pars,$_)}, |t.terms;
            [*] @pts
        }
    }
}

# Turn a Term into a BB Term
multi sub termToBB(Var \t) { _var(t.var)}
multi sub termToBB(Par \c) { _par( c.par)}
multi sub termToBB(Const \n) {_cons(n.const)}
multi sub termToBB(Pow \pw){ _pow( termToBB(pw.term), pw.exp)}
multi sub termToBB(Add \t){ _add( typed-map( TermBB, t.terms, &termToBB ))}
multi sub termToBB(Mult \t){ _mult( typed-map(TermBB, t.terms, &termToBB ))}

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
            my \p = 
        reduce { [ $^a[0] + $^b[0], $^a[1] ~ " + " ~ $^b[1]] }, ts[0],  |ts[1..*];
        [ p[0], "("~p[1]~")" ]; 
        }, 
        -> \ts { reduce { [ $^a[0] * $^b[0], $^a[1] ~ " * " ~ $^b[1]] }, ts[0],  |ts[1..*]}
    )
}

say ppTerm(qterm);
say ppTermBB( qtermbb);
say evalTerm(
    {"x" => 2}, {"a" =>2,"b"=>3,"c"=>4},  qterm 
);
say evalTermBB(
    {"x" => 2}, {"a" =>2,"b"=>3,"c"=>4},  qtermbb
);
say evalAndppTermBB(
    {"x" => 2}, {"a" =>2,"b"=>3,"c"=>4},  qtermbb
);
sub toTerm(TermBB \t --> Term){ 
        sub var( \x ) { Var[x].new }
        sub par( \x ) { Par[x].new }
        sub const( $x ) { Const[$x].new }
        sub pow( \t, $m ) { Pow[ t, $m].new } 
        sub add( \ts ) { Add[ Array[Term].new(ts) ].new }
        sub mult( \ts ) { Mult[ Array[Term].new(ts) ].new }
        t.unTermBB( &var, &par, &const, &pow, &add, &mult);
}

say toTerm(qtermbb).raku;


my \qtermbbb = _add(
    Array[TermBB].new(
    _mult( 
        Array[TermBB].new(
        _par( "a"), 
        _pow( _var( "x"), 2) 
        )
        ),
    _mult(
        Array[TermBB].new(
            _par( "b"), 
            _var( "x")
            ) 
        ),
    _par( "c")
    )
    );
    
say ppTermBB( qtermbbb);

# This is for parsing into AST, the link between Term and the TaggedEntry
role TaggedEntry {}
role Val[Str @v] does TaggedEntry {
	has Str @.val=@v;
} 
# valmap :: [(String,TaggedEntry)]
role ValMap [  @vm] does TaggedEntry { #String \k, TaggedEntry \te,
	has @.valmap = @vm; 
}
multi sub taggedEntryToTerm (Var ,\val_strs) { Var[ val_strs.val.head].new }
multi sub taggedEntryToTerm (Par ,\par_strs) { Par[par_strs.val.head].new }
multi sub taggedEntryToTerm (Const ,\const_strs) {Const[ Int(const_strs.val.head)].new } 
# Pow => { }
# multi sub taggedEntryToTerm (Pow , ValMap [t1,(_,Val [v2])]) { Pow[ taggedEntryToTerm(...,....), Int(...)].new}        
# multi sub taggedEntryToTerm (Add , ValMap hmap) = Add $ map taggedEntryToTerm hmap
# multi sub taggedEntryToTerm (Mult , ValMap hmap) = Mult $ map taggedEntryToTerm hmap
my Str @val_strs = "42";
my \v = taggedEntryToTerm(Const, Val[@val_strs].new);
say v.raku; 
