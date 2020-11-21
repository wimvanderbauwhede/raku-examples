use v6;

constant VER=@*ARGS[0];
constant NITERS = 100_000;

for 1 .. NITERS {
my @strs = '3.1415','1e-7','2.e4','1.d+8','11.22q-33.4', '42.eq.7188+v', '5+2', 'var';
for @strs -> $str_ {    
my $str = $str_;
my $real_const_str='';
if VER==1 {
# real    0m5.663s
# user    0m5.884s
# sys     0m0.036s

    my $mant='';
    my $sep='';
    my $sgn='';
    my $exp='';

    my $h =$str.substr(0,1);
    my $idx=0;
    while '0' le $h le '9' or $h eq '.' {
        $mant ~=$h;
        $h =$str.substr(++$idx,1);
    }
    $str .= substr($idx);

    # This is the above wrapped in a function, it takes 9.9 s
    # ($str,$mant) = substr-pattern($str, { '0' le $_ le '9' or $_ eq '.'});
    # my $has_dot = index($mant,'.').Bool;
    
    # This one, without the $has_dot check, take 8s
    # ($str,$mant) = parse-rat($str);
    # my $h =$str.substr(0,1);
    # say "$str;$mant;"~$has_dot;


    if !$mant {
        # say "No match: $str";
    } 
    if not ($mant.ends-with('.') and $str.starts-with('eq',:i)) { 
        # if $h eq 'e' or $h eq 'd' or $h eq 'q' {
        if $h eq 'e' | 'd' | 'q' {

            $sep = $h;
            my $idx=1;
            $h =$str.substr(1,1);
            # $str .= substr(1);
            # $h =$str.substr(0,1);
            if $h eq '-' or $h eq '+' {
                ++$idx;
                $sgn = $h;
                # $str .= substr(1);
                $h =$str.substr($idx,1);
            }
            while '0' le $h le '9' {
                ++$idx;
                $exp~=$h;
                # $str .= substr(1);
                $h =$str.substr($idx,1);
            }
            $str .= substr($idx);
        # so we have $mant $sep $sgn $exp
            # say "$mant$sep$sgn$exp";
            $real_const_str="$mant$sep$sgn$exp";

        } elsif index($mant,'.').Bool {
        # means $h is no more part of the number, emit the $mant only
            # say $mant;
            $real_const_str=$mant;
        }
        else { # No dot and no sep, so an integer
            # $str="$mant$str";        
            # say "No match: $mant;$str";
            $str="$mant$str";    
        }
    } else { # .eq.
        $str="$mant$str";        
        # say "No match: $str";
    }
} 
elsif VER==0 {
# real    0m34.923s
# user    0m35.042s
# sys     0m0.088s    
        if (                    	
            (
                !($str~~rx:i/^\d+\.eq/) and
                $str~~s:i/^([\d*\.\d*][[e|d|q][\-|\+]?\d+]?)//        
            )        	
            or 
            $str~~s:i/^(\d*[e|d|q][\-|\+]?\d+)//
        ) {
            $real_const_str=$/.Str;
            # say $real_const_str;
        } 
        # else {
        #     say "No match: $str";
        # }
} # VER


} # for
# exit;
}


sub substr-pattern($str, &patt) {
    my $h =$str.substr(0,1);
    my $idx=0;
    my $match='';
    while &patt($h) {
        $match ~= $h;
        $h = $str.substr(++$idx,1);
    }
    if $match.Bool {
    ($str.substr($idx),$match);
    } else {
        ($str,'');
    }
}

sub parse-rat(\str_) {
    my $h =str_.substr(0,1);
    # my $has_dot = False;
    my $idx=0;
    my $match='';
    while '0' le $h le '9' or $h eq '.' {
        # say "W$h => $has_dot";
        # $has_dot=$h eq '.' if not $has_dot;
        $match ~=$h;
        # $str .= substr(1);
        $h =str_.substr(++$idx,1);
    }
    # my \has_dot = False;#index($match,'.').Bool;
    # if $match.Bool 
    (str_.substr($idx),$match);
    # } else {
        # ($str,'',False);
    # }
}

sub parse-num (\str_) {}
sub parse-alpha (\str_) {}
sub parse-word (\str_) {}
sub parse-identifier (\str_) {}