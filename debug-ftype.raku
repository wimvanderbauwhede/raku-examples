use v6;


my &f1 = sub {};
my Callable \f2 = sub {};
my Callable $f3 = sub {};
say '&f';
say &f1.WHAT;
say 'Callable \f';
say f2.WHAT;
say 'Callable $f';
say $f3.WHAT;

say '----';
sub sqsum(Int \x, Int \y --> Int) { x*x+y*y }
say "type of sqsum: ",  &sqsum.WHAT;
say '----';
# ===SORRY!=== Error while compiling /home/wim/Git/raku-examples/debug-ftype.raku
# Undeclared routine:
#     f used at line 11

# sub ten_times_sigil-less (Callable \f:(Int,Int --> Int) ) { # OK!
# f.(3,4);
# }

# So the adverb syntax does not work, we need the where clause
sub ten_times_sigil-less (Callable \f where { f.signature ~~ :(Int,Int --> Int) }) { # OK!
f.(3,4);
}

say 'ten_times_sigil-less(&sqsum)';
say ten_times_sigil-less(&sqsum); # 25

say "type of ten_times_sigil-less: ",  &ten_times_sigil-less.WHAT;
say '----';

# Cannot unpack or Capture `&sqsum`.
# To create a Capture, add parentheses: \(...)
# If unpacking in a signature, perhaps you needlessly used parentheses? -> ($x) {} vs. -> $x {}
# or missed `:` in signature unpacking? -> &c:(Int) {}
#   in sub ten_times_scalar at debug-ftype.raku line 21
#   in block <unit> at debug-ftype.raku line 25

# sub ten_times_scalar (Callable $f:(Int,Int --> Int)-->Int) { # WRONG!
# $f.(3,4);
# }
# # Goes wrong here:
# say ten_times_scalar(&sqsum);

# OK
sub ten_times (&f:(Int,Int --> Int)-->Int) {
    f(3,4);
}
say 'ten_times(&sqsum)';
say ten_times(&sqsum); # 25

say "type of ten_times: ",  &ten_times.WHAT;


say '----';
# bbj :: b -> ((b->a)->a)
# returns a function that takes a function b->a and returns its application 
# sub bbj(Any \x --> Callable) { 
sub bbj( \x) { 

    sub ( Callable \j 
    where {j.signature ~~ :(Any --> Any )} 
    --> Any) { j.(x) } 
}
say "Type of bbj: ",  &bbj.WHAT;
say "Sig of bbj: ", &bbj.signature;
say 'bbj(42)';
my $v=42;
say bbj($v); # sub {}
# res :: (b->a)->a
my Callable \res = bbj($v);
say 'my &res = bbj(42)';
say res; # sub {}
say 'Type of res: ',res.WHAT;
say 'Sig of res: ',res.signature;
say '----';

say "res id:";
say res.( -> Any \x --> Any { x } ); # 42
say '----';

# mbb  :: ((b -> a) -> a) --> a
sub mbb_nt ( &jm, &f --> Any ) {
    # 42;
    jm(&f);
}

say 'Type of mbb: ', &mbb_nt.WHAT;

say "mbb res:";
say mbb_nt( res,  -> Any \x --> Any { x } );
say '----';

# mbb  :: ((b -> a) -> a) -> (b -> a) -> a
#where { &jm.signature ~~ :((Any --> Any) --> Any)}
sub mbb ( 
    Callable[Any]
      \jm 
    # where { jm.signature ~~  Any } 
    # where { jm.signature ~~ :(Callable --> Any) } 
    # where { jm.signature ~~ :(Callable \j where {j.signature ~~ :(Any --> Any )} --> Any ) } 
,  
&f:(Any --> Any) 
--> Any ) {
    say 'Type of jm: ',jm.WHAT;
    say 'Sig of jm: ',jm.signature;
    jm.(&f);
}

sub ff (Any \x --> Any) {x}
say 'Type of mbb: ', &mbb.WHAT;
# say 'mbb: ',&mbb.signature;
say 'Sig of res: ',res.signature;
# say 'ff: ',&ff.signature;


say mbb( res,  &ff);


 say mbb( res,  -> Any \x --> Any { x });

say '=========';

# I would like the generated function to be constrained as Int -> Any 
# gen :: b -> ((b -> a) -> a)
sub gen( Int \x --> Callable) { 
    # (b -> a) -> a
    sub (  Callable \j where { j.signature ~~ :(Any --> Any) } --> Any  ) { j.(x) } 
    # sub (  &j   ) { j(x) } 

}

# fres :: (b -> a) -> a
my Callable \fres = gen(42);    
# id : a -> a
my Callable \lid = -> Any \x --> Any {x};
# Note this does not work:
# my \lid = -> \x {x};

sub t (  Callable \j where { j.signature ~~ :(Any --> Any) }  --> Any ) { j.(33) } 



sub id ( Any \x --> Any ) {x};
# Note this does not work:
# sub id ( \x  ) {x};

say fres.(&id);
say fres.(lid);
say t(&id);
say t(lid);
# \j where { j.signature ~~ :(Any --> Any) }
sub apply ( &g:( &j:(Any --> Any)   --> Any ) --> Any
    # Any &g
#   where { g.signature ~~ :(
#       Callable 
# \j 
#   where { j.signature ~~ :(Any --> Any) } 
#   --> Any)  }
# , &f:(Any --> Any)  
# , Callable \f where { f.signature ~~ :(Any --> Any)  }

) {
    say &g.signature;
    say &g.WHAT;
    # g(&id);
}
say '=========';
# sub g (           &j:(Any-->Any) --> Any  ) { 
#     j(33);
#  } 
sub apply_ (Any &g
# :( &j:(Any-->Any) --> Any)  
--> Any) { 
    g(&id);
} 
say apply_( 

    sub  (           &j:(Any-->Any) --> Any  ) { 
        j(33);
    } 

);



# say apply_( &g);

my \true  = -> Any \t, Any \f --> Any { t }
my \false = sub (Any \t,Any \f --> Any ) { f }

role PairBB[ &p ] {
    # has $.unPairBB = p;
    method unPairBB(&p_:(Any,Any --> Any)  --> Any) {
        p(&p_);
    }

# To get the elements out of the pair
method fst_( ){ self.unPairBB(true) }
method snd_( ){ self.unPairBB(false) }

}

# To get the elements out of the pair
sub fst( \p ){ p.unPairBB(true) }
sub snd( \p ){ p.unPairBB(false) }

# Final pair constructor

sub pair(\x,\y --> PairBB) {
    PairBB[ -> \p { p.(x, y) } ].new;
}

my PairBB \bbp = pair 42,"forty-two";

say fst bbp ;
say snd bbp ;

say bbp.fst_  ;
say bbp.snd_  ;


  
role BoolBB[&b] {
    method unBoolBB(Any \t, Any \f --> Any) {
        b(t,f);
    }
}


# my \true  = -> Any \t, Any \f --> Any { t }
# my \false = sub (Any \t,Any \f --> Any ) { f }

sub bbb(\tf --> BoolBB) { BoolBB[ tf ].new };
my BoolBB \BBTrue = bbb true;
my BoolBB \BBFalse = bbb false;

my BoolBB \trueBB = BBTrue;


sub boolBB (Bool \tf --> BoolBB){ tf ?? BBTrue !! BBFalse }
sub bool(BoolBB \b --> Bool) { 
    b.unBoolBB(  True, False) 
}
say bool BBTrue; # => True
say bool BBFalse; # => False
say bool boolBB( bool BBTrue); # => True
say bool boolBB( bool BBFalse); # => False
