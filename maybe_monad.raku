use v6;

# The Maybe type, a polymorphic algebraic data type
role Maybe[::a] { }
role Nothing[::a] does Maybe[a] { }
role Just[::a \v] does Maybe[a] { 
    has a $.just = v;
}

# The bind and return operations
sub bind(Maybe \mx,\f --> Maybe ) {
    given  mx {
        when Just {f.(mx.just)}
        when Nothing { mx}
    }
}

# return
sub wrap(\x) { Just[x].new }

# A convenience function which unwraps Just and returns Nil for Nothing   
sub unwrap(Maybe \mx) {
    given  mx {
        when Just { mx.just }
        when Nothing { Nil }
    }
}
# Let's create some nice operators
sub infix:<⊳>( \mx,\f ) is assoc<left> {
    bind(mx,f)
}
sub infix:<⧐>( \x,\f ) is assoc<left> {
    bind(wrap(x),f)
}
 
sub prefix:<⧏>( \mx ) is looser(&infix:<⧐>) {
    unwrap(mx)
}

# Some example functions. I use lambda functions so I don't have to write the '&'
my \f = sub (Int \x --> Maybe[Int]) { Just[x].new }
my \g = sub (Int \x --> Maybe[Real]) {
    if x==43 {
        Nothing[Real].new
    } else {
        Just[2.0*x].new
    }
}
my \h = sub (Real \x --> Maybe[Str]) {
    if x==44 {
        Nothing[Str].new
    } else {
        Just["{2+x}"].new
    }
}
    
# And here is our final monadic computation    
# The type signature works because returning Nil is not a type error
sub comb_m(Int \x --> Str) {
    ⧏ x ⧐ f ⊳ g ⊳ h
}
    
say comb_m(42);
say comb_m(43);
