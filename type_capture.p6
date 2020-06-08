use v6;

sub f(::T $p1, T $p2, &g, ::C)  {
    my C $c = g($p1, $p2);
    return sub (T $p1)  {
        return $c * $p1; 
    }
}

my &h1 = f(42, 2, sub ($t,$n) {$t/$n},Rat); say h1(2); # 42
my &h2 = f(48.0 ,3.5, sub ($t,$n) {$t*$n}, Rat); say h2(0.25); # 42
my &h3 = f(3 ,7, sub ($t,$n) {$t*$n}, Int); say h3(2); # 42
my &h1a = f(42, 2, sub ($t,$n) {$t/$n},1/2); say h1a(2); # 42


#my Callable[Str] $h0  = sub (Int $x) { return "$x" }
my Callable[Str] $h4  = sub (Int $x) returns Str { return "$x" }
my Callable[Str] $h5  = sub (Int $x --> Str) { return "$x" }
my Sub $h6 = sub (Int $x) { return "$x" }
sub h7 (Int $x --> Str) {$x+1}

my Str $v = $h4(42);
my Str $v1 = $h5(42);
my Str $v2 = $h6(42);

sub f3(::T $p1, T $p2, &g, ::C, ::R)  {
    my C $c = g($p1, $p2);
    return sub (T $p1)  {
        my R $res = $c * $p1;return $res;
    }
}


sub typed_map(@lst, &f,::T1, ::T2) {
    my @res=();
    for @lst -> T1 $elt { my T2 $r=f($elt); @res.push($r) };
    return @res;
}

sub g (Int $x -->Str) {"$x"}

my Str @res = typed_map(1..10, &g,Int,Str);
say @res;

