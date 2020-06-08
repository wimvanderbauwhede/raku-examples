use v6;

role Test[@a]{
	has @.vs = @a;
}
my @a = 1,2,3;
my Test $t = Test[@a].new;

say @a;
say $t.vs;
say @($t.vs);
