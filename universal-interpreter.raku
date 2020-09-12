use v6;

=begin pod
In this article, I want to explain a technique called [Böhm-Berarducci encoding](http://okmij.org/ftp/tagless-final/course/Boehm-Berarducci.html) of algebraic data types. 
This is the final article in a series about functional programming and in particular algebraic data types and function types in [Raku](https://raku.org/).

XXX boilerplate about what the reader needs to know XXX


The link above is to Oleg Kiselyov's explanation, which makes interesting reading but is not required for what follows. Oleg says:

"Boehm-Berarducci's paper has many great insights. Alas, the generality of the presentation makes the paper very hard to understand. It has a Zen-like quality: it is incomprehensible unless you already know its results."

For the purpose of this article, it is sufficient to say that the Böhm-Berarducci encoding is a way to encode an algebraic data type as a function type. The function encoding the data type becomes a "universal interpreter". 
As a result, it is easy to create various interpreters for ADTs. 

I will illustrate this with a few trivial examples and then use it to construct a pretty printer and evaluator for a polynomial expression.

In my [previous post]() I showed how you can use Raku's _role_ feature to implement algebraic data types. I gave the example of 
`OpinionatedBool`:

role OpinionatedBool {}
role AbsolutelyTrue does OpinionatedBool {}
role TotallyFalse does OpinionatedBool {}

The basic idea behind the Böhm-Berarducci (BB) encoding is to create a type which represents a function with an argument for every alternative in a sum type.
Every argument is itself a function which takes as arguments the arguments of each alternative, and returns a type. However, the return type is polymorphic, so we decide what it will be when we use the BB type. 

For example, if we have a sum type with three alternatives `A1`, A2 and A3: 

    A1 Int | A2 String | A3

then the corresponding BB type will be

    -- A1
    (Int -> a) -> 
    -- A2
    (String -> a) -> 
    -- A3
    (a) -> 
    -- The return type
    a

I have put parentheses to show which part of the type is the function type corresponding to each alterative. 
Because the constructor for `A3` takes no arguments, the corresponding function signature in the BB encoding is simply `a`: 
a function wich takes no arguments and returns something of type `a`.
The final `a` is the return value of the top-level function. 

In Raku, the signature of our `OpinionatedBool` would be 

    my $sig = :(Sub, Sub --> Any)

which only shows that this is a sum type with two alternatives. 

In Haskell, the type declaration lists the types of all the arguments:

    newtype OpinionatedBoolBB b = OpinionatedBoolBB {
        unBoolBB :: forall a . 
        a -- True
        -> a -- False
        -> a
    }

which shows that the two constructors don't take any arguments.

In Raku, the type system is less expressive, but it is powerful enough to implement the BB type.
We can either implement it very simply as a role with a single accessor:

    role BoolBB[\b] {
        has $.unBoolBB = b;
    }

Note that this is so general that _any_ BB type would have this representation, so there is no type safety.

We can be a bit more explicit by using a method with a typed signature:

    role BoolBB[Block \b] {
        method unBoolBB(Block \t, Block \f --> Any) {
            b.(t,f)
        }
    }
    
    
    role BoolBB_BETTER[&b] {
        method unBoolBB(&t:(--> Any), &f:(--> Any) --> Any) {
            b.(t,f)
        }
    }
    

XXX needs rewrite. Why not 
Although we don't know the function types, at least we know the number of arguments in the function encoding the type, and that each of these arguments is a function.
I use the `Block` type rather than `Sub` because I like to use the "pointy block" syntax for anonymous subroutines. 
In Raku, a `Sub` inherits from `Routine` which inherits from `Block`.

=end pod

# Boolean, the simplest sum type

say "\nBool:\n";

role BoolBB[&b] {
    # has $.unBoolBB = b;
    method unBoolBB(Any \t, Any \f --> Any) {
        b(t,f)
    }
}

# role BoolBB[&b] {
#     method unBoolBB(&t:(--> Any), &f:(--> Any) --> Any) {
#         b(&t,&f);
#     }
# }

# my \true  = -> \t,\f { t }
# my \false = sub (\t,\f) { f }
my \true  = -> Any \t, Any \f --> Any { t }
my \false = sub (Any \t,Any \f --> Any ) { f }

# Make a BB bool
sub bbb(\tf --> BoolBB) { BoolBB[ tf ].new };

my BoolBB \BBTrue = bbb true;
my BoolBB \BBFalse = bbb false;

my BoolBB \trueBB = BBTrue;
my BoolBB \falseBB = BBFalse; 

# Turn the BB bool into an actual bool
sub bool(BoolBB \b --> Bool) { 
    b.unBoolBB( True,False); 
    #    b.unBoolBB.( True, False) 
}

say bool BBTrue;
say bool BBFalse;
say bool trueBB;
say bool falseBB;

sub boolBB (\tf){ tf ?? BBTrue !! BBFalse }


say bool boolBB( bool BBTrue);
say bool boolBB( bool BBFalse);

say boolBB(True).raku;
say boolBB(False).raku;

# The Maybe type
say "\nMaybe:\n";

role MayBB_OFF[ Block \mb ] {#:((Any --> Any),(--> Any) --> Any)
    has $.unMayBB = mb; 
    #:: forall a .  
    #(b -> a) -- Justgit  a 
    #-> a -- Nothing 
    #-> a
   # method unMayBB_(Block \j:(Any --> Any),Block \n:(--> Any) --> Any) {
    method unMayBB_(Block \j,Block \n --> Any) {
        mb.(j,n);
    }
}

role MayBB_[ &mb ] {#:((Any --> Any),(--> Any) --> Any)
    # has $.unMayBB = mb; 
    #:: forall a .  
    #(b -> a) -- Justgit  a 
    #-> a -- Nothing 
    #-> a
   # method unMayBB_(Block \j:(Any --> Any),Block \n:(--> Any) --> Any) {
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
    #mb.unMayBB.( -> $x { "$x" }, -> { "NaN"} );
    mb.unMayBB( sub (Any \x --> Any) { ''~x },  "NaN" );
}

my MayBB \mbb = Just 42;
my MayBB \mbbn = Nothing;

say testBB mbb ;
say testBB mbbn;

# # selectors
# sub bbj( \x ) { -> &j:(Any --> Any),&n:(-->Any) --> Any { &j(x)} }
# sub bbn { -> &j:(Any --> Any),&n:(-->Any) --> Any {n()} }

# # wrapper for the role constructor
# sub mbb (&jm) {#:((Any --> Any),(--> Any) --> Any)
#     MayBB[ &jm ].new;
# }

# # final type constructors
# sub Just(\v) {mbb( bbj( v) )}
# sub Nothing {mbb( bbn )}

# sub testBB(MayBB \mb --> Str) {
#     #mb.unMayBB.( -> $x { "$x" }, -> { "NaN"} );
#     mb.unMayBB( sub (Any \x --> Any) { ''~x }, -> --> Any { "NaN"} );
# }

# my MayBB \mbb = Just 42;
# my MayBB \mbbn = Nothing;

# say testBB mbb ;
# say testBB mbbn;

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

say "({fst bbp},{snd bbp})";

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
    # has $.unTermBB = f; This is OK but tells us nothing
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
        a.( map {.unTermBB( v, c, n, p, a, m )}, ts )
    }
    ].new;
}
# But this works as well
sub _mult(  @ts --> TermBB) {
    TermBB[  sub (\v, \c, \n, \p, \a, \m) { 
        m.( map {.unTermBB( v, c, n, p, a, m )}, @ts )
    }
    ].new;
}

sub typed-map (\T,\lst,&f) {
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
multi sub evalTerm(%vars,  %pars,Pow \pw){ evalTerm(%vars,  %pars,pw.term) ** pw.exp }
multi sub evalTerm(%vars,  %pars,Add \t) { 
    my @pts = map {evalTerm(%vars,  %pars,$_)}, |t.terms;
    [+] @pts
}
multi sub evalTerm(%vars,  %pars,Mult \t){ 
    my @pts = map {evalTerm(%vars,  %pars,$_)}, |t.terms;
    [*] @pts
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
# multi sub taggedEntryToTerm (Pow , ValMap [t1,(_,Val [v2])]) { Pow[ taggedEntryToTerm(...,....), Int(...)].new}        
# multi sub taggedEntryToTerm (Add , ValMap hmap) = Add $ map taggedEntryToTerm hmap
# multi sub taggedEntryToTerm (Mult , ValMap hmap) = Mult $ map taggedEntryToTerm hmap
my Str @val_strs = "42";
my \v = taggedEntryToTerm(Const, Val[@val_strs].new);
say v.raku; 
