use v6;

constant CASE=@*ARGS[0];
constant NITERS = 2_000_000;
if (CASE==0) {
# 2.6 s 
    my @res=();
    my @src=();

    for 1..NITERS -> $elt {
        push @src, $elt;
    }

    for @src -> $elt {
        push @res, 2*$elt+1;
    }

} elsif (CASE==1) {
# 3.3s 
    my @src = map {$_}, 1 .. NITERS;
    my @res = map {2*$_+1}, @src;

} elsif (CASE==2) {
        # 3.8s
    my @res=();
    my @src=();

    for 0..NITERS-1 -> $idx {
        my $elt=$idx+1;
        @src[$idx] = $elt;
    }

    for 0..NITERS-1 -> $idx {
        my $elt=@src[$idx];
        @res[$idx] = 2*$elt+1;
    }
} elsif (CASE==3) {
        # 4.4s
    my @res=();
    my @src=();
    loop (my $idx=0;$idx < NITERS;++$idx) {
        my $elt=$idx+1;
        @src[$idx] = $elt;
    }
    loop (my $idx2=0;$idx2 < NITERS;++$idx2) {
        my $elt=@src[$idx2];
        @res[$idx2] = 2*$elt+1;
    }
} elsif (CASE==4) {
    # 2.5s 
    my @src = ();
    my @res=();
    push @src, $_ for 1 .. NITERS;
    push @res, 2*$_+1 for @src;
} elsif (CASE==5) {
    my @src = ($_ for 1 .. NITERS);
    my @res= (2*$_+1 for @src);
}

# 000 suffix for push
# real	0m22.814s
# user	0m22.225s
# sys	0m0.788s

# 01x suffix for list comp
# real	0m20.969s
# user	0m20.463s
# sys	0m0.740s


# 100 loop/idx
# real	1m5.340s
# user	1m4.796s
# sys	0m0.772s

# 101 for/idx

# real	0m46.769s
# user	0m46.032s
# sys	0m0.932s

# 110 map

# real	0m34.109s/32.5
# user	0m33.175s/31.7
# sys	0m1.120s

# 111 for/push
# real	0m46.713s
# user	0m46.146s
# sys	0m0.772s


