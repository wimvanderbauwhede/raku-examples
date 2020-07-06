use v6;
use ListBasedCombinators;

# sub seq {
# 	my \ps = @_;
# 	sequence( Array[LComb](ps) );
	
# }

# sub choice_ {
# my \ps = @_;
# choice( Array[LComb](ps));

# } 
my $str = 'hello, world';
say apply word,$str;
my $str2 = ';hello, world';
say apply word,$str2 ;

#my LComb @ws = (word,word);
#sequence(@ws);
say "test seq";
my $str3 = 'hello, world; answer = 42';
my $ms = apply
	#sequence( Array[LComb](
		sequence(
		word, comma, word, 
		semi, 
		word, symbol('='),natural  ), $str3
;
multi sub defMatch(Match[Str] $m) { True }
multi sub defMatch(UndefinedMatch $u) { False }


say $ms.matches.grep: Match[Str];
say map {.match} ,grep Match[Str], |$ms.matches;


my $str4 = 'answer = hello( world)';
my $ms4 = apply(
	sequence( #Array[LComb](
		word, symbol('='), word, parens(word)
		#) 
    ), $str4
);
say $ms4;
say map {.match} ,grep Match[Str], |$ms4.matches;
my \type_str = "integer(kind=8), ";
my \test_parser = 
  sequence(
    whiteSpace,
    # Tag[ "Type", word].new,
    tag("Type",word),
    word,
    word,
    symbol( "="),
    natural
  );

my \type_parser =     
    sequence(
        Tag[ "Type", word].new,
        maybe( parens( 
            choice( 
                Tag[ "Kind" ,natural].new,
                sequence(
                    symbol( "kind"),
                    symbol( "="),
                    Tag[ "Kind", natural].new
	              )
              )
            )
          )
      ); 

my $resh1 =  apply( test_parser, "   hello world   spaces =  7188 .");
say $resh1.raku;
# my $resh2 = apply( type_parser, type_str);   
my (\tpst,\tpstr,\tpms) = unmtup apply( type_parser, type_str);# $resh2;   
say 'Matches: ',tpms;
# apply (sepBy (symbol "=>") word) "Int => Bool => String"    
# apply (sequence [oneOf "aeiou", word]) "aTest"    
#    let
#        MTup (st,str,ms) = apply (sequence [word, symbol "=", word,parens word]) "answer = hello(world)"  
# (st,str,ms)        
say getParseTree( tpms);
