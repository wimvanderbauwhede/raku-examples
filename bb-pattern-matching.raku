use v6;

my \id = ->\x {x}
my \_ = -> {}

role TermBB[&f] {
    has $.alt;
    method unTermBB(
        &var, &par, &const, &pow, &add, &mult 
    ) {
        f(&var,&par,&const,&pow,&add,&mult);
    }
}

my &VarBB = sub (\s) { 
    my $caller = callframe(0).code;
    TermBB[ 
        sub (\v, \c, \n, \p, \a, \m) { v.(s) }
    ].new( alt => $caller);
}

my &ParBB = sub (\s) { 
    my $caller = callframe(0).code;
    TermBB[ 
        sub (\v, \c, \n, \p, \a, \m) { c.(s) }
    ].new( alt => $caller);
}


my $v = VarBB('test');

if ($v.alt ~~ &VarBB ) {
	say $v.unTermBB(
        id,
        _,
        _,
        _,
        _,
        _
    )
}

multi sub match-alts ($v where {$v.alt ~~ &VarBB}) {
    say 'Yay!'
}
multi sub match-alts ($v
#  where {$v.alt ~~ &ParBB}
 ) {
    say 'ok'
}

match-alts($v);