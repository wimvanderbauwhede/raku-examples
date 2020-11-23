use v6;
use Expressions;
$Expressions::defaultToArrays=1;
our $Config=%();
for 1..1000 {
for 
    'z(j+i,k*km)*p(i+1,j+jm)','i+1','v( i + 1 )','z','z(j,k)','j+k','i-im',        
        "5+42+ +6/42/44-45*7", '6*7', '44 - -2', '(1+2*3)+3+4/5','4+(22*(33*44+1)+77)/2',
      '1 .and. .not. 0','1 <= 2', '(3.5 < 4) .or. (1 == 0.0)',
    '*8','RANK ( N, *8, *9 )','f(x)(y)', 'a**b**3', 'B .and. .not. A .or. C','.not.A .and. B','A(I,J,K)(M+N,1)', 'dimension(0:im,-1:jm)','a(1,1)', 'A(1,J,K)(M:N,1)', 'f(x+2,1)(v,12)','time',
    '((-beta-(beta*beta-2.*alpha)**(0.5))/alpha).lt.dt',
    '((-beta - (beta*beta-2.*alpha)**(0.5))/alpha).lt.dt',
    '-beta - beta','range(i,1,im,j,1,jm,k,1,km)',
    'print(__PH0__)','(((u(i,j,k),i=1,im),j=1,jm),k=1,km)',
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
    'time'
    -> $str
    {
			(my $ast, my $rest, my $err) = parse_expression_no_context($str); # 12/12 s
            ($ast, my $acc) = _traverse_ast_with_action($ast,%(), &collect_vars ); # 22/21/22 s => 10 s
            # my $vars = _find_vars_in_ast( $ast, {} ); # 16/17/16 s => 4 s
            # say 'VARS'; 
            # say ($vars.raku);die;
            # say 'ACC';
            # say ($acc.raku);die;

}

}
sub collect_vars ($ast_, $acc_) {
    my $ast=$ast_;
    my $acc=$acc_;
    if ($ast[0]==2) {
        my $mvar = $ast[1]; 
        if (not  $Config{'Macros'}{uc($mvar)}:exists ) {
            $acc{$mvar}={'Type'=>'Scalar'} ;
        }      
    }
    elsif ($ast[0]>28) {
        # constants
        # my $mvar = $ast[1]; 
        # $acc{$mvar}= {'Type'=>@sigils[ $ast[0] ] };
    }
    elsif ($ast[0]==10) {
        #say '@'.$ast[1];
        my $mvar = $ast[1];
        $acc{$mvar}= {'Type'=>'Array', 'IndexVars' => {} };
        # Handle IndexVars
        # my $index_vars={};
        
        (my $ast3,my $index_vars) =  _traverse_ast_with_action($ast[2],{},&collect_vars);

        for  keys $index_vars  -> $idx_var {
            if $index_vars{$idx_var}{'Type'} eq 'Array' {
                $index_vars{$idx_var}:delete;
            }
        }          
        $acc{$mvar}{'IndexVars'} = $index_vars;
    } 


    #else {
    #say $sigils[$ast[0]];
    #}
    return $acc;
}


sub _traverse_ast_with_action($ast_, $acc_, &f) {
    my $ast=$ast_;
my $acc=$acc_;
  return $acc unless $ast ~~ Array;
  if not $ast {
      return $acc;
  }

  if ( ($ast[0] ) == 1 or
       ($ast[0] ) == 10 ) { # array var or function/subroutine call
        $acc=&f($ast,$acc);
        (my $entry, $acc) = _traverse_ast_with_action($ast[2],$acc, &f);
        $ast[2] = $entry;

  } elsif (($ast[0] ) == 2) { # scalar variable
    $acc=&f($ast,$acc);
  } elsif (($ast[0] ) > 28) { # constants
    $acc=&f($ast,$acc);

#   if <cond> { 
# 		$acc=&f($ast,$acc);
  } else { 
     $acc=&f($ast,$acc);
	for  1 .. $ast.elems - 1  -> $idx {
		(my $entry, $acc) = 
            _traverse_ast_with_action($ast[$idx],$acc, &f);
		$ast[$idx] = $entry;
	}
  }
  return ($ast, $acc);
} 


# returns a hash of the var names
sub _find_vars_in_ast ( $ast, $vars_) {
    my $vars=$vars_;
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
        $index_vars =  _find_vars_in_ast($ast[2],$index_vars);

        for  keys $index_vars  -> $idx_var {
            if ($index_vars{$idx_var}{'Type'} eq 'Array') {
                    $index_vars{$idx_var}:delete;
            }
        }                   
        $vars{$mvar}{'IndexVars'} = $index_vars;
    } else {      
        $vars = _find_vars_in_ast($ast[2], $vars);
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
        $vars = _find_vars_in_ast($ast[$idx],$vars);        
    }
  }	

    return $vars;
} # END of _find_vars_in_ast