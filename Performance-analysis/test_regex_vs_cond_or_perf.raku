use v6;
constant CASE=@*ARGS[0];
constant NITERS = 1000_000;

my @strs=(
    'READ( 1, 2, ERR=8, END=9, IOSTAT=N ) X, Y',
    'CLOSE( [ UNIT=] u [, STATUS= sta] [, IOSTAT= ios] [, ERR= s ] )',
    'WRITE( 1, REC=3, IOSTAT=N, ERR=8 ) V'
);
 my @hits=();
for 1..NITERS {
    @hits=();
    for @strs -> $str {
if (CASE==0) {
        # perl 1.360s 
        # python 2.3s
        # raku
        # with (...)        
        # real	0m43.745s
        # user	0m43.853s
        # sys	0m0.088s
        # with [...]
        # real	0m34.890s
        # user	0m34.985s
        # sys	0m0.104s

            if ($str ~~ /$<m> = [READ|ACCEPT|OPEN|CLOSE|PRINT|WRITE]/) {
                push @hits, $<m>.Str;#>
                # say $<m>.Str;#>
                # exit;
            }
} elsif (CASE==1) {
            # perl
            # with (?: ... ) 1.264 s 
            # without grouping 1.264 s
            # python 2.3s
            # raku
            # real	0m21.897s
            # user	0m22.016s
            # sys	0m0.056s

            if ($str ~~ /READ|ACCEPT|OPEN|CLOSE|PRINT|WRITE/) {
                push @hits, $/.Str;
            }
        
} elsif (CASE==2) {
            # perl
        # 1.6s
        # python 6 s
        # raku
        # with (...) I gave up after 5 minutes
        # with [...]
        # real	2m33.938s
        # user	2m33.726s
        # sys	0m0.168s

            if (
                $str~~/$<m> = [READ]/
                || $str~~/$<m> = [ACCEPT]/
                || $str~~/$<m> = [OPEN]/
                || $str~~/$<m> = [CLOSE]/
                || $str~~/$<m> = [PRINT]/
                || $str~~/$<m> = [WRITE]/
                    ) {
                        # say $<m>.Str;#>
                        # exit;
                push @hits, $<m>.Str;#>
            }
} elsif (CASE==3) {
            # say 'HERE';
            # perl 1.2s
            # python 5.9s
            # raku
            # real	1m8.407s
            # user	1m8.490s
            # sys	0m0.104s
            
            if (
                $str~~/READ/
                || $str~~/ACCEPT/
                || $str~~/OPEN/
                || $str~~/CLOSE/
                || $str~~/PRINT/
                || $str~~/WRITE/
                    ) {
                push @hits, $/.Str;
            }
        
    
}}
}
say @hits.raku;    

