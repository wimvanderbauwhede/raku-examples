#!/usr/bin/env perl
use v5.28;
use strict;
use warnings;

my $test_case = $ARGV[0];
my $ver_start = $ARGV[1];
my $ver_stop = $ARGV[2];

my $ext = $test_case;
$ext =~s/^.+\.//;

my %ext2lang = (
    raku => 'raku -I.',
    pl => 'perl',
    py => 'python3'
);

my $nruns = 5;

my $lang = $ext2lang{$ext};

#  %Uuser %Ssystem %Eelapsed %PCPU (%Xtext+%Ddata %Mmax)k
#  %Iinputs+%Ooutputs (%Fmajor+%Rminor)pagefaults %Wswaps
my @times_for_vers=();        
say "TEST: $test_case";
for my $ver ($ver_start .. $ver_stop) {
    say "VER $ver";
my $time_ver=0;
for my $run (1 .. $nruns) {
    print  "\tRUN $run\t";
my $res = `TIME='user:%U' time $lang $test_case $ver 2>&1`;
chomp $res;
$res=~s/^.*user://s;
say $res;
$time_ver+=$res;
}
$time_ver/=$nruns;
say "AVG TIME: $time_ver";
$times_for_vers[$ver]=$time_ver;
}

for my $ver ($ver_start .. $ver_stop) {
    say $times_for_vers[$ver];
}
