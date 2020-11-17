#!/usr/bin/env perl
use v5.28;
use strict;
use warnings;
use Data::Dumper;

if (1) {
if (1) {
if (1) {
    # 2.6 s/1.5s 
    my @res=();
my @src=();

for my $elt  (1..10_000_000) {
    push @src, $elt;
}

for my $elt  (@src) {
    push @res, 2*$elt+1;
}

} else {
    # 3.3s/2.0s 
my @src = map {$_} (1 .. 10_000_000);
my @res = map {2*$_+1} @src;

}
} else {
    if (1) {
        # 3.8s/2.1s
        my @res=();
        my @src=();

        for my $idx  (0..10_000_000-1) {
            my $elt=$idx+1;
            $src[$idx] = $elt;
        }

        for my $idx  (0..10_000_000-1) {
            my $elt=$src[$idx];
            $res[$idx] = 2*$elt+1;
        }
    } else {
        # 4.4s/2.5
        my @res=();
        my @src=();
        #my $idx=0;
        for (my $idx=0;$idx<10_000_000;++$idx) {
            my $elt=$idx+1;
            $src[$idx] = $elt;
        }
        #   $idx=0;
        for (my $idx=0;$idx<10_000_000;++$idx) {
            my $elt=$src[$idx];
            $res[$idx] = 2*$elt+1;
        }
    }
}
} else {
# 2.5s/1.46s 
my @src = ();
my @res=();
push @src, $_ for 1 .. 10_000_000;
push @res, 2*$_+1 for @src;

}
