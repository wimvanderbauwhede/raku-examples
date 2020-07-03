use v6;

role Either[::a,::b] { }
role Left[::a \l,::b] does Either[a,b] { 
    has a $.left = l;
}
role Right[::a,::b \r] does Either[a,b] { 
    has b $.right = r;
}

sub small_int (Int $m --> Either[Int,Str]) {
    if $m < 10 {
        Left[$m,Str].new
    } else {
        Right[Int,"$m"].new
    }
}

multi sub test (Left[Int,Str] $v) { say 'Left: '~$v.left }
multi sub test (Right[Int,Str] $v) {say 'Right: '~$v.right }

my $n = small_int(4); # Left
my $m = small_int(12); # Right

say $n;
say $m;
#.raku;
#say $m.just;

test($n);
test($m);

my Either[Int,Str] \iv = Left[ 42, Str].new;
my Either[Int,Str] \sv = Right[Int, 'forty-two'].new;
say iv;
say sv;
test(iv);
test(sv);

#multi sub par_test (::a, ::b, Left[a,b] $v) { say 'Left: '~$v.left }
#multi sub par_test (::a,::b,Right[a,b] $v) {say 'Right: '~$v.right }

#par_test(Int,Str,$n);
#par_test(Int,Str,$m);

