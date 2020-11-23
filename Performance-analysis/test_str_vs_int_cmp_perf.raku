use v6;

constant VER=@*ARGS[0].Num;
constant NITERS = 10_000_000;


#perl, int
#real    0m2.973s
#user    0m2.969s
#sys 0m0.004s

#perl, str
#real    0m3.347s
#user    0m3.346s
#sys 0m0.001s

#raku, int
#real    0m23.858s
#user    0m23.872s
#sys 0m0.036s

#raku, int
#real    0m23.858s
#user    0m23.872s
#sys 0m0.036s
#raku, int, sigilless
# real	0m24.062s
# user	0m24.083s
# sys	0m0.044s
#raku, Int, sigilless
# real	0m23.624s
# user	0m23.676s
# sys	0m0.024s

# raku, explixit 'int' type or 'Int' type
# real	0m22.627s
# user	0m22.641s
# sys	0m0.052s

#raku, str
#real    0m23.818s
#user    0m23.827s
#sys 0m0.044s

#raku, no cond
# real	0m21.673s
# user	0m21.700s
# sys	0m0.036s

# my $str = '*';
# my $c=42;
# my Int \cc = 42;
my $count=0;
# int: 4.6 string: 5.3
if VER==1 { # 7.3 - 5.3 = 2 s net
    for 1 .. NITERS -> $i {
        my $str = chr($i % 43);
        # say $str;
        if $str eq '*' {
            $count+=$i;
        }
    }
} 
elsif VER==2 { # 3.3 - 3.1 = 0.3
    for 1..NITERS -> $i {
        my \cc = $i % 43;
        if cc == 42 {
            $count+=$i;
        }
    }
# } elsif VER==3 { # 4.6-3.5 = 1.1
#     for 1..NITERS -> $i {
#         my $c = $i % 43;
#         if $c == 42 {
#             $count+=$i;
#         }
#     }
# } elsif VER==4 { # 3.2 s
#     for 1..NITERS -> $i {
#         $count+=$i;
#     }
# } elsif VER==5 { # 5.3
#     for 1..NITERS -> $i {
#         my $str = chr($i % 43);
#     }
} elsif VER==6 { # 3.1
    for 1..NITERS -> $i {
        my \cc = $i % 43;
    }
} elsif VER==7 { # 3.5
    for 1..NITERS -> $i {
        my $c = $i % 43;
    }
}
say $count;
