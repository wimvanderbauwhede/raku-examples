use v6;

constant VER=@*ARGS[0].Num;
constant NITERS = 10_000_000;

my $str = lc('READ( 1, 2, ERR=8, END=9, IOSTAT=N ) X');
my %info =();   
my SetHash $infoset .= new;
if ($str~~/read/) {
    %info<ReadCall> = 1;
    $infoset<ReadCall>++;
}

my $count=0;
# my $i=1;
# perl
# no cond: 1.9s (Linux, 5.30)
# regex: 6.4s (Linux, 5.30)
# hash: 3.5s (Linux, 5.30)

# python3 v3.8.5 : 
# dict 8.5 s
# regex:
# real	0m49.012s
# user	0m49.003s
# sys	0m0.004s

#raku, hash
# real	0m41.299s
# user	0m41.379s
# sys	0m0.040s

# raku, regex (!)
# real	12m38.106s
# user	12m37.715s
# sys	0m0.448s

#raku, SetHash
# about 6 mins

    if VER==1 {
for 1..NITERS -> $i {
       if ($str~~/read/) { # super slow
        $count+=$i;
       }
}
    } elsif VER==2 {
for 1..NITERS -> $i {
        if (%info<ReadCall>:exists) {
            $count+=$i;
        }
}
   
} else {
for 1..NITERS -> $i {
        # if (%info<ReadCall>:exists) {
            $count+=$i;
        # }
}    
}
say $count;
