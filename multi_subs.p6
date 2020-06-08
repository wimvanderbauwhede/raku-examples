use v6;

role ComplexInt {
    has Int $.r;
    has Int $.c
}

multi sub metric (Int \x, Int \y) returns Int { x*x+y*y }
multi sub metric (ComplexInt \x, ComplexInt \y) returns ComplexInt { 
    ComplexInt.new(r => x.r*y.r+x.c*y.c, c=> x.r*y.c+x.c*y.r) 
}

my Int \vi = metric(4,5);
my ComplexInt \vc= metric(ComplexInt.new(r=>1,c=>2),ComplexInt.new(r=>5,c=>6));

say vi;
say vc
