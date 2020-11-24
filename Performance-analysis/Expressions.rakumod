
use v6;
use MONKEY-SEE-NO-EVAL;
unit module Expressions;

our $defaultToArrays = 0;
# my $DBG=0;
our %F95_intrinsics;
our %F95_reserved_words;
our %F95_function_like_reserved_words;
our $DBG=False;
our $W=False;
our $WW=False;

our $Config=%();
#                          0    1    2    3    4    5    6    7    8    9    10   11   12   13    14
our @sigils is export = ( '{', '&', '$', '+', '-', '*', '/', '%', '**', '=', '@', '#', ':', '//', ')(',
#                15    16    17   18   19    20     21       22       23      24       25       26      
                '==', '/=', '<', '>', '<=', '>=', '.not.', '.and.', '.or.', '.xor.', '.eqv.', '.neqv.',
#                27   28 
                ',', '(/',
# Constants               
#                29         30      31         32           33             34       35 
                'integer', 'real', 'logical', 'character', 'PlaceHolder', 'Label', 'BLANK'
              );
my $opcode=0;
our %sigil_codes = map { $_ => $opcode++  }, @sigils;

my %F95_ops =(
	'==' => '.eq.',  
    '/=' => '.ne.',  
    '<=' => '.le.',  
    '>=' => '.ge.',
	'eq' => '==',
	'ne' => '/=',
	'le' => '<=',
	'ge' => '>=',     			
);
# Returns the AST
sub parse_expression ($exp, $info, $stref, $f) is export  {
	
		my ($ast, $rest, $err, $has_funcs)  = parse_expression_no_context($exp);
		if $DBG and $err or $rest ne '' {
            die "PARSE ERROR in <$exp>, REST: $rest";
		}
        my ($ast2, $grouped_messages) = $has_funcs ?? _replace_function_calls_in_ast($stref,$f,$info,$ast, $exp, {}) !! ($ast,{});
	    if ($W) {
	        for   sort keys $grouped_messages<W> -> $warning_type {
	            for  sort keys $grouped_messages<W>{$warning_type} -> $k {
	                my $line = $grouped_messages<W>{$warning_type}{$k};
	                say $line;
	            }
	        }
	    }		
	    return $ast;
	
} # END of parse_expression()

sub parse_expression_regex ($exp, $info, $stref, $f) is export  {
	
		my ($ast, $rest, $err, $has_funcs)  = parse_expression_no_context_regex($exp);
		if $DBG and $err or $rest ne '' {
            die "PARSE ERROR in <$exp>, REST: $rest";
		}
        my ($ast2, $grouped_messages) = $has_funcs ?? _replace_function_calls_in_ast($stref,$f,$info,$ast, $exp, {}) !! ($ast,{});
	    if ($W) {
	        for   sort keys $grouped_messages<W> -> $warning_type {
	            for  sort keys $grouped_messages<W>{$warning_type} -> $k {
	                my $line = $grouped_messages<W>{$warning_type}{$k};
	                say $line;
	            }
	        }
	    }		
	    return $ast;
	
} # END of parse_expression_regex()


# ==============================================================================
# States
# 1            2           3                4        5           0           6             7                     8
# read_scalar, read_array, read_paren_expr, read_op, append_ast, do_nothing, handle_comma, handle_closing_paren, handle_not
#

# As we are not using the nodeId I will not waste cycles on it
# Sadly I need a lot more bits than originally so either I do not mask at all or use 0xFF and make sure the shift is <<8

# - Returns a flag to say that the AST contains function calls. If this is not the case there's no point in calling the _change_func_to_array()

