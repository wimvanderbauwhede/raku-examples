use v6;

constant VER=@*ARGS[0].Num;
constant NITERS = 2_000_000;

enum Numbers <one two three four>;
my $count=0;
if VER==1 {
for 1 .. NITERS {
    # 3.3 s
    for 1..4 -> $v {
        if $v == 1 {
            $count+=3;
        } elsif $v==3 {
            $count--
        }
    }
}
} else {
for 1 .. NITERS {
    # 5.4 s
    for one .. four -> $v {
        if $v == one {
            $count+=3;
        } elsif $v == three {
            $count--
        }
    }
}
}
say $count;