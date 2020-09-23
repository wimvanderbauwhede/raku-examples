use v6;

=begin
In previous articles I have explained two approaches to creating algebraic data types in Raku. They are fine from a static typing perspective, and provide pattern matching against the type alternatives.
But as we have seen, they have the disadvantage of being rather slow. In this article I will create an alternative for the parse tree data structure which provides the same presentation but is much faster.

The idea is very simple: I use nested lists as the data structure, making use of Raku's dynamic typing. The first element of the list is an `enum` indicating which alternative in a sum type we have selected. 
The other elements are the actual values stored in the data structure. So a Maybe type will be

enum Maybe <Just Nothing>;

my $just_42 = Just,42;
my $nothing = Nothing

To make this nicer we create some wrapper functions:

sub Just($x) {
    Just,$x
}

And (redundant in this case of course):

sub Nothing { Nothing } 





=end

my $nruns=200;

# Bare

# 200
# 390600

# real	0m0.522s
# user	0m0.838s
# sys	0m0.032s

# With functions

# 200
# 390600

# real	0m0.533s
# user	0m0.871s
# sys	0m0.016s


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

sub Var ($v) {
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


sub ppTerm(\t) {
    
    given t[0] {
        when Var { t[1] }
        when Par { t[1] }
        when Const { "{t[1]}" }
        when Pow { ppTerm(t[1])  ~ '^' ~ ppTerm(t[2]) }
        when Add {
            my @pts = map {ppTerm($_)}, |t[1];
            "("~join( " + ", @pts)~")"
        }
        when Mult { 
    #         say t[1];
    # exit;
            my @pts = map {ppTerm($_)}, |t[1];
            join( " * ", @pts)
        }
    }
}

# Evaluate a Term 

sub evalTerm(%vars, %pars,  \t) {    
    given t[0] {
        when Var { %vars{t[1]} }
        when Par { %pars{t[1]} }
        when Const { t[1] }
        when Pow { evalTerm(%vars, %pars,t[1])  ** evalTerm(%vars, %pars,t[2]) }
        when Add {
            my @pts = map {evalTerm(%vars, %pars,$_)}, |t[1];
            [+] @pts
        }
        when Mult { 
            my @pts = map {evalTerm(%vars, %pars,$_)}, |t[1];
            [*] @pts
        }
    }
}


my @strs=();
my @vals=();
for 1 .. $nruns -> $c {
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
    (Const,$c)
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
        PowT( Var( "x"), ConstT(2)) 
        ),
    MultT(
        ParT("b"), 
        Var("x") 
        ),
    ParT( "c")
);

#   x^3 + 1    
my \qtermt2 = AddT( 
    PowT( 
          Var("x"), 
          ConstT(3)
          ), 
    ConstT($c)    
);

#   qtermt1 * qtermt2    
my \qtermt3 = MultT( 
    qtermt1, qtermt2
);

# my @qt4 = Add,[(Pow, $(Var,'x'),$(Const,2)),$(Const,1)];
# my @qt4s = Add,[(Pow, [Var,'x'],[Const,2]),[Const,1]];
# my @qt4t = AddT(PowT(VarT('x'),ConstT(2)),ConstT(1));

# say @qt4.raku;
# say @qt4s.raku; # is not the same!
# say @qt4t.raku;

# say qterm1.raku;
# say qtermt1.raku;
# say qterm2.raku;
# say qtermt2.raku;
# say qterm3.raku;
# say qtermt3.raku;

my $str = ppTerm( qtermt3);
push @strs, $str;

my $val = evalTerm(
    {"x" => 2}, {"a" =>2,"b"=>3,"c"=>4},  qtermt3
);
push @vals, $val;
# say $str, $val; exit;

}

say @strs.elems;
say [+] @vals;
