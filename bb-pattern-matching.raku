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

sub VarBB(\s) { 
    my $caller = callframe(0).code;
    TermBB[ 
        sub (\v, \c, \n, \p, \a, \m) { v.(s) }
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
