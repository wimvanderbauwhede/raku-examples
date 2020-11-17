#!/usr/bin/perl
use strict;
use warnings;
use v5.30;

my $VER=$ARGV[0];
# substr
# real	0m2.961s
# user	0m2.961s
# sys	0m0.000s
# regex
# real	0m3.221s
# user	0m3.221s
# sys	0m0.000s

# strip leading spaces
#substr
# real	0m5.020s
# user	0m5.019s
# sys	0m0.000s

# regex
# real	0m3.425s
# user	0m3.417s
# sys	0m0.004s



# say '<'~$str~'>';
my $count =0;
my $str = '    no content';
if ($VER<=3) { 

for (1 .. 10_000_000 ){
 $str = '    no content';
if ($VER==0) {
while (substr($str,0,1) eq ' ') {
    $str = substr($str,1);
} 
    $count++;
} elsif ($VER==1) {
    $count++;
} elsif ($VER==2) {
    
if ($str =~ s/^\s+//) {
    $count++;
}

}
}
# say $str;
# say $count;
# exit;
} else {
for (1 .. 10_000_000) {
    # say $_;
my $str1 = '(no content)';
my $str2 = 'no (content)';
if ($VER==4)  {

$str1 = remove_leading_chars('(',$str1);
$str2 = remove_leading_chars('(',$str2);
} elsif ($VER==5) {
if (substr($str1,0,1) eq '(') {
    $str1=substr($str1,1);
    $count++;
}

if (substr($str2,0,1) eq '(') {
    $str2=substr($str2,1);
    $count++;
}
} else {
if ($str1=~ s/^\(//) {
    $count++;
}
if ($str2=~s/^\(//) {
    $count++;
}
}   
}
}
say $count;


sub remove_leading_chars {my ($cstr,$tstr) = @_;
    if (substr($tstr,0,length( $cstr)) eq $cstr) {
        return substr($tstr,length($cstr));
    } else {
        return $tstr;
    }
}