# parse_expression_no_context :: String -> (AST,String,Error,HasFuncs)
sub parse_expression_no_context($str_)  is export  { 	
    my $str = $str_;
    my $max_lev=11; # levels of precedence
    my $prev_lev=0;
    my $lev=0;
    # Let's try an array first
    my @ast=[];
    my $op = Nil;
    my $state=0; # I will use state=8/9/10 as "has prefix .not. - + "
    my $error=0;
    # I will not treat * as a proper prefix


    my Array $expr_ast=[];
    my Array $arg_expr_ast=[];
    # say ':::',$arg_expr_ast.WHAT;die;
    my $has_funcs=0;
    # my $empty_arg_list=0;
    while $str {
        $error=0;
        # Remove whitespace
        $str .= trim-leading;
        # Handle prefix -,+,.not.
        given $str {
            when .starts-with('-') {
                $str.=substr(1);
                $state=4;
            }    
            when $str.starts-with('+') {
                $str.=substr(1);
                $state=3;
            }    
            when .starts-with('.not.') {
                $str.=substr(5);
                $state=21;
            }    
        }

        # Remove whitespace after prefix
        if ($state ) {
            $str .= trim-leading;
        }

        given $str {
            # First check for a variable, then trim and then see if there is a paren.
            when 'a' le (my $var = .substr(0,1)).lc le 'z' {
                #variable
                # my $var= .substr(0,1);
                # .=substr(1);
                my $idx=1;
                my $c = .substr($idx,1);                
                while 'a' le $c.lc le 'z' or $c eq '_' or '0' le $c le '9' {
                    $var~=$c;

                    # $_ .=substr(1);
                    # $c = .substr(0,1);
                    $c = .substr(++$idx,1);
                }
                # say $var,';',$str,';',$idx;
                .=substr($idx);
                .=trim-leading;
                if .starts-with('(') {
                    # array access or function call;
                    .=substr(1); # remove the '('
                    $has_funcs=1;
                    my $arg_expr_ast;
                    if not .starts-with(')') { # non-empty arg list
                        ($arg_expr_ast,$str, my $err, my $has_funcs2) = parse_expression_no_context($str);
                        # $_=$str2;
                        $has_funcs||=$has_funcs2;
                    } else { # empty arg list                       
                        $str .= substr(1); # removed ')'
                        $str .= trim-leading;
                        $arg_expr_ast=[];
                    }
                    if ($defaultToArrays) {
                        $expr_ast=[10,$var,$arg_expr_ast];
                    } else {
                        $expr_ast=[1,$var,$arg_expr_ast];
                    }
                    
                    # f(x)(y)
                    if .starts-with('(') {
                        (my $arg_expr_ast2,$str, my $err2,my $has_funcs2)=parse_expression_no_context($_);
                        # $_=$str2;
                        $expr_ast=[1, $var,[14,$arg_expr_ast,$arg_expr_ast2[1]]];
                        $has_funcs||=$has_funcs2;
                    }

                } else {
                    $expr_ast=[2,$var];
                }
            }
            when .starts-with('[') {
                # constant array constructor expr
                .=substr(1);
                ($expr_ast,$str, my $err,my $has_funcs2)=parse_expression_no_context($_);
                # $_ = $str2;
                $has_funcs||=$has_funcs2;
                #$expr_ast=['(/',$expr_ast];
                $expr_ast= [28,$expr_ast];
                if $err {
                    return [$expr_ast,$str, $err,0];
                }
            } 
            when .starts-with('(') { 
                .=substr(1);
                my $str2 = .trim-leading;
                if $str2.starts-with('/') {
                # constant array constructor expr
                    $str2 .=substr(1);
                    ($expr_ast,$str, my $err,my $has_funcs2)=parse_expression_no_context($str2);
                    # $_ = $str3;
                    $has_funcs||=$has_funcs2;
                    #$expr_ast=['(/',$expr_ast];
                    $expr_ast= [28,$expr_ast];
                    if $err {
                        return [$expr_ast,$str, $err,0];
                    }
                } else {
                    # $_.=substr(1);                            
                    # paren expr, I use '{' as it appears not to be used. Would make send to call it '('
                    ($expr_ast,$str, my $err,my $has_funcs2)=parse_expression_no_context($_);
                    # $_=$str2;
                    $has_funcs||=$has_funcs2;
                    $expr_ast=[0,$expr_ast];
                    if $err {#say "ERR 2";
                        return [$expr_ast,$str, $err,0];
                    }
                }
            }
            # Apparently Fortran allows '$' as a character in a variable name but I think I'll ignore that.
            # I allow _ as starting character because of the placeholders
                    
            # when 'a' le .substr(0,1).lc le 'z' { die 'BOOM! SHOULD NOT COME HERE';
            #     #variable
            #     my $var= .substr(0,1);
            #     .=substr(1);
            #     my $c = .substr(0,1);
            #     my $idx=0;
            #     while 'a' le $c.lc le 'z' or $c eq '_' or '0' le $c le '9' {
            #         my $var~=$c;
            #         # .=substr(1);
            #         # $c = .substr(0,1);
            #         $c = .substr(++$idx,1);
            #     }
            #     $str .= substr($idx);
            #     $expr_ast=[2,$var];
            # }
            when .starts-with('__PH') {    
                # placeholders
                my $ns = .index('H')+1;
                # from there
                my $ne = .index('__',$ns);
                # get the substr, we know it is a number
                my $nn = $ne-$ns;
                my $n = .substr($ns,$nn);

                my $phs = '__PH'~$n~'__'; 
                .=substr($nn+6);
                # $str.=trim-leading;
                #  Now it is possible that there are several of these in a row!
                while .starts-with('__PH') {                    
                    # now find the number
                    my $ns = .index('H')+1;
                    # from there
                    my $ne = .index('__',$ns);
                    # get the substr, we know it is a number
                    my $nn = $ne-$ns;
                    my $n = .substr($ns,$nn);
                    $phs ~= '__PH'~$n~'__'; 
                     .=substr($nn+6);
                    # $str.trim-leading;
                    # say $expr_ast;
                }        
                $expr_ast=[33,$phs]; 
            }
            when  .starts-with('.true.') {    
                .=substr(6);        
                # boolean constants
                $expr_ast=[31,'.true.'];
            }
            when  .starts-with('.false.') {
                # boolean constants
                .=substr(7);
                $expr_ast=[31,'.false.'];
            }
            when '0' le .substr(0,1) le '9' or .substr(0,1) eq '.' { # could be a real const, carry on
                my $sep='';
                my $sgn='';
                my $exp='';
                my $real_const_str='';

                my $mant = .substr(0,1);
                # my $mant=$h;
                # $str .=substr(1);
                my $idx=1;
                my $h = .substr($idx,1);
                while '0' le $h le '9' or $h eq '.' {
                    $mant ~=$h;
                    $h = .substr(++$idx,1);
                }
                $str .= substr($idx);

                if not ($mant.ends-with('.') and .starts-with('eq',:i)) { 
                    # if $h eq 'e' or $h eq 'd' or $h eq 'q' {
                    if $h.lc eq 'e' | 'd' | 'q' {
                        $sep = $h;
                        my $idx=1;
                        $h =.substr(1,1);
                        if $h eq '-' or $h eq '+' {
                            ++$idx;
                            $sgn = $h;
                            $h =.substr($idx,1);
                        }
                        while '0' le $h le '9' {
                            ++$idx;
                            $exp~=$h;
                            $h =.substr($idx,1);
                        }
                        $str .= substr($idx);
                    # so we have $mant $sep $sgn $exp
                        $real_const_str="$mant$sep$sgn$exp";
                        # reals
                        $expr_ast=[30,$real_const_str];
                    } elsif index($mant,'.').Bool {
                    # means $h is no more part of the number, emit the $mant only
                        $real_const_str=$mant;
                        # real
                        $expr_ast=[30,$real_const_str];
                    }
                    else { # No dot and no sep, so an integer
                        # integer
                        $expr_ast=[29,$mant];   
                    }
                } else { # .eq., backtrack and carry on
                    $str ="$mant$str";        
                    proceed;
                }            
            }
            when .starts-with('*') and '0' le (my $h=.substr(1,1)) le '9' {
                my $addr=$h;
                my $idx=2;
                $h = .substr($idx,1);
                while '0' le $h le '9' {
                    ++$idx;
                    $addr~=$h;
                    $h =.substr($idx,1);
                }
                $str .= substr($idx);            
                # The '*' is for "alternate returns", a bizarre F77 feature.
                # The integer following the * is a label 
                $expr_ast=[34,$addr];
            }        
        # TODO see file with old content: spaces in numbers

            when .starts-with('*') {        
                .=substr(1);        
                # '*' format for write/print
                $expr_ast=[32,'*'];
            }
            # Maybe I should handle string constants as well
            # Although we use placeholders so they should not occur
            when  .starts-with("'") and (my $cq= .index("'",1)) >1 {
                my $str_const = .substr(0,$cq+1);
                $expr_ast=[32,$str_const ];
                .=substr($cq+1);
            }
            # Here we return with an error value
            # What I could do is say:
            # if the next token is ':' or the pending op is ':' (12)
            when .starts-with(':') or $op == 12 {
                    # Return a blank
                    $expr_ast=[35,'']
            }
            default { # error
                    $error=1;
                    return [$expr_ast, $_, $error,0];
            }    
        } # given

        # say "STR2: "~$str.raku;
        # say 'expr_ast: '~$expr_ast.raku;
        # say 'state: '~$state;
        # If state is not 0 there is a prefix
        if ($state) {
            $expr_ast=[$state,$expr_ast];
        }
        #say "STR before operator: $str";

        # Strip whitespace
        $str .= trim-leading;
        
        if (!$str.Bool) {    
            last;
        }

        given $str {
            when .starts-with(',') { # comma
                .=substr(1);
                # just set a state here
                $state=6;
            }
            when .trans(' ' => '').starts-with( '/)') 
            or .starts-with( ']')
            { # closing paren for constant array constructor
                if .starts-with( '/') {
                    .=substr(1);
                    .=trim-leading;
                }
                .=substr(1);
                # Again this is like falling off the end of the string
                # if  @{$arg_expr_ast} is not empty, then this must become the ast to return
                # after appending the final value
                if $arg_expr_ast {
                    # Just set a state here
                    $state=7; # because the operator has already been set
                }
                # otherwise it is quite the same as the end of the string
                else {
                    # say "LEAVE WHILE: closing paren";die $state;
                    last;
                }
            }        
            when .starts-with(')') { # closing paren
            
                .=substr(1);
                # say 'closing paren '~ $_;
                # Again this is like falling off the end of the string``    `
                # if  @{$arg_expr_ast} is not empty, then this must become the ast to return
                # after appending the final value
                if ( $arg_expr_ast  ) {
                    # Just set a state here
                    $state=7;                
                }
                # otherwise it is quite the same as the end of the string
                else {
                    # say "LEAVE WHILE: closing paren";
                    last;
                }
            } 
            default { 
            # warn "HERE OPS $str";
            # Operators
=begin pod
Operator precedence
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


            $prev_lev=$lev;
            my $str2=$str;
            given $str2 {
                when .starts-with('+')  {
                    $str2 .= substr(1);
                    $lev=4;
                    #$op='+';
                    $op=3;
                }
                when .starts-with('-') {
                    $str2 .= substr(1);
                    $lev=4;
                    #$op='-';
                    $op=4;
                }
                when .starts-with('**')  {
                    $str2 .= substr(2);
                    # We store this incorrectly left-assoc, the emitter can fix it.
                    $lev=2;
                    #$op='**';
                    $op=8;
                } 
                when .starts-with('*')  {

                    $str2 .= substr(1);                    
                    # say 'MULT: <',$str2, '>';
                    $lev=3;
                    #$op='*';
                    $op=5;
                }
                when .starts-with('//')  {
                    $str2 .= substr(2);
                    $lev=5;
                    #$op='//';
                    $op=13;
                } 
                when .starts-with(':') {
                    $str2 .= substr(1);
                    $lev=5;
                    #$op=':';
                    $op=12;
                } 
                when .starts-with('/') {
                    $str2 .= substr(1);
                    $lev=3;
                    #$op='/';
                    $op=6;
                } 
                when .starts-with( '>=' ) {
                    $str2 .= substr(2);
                    $lev=6;
                    #$op='>=';
                    $op=20;
                }
                when .starts-with( '<=' ) {
                    $str2 .= substr(2);
                    $lev=6;
                    #$op='<=';
                    $op=19;
                }                
                when .starts-with('<') {
                    $str2 .= substr(1);
                    $lev=6;
                    #$op='<';
                    $op=17;
                } 
                when .starts-with('>') {
                    $str2 .= substr(1);
                    $lev=6;
                    #$op='>';
                    $op=18;
                } 
                when .starts-with('==') {
                    $str2 .= substr(2);
                    $lev=7;
                    #$op='==';
                    $op=15;
                } 
                when .starts-with('!=') {
                    $str2 .= substr(2);
                    $lev=7;
                    #$op='/=';
                    $op=16;
                } 
                when .starts-with('=') {
                    $str2 .= substr(1);
                    $lev=5;
                    #$op='=';
                    $op=9;
                } 
                when .starts-with('.') and  .index( ' ' ) and (.index( ' ' ) < (my $eidx = .index('.',2 ))) {
                    
                    # Find the keyword with spaces
                    my $match = .substr(0, $eidx+1);
                    # remove the spaces
                    $match .= trans( ' ' => '' );
                    # update the string
                    $str2 = $match ~ .substr( $eidx+1);
                    proceed;
                }

                when .starts-with( '.ge.') {
                    # say 'H!';
                    $str2 .= substr(4);
                    $lev=6;
                    #$op='>=';
                    $op=20;
                }
                when .starts-with( '.lt.') {
                    $str2 .= substr(4);
                    $lev=6;
                    #$op='<';
                    $op=17;
                } 
                when .starts-with( '.gt.') {
                    $str2 .= substr(4);
                    $lev=6;
                    #$op='>';
                    $op=18;
                } 
                when .starts-with( '.eq.') {
                    $str2 .= substr(4);
                    $lev=7;
                    #$op='==';
                    $op=15;
                } 
                when .starts-with( '.ne.') {
                    $str2 .= substr(4);
                    $lev=7;
                    #$op='/=';
                    $op=16;
                } 
                when .starts-with( '.and.') {
                    $str2 .= substr(5);
                    $lev=9;
                    #$op='.and.';
                    $op=22;
                } 
                when .starts-with( '.or.') {
                    $str2 .= substr(4);
                    $lev=10;
                    #$op='.or.';
                    $op=23;
                } 
                when .starts-with( '.xor.') {
                    $str2 .= substr(5);
                    $lev=11;
                    #$op='.xor.';
                    $op=24;
                } 
                when .starts-with( '.eqv.') {
                    $str2 .= substr(5);
                    $lev=11;
                    #$op='.eqv.';
                    $op=25;
                } 
                when .starts-with( '.neqv.') {
                    $str2 .= substr(6);
                    $lev=11;
                    #$op='.neqv.';
                    $op=26;
                } 
            
                default {
                    #say "LEAVE WHILE: ERROR, str $str does not match any op";
                    $error=1;
                    last;
                }
            } # nested given
            $str=$str2;
            # $str = $_;
            # say 'OUT  wit state = 5; ',$str,';',$_,';',$str2;
            $state=5;        
        } # default of nesting given
    } # given
    # say 'EXPR AST: ',$expr_ast.raku;
        if ($state==5 and not defined $op) {
        	#say "ERR 5";
            $error=1;
        	return [$expr_ast, $str, $error,0];
        }
        # Append to the AST
        if $state==5 {
            if $prev_lev==0 { # start            
                @ast[$lev]=[$op,$expr_ast];
                # say "OP START $lev ",@ast.raku;
            } 
            elsif $prev_lev < $lev { # '*' < '+'
                push @ast[$prev_lev],$expr_ast;
                if not defined @ast[$lev] {
                    @ast[$lev]=@ast[$prev_lev];
                } else {
                    push @ast[$lev], @ast[$prev_lev];
                }
                @ast[$prev_lev] = Nil;
                @ast[$lev] = [$op, @ast[$lev]];
            } elsif $prev_lev > $lev {
                @ast[$lev]=[$op, $expr_ast];
            } elsif $lev==$prev_lev {
                push @ast[$lev],$expr_ast;
                @ast[$lev]=[$op, @ast[$lev]];
            }
            $state=0;
            # say "OP STATE (5) $lev ",@ast.raku;
        } 
        elsif $state == 6 or $state==7 {
            # warn "$state $str";
            # This is the same as end of str, except we need to keep parsing afterwards
            # So we do the same as in that case
            if not defined @ast[$lev] {
                @ast[$lev] = $expr_ast;
            } 
            else {
               push @ast[$lev], $expr_ast;
            }
            # Now determine the highest level; fold the lower levels into it
            if @ast.elems == 1 {
                # say 'HERE ARG EXPR AST ';
                push $arg_expr_ast,@ast[0];
            } 
            else {
                for 1 .. $max_lev -> $tlev {
                    if not defined @ast[$tlev+1] {
                        @ast[$tlev+1] = @ast[$tlev] if defined @ast[$tlev] and @ast[$tlev];
                    } 
                    else {
                        push @ast[$tlev+1], @ast[$tlev] if defined @ast[$tlev] and @ast[$tlev];
                    }
                }            
                # say  $arg_expr_ast.WHAT;  
                # say  $arg_expr_ast.raku;  
                push $arg_expr_ast, @ast[$max_lev+1];
            }
            if $state==6 {
                @ast=[];
                $state=0;
                $prev_lev=0;
                $lev=0;
            } 
            else { # state==7
                # Now we return this as the ast
                # say "ERR 6 $error $str";
                # warn Dumper([27,@{$arg_expr_ast}],$str,$error,$has_funcs);
                return( [[27,|$arg_expr_ast],$str,$error,$has_funcs]);
            } 
        }
    } # while
    # say "TEST: $TEST";
    
    # So when we fall off the end of the string we need to clean up
    # There is an $expr_ast pending
    # say 'AST: ',@ast.raku;
    # say 'EXPR AST:',$expr_ast.raku;
    # say 'ARG EXPR AST:',$arg_expr_ast.raku;
    # say 'STR: ',$str;
    if not defined @ast[$lev] {
    # die $lev~@ast.raku if $expr_ast[0] == 10;
        @ast[$lev] = $expr_ast;
    } else {
        push @ast[$lev], $expr_ast;
    }
    if $arg_expr_ast { 
        if @ast.elems == 1 {
            push $arg_expr_ast,@ast[0];
        } else {
            for  1 .. $max_lev -> $tlev {
                if not defined @ast[$tlev+1] {
                    @ast[$tlev+1] = @ast[$tlev] if defined @ast[$tlev] and @ast[$tlev];
                } else {
                    push @ast[$tlev+1], @ast[$tlev] if defined @ast[$tlev] and @ast[$tlev];
                }
            }            
            push $arg_expr_ast,@ast[$max_lev+1];
        }
        #say "ERR 7 $error";
        return [[27,|$arg_expr_ast],$str,$error,$has_funcs];
    } else {
        # Now determine the highest level; fold the lower levels into it
        if @ast.elems == 1 {
            # die 'BOOM ' ~ @ast[0].raku;
            return [@ast[0],$str,$error,$has_funcs];
        } else {
            # FOR here cut out
            for  1 .. $max_lev -> $tlev {
                if not defined @ast[$tlev+1] {
                    @ast[$tlev+1] = @ast[$tlev] if defined @ast[$tlev] and @ast[$tlev];
                } else {
                    push @ast[$tlev+1], @ast[$tlev] if defined @ast[$tlev] and @ast[$tlev];
                }
            }
            #say "ERR 8 $error";
            return [@ast[$max_lev+1],$str,$error,$has_funcs];
        }
    }
} # END of parse_expression_no_context

