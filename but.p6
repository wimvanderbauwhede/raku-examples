use v6;
subset UInt of Int where sub ($x) {$x <= 0}
my Complex $c = 4.0+2.0i;
my Int $x = 42 but 'forty-two' ;

say "Value is $x";

#my Complex $cc = $x;
say $c+$x;
