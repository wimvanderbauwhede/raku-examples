use v6;

my Int @tags = 1..20;
# Sum them all:
say [+] @tags;

sub f(Int $x -->Bool) {$x==7}

my Bool $res1 = False;
for @tags -> $t {
    if (f($t)) { 
        $res1= True;
        last;
    }
}
sub g(Bool $x, Bool $y --> Bool) { say $x,$y;$x||$y}
#my $res3 = reduce &g, map &f,@tags;
my @bs = map &f,@tags;

my &curried_fold = &reduce.assuming(&g);
my &curried_map = &map.assuming(&f);

my $res2 = so [|] map &f,@tags;
#say $res3;
say $res1==$res2;

my &ff := &substr.assuming('Hello, World');
say (&curried_fold o &curried_map)(@tags);                # ∘ 

say ( &reduce.assuming(&g) o  &map.assuming(&f) )( @tags );
say ( *.reduce(&g) ∘  *.map(&f) )( @tags );

