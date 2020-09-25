use v6;

# Fully explicit typing, contrast with ubb-timing.raku

# [wim@hackbox raku-examples]$ time raku ubb-timing.raku 
# 200
# 390600

# real	0m3.780s
# user	0m4.279s
# sys	0m0.112s

# [wim@hackbox raku-examples]$ time raku tbb-timing.raku 
# 200
# 390600

# real	0m9.070s
# user	0m9.620s
# sys	0m0.073s

# [wim@hackbox raku-examples]$ time raku no-bb-timing.raku 
# 200
# 390600

# real	0m3.078s
# user	0m3.602s
# sys	0m0.076s

my Int $nruns= 200 ;

role TermBB[&f] {
    method unTermBB(
        &var:(Str --> Any),
        &par:(Str --> Any),
        &const:(Int --> Any),
        &pow:(Any,Int --> Any),
        &add:( Array[Any] --> Any),
        # &add:( @ --> Any),
        &mult:(Array[Any] --> Any) 
        --> Any
    ) {
        f(&var,&par,&const,&pow,&add,&mult);
    }
}

# We need this because `map` returns Seq, not Array
# ::T does not work: Died with X::TypeCheck::Assignment
# \T does work but
# --> Array[T] is broken: Type check failed for return value; expected Array[Mu] but got Array[TermBB] (Array[TermBB].new(TermBB[Sub].new,...)
sub typed-map (\T,\lst,&f) { #  --> Array[T] 
    Array[T].new(map {f($_) }, |lst )
}

# The constructors
sub VarBB(Str \s --> TermBB) { 
    TermBB[ 
        sub (\v, \c, \n, \p, \a, \m) { v.(s) }
    ].new;
    }
sub ParBB(Str \s --> TermBB) { 
    TermBB[ 
        sub (\v, \c, \n, \p, \a, \m) { c.(s) }
    ].new;
    }
sub ConstBB(Int \i --> TermBB) { 
    TermBB[ 
        sub (\v, \c, \n, \p, \a, \m) { n.(i) }
    ].new;
    }    
sub PowBB( TermBB \t, Int \i --> TermBB) {
    TermBB[  sub (\v, \c, \n, \p, \a, \m) { 
        p.( t.unTermBB( v, c, n, p, a, m ), i);
    }
    ].new;
}
sub AddBB( 
    Array[TermBB] \ts --> TermBB
    #  @ts --> TermBB
    ) {
    TermBB[  sub (\v, \c, \n, \p, \a, \m) { 
        a.( 
            # map( {.unTermBB( v, c, n, p, a, m )},@ts)
            typed-map( Any, ts, {.unTermBB( v, c, n, p, a, m )} )
        )
    }
    ].new;
}
sub MultBB(  
    Array[TermBB] \ts --> TermBB
    # @ts --> TermBB
    ) { 
    TermBB[  sub (\v, \c, \n, \p, \a, \m) { 
        m.( 
            # map( {.unTermBB( v, c, n, p, a, m )},@ts)
            typed-map( Any, ts, {.unTermBB( v, c, n, p, a, m )} )
        )
    }
    ].new;
}


# A pretty-printer
sub ppTermBB(TermBB \t --> Str){ 
        sub var(Str \x --> Any) { x }
        sub par(Str  \x --> Any) { x }
        sub const(Int $x --> Any) { "$x" }
        sub pow( Any \t, Int $m --> Any) { t ~ "^$m" } 
        sub add(Array[Any]  \ts --> Any) { "("~join( " + ", ts)~")" }
        # sub add( @ts --> Any) { "("~join( " + ", @ts)~")" }
        sub mult(Array[Any] \ts --> Any) { join( " * ", ts) }
        t.unTermBB( &var, &par, &const, &pow, &add, &mult);
}



# evalTermBB :: H.Map String Int -> H.Map String Int -> TermBB -> Int
sub evalTermBB( %vars,  %pars, \t) {
    t.unTermBB( 
        -> Str \x --> Any {%vars{x}}, 
        -> Str \x --> Any  {%pars{x}},
        -> Int \x --> Any  {x},
        -> Any \t, Int \m --> Any  { t ** m},
        -> Array[Any] \ts --> Any  { [+] ts},
        # -> @ts --> Any  { [+] @ts},
        -> Array[Any] \ts --> Any  { [*] ts}
    );
}


my Str @strs=();
my Int @vals=();
for 1 .. $nruns -> Int $c {
my TermBB \qtermbb1 = AddBB(
    Array[TermBB].new(
        # @(
    MultBB( 
        Array[TermBB].new(
        # @(
        ParBB( "a"), 
        PowBB( VarBB( "x"), 2) 
        )
        ),
    MultBB(
        Array[TermBB].new(
            # @(
            ParBB( "b"), 
            VarBB( "x")
            ) 
        ),
    ParBB( "c")
    )
    );
#   x^3 + 1    
my TermBB \qtermbb2 = AddBB( 
    Array[TermBB].new(
        # @(
        PowBB( VarBB( "x"), 3), 
        ConstBB($c)
        )
    # )
);

#   qterm1 * qterm2    
my TermBB \qtermbb3 = MultBB( 
    Array[TermBB].new(
        # @(
        qtermbb1, qtermbb2
    ));    

my Str $str = ppTermBB( qtermbb3);
push @strs, $str;

 my Int $val = evalTermBB(
    {"x" => 2}, {"a" =>2,"b"=>3,"c"=>4},  qtermbb3
);
push @vals, $val;

}
say @strs.elems;
say [+] @vals;


