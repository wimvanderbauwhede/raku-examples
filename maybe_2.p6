use v6;

role Maybe[::a] { }
role Nothing[::a] does Maybe[a] { }
role Just[::a $v] does Maybe[a] { 
    has a $.just=$v;
}

sub small_int (Int $m --> Maybe[Int]) {
    if $m < 10 {
        Just[$m].new
    } else {
        Nothing[Int].new
    }
}

multi sub test (Nothing) { say 'Failed' }
multi sub test (Just[Int] $v) {say 'Passed with '~$v.just }

my $n = small_int(4); # Nothing
my $m = small_int(12); # Just 12

say $n;
say $m;
#.raku;
#say $m.just;

test($n);
test($m);