sub parse_expression_no_context_regex($str_) is export  { 	
    my $str = $str_;
    my $max_lev=11; # levels of precedence
    my $prev_lev=0;
    my $lev=0;
    # Let's try an array first
    my @ast=[];
    my $op = Nil;
    my $state=0; # I will use state=8/9/10 as "has prefix .not. - + "
    my $error=0;
    # I will not treat * as a proper prefix

    my Array $expr_ast=[];
    my Array $arg_expr_ast=[];
    # say ':::',$arg_expr_ast.WHAT;die;
    my $has_funcs=0;
    # my $empty_arg_list=0;
    while $str {
        $error=0;
        # Remove whitespace
        $str .= trim-leading;
        # Handle prefix -,+,.not.
        given $str {
            when  s/^\-// {
                $state=4;
            }    
            when s/^\+// {
                $state=3;
            }    
            when s/\.not\.// {
                $state=21;
            }    
        }

        # Remove whitespace after prefix
        if ($state ) {
            $str ~~ s/^\s*//;
        }

        given $str {
            
            # First check for a variable, then trim and then see if there is a paren.
            when s:i/^$<m> = [<[ a..z ]> \w* ] \s* \( // { 
                    my $var=$<m>.Str;

                    $has_funcs=1;
                    my $arg_expr_ast;
                    if !/^\s*\)/ { # non-empty arg list
                        ($arg_expr_ast,$str, my $err, my $has_funcs2) = parse_expression_no_context_regex($str);
                        # $_=$str2;
                        $has_funcs||=$has_funcs2;
                    } else { # empty arg list                       
                        $str ~~ s/^\)\s*//;
                        $arg_expr_ast=[];
                    }
                    if ($defaultToArrays) {
                        $expr_ast=[10,$var,$arg_expr_ast];
                    } else {
                        $expr_ast=[1,$var,$arg_expr_ast];
                    }
                    
                    # f(x)(y)
                    if /^\(/ {
                        (my $arg_expr_ast2,$str, my $err2,my $has_funcs2)=parse_expression_no_context_regex($_);
                        # $_=$str2;
                        $expr_ast=[1, $var,[14,$arg_expr_ast,$arg_expr_ast2[1]]];
                        $has_funcs||=$has_funcs2;
                    }
            }

            when s:i/\[// {
                # constant array constructor expr
                ($expr_ast,$str, my $err,my $has_funcs2)=parse_expression_no_context_regex($_);
                # $_ = $str2;
                $has_funcs||=$has_funcs2;
                #$expr_ast=['(/',$expr_ast];
                $expr_ast= [28,$expr_ast];
                if $err {
                    return [$expr_ast,$str, $err,0];
                }
            } 
            when s/^\(\s*\/// { 
                # constant array constructor expr
                    ($expr_ast,$str, my $err,my $has_funcs2)=parse_expression_no_context_regex($str);
                    # $_ = $str3;
                    $has_funcs||=$has_funcs2;
                    #$expr_ast=['(/',$expr_ast];
                    $expr_ast= [28,$expr_ast];
                    if $err {
                        return [$expr_ast,$str, $err,0];
                    }
            }
            when s/^\(// {
                    # paren expr, I use '{' as it appears not to be used. Would make send to call it '('
                    ($expr_ast,$str, my $err,my $has_funcs2)=parse_expression_no_context_regex($str);
                    # $_=$str2;
                    $has_funcs||=$has_funcs2;
                    $expr_ast=[0,$expr_ast];
                    if $err {#say "ERR 2";
                        return [$expr_ast,$str, $err,0];
                    }            
            }

            # Apparently Fortran allows '$' as a character in a variable name but I think I'll ignore that.
            # I allow _ as starting character because of the placeholders
            # when s/^a1_i// { die $str,$_ }
            when  s:i/^$<m>=[<[a..z]>\w*]\s*// { 
                my $var=$<m>.Str;
                $expr_ast=[2,$var];
            }       
            when s/^$<m> = [[__PH\d+__]+]// {
            #
                $expr_ast=[33,$<m>.Str];
            #$expr_ast=['$',$1];
            # Now it is possible that there are several of these in a row!
            # say @expr_ast;exit;
            }

            when  s/\.true\.// {            
                # boolean constants
                $expr_ast=[31,'.true.'];
            }
            when  s/\.true\.// {
                # boolean constants
                $expr_ast=[31,'.false.'];
            }
            when (                    	
                (
                    !(rx:i/^\d+\.eq/) and
                    s:i/^ $<m> = [[\d*\.\d*][[e|d|q][\-|\+]?\d+]?]//        
                )        	
                or 
                s:i/^$<m> = [\d*[e|d|q][\-|\+]?\d+]//
            ) {
                my $real_const_str=$<m>.Str;
                $expr_ast=[30,$real_const_str];
                # say $real_const_str;
            }             
            when s/^\* $<m> = [\d+]// {
                my $addr=$<m>.Str;
                # The '*' is for "alternate returns", a bizarre F77 feature.
                # The integer following the * is a label 
                $expr_ast=[34,$addr];
            }        
        # TODO see file with old content: spaces in numbers
            when s/^ $<m> = [\d+]// {            
                # integers                       
                # warn 'INTEGER, ALLOW_SPACES_IN_NUMBERS==0';
                $expr_ast=[29,$<m>.Str];
                #$expr_ast=$1;#['integer',$1];
            }
            when s/^\*// {        
                # '*' format for write/print
                $expr_ast=[32,'*'];
            }
            # Maybe I should handle string constants as well
            # Although we use placeholders so they should not occur
            when  .starts-with("'") and (my $cq= .index("'",1)) >1 {
                my $str_const = .substr(0,$cq+1);
                $expr_ast=[32,$str_const ];
                .=substr($cq+1);
            }
            when s/^\'(.+?)\'//  {
            $expr_ast=[32, $/.Str];
            #$expr_ast="'".$1."'";
            }
            # Here we return with an error value
            # What I could do is say:
            # if the next token is ':' or the pending op is ':' (12)
            when s/\:// or $op == 12 {
                    # Return a blank
                    $expr_ast=[35,'']
            }
            default { # error
                    $error=1;
                    return [$expr_ast, $_, $error,0];
            }    
        } # given

        # say "STR2: "~$str.raku;
        # say 'expr_ast: '~$expr_ast.raku;
        # say 'state: '~$state;
        # If state is not 0 there is a prefix
        if ($state) {
            $expr_ast=[$state,$expr_ast];
        }
        #say "STR before operator: $str";

        # Strip whitespace
        $str .= trim-leading;
        
        if (!$str.Bool) {    
            last;
        }

        given $str {
            when s/^\,// { # comma
                # just set a state here
                $state=6;
            }
            when s/^\/\s*\)// or s/^\]// {
             # closing paren for constant array constructor
                # Again this is like falling off the end of the string
                # if  @{$arg_expr_ast} is not empty, then this must become the ast to return
                # after appending the final value
                if $arg_expr_ast {
                    # Just set a state here
                    $state=7; # because the operator has already been set
                }
                # otherwise it is quite the same as the end of the string
                else {
                    # say "LEAVE WHILE: closing paren";die $state;
                    last;
                }
            }        
            when s/^\)// { # closing paren
            
                # say 'closing paren '~ $_;
                # Again this is like falling off the end of the string``    `
                # if  @{$arg_expr_ast} is not empty, then this must become the ast to return
                # after appending the final value
                if ( $arg_expr_ast  ) {
                    # Just set a state here
                    $state=7;                
                }
                # otherwise it is quite the same as the end of the string
                else {
                    # say "LEAVE WHILE: closing paren";
                    last;
                }
            } 
            default { 
            # warn "HERE OPS <$str>";
            # Operators
=begin pod
Operator precedence
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


            $prev_lev=$lev;
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
            elsif ($str~~s/^ \/\/ //) {
                $lev=5;
                #$op='//';
                $op=13;
            } 
            elsif ($str~~s/^\://) {
                $lev=5;
                #$op=':';
                $op=12;
            } 
            elsif ($str~~s/^ \/ //) {
                #  die 'DIV';
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
                    $error=1;
                    last;
            }
            # $str = $_;
            # say 'OUT  wit state = 5; ',$str,';',$_,';',$str2;
            $state=5;        
        } # default of nesting given
    } # given
    # say 'EXPR AST: ',$expr_ast.raku;
        if ($state==5 and not defined $op) {
        	#say "ERR 5";
            $error=1;
        	return [$expr_ast, $str, $error,0];
        }
        # Append to the AST
        if $state==5 {
            if $prev_lev==0 { # start            
                @ast[$lev]=[$op,$expr_ast];
                # say "OP START $lev ",@ast.raku;
            } 
            elsif $prev_lev < $lev { # '*' < '+'
                push @ast[$prev_lev],$expr_ast;
                if not defined @ast[$lev] {
                    @ast[$lev]=@ast[$prev_lev];
                } else {
                    push @ast[$lev], @ast[$prev_lev];
                }
                @ast[$prev_lev] = Nil;
                @ast[$lev] = [$op, @ast[$lev]];
            } elsif $prev_lev > $lev {
                @ast[$lev]=[$op, $expr_ast];
            } elsif $lev==$prev_lev {
                push @ast[$lev],$expr_ast;
                @ast[$lev]=[$op, @ast[$lev]];
            }
            $state=0;
            # say "OP STATE (5) $lev ",@ast.raku;
        } 
        elsif $state == 6 or $state==7 {
            # warn "$state $str";
            # This is the same as end of str, except we need to keep parsing afterwards
            # So we do the same as in that case
            if not defined @ast[$lev] {
                @ast[$lev] = $expr_ast;
            } 
            else {
               push @ast[$lev], $expr_ast;
            }
            # Now determine the highest level; fold the lower levels into it
            if @ast.elems == 1 {
                # say 'HERE ARG EXPR AST ';
                push $arg_expr_ast,@ast[0];
            } 
            else {
                for 1 .. $max_lev -> $tlev {
                    if not defined @ast[$tlev+1] {
                        @ast[$tlev+1] = @ast[$tlev] if defined @ast[$tlev] and @ast[$tlev];
                    } 
                    else {
                        push @ast[$tlev+1], @ast[$tlev] if defined @ast[$tlev] and @ast[$tlev];
                    }
                }            
                # say  $arg_expr_ast.WHAT;  
                # say  $arg_expr_ast.raku;  
                push $arg_expr_ast, @ast[$max_lev+1];
            }
            if $state==6 {
                @ast=[];
                $state=0;
                $prev_lev=0;
                $lev=0;
            } 
            else { # state==7
                # Now we return this as the ast
                # say "ERR 6 $error $str";
                # warn Dumper([27,@{$arg_expr_ast}],$str,$error,$has_funcs);
                return( [[27,|$arg_expr_ast],$str,$error,$has_funcs]);
            } 
        }
    } # while
    # say "TEST: $TEST";
    
    # So when we fall off the end of the string we need to clean up
    # There is an $expr_ast pending
    # say 'AST: ',@ast.raku;
    # say 'EXPR AST:',$expr_ast.raku;
    # say 'ARG EXPR AST:',$arg_expr_ast.raku;
    # say 'STR: ',$str;
    if not defined @ast[$lev] {
    # die $lev~@ast.raku if $expr_ast[0] == 10;
        @ast[$lev] = $expr_ast;
    } else {
        push @ast[$lev], $expr_ast;
    }
    if $arg_expr_ast { 
        if @ast.elems == 1 {
            push $arg_expr_ast,@ast[0];
        } else {
            for  1 .. $max_lev -> $tlev {
                if not defined @ast[$tlev+1] {
                    @ast[$tlev+1] = @ast[$tlev] if defined @ast[$tlev] and @ast[$tlev];
                } else {
                    push @ast[$tlev+1], @ast[$tlev] if defined @ast[$tlev] and @ast[$tlev];
                }
            }            
            push $arg_expr_ast,@ast[$max_lev+1];
        }
        #say "ERR 7 $error";
        return [[27,|$arg_expr_ast],$str,$error,$has_funcs];
    } else {
        # Now determine the highest level; fold the lower levels into it
        if @ast.elems == 1 {
            # die 'BOOM ' ~ @ast[0].raku;
            return [@ast[0],$str,$error,$has_funcs];
        } else {
            # FOR here cut out
            for  1 .. $max_lev -> $tlev {
                if not defined @ast[$tlev+1] {
                    @ast[$tlev+1] = @ast[$tlev] if defined @ast[$tlev] and @ast[$tlev];
                } else {
                    push @ast[$tlev+1], @ast[$tlev] if defined @ast[$tlev] and @ast[$tlev];
                }
            }
            #say "ERR 8 $error";
            return [@ast[$max_lev+1],$str,$error,$has_funcs];
        }
    }
} # END of parse_expression_no_context_regex


#  0    1    2    3    4    5    6    7    8    9    10   11   12   13    14
# '{', '&', '$', '+', '-', '*', '/', '%', '**', '=', '@', '#', ':', '//', ')(',
#  15    16    17  18   19    20     21       22       23      24       25       26      
# '==', '/=', '<', '>', '<=', '>=', '.not.', '.and.', '.or.', '.xor.', '.eqv.', '.neqv.',
sub interpret(@ast)  is export  {
    if  @ast.elems==3 {
        (my $opcode, my $lexp, my $rexp) =@ast;
        my $lv = $lexp ~~ Array ?? interpret($lexp) !! $lexp;
        my $rv = $rexp ~~ Array ?? interpret($rexp) !! $rexp;
        my $op=@sigils[$opcode];
        if ($op ~~/\./) {
            $op~~s:g/\.//;
        }
        die($lexp.raku) if $DBG and not defined $lv;
        return EVAL "$lv $op $rv";
    } elsif @ast.elems==2 { 
        (my $op, my $exp) =@ast;
        if ($op == 0) { # {
            my $v = $exp ~~ Array ?? interpret($exp) !! $exp;
            return $v;
        } 
        elsif ($op == 3 ) { # '+'
            my $v = $exp ~~ Array ?? interpret($exp) !! $exp;
            return $v.Num;            
        }
        elsif ($op == 4 ) { # '-'
            my $v = $exp ~~ Array ?? interpret($exp) !! $exp;
            return -$v.Num;            
        }
        elsif ($op == 21 ) { # .not.
            my $v = $exp ~~ Array ?? interpret($exp) !! $exp;
            return !($v.Num);
        }
        elsif ($op == 2 or $op > 28) { # '$' or consts, not an op!
            return $exp; 
        }
    } 
} # END of interpret

# What to emit?
# binops 3
# unops 2
# arrays and functions 3 
# These can have an )( inside them
# if not, emit each elt in the list and join with ',' and surround by '()'
# if ')(', do the same for each of them and join them together
# parenthesised expressions unop
# atomics: vars and constants unop and scalar, or later unop?
sub emit_expr_from_ast (@ast)  is export  {

        if @ast.elems==3 {
            if (@ast[0] ==1 or @ast[0] ==10) { # '&' or '@', array access or function call
                my ( $sigil,  $name,  $args) =@ast;
                
                # carp Dumper($ast);
                
                if $args {
					if $args[0] != 14 { # ')('
						my $args_lst=[];
						if $args[0] == 27 { # ','
                        # die $args.raku,$args.elems;
							for 1 .. $args.elems-1 -> $idx {
								my $arg = $args[$idx];
								push $args_lst, emit_expr_from_ast($arg);
							}

							#                    for my $arg (@{$args->[1]}) {
							#       push $args_lst, emit_expr_from_ast($arg);
							#    }
                            # if (grep {(not defined $_)} $args_lst){
							#     carp Dumper($ast,$args_lst);
                            # }
                            # say $args_lst.raku,join(',',|$args_lst);
							return $name ~ '(' ~ join(',',|$args_lst) ~')';
						} else {
							return $name ~ '(' ~ emit_expr_from_ast($args) ~')';
						}
					} else { # f(x)(y)
						#say Dumper($args);
						(my $sigil,my $args1, my $args2) = $args;
						my $args_str1='';
						my $args_str2='';
						if $args1[0] == 27 { #eq ',' 
							my $args_lst1=[];
							for 1 .. $args1.elems-1 -> $idx {
								my $arg = $args1[$idx];
								push $args_lst1, emit_expr_from_ast($arg);
							}
							$args_str1=join(',',|$args_lst1);

						} else {
							$args_str1= emit_expr_from_ast($args1);
						}
						if $args2[0] == 27 { #eq ','
							#say Dumper($args2);
							my $args_lst2=[];
							for 1 .. $args2.elems-1 -> $idx {
								my $arg = $args2[$idx];
								push $args_lst2, emit_expr_from_ast($arg);
							}

							#                for my $arg (@{$args2->[1]}) {
							#    push $args_lst2, emit_expr_from_ast($arg);
							#}
							$args_str2=join(',',|$args_lst2);
						} else {
							$args_str2=emit_expr_from_ast($args2);
						}
						return $name ~ '(' ~ $args_str1 ~ ')(' ~ $args_str2 ~  ')';
					}
				} else {
					return $name ~ '()';
				}
            } else {
#            	say Dumper($ast);
                (my $opcode, my $lexp, my $rexp) =@ast;
                my $lv = $lexp ~~ Array ?? emit_expr_from_ast($lexp) !! $lexp;
                my $rv = $rexp ~~ Array ?? emit_expr_from_ast($rexp) !! $rexp;
                return $lv ~ @sigils[$opcode] ~ $rv;
            }
        } elsif @ast.elems ==2 { #  for '{'  and '$'
            (my $opcode, my $exp) =@ast;
            if $opcode==0  {#eq '('
            # warn Dumper($exp);
                my $v = $exp ~~ Array ?? emit_expr_from_ast($exp) !! $exp;
                if (not defined $v) {
                    die(@ast.raku) if $DBG;
                }
                return "($v)";
            } elsif ($opcode==28 ) {#eq '(/'
                my $v = $exp ~~ Array ?? emit_expr_from_ast($exp) !! $exp;
                return "(/ $v /)";
            } elsif ($opcode==2 or $opcode > 28) {# eq '$' or constants    
                return ($opcode == 34) ??  "*$exp" !! $exp;            
            } elsif ($opcode == 21 or $opcode == 4 or $opcode == 3) {# eq '.not.' '-'
                my $v = $exp ~~ Array ?? emit_expr_from_ast($exp) !! $exp;
                return @sigils[$opcode] ~ $v;
            } elsif ($opcode == 27) { # ',' 
                die(@ast.raku) if $DBG ;
                my @args_lst=();
                for $exp -> $arg {
                    push @args_lst, emit_expr_from_ast($arg);
                }
                return join(',',@args_lst);        
            } else {
                die 'BOOM! ' ~ @ast.raku ~ $opcode if $DBG;
            }
        } elsif @ast.elems > 3 {

            if @ast[0] == 27 { # ','
                my @args_lst=();
                for 1 .. @ast.elems-1 -> $idx {
                    my $arg = @ast[$idx];
                    push @args_lst, emit_expr_from_ast($arg);
                }
                return join(',',@args_lst); 
            } else {
                die(@ast.raku) if $DBG;
            }
        }
    # } else {return @ast;}
} # END of emit_expr_from_ast




# This replaces _change_func_to_array
sub _replace_function_calls_in_ast($stref, $f,  $info, $ast, $exp, $grouped_messages_) {
    my $grouped_messages = $grouped_messages_;
    #say Dumper($ast);
    if $ast { 
        if $ast[0] == 1 or $ast[0] == 10 { # '&', function call; '@', array
           
            if $ast[0]== 1 {
                my $mvar = $ast[1];
                #say 'FUNCTION CALL: '.$mvar;
	            my $code_unit = sub_func_incl_mod( $f, $stref );
				# If the line is not a subroutine call, we set subname to #dummy#
				# We do this to check if the $mvar is maybe the subroutine itself
				my $subname =  ($info<SubroutineCall>:exists and $info<SubroutineCall><Name>:exists) ?? $info<SubroutineCall><Name> !! '#dummy#';
				# Now, when is $mvar NOT a function?
				# - if $mvar ne $subname including #dummy#, because this function is used for parsing both subcalls and assignments
				#	AND $mvar is not a called sub in $f AND $mvar is not an unmasked intrinsic
				# - if $mvar is in MaskedIntrinsics then it's a var masking an intrinsic
				# - if $f does not have a Called Sub named $mvar. Seems acceptable, but what if it's a function call and we have v = f(x) ?
				# So I say, if $mvar is the name of a subroutine in the whole source code base, and it's a function
				# 
                if (
 					(
 				# 1. $mvar is not a function, including intrinsic
 					not ( ($mvar eq $subname) or (
 					 $stref{$code_unit}{$mvar}:exists and 
 					 $stref{$code_unit}{$mvar}<Function>:exists and 
 					$stref{$code_unit}{$mvar}<Function> == 1 ) or (
 					%F95_intrinsics{$mvar}:exists or
 					%F95_function_like_reserved_words{$mvar}:exists # WV 2019-04-17
 					) 
 					)
 				# 2. OR $mvar is a masked intrinsic	 
 					or  $stref{$code_unit}{$f}<MaskedIntrinsics>{$mvar}:exists
 					) 
                ) {
            		# change & to @
                	$ast[0]=  10 + (($ast[0] +> 8) +< 8);#    '@';
    				say "\tFound array $mvar" if $DBG;
				} elsif (   	%F95_intrinsics{$mvar}:exists ) {
					say "parse_expression('$exp') " . __LINE__ if $DBG;
                    say "WARNING: treating $mvar in $f as an intrinsic! " if $DBG;
					$grouped_messages{'W'}{'VAR_AS_INTRINSIC'}{$mvar} =   "WARNING: treating $mvar in $f as an intrinsic! " if $WW;  
				} elsif (   	 %F95_function_like_reserved_words{$mvar}:exists ) {
					say "parse_expression('$exp') " . __LINE__ if $DBG;
                    say "Treating $mvar in $f as a function-like reserved word " if $DBG;
					$grouped_messages{'W'}{'VAR_AS_INTRINSIC'}{$mvar} =   "WARNING: Treating $mvar in $f as a function-like reserved word  " if $WW;  
				} else {
                    #say ' FUNCTION CALL';
					# So, this line contains a function call, so we should say so in $info!
					# I introduce FunctionCalls for this purpose!
					if (
					(  $stref{$code_unit}{$mvar} and $stref{$code_unit}{$mvar}{'Function'}:exists  
					  and $stref{$code_unit}{$mvar}{'Function'} == 1) # $mvar is def a function! 
					  and ( # 
						$mvar ne $subname 
# 						and not exists $stref->{$code_unit}{$f}{'CalledSubs'}{'Set'}{$mvar}
						and not  %F95_reserved_words{$mvar}:exists 					
						)
					) {
						my ( $expr_args, $expr_other_vars ) = find_args_vars_in_ast($ast[2]); # look only at the argument list
                        #say Dumper($expr_args);
						for $expr_args<List> -> $expr_arg {
							if  $expr_args<Set>{$expr_arg}<Type> eq 'Label' {
								my $label=$expr_arg;
								$stref{$code_unit}{$f}<ReferencedLabels>{$label}=$label;	
	
							}
						}
						push  $info<FunctionCalls>,  {
							'Name' => $mvar,
							'Args' => $expr_args,
							'ExprVars' => $expr_other_vars,
							'ExpressionAST' => $ast,						
						};	
						# Add to CalledSubs for $f
						if not $stref{$code_unit}{$f}{'CalledSubs'}{'Set'}{$mvar}:exists {
						push $stref{$code_unit}{$f}{'CalledSubs'}{'List'} , $mvar;
						$stref{$code_unit}{$f}{'CalledSubs'}{'Set'}{$mvar} = 2;
						}

						
						# Add $f to Callers for $mvar
						my $Sname =  $stref{'Subroutines'}{$mvar};
						$Sname{'Called'} = 1;
						if ( not  $Sname{'Callers'}{$f}:exists ) {
							$Sname{'Callers'}{$f} = [];
						}						
						push $Sname{'Callers'}{$f}, $info{'LineID'}; #the line number
						# Add to the call tree
						$stref = add_to_call_tree( $mvar, $stref, $f );							
							
					}
				} 
            } #else {
            #  say "\t".'ARRAY ACCESS: '.$ast->[1];
            #}
                (my $entry, $grouped_messages) = _replace_function_calls_in_ast($stref, $f,  $info, $ast[2], $exp, $grouped_messages);
                $ast[2]= $entry;
             
        } 
        elsif ( $ast[0] != 2 and $ast[0]  < 29) { # not a var or constant
            for 1 .. $ast.elems -1 -> $idx {
                (my $entry, $grouped_messages)  = _replace_function_calls_in_ast($stref, $f,  $info, $ast[$idx], $exp, $grouped_messages);
                $ast[$idx]= $entry;
            }
        }
    }
    return ($ast,$grouped_messages);
} # END of _replace_function_calls_in_ast

sub add_to_call_tree ( $f, $stref, $p) {
    push $stref<CallTree>{$p}, $f;
    return $stref;
}    # END of add_to_call_tree()



# if the expression is a sub call (or in fact just a comma-sep list), return the arguments and also all variables that are not arguments
# range(...) is one use case. I guess we don't even need that anymore
sub find_args_vars_in_ast ( $ast) {

    my $all_vars= ('List' => [], 'Set' => %());
    $all_vars{'Set'}=find_vars_in_ast($ast,%());
    
    
    my $args={'List'=>[],'Set'=>%()};
    $args{'Set'}=_find_args_in_ast($ast,%());
    $args{'List'} = [keys %{ $args{'Set'} }]; 
    for  $args{'List'} -> $arg {
    	if ( $all_vars{'Set'}{$arg}:exists ) {
    		 $all_vars{'Set'}{$arg}:delete;
    	}     	
    }
     
    $all_vars{'List'} = [keys %{ $all_vars{'Set'} }];
    return [$args,$all_vars];
} # END of find_args_vars_in_ast


# returns a hash of the var names
sub find_vars_in_ast ( $ast, $vars) {

  return %() unless $ast ~~ Array;
  if not $ast {
      return %();
  }
  if ( ($ast[0] ) == 1 or
       ($ast[0] ) == 10 ) { # array var or function/subroutine call
       
                if (($ast[0] ) == 10) { 
                my $mvar = $ast[1];
                $vars{$mvar}={'Type'=>'Array'};
                my $index_vars={};
                $index_vars =  find_vars_in_ast($ast[2],$index_vars);

                    for  keys $index_vars  -> $idx_var {
                        if ($index_vars{$idx_var}{'Type'} eq 'Array') {
                             $index_vars{$idx_var}:delete;
                        }
                    }                   
                    $vars{$mvar}{'IndexVars'} = $index_vars;
                } else {      
                    $vars = find_vars_in_ast($ast[2], $vars);
                }
  } elsif (($ast[0]) == 2) { # scalar variable
                my $mvar = $ast[1]; 
                if (not  $Config{'Macros'}{uc($mvar)}:exists ) {
                    $vars{$mvar}={'Type'=>'Scalar'} ;
                }      
  } elsif (($ast[0]) > 28) { # constants
    # constants
  } else { # other operators    
    for 1 .. $ast.elems-1 -> $idx {
        $vars = find_vars_in_ast($ast[$idx],$vars);        
    }
  }	

    return $vars;
} # END of find_vars_in_ast

# I'm only looking for arguments, so I don't bother with index vars
# Funny enough it seems I also need constant args because I look for ReferencedLabels
# I think only keeping these would be enough; and also maybe I should give them a proper Type and sigil
sub _find_args_in_ast ( $ast, $args) {
	if ! $ast { return $args; }
	if $ast[0] == 0 {	
	# descend
	   $args = _find_args_in_ast($ast[1], $args);
	} elsif $ast[0] == 27 {
		#process the list and collect any scalar or array
		for  1 .. $ast.elems-1 -> $idx {
			# This is a comma-sep arg list. We test for $ and @
			$args = _find_args_in_ast($ast[$idx], $args);
		}
	}
	elsif (($ast[0] & 0xFF)== 2) {
	        my $mvar = $ast[1];
	        $args{$mvar}={'Type'=>'Scalar'} ;
	    }
	elsif (($ast[0] & 0xFF)== 10) {
	        my $mvar = $ast[1];
	        $args{$mvar}={'Type'=>'Array'} ;
	}  
    elsif (($ast[0] & 0xFF) > 28) { # constants
    # constants
    my $mvar = $ast[1]; 
    $args{$mvar}= 'Type' => @sigils[ $ast[0] ] ;
    }	
    return $args;
} # END of _find_args_in_ast

sub sub_func_incl_mod ( $f, $stref ) {
    if (  $stref{'Subroutines'}{$f}:exists ) {
        if (not $stref{'Modules'}{$f}:exists ) {
            return 'Subroutines';
        } elsif ( $stref{'Subroutines'}{$f}{'Source'}:exists) {
                return 'Subroutines';
        } elsif ( $stref{'Modules'}{$f}{'Source'}:exists) {
            return 'Modules';
        }
#    } elsif ($stref{'Functions'}{$f} ) {
#        return 'Functions';
    } elsif ($stref{'IncludeFiles'}{$f}:exists ) {
        return 'IncludeFiles';
    } elsif ($stref{'Modules'}{$f}:exists ) { # So we only say it's a module if it is nothing else.
        return 'Modules';        
    } elsif ($stref{'SourceFiles'}{$f}:exists ) { # So we only say it's a module if it is nothing else.
        if ( $stref{'SourceFiles'}{$f}{'SourceType'}:exists and $stref{'SourceFiles'}{$f}{'SourceType'} eq 'Modules') {
        	return 'Modules';
        } else {
            return 'SourceFiles';
        }        
    } else {
#        #print Dumper($stref);
#        #croak "No entry for $f in the state\n";
        # Assuming it's a C function
#WV23JUL        
        return 'ExternalSubroutines';
    }
}
