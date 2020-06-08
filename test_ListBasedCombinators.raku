use v6;
use ListBasedCombinators;

my $str = 'hello, world';
say apply word,$str;
my $str2 = ';hello, world';
say apply word,$str2 ;

#my LComb @ws = (word,word);
#sequence(@ws);
say "test seq";
my $str3 = 'hello, world; answer = 42';
my $ms = apply(
	sequence( Array[LComb](
		word, comma, word, 
		semi, 
		word, symbol('='),natural) ), $str3
);
multi sub defMatch(Match[Str] $m) { True }
multi sub defMatch(UndefinedMatch $u) { False }


say $ms.matches.grep: Match[Str];
say map {.match} ,grep Match[Str], |$ms.matches;


my $str4 = 'answer = hello( world)';
my $ms4 = apply(
	sequence( Array[LComb](
		word, symbol('='), word, parens(word)
		) ), $str4
);
say $ms4;
say map {.match} ,grep Match[Str], |$ms4.matches;
