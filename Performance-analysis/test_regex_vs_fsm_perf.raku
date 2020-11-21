use v6;

constant VER=@*ARGS[0];
constant NITERS = 100_000;

my $str='This means we need a stack per type of operation and run until the end of the expression';

my @chrs =  $str.comb;#split('',$str); # No advantage in making this a List or Array
# my \chrs__ = $str.comb; # SLOW
# say chrs_.raku;die;
#say @chrs;
#exit;
# The regex version is 1.45s, the other version 3.25s (mean over 10 runs)

for 1 .. NITERS -> $ct {
# my \chrs_=chrs__.cache;
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
        push @words, $word;
        # say @words;
        # exit;
} elsif VER==10 {     # neat but way too slow!    
        my \res = reduce(
        -> \acc, \c { 
            if (c ne ' ') {
                acc[0],acc[1] ~ c;
            } else {
                ( |acc[0], acc[1] ),'';
            }
        }, ((),''), |@chrs);
        my @words = |res[0],res[1];
        # say @words;
        # exit;        
} elsif VER==11 {     
        my $str='This means we need a stack per type of operation and run until the end of the expression';
        # my $word='';
        # while $str.Bool {   
        while my $idx=$str.index( ' ' ) {
        # while $str.Bool and not $str.starts-with( ' ' ) {
            # $word ~= $str.substr(0,1);
            # $str.=substr(1);
            push @words, $str.substr(0,$idx);
            $str .= substr($idx+1);
            # say $str;
            # say $word;
        }
        push @words, $str;
        # $str .= trim-leading;
                # push @words, $word;# if $word.Bool;
                # $word='';                
        # }
        # say @words;
        # exit;         
} elsif VER==1 {  
        my @chrs_ = @chrs;
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
        # say @words;
        # exit;        
} elsif VER==2 {
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
        # say @words;
        # exit;      
} elsif VER==3 {
        my $word='';

} elsif VER==4 {
        my @chrs_ =  @chrs;
        my $word='';      

} elsif VER==5 {
            my $str='This means we need a stack per type of operation and run until the end of the expression';
    
#    say @words.raku if $ct==2;  
    # exit;
}

}

