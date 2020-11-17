use v6;

constant VER=@*ARGS[0];
constant NITERS = 10_000_000;
# raku regex 1_000_000
# real	0m19.866s
# user	0m19.978s
# sys	0m0.040s

# raku substr 1_000_000
# real	0m1.010s
# user	0m1.078s
# sys	0m0.036s

# raku substr in function 1_000_000
# real	0m1.596s
# user	0m1.682s
# sys	0m0.032s

# raku starts-with
# real	0m0.709s
# user	0m0.805s
# sys	0m0.020s


# =========
# trim-leading
# real	0m0.544s
# user	0m0.584s
# sys	0m0.048s

# remove leading ws, substr
# real	0m2.444s
# user	0m2.573s
# sys	0m0.024s

# with an extra 80 spaces
# real	0m24.593s
# user	0m24.707s
# sys	0m0.036s


# remove leading ws, regex
# real	0m32.985s
# user	0m33.099s
# sys	0m0.020s

# with an extra 80 spaces
# real	0m46.861s
# user	0m46.957s
# sys	0m0.068s

# s///
# real	0m17.926s
# user	0m18.034s
# sys	0m0.048s

# s///, with the extra 80 spaces
# real	0m22.367s
# user	0m22.487s
# sys	0m0.048s

# say '<'~$str~'>';
my $count =0;
my $str = ' ' x 80 ~ '    no content';

if VER <= 3 {
for 1 .. NITERS {
    $str = '    no content';
if VER==0 {
    while $str.starts-with( ' ') {
        $str = substr($str,1);
    } 
    $count++;
} elsif VER==1 {
    $str .= trim-leading;
    $count++;
} elsif VER==2 {
    if ($str ~~ s/^\s+//) {
        $count++;
    }
}
}
} else {
# say $str;
# say $count;
# exit;
for 1 .. NITERS {
my $str1 = '(no content)';
my $str2 = 'no (content)';
if VER==4 {
    $str1=remove_leading_chars('(',$str1);
    $str2=remove_leading_chars('(',$str2);
    $count++;
} elsif VER==5 {
    if ($str1.starts-with('(')) {
        $str1=substr($str1,1);
        $count++;
    }
    if ($str2.starts-with('(')) {
        $str2=substr($str2,1);
        $count++;
    }
} else {

    if ($str1 ~~ s/^\(//) {
        $count++;
    }
    if ($str2 ~~ s/^\(//) {
        $count++;
    }
}

}

say $count;
}

sub remove_leading_chars ($cstr,$tstr) {
    if $tstr.starts-with($cstr) {
        substr($tstr,$cstr.chars);
    } else {
        $tstr;
    }
}
