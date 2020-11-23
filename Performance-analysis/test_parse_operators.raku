use v6;

constant VER=@*ARGS[0];
constant NITERS = 100_000;

for 1 .. NITERS {
my @strs = 
'+3.1415',
'-1e-7',
'**',
'*2.e4',
'// 1.d+8',
': 11.22q-33.4', 
'/42.eq.7188+v', 
'>=5+2', 
'.ge. var',
'.  le . 42'
;
for @strs -> \str_ {    
my $str = str_;
my $real_const_str='';
if VER==1 { # 7 s
    my $op=0;
    my $lev=0;
            given $str {
            when .starts-with('+')  {
                $str .= substr(1);
                $lev=4;
                #$op='+';
                $op=3;
            }
            when .starts-with('-') {
                $str .= substr(1);
                $lev=4;
                #$op='-';
                $op=4;
            }
            when .starts-with('**')  {
                $str .= substr(2);
                # We store this incorrectly left-assoc, the emitter can fix it.
                $lev=2;
                #$op='**';
                $op=8;
            } 
            when .starts-with('*')  {
                $str .= substr(1);
                $lev=3;
                #$op='*';
                $op=5;
            }
            when .starts-with('//')  {
                $str .= substr(2);
                $lev=5;
                #$op='//';
                $op=13;
            } 
            when .starts-with(':') {
                $str .= substr(1);
                $lev=5;
                #$op=':';
                $op=12;
            } 
            when .starts-with('/') {
                $str .= substr(1);
                $lev=3;
                #$op='/';
                $op=6;
            } 
            when .starts-with( '>=' ) {
                $str .= substr(2);
                $lev=6;
                #$op='>=';
                $op=20;
            }
            # Do all the ones without dots here
            when .starts-with('<') {
                $str .= substr(1);
                $lev=6;
                #$op='<';
                $op=17;
            } 
            when .starts-with('>') {
                $str .= substr(1);
                $lev=6;
                #$op='>';
                $op=18;
            } 
            when .starts-with('==') {
                $str .= substr(2);
                $lev=7;
                #$op='==';
                $op=15;
            } 
            when .starts-with('!=') {
                $str .= substr(2);
                $lev=7;
                #$op='/=';
                $op=16;
            } 
            when .starts-with('=') {
                $str .= substr(1);
                $lev=5;
                #$op='=';
                $op=9;
            } 

            when .starts-with('.') and  (.index( ' ' ) < (my $eidx = .index('.',2 ))) {
                
                # Find the keyword with spaces
                my $match = .substr(0, $eidx+1);
                # remove the spaces
                $match .= trans( ' ' => '' );
                # update the string
                $str = $match ~ .substr( $eidx+1);
                proceed;
            }

            when .starts-with( '.ge.') {
                # say 'H!';
                $str .= substr(4);
                $lev=6;
                #$op='>=';
                $op=20;
            }
            when .starts-with('.lt.') {
                $str .= substr(4);
                $lev=6;
                #$op='<';
                $op=17;
            } 
            when .starts-with('.gt.') {
                $str .= substr(4);
                $lev=6;
                #$op='>';
                $op=18;
            } 
            when .starts-with('.eq.') {
                $str .= substr(4);
                $lev=7;
                #$op='==';
                $op=15;
            } 
            when .starts-with('.ne.') {
                $str .= substr(4);
                $lev=7;
                #$op='/=';
                $op=16;
            } 
            when .starts-with('.and.') {
                $str .= substr(5);
                $lev=9;
                #$op='.and.';
                $op=22;
            } 
            when .starts-with('.or.') {
                $str .= substr(4);
                $lev=10;
                #$op='.or.';
                $op=23;
            } 
            when .starts-with('\.xor.') {
                $str .= substr(5);
                $lev=11;
                #$op='.xor.';
                $op=24;
            } 
            when .starts-with('.eqv.') {
                $str .= substr(5);
                $lev=11;
                #$op='.eqv.';
                $op=25;
            } 
            when .starts-with('.neqv.') {
                $str .= substr(6);
                $lev=11;
                #$op='.neqv.';
                $op=26;
            } 
         
            default {
                # dummies
                $lev=0;
                $op=0;

                #say "LEAVE WHILE: ERROR, str $str does not match any op";
                # $error=1;
                # last;
                #return ($expr_ast, $str, 1,0);
            }

            # $state=5;
            }
# say "$str : $op : $lev";

} 
elsif VER==0 { # 49 s
            # Operators
=begin pod 
info_operator_precedence
Level
    Scalars
0
    Arithmetic
1        right       ** NOTE F ** S ** Z means F ** (S ** Z)
2        right       unary + and - NOTE X ** -A * Z means X ** (-(A * Z)) => Handled in state=0
3        left        * / 
4        left        + - 
    Character
5        left         //
         left         :   NOTE I put this here, main purpose is array dims but it also works for substring ranges
         left         =   NOTE I put this here, main purpose is implicit do. Actually this should be a separate level between Relational and Logical
    Relational
6        nonassoc    < > <= >= .lt. .gt. .le. .ge.
7        nonassoc    == != .eq. .ne. 
    Logical
8        right       .not.
9        left        .and. 
10        left        .or. 
11        left        .xor. .eqv. .neqv.

So it looks like I need at least 6 bits, so we'll need <<8 and 0xFF

=end pod 
    my $op=0;
    my $lev=0;
            # $prev_lev=$lev;
            if ($str~~s/^\+//) {
                $lev=4;
                #$op='+';
                $op=3;
            }
            elsif ($str~~s/^\-//) {
                $lev=4;
                #$op='-';
                $op=4;
            }
            elsif ($str~~s/^\*\*//) {
                # We store this incorrectly left-assoc, the emitter can fix it.
                $lev=2;
                #$op='**';
                $op=8;
            } 
            elsif ($str~~s/^\*//) {
                $lev=3;
                #$op='*';
                $op=5;
            }
            elsif ($str~~s/^\/\///) {
                $lev=5;
                #$op='//';
                $op=13;
            } 
            elsif ($str~~s/^://) {
                $lev=5;
                #$op=':';
                $op=12;
            } 
            elsif ($str~~s/^\///) {
                $lev=3;
                #$op='/';
                $op=6;
            } 
            elsif $str~~s/^[\>\= | \.\s*ge\s*\.] // {
                $lev=6;
                #$op='>=';
                $op=20;
            } 
            elsif $str~~s/^[ \<\= | \.\s*le\s*\.] // {
                $lev=6;
                #$op='<=';
                $op=19;
            } 
            elsif ($str~~s/^[\< | \.\s*lt\s*\.]//) {
                $lev=6;
                #$op='<';
                $op=17;
            } 
            elsif ($str~~s/^[\> | \.\s*gt\s*\.]//) {
                $lev=6;
                #$op='>';
                $op=18;
            } 
            elsif ($str~~s/^[\=\= | \.\s*eq\s*\.]//) {
                $lev=7;
                #$op='==';
                $op=15;
            } 
            elsif ($str~~s/^\!\=// || $str~~s/^\.ne\.// || $str~~s/^\.\s*ne\s*\.//) {
                $lev=7;
                #$op='/=';
                $op=16;
            } 
            elsif ($str~~s/^\.and.// || $str~~s/^\.\s*and\s*\.//) {
                $lev=9;
                #$op='.and.';
                $op=22;
            } 
            elsif ($str~~s/^\.or.// || $str~~s/^\.\s*or\s*\.//) {
                $lev=10;
                #$op='.or.';
                $op=23;
            } 
            elsif $str~~s/^\.\s*xor\s*\.// {
                $lev=11;
                #$op='.xor.';
                $op=24;
            } 
            elsif $str~~s/^\.\s*eqv\s*\.// {
                $lev=11;
                #$op='.eqv.';
                $op=25;
            } 
            elsif $str~~s/^\.\s*neqv\s*\.// {
                $lev=11;
                #$op='.neqv.';
                $op=26;
            } 
            elsif ($str~~s/^\=//) {
                $lev=5;
                #$op='=';
                $op=9;
            } else {
                #                carp 'NO OP, ERROR '.$str;
                #say "LEAVE WHILE: ERROR, str $str does not match any op";
                # $error=1;
                $op=0;
                $lev=0;
                #return ($expr_ast, $str, 1,0);
            }

            # $state=5;
        
}
elsif VER==3 { # 2s
} # VER
elsif VER==2 { # 10 s, so disappointing!
my ( \str__, \lev, \op) = do given str_ {
            when .starts-with('+')  {
                (str_.substr(1),
                4,
                #$op='+';
                3);
            }
            when .starts-with('-') {
                (str_.substr(1),
                4,
                #$op='-';
                4);
            }
            when .starts-with('**')  {
                (str_.substr(2),
                # We store this incorrectly left-assoc, the emitter can fix it.
                2,
                #$op='**';
                8);
            } 
            when .starts-with('*')  {
                (str_.substr(1),
                3,
                #$op='*';
                5);
            }
            when .starts-with('//')  {
                (str_.substr(2),
                5,
                #'//';
                13);
            } 
            when .starts-with(':') {
                (str_.substr(1),
                5,
                #':';
                12);
            } 
            when .starts-with('/') {
                (str_.substr(1),
                3,
                #'/';
                6);
            } 
            when .starts-with( '>=' ) {
                (str_.substr(2),
                6,
                #'>=';
                20);
            }
            # Do all the ones without dots here
            when .starts-with('<') {
                (str_.substr(1),
                # // || $str=~s/^\.lt\.// || $str=~s/^\.\s*lt\s*\.//) {
                6,
                #$op='<';
                17);
            } 
            when .starts-with('>') {
                (str_.substr(1),
                # // || $str=~s/^\.gt\.// || $str=~s/^\.\s*gt\s*\.//) {
                6,
                #'>';
                18);
            } 
            when .starts-with('==') {
                (str_.substr(2),
                # // || $str=~s/^\.eq\.// || $str=~s/^\.\s*eq\s*\.//) {
                7,
                #'==';
                15);
            } 
            when .starts-with('!=') {
                (str_.substr(2),
                # // || $str=~s/^\.ne\.// || $str=~s/^\.\s*ne\s*\.//) {
                7,
                #'/=';
                16);
            } 
            when .starts-with('=') {
                (str_.substr(1),
                5,
                #'=';
                9);
            } 

            # # Maybe
            # when .trans(' ' => '').starts-with( '.ge.') {
            #     $str .= substr(index($str,2,'.')+1);
            #     $lev=6;
            #     #$op='>=';
            #     $op=20;
            # }
            when .starts-with('.') and  (.index( ' ' ) < (my \eidx = .index('.',2 ))) {
                # say eidx;
                # Find the keyword with spaces
                my $match = .substr(0, eidx+1);
                # remove the spaces
                $match .= trans( ' ' => '' );
                # die $match;
                # update the string
                $_ = $match ~ .substr( eidx+1);
                proceed;
            }

            when .starts-with( '.ge.') {
                # say 'H!';
                (str_.substr(4),
                6,
                #$op='>=';
                20);
            }
            when .starts-with('.lt.') {
                (str_.substr(4),
                # // || $str=~s/^\.lt\.// || $str=~s/^\.\s*lt\s*\.//) {
                6,
                #'<';
                17);
            } 
            when .starts-with('.gt.') {
                (str_.substr(4),
                # // || $str=~s/^\.gt\.// || $str=~s/^\.\s*gt\s*\.//) {
                6,
                #'>';
                18);
            } 
            when .starts-with('.eq.') {
                (str_.substr(4),
                # // || $str=~s/^\.eq\.// || $str=~s/^\.\s*eq\s*\.//) {
                7,
                #'==';
                15);
            } 
            when .starts-with('.ne.') {
                (str_.substr(4),
                # // || $str=~s/^\.ne\.// || $str=~s/^\.\s*ne\s*\.//) {
                7,
                #'/=';
                16);
            } 
            when .starts-with('.and.') {
                (str_.substr(5),
                # // || $str=~s/^\.\s*and\s*\.//) {
                9,
                #'.and.';
                22);
            } 
            when .starts-with('.or.') {
                (str_.substr(4),
                # // || $str=~s/^\.\s*or\s*\.//) {
                10,
                #$op='.or.';
                23);
            } 
            when .starts-with('\.xor.') {
                (str_.substr(5),
                # // || $str=~s/^\.\s*xor\s*\.//) {
                11,
                #'.xor.';
                24);
            } 
            when .starts-with('.eqv.') {
                (str_.substr(5),
                # // || $str=~s/^\.\s*eqv\s*\.//) {
                11,
                #'.eqv.';
                25);
            } 
            when .starts-with('.neqv.') {
                (str_.substr(6),
                # // || $str=~s/^\.\s*neqv\s*\.//) {
                11,
                #'.neqv.';
                26);
            }        
            default { (str_,0,0);
                # dummies
                # $lev=0;
                # $op=0;
                #                carp 'NO OP, ERROR '.$str;
                #say "LEAVE WHILE: ERROR, str $str does not match any op";
                # $error=1;
                # last;
                #return ($expr_ast, $str, 1,0);
            }

            # $state=5;
            }
# say "{str__} : {op} : {lev}";

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


