use v6;

# Difference between () and []
# https://docs.raku.org/routine/[%20]
# Use of $()
# https://docs.raku.org/language/list#Itemization

#my @lst1 = 1,(2,3,(4,5));
#my \lst2 = |@lst1;# 1,(2,3,(4,5));

#say @lst1.raku; # (1, (2, 3, (4, 5)))
#say lst2.raku; # (1, (2, 3, (4, 5)))

#say  (-> **@lst {@lst}(|@lst1) == @lst1); # True
#say  (-> **@lst {@lst}(lst2) == lst2); # True
#exit;

enum Term <Var Par Const Pow Add Mult>;

sub VarT ($v) {
    (Var,$v)
}
sub ParT ($p) {
    (Par, $p)
}
sub ConstT ($c) {
    (Const,$c)
}
sub PowT ($m,$e) {
    (Pow,$m,$e)
}
sub AddT (**@ts) {
    (Add,@ts)
}
sub MultT (**@ts) {
    (Mult,@ts)
}

# a*x^2 + b*x + x
my \qterm1 = (Add, (
    (Mult, ( 
        (Par, "a"), 
        (Pow, (Var, "x"), (Const,2)) 
        )),
    (Mult,(
        (Par, "b"), 
        (Var, "x") 
        )),
    (Par, "c")
));

#   x^3 + 1    
my \qterm2 = (Add,(
    (Pow,
          (Var, "x"), 
          (Const,3)
      ), 
    (Const,1)
)
);

#   qterm1 * qterm2    
my \qterm3 = (Mult,( 
    qterm1, qterm2
));


# a*x^2 + b*x + x
my \qtermt1 = AddT(
    MultT( 
        ParT("a"), 
        PowT( VarT( "x"), ConstT(2)) 
        ),
    MultT(
        ParT("b"), 
        VarT("x") 
        ),
    ParT( "c")
);

#   x^3 + 1    
my \qtermt2 = AddT( 
    PowT( 
          VarT("x"), 
          ConstT(3)
          ), 
    ConstT(1)    
);

#   qtermt1 * qtermt2    
my \qtermt3 = MultT( 
    qtermt1, qtermt2
);

my @qt4 = Add,[(Pow, $(Var,'x'),$(Const,2)),$(Const,1)];
my @qt4s = Add,[(Pow, [Var,'x'],[Const,2]),[Const,1]];
my @qt4t = AddT(PowT(VarT('x'),ConstT(2)),ConstT(1));
say @qt4.raku;
say @qt4s.raku; # is not the same!
say @qt4t.raku;

say qterm1.raku;
say qtermt1.raku;
say qterm2.raku;
say qtermt2.raku;
say qterm3.raku;
say qtermt3.raku;
