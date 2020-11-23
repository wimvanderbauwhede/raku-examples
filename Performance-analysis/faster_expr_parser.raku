use v6;
use MONKEY-SEE-NO-EVAL;
use Expressions;
$Expressions::defaultToArrays=1;

for  
    'a1_i* 42 + bbx',
    '(x+y)',
    'f(x,y)',
    'z(j+i,k*km)*p(i+1,j+jm)',
    'i+1',
    '( i + 1 )',
    'v( i + 1 )',
    'z',
    'z(j,k)',
    'j+k',
    'i-im' 
    -> $str_  {
    print "$str_\t"; 
    my $str=$str_;
    my ( $ast, $rest, $err) = parse_expression_no_context($str);#*p(i+1,j+jm)');
    if $err {
        say 'ERROR' 
    } else {
        # say "AST: " ~ $ast.raku;
        my $estr=emit_expr_from_ast($ast);
        # say 'EMIT: ' ~ $estr;
        my $sstr=$str;
        $sstr .= trans(' ' => '');
        say $sstr eq $estr ?? 'OK' !! 'NOK: ' ~ $sstr ~ '<>' ~ $estr;
        # die;
    }
}
# die;
for 
    "5+42+ +6/42/44-45*7", 
    '6*7', 
    '44 - -2', 
    '(1+2*3)+3+4/5',
    '4+(22*(33*44+1)+77)/2' 
    -> $str {
    print "$str\t";
    #say "\nTEST: $str";
    (my $ast, my $rest, my $err) = parse_expression_no_context($str);
    if ($err) {say 'ERROR' } else {
        # say "AST: " ~ $ast.raku;
        my $estr=emit_expr_from_ast($ast);
        #say 'EMIT: '.$estr;

    
    #say Dumper(@ast);
    my $r1 = EVAL($str);
    my $r2 = interpret($ast);
    say $r1==$r2 ?? 'OK' !! 'NOK ' ~ $r1 ~ '<>' ~ $r2;
        my $sstr=$str;
        $sstr .= trans(' ' => '');
        say $sstr eq $estr ?? 'OK' !! 'NOK: '  ~ $sstr ~ '<>' ~ $estr;
        #say $sstr eq $estr ? 'OK' : 'NOK';
    }
}

for 
    '1 .and. .not. 0',
    '1 <= 2', 
    '(3.5 < 4) .or. (1 == 0.0)' 
    -> $str {
    print "$str\t";

    #    say "\nTEST: $str";
    (my $ast, my $rest, my $err) = parse_expression_no_context($str);
    if ($err) {say 'ERROR' } else {
        #say "AST: ".Dumper($ast);
        my $estr=emit_expr_from_ast($ast);
        #say 'EMIT: '.$estr;

    my $str2=$str;
    $str2 ~~s:g/\.$<a> = [<alpha>+]\./$<a>/;
    $str2~~s/not/!/;
    # say "\n",$str2;
    # say $ast.raku;
    # say EVAL($str2);
    #    say interpret($ast);
    my $r1 = EVAL($str2);
    my $r2 = interpret($ast);
    say $r1==$r2 ?? 'OK' !! 'NOK '~$r1~'<>'~$r2;
    my $sstr=$str;
    $sstr .= trans( ' ' => '');
    say $sstr eq $estr ?? 'OK' !! 'NOK: '~$sstr~'<>'~$estr;
    #say $sstr eq $estr ? 'OK' : 'NOK';
    # die;
    }
}
# die;

for 
    '*7188',
    '*42',
    '*8',
    'RANK ( N, *8, *9 )',
    'f(x)(y)', 
    'a**b**3', 
    'B .and. .not. A .or. C',
    '.not.A .and. B',
    'A(I,J,K)(M+N,1)', 
    'dimension(0:im,-1:jm)',
    'a(1,1)', 'A(1,J,K)(M:N,1)', 'f(x+2,1)(v,12)', 'time',
    '((-beta-(beta*beta-2.*alpha)**(0.5))/alpha).lt.dt',
    '((-beta - (beta*beta-2.*alpha)**(0.5))/alpha).lt.dt',
    '-beta - beta', 'range(i,1,im,j,1,jm,k,1,km)',
    'print(__PH0__)', '(((u(i,j,k),i=1,im),j=1,jm),k=1,km)',
    '( 3.14 , 2.7e-3)',
    '(/ 3.14 , 2.7e-3 /)',
    "[ 'A3.14' , 'B2.7e-3' ]",
    'u(i+1,j+jm)',
    'a,b',
    'WRITE(*,*)',
    '*, I, J, ( VECTOR(I), I = 1, 5 )',
    'p(i-1,j+jm,0)',
    'lhs_var',    
    "READ( 3, '(5F4.1)')",
    'READ( 1, 2, ERR=8, END=9, IOSTAT=N ) X',
    'READ( 1, 2, ERR=8, END=9, IOSTAT=N ) X, Y',
    'READ FMT, A, V',
    'READ *, A, V',
    'READ *, AV',
    'READ( *, * )',
    'READ( *, FMT )',
    'READ( *)',
    'time',
    '2*v+1',
    "READ( 3, 5E1)",
    "( 3, 5E1)",
    "5E1"
    -> $str {
	for 1 -> $tt {
		if $tt==1 {
            #    say "\nTEST: $str";
            print "$str\t";
            
            (my $ast, my $rest, my $err) = parse_expression_no_context($str);
            # say "AST: " ~ $ast.raku;
            if ($err or $rest ne '') {say 'ERROR: <'~$rest~'>' } else {
                my $estr=emit_expr_from_ast($ast);
                my $sstr=$str;                
                $sstr .= trans( ' ' => '');
                $sstr .= subst('.lt.','<');
                say $sstr eq $estr ?? 'OK' !! 'NOK: '~ $sstr~'<>'~$estr;
            }
		} else {
			(my $ast, my $rest, my $err) = parse_expression_no_context($str);#*p(i+1,j+jm)');
        #say "AST: ".Dumper($ast);
			if ($err or $rest ne '') {
                say 'ERROR: <' ~ $rest ~ '>' ;
            } else {
                say $ast.raku;
			}
		}
	}
    # die;
}

sub ff ($ast, $acc) {
    if $ast[0] ==2 {
        say '$' ~ $ast[1];
    }
    elsif $ast[0] > 28 {
        say @sigils[$ast[0]] ~ ' ' ~ $ast[1];
    }
    elsif $ast[0] ==10 {
        say '@' ~ $ast[1];
    } else {
    say @sigils[$ast[0]];
    }
    return $acc;
}

