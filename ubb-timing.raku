use v6;

# No explicit typing, contrast with tbb-timing.raku

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

my $nruns=200;

# The BB encoding of Term
role TermUBB[\f] {
    method unTermUBB(
        \var,\par,\const,\pow,\add,\mult 
    ) {
        f.(var,par,const,pow,add,mult);
    }
}

# The little helpers
sub VarUBB( \s ) { 
    TermUBB[ 
        sub (\v, \c, \n, \p, \a, \m) { v.(s) }
    ].new;
    }
sub ParUBB(\s) { 
    TermUBB[ 
        sub (\v, \c, \n, \p, \a, \m) { c.(s) }
    ].new;
    }
sub ConstUBB( \i ) { 
    TermUBB[ 
        sub (\v, \c, \n, \p, \a, \m) { n.(i) }
    ].new;
    }    
sub PowUBB(  \t, \i) {
    TermUBB[  sub (\v, \c, \n, \p, \a, \m) { 
        p.( t.unTermUBB( v, c, n, p, a, m ), i);
    }
    ].new;
}
# Slurpy
sub AddUBB(  *@ts ) {
    TermUBB[  sub (\v, \c, \n, \p, \a, \m) { 
        a.( map {.unTermUBB( v, c, n, p, a, m )}, @ts )
    }
    ].new;
}
sub MultUBB(  *@ts) { 
    TermUBB[  sub (\v, \c, \n, \p, \a, \m) { 
        m.( map {.unTermUBB( v, c, n, p, a, m )}, @ts ) 
        # @ts )
    }
    ].new;
}

# A pretty-printer
sub ppTermUBB(\t){ 
        sub var( \x ) { x }
        sub par( \x ) { x }
        sub const( $x ) { "$x" }
        sub pow( \t, $m ) { t ~ "^$m" } 
        sub add( \ts ) { "("~join( " + ", ts)~")" }
        sub mult( \ts ) { join( " * ", ts) }
        t.unTermUBB( &var, &par, &const, &pow, &add, &mult);
}

# evalTermBB :: H.Map String Int -> H.Map String Int -> TermBB -> Int
sub evalTermUBB( %vars,  %pars, \t) {
    t.unTermUBB( 
        -> \x {%vars{x}}, 
        -> \x {%pars{x}},
        -> \x {x},
        -> \t,\m { t ** m},
        -> \ts { [+] ts},
        -> \ts { [*] ts}
    );
}


my @strs=();
my @vals=();
for 1 .. $nruns -> $c {
my \qtermbb1 = AddUBB(
    MultUBB( 
        ParUBB( "a"), 
        PowUBB( VarUBB( "x"), 2) 
        ),
    MultUBB(  
            ParUBB( "b"), 
            VarUBB( "x")
        ),
    ParUBB( "c")
);
#   x^3 + 1    
my \qtermbb2 = AddUBB(     
        PowUBB( VarUBB( "x"), 3), 
        ConstUBB($c)
);

#   qterm1 * qterm2    
my \qtermbb3 = MultUBB( 
     qtermbb1, qtermbb2 
);    

my $str = ppTermUBB( qtermbb3);
push @strs, $str;

 my $val = evalTermUBB(
    {"x" => 2}, {"a" =>2,"b"=>3,"c"=>4},  qtermbb3
);
push @vals, $val;

}
say @strs.elems;
say [+] @vals;
