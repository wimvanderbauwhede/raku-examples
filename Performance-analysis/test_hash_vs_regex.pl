#!/usr/bin/env perl
use v5.28;
use strict;
use warnings;


my $VER=$ARGV[0];
my $NITERS = 100_000_000;

my $str = lc('READ( 1, 2, ERR=8, END=9, IOSTAT=N ) X');
my $info={};
    if ($str=~/read/) {
$info->{'ReadCall'}=1;
}
my $count=0;
# no cond: 3.1 s (Mac) 2.2s/1.9s (Linux, 5.30)
# regex: 10.1 (Mac) 7.5s/6.4s (Linux, 5.30)
# hash: 5.6 s (Mac) 4.3s/3.46s (Linux, 5.30)
    if ($VER==1) {
for my $i (1..$NITERS) {
        if ($str=~/read/) {
            $count+=$i;
        }
}
    } else {
for my $i (1..$NITERS) {
        if (exists $info->{'ReadCall'}) {
            $count+=$i;
        }
}
    }

#say $count;
