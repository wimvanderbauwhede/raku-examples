use v6;
#use Data::Dumper;

# perl
# ver=1
# real	0m1.999s
# user	0m1.998s
# sys	0m0.000s
# ver=2
# real	0m0.783s
# user	0m0.779s
# sys	0m0.004s
#raku
#ver=1
# real	0m20.033s
# user	0m20.110s
# sys	0m0.040s
#ver=2
# real	0m9.973s
# user	0m10.094s
# sys	0m0.020s



my $str='This means we need a stack per type of operation and run until the end of the expression';

my @chrs =  $str.comb;#split('',$str);
#say @chrs;
#exit;
# The regex version is 1.45s, the other version 3.25s (mean over 10 runs)
constant VER=@*ARGS[0];
for 1 .. 1_000_000 -> $ct {

my @words=();
    if (VER==0) {
        my $word='';
        map(-> \c { 
                    if (c ne ' ') {
                $word ~= c;
            } else {
                push @words, $word;
                $word='';
            }
        }, @chrs);
        
} elsif (VER==1) {  
    my @chrs_ =  @chrs;
  my $word='';      
        while @chrs_ {
            my $chr=  shift @chrs_;
            if ($chr ne ' ') {
                $word~=$chr;
            } else {
                push @words, $word;
                $word='';
            }
        }
        push @words, $word;
        
    } elsif (VER==2) {
        my $str='This means we need a stack per type of operation and run until the end of the expression';

        while $str.Bool {
             $str ~~ s/^$<w> = [ \w+ ]//;
            if ($<w>.Bool) {
                push @words, $<w>.Str;
            }
            else {
                $str ~~s/^\s+//;
            } 
        }
    
    } elsif (VER==3) {
        my $word='';

    } elsif (VER==4) {
        my @chrs_ =  @chrs;
        my $word='';      

    } else {
            my $str='This means we need a stack per type of operation and run until the end of the expression';
    }    
#    say @words.raku if $ct==2;  
    # exit;
}
      

