use v6;

constant VER=@*ARGS[0];
constant NITERS = 100_000;

    my @strs = 
    '3.1415', 
    '1e-7',
    '2.e4',
    '1.d+8',
    '11.22q-33.4', 
    '42.eq.7188+v', 
    '5+2', 
    'var';

for 1 .. NITERS {
my $count=0;
for @strs -> $str_ {    
my $str=$str_;
if VER==0 {
# real	0m32.630s
# user	0m32.768s
# sys	0m0.036s

    if $str.starts-with( '1' | '2' ) {
        $count++;
    } elsif $str.starts-with('v') {
        $count++;
    } elsif $str.ends-with('v') {
        $count++;
    } else {
        $count++;
    }

} elsif VER==1 {
# real	0m36.806s
# user	0m36.938s
# sys	0m0.044s

    given $str {
        when .starts-with( '1' | '2' ) {
            $count++;
        }
        when .starts-with('v') {
            $count++;
        } 
        when .ends-with('v') {
            $count++;
        } 
        default {
            $count++;
        }
    }

} # VER
} # @strs
} # NITERS