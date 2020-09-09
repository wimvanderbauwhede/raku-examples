use v6;
role Fun2NumArgs[&b] {
    method unF( Numeric \x,  Numeric \y --> Numeric) {
        &b(x,y);
    }
    submethod CALL-ME( Numeric \x,  Numeric \y --> Numeric) {
        &b(x,y);
    }
}

role Fun2Args[&b] {
#method unF( Numeric \x,  Numeric \y --> Numeric) {
    method unF( \x,  \y --> Any) {
        &b(x,y);
    }
}

role Fun2ArgsC[&b] does Callable {
    submethod CALL-ME( \x,  \y --> Any) {
        &b(x,y);
    }
}


my \ft = Fun2NumArgs[ ->\x,\y {x*x+y*y} ].new;
my \ft2 = Fun2NumArgs[ ->\x,\y {x*y+y+x} ].new;

say ft.unF(3,4);

my &f =  -> Numeric \x, Numeric \y --> Numeric {x*x+y*y};

say f(3,4);

sub fof (Fun2NumArgs \f1, Fun2NumArgs \f2 --> Fun2NumArgs) {
    f1
}

say fof(ft,ft).unF(3,4);
my \fof2 = Fun2Args[ sub (Fun2NumArgs \f1,Fun2NumArgs \f2 --> Fun2NumArgs) {
    f2;
} 
].new;

say fof2.unF(ft,ft2).unF(3,4);

my &fof3 = Fun2ArgsC[ sub (Fun2NumArgs \f1,Fun2NumArgs \f2 --> Fun2NumArgs) {
    f2;
} 
].new;

say fof3(ft,ft2);
say fof3(ft,ft2)(3,4);
