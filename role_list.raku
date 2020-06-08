use v6;

role RList[::a $vs] {
	has $.vs = $vs;
}

my RList[Int] \vs = RList[ [1,2,3,4] ].new;

say vs.raku;
