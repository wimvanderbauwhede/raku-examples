use v6;

my \fst_ = -> \x,\y {x};
my \snd_ = -> \x,\y {y};

my sub fst (&p1) {p1(fst_)}
my sub snd (&p1) {p1(snd_)}

sub pair(\x,\y) {
    sub (&p) { sub (\v ) { p(v) }}( -> &f { f(x, y) } );
}

my Sub \p1 = pair 42,'OK';

if ( 42 == fst p1) {
    say snd p1;	
}

my Junction \p1j = pair (42|32),'OK';

if ( so 42 == fst p1j) {
    say snd p1j;	
}


