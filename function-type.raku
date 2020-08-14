use v6;
role Fun2Args[&b] {
#method unF( Numeric \x,  Numeric \y --> Numeric) {
    method unF( \x,  \y --> Any) {
        &b(x,y);
    }
}

my \ft = Fun2Args[ ->\x,\y {x*x+y*y} ].new;

say ft.unF(3,4);

my &f =  -> Numeric \x, Numeric \y --> Numeric {x*x+y*y};

say f(3,4);

sub fof (Fun2Args \f1,Fun2Args \f2 --> Fun2Args) {
    f1
}

say fof(ft,ft).unF(3,4);
my \fof2 = Fun2Args[ sub (Fun2Args \f1,Fun2Args \f2 --> Fun2Args) {
    f1;
} 
].new;

say fof2.unF(ft,ft).unF(3,4);
