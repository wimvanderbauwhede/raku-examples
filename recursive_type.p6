use v6;

role FName { }
role Single[$str] does FName { 
    has $.single = $str;#is rw;
}
role Composite[@vs] does FName { 
    has FName @.composite=@vs;# is rw;
}
my FName @strs2 = (Single['b1'].new,Single['b2'].new);
my @strs = (Single['a'].new,Composite[@strs2].new);
my  $rec_type = Composite[@strs].new;
#say $rec_type;

    
multi sub  show (Single[Str] $nm) { $nm.single } ;
multi sub  show (Composite[Array] $nms) {
    join( ", ", map &show, $nms.composite);
};

say show( $rec_type);