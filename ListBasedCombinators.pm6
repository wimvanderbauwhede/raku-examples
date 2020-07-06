use v6;
#unit module ListBasedCombinators; # This doesn't work because of the roles

# The following is purely as documentation, none of these prototypes are needed.
# This must be declared
role LComb {...}
sub sequence (Array[LComb] --> LComb) {...}
# sub sequence_ (LComb --> LComb) {...}
sub parens (LComb --> LComb)  {...}
sub word (--> LComb) {...}
sub natural (--> LComb) {...}
sub comma (--> LComb) {...}
sub semi (--> LComb) {...}
sub symbol (Str --> LComb) {...}
sub char(Str --> LComb) {...}
sub whiteSpace (--> LComb) {...}

sub sepBy (LComb--> LComb) {...}
sub oneOf (Str --> LComb) {...}
sub greedyUpto (Str --> LComb) {...}
sub upto (Str --> LComb) {...}
sub many (LComb --> LComb) {...}
sub many1 (LComb --> LComb) {...}
# sub choice () {...}
sub choice( Array[LComb] --> LComb) {...} 
# sub choice ([LComb] --> LComb) {...}
sub try (LComb --> LComb) {...}
sub maybe (LComb --> LComb) {...}

role MTup {...}
multi sub apply(LComb, Str --> MTup) {...}

## Roles as algebraic datatypes
# Matches
role Matches {}
role Match[Str $str] does Matches {
    has Str $.match=$str;
} 
role TaggedMatch[Str $tag, Array[Matches] \ms] does Matches {
    has Str $.tag = $tag;
    has Matches @.matches = ms;
} 
role UndefinedMatch does Matches {}
# convenience
sub undef-match {
	my Matches @um = (UndefinedMatch.new);
	return @um;
}
sub empty-match {
	#my Array[Matches] $em = Array[Matches].new;
	#return $em;
	Array[Matches].new;
}

# Tuple to return (status, remaining string, matches)
role MTup[Int $st,Str $rest,Array[Matches] $ms] {
	has Int $.status=$st;
	has Str $.rest=$rest;
	has Array[Matches] $.matches=$ms;
}
our sub unmtup (MTup $t --> Array) {
	[$t.status,$t.rest,$t.matches];
}
# Generic Tuple 
role Tuple[::a $fst,::b $snd] {
	has a $.fst=$fst;
	has b $.snd=$snd;
}
sub untup(Tuple $t --> Array) {
	($t.fst,$t.snd);
}
# Generic Triple 
role Triple[::a $fst,::b $snd,::c $thrd] {
	has a $.fst=$fst;
	has b $.snd=$snd;
	has c $.thrd=$thrd;
}
sub untrip(Triple $t --> Array) {
	($t.fst,$t.snd,$t.thrd);
}

# Combinator types
role LComb {}
role Seq[LComb @combs] does LComb {
    has LComb @.combs = @combs;
}
role Comb[Sub $comb] does LComb {
    has Sub $.comb = $comb;
}
role Tag[Str $tag,LComb $comb] does LComb {
    has Str $.tag = $tag;
    has LComb $.comb = $comb; 
} 

## List-based Combinators

# The most important one
sub sequence_ (LComb @combs --> LComb) {
	Comb[
		sub (Str $str --> MTup) {

			#say "* sequence_( '$str' )" if $V;
			my Sub $f = sub ( MTup $acc, LComb $p --> MTup) {
				my (Int $st1, Str $str1, Array[Matches] $ms1) = unmtup($acc);
				my MTup $res = apply($p,$str1);
				my (Int $st2, Str $str2, Array[Matches] $ms2) = unmtup($res);
				if ($st2*$st1==0) {
					return MTup[0,$str1,empty-match].new;
				} else {
					return MTup[1,$str2,  Array[Matches].new(|$ms1,|$ms2) ].new;
				}
			}
			my MTup $res = reduce $f, MTup[1,$str,empty-match].new,|@combs;
			my (Int $status, Str $rest, Array[Matches] $matches) = unmtup($res);
			if ($status == 0) {
				MTup[0,$rest,empty-match].new;
			} else {
				MTup[1,$rest,$matches].new;
			}
		}
	].new;
}

sub word is export {  Comb[  sub ( \str) {
	str ~~ / ^ $<m> = [ \w+ ] \s* $<r> = [ .* ]/;
	if (not ($<m> ~~ Nil)) {    
		my \match = ~$<m>;
		# say "<$match>";
		my  \str2 = ~$<r>;
		# say "<$str2>";
		my Matches @ms = Match[match].new;		    
		MTup[ 1,str2, @ms ].new;
	} else {
		MTup[ 0,str, undef-match ].new;    
	}
} ].new;
}

sub word_OFF (--> LComb) is export {  Comb[  sub (Str $str --> MTup) {
	$str ~~ / ^ $<m> = [ \w+ ] \s* $<r> = [ .* ]/;
	if (not ($<m> ~~ Nil)) {    
		my Str $match = ~$<m>;
		say "<$match>";
		my Str $str2 = ~$<r>;
		say "<$str2>";
		my Matches @ms = (Match[$match].new);		    
		MTup[ 1,$str2, @ms ].new;
	} else {
		MTup[ 0,$str, undef-match ].new;    
	}
} ].new;
}



sub natural (--> LComb) is export { Comb[  sub (Str $str --> MTup) {
	$str ~~ / ^ $<m> = [ \d+ ] \s* $<r> = [ .* ]/;
	if (not ($<m> ~~ Nil)) {    
		my Str $match = ~$<m>;
		my Str $str2 = ~$<r>;
		my Matches @ms = (Match[$match].new);		    
		MTup[ 1,$str2, @ms ].new;
	} else {
		MTup[ 0,$str, undef-match ].new;    
	}
} ].new;
}
sub comma (--> LComb) is export {
    Comb[ sub (Str $str --> MTup) {
        my $m = $str ~~ /^\s*\,\s* $<r> = [.*]/;
	my $str_ = ~$<r>;
	my $st = $m ?? 1 !! 0;
	MTup[$st, $str_, undef-match ].new;
    }
    ].new;
}

our sub semi (--> LComb) {
    Comb[ sub (Str $str --> MTup) {
        my $st = ($str ~~ /^\s*\;\s* $<r> = [.*]/) ??1 !! 0;
	my $str_ = ~$<r>;
	MTup[$st, $str_, undef-match ].new;
    }
    ].new;
}

# As in Parsec, parses a literal and removes trailing whitespace
our sub symbol (Str $lit_str --> LComb) {
    my $lit_str_ = $lit_str;
    #$lit_str_ ~~ s:g/$<nw> = [ \W ] /\\$<nw>/;
    say $lit_str_;
    Comb[ sub (Str $str --> MTup) {
        if (
                $str ~~ m/^\s*$lit_str_\s* $<r> = [.*]/ 
          ) {
            my $matches=Array[Matches](Match[$lit_str_].new);
            my $str_ = ~$<r>; 
	    my $st=1; 
	    say $str_.raku;
	    say $matches.raku;
            MTup[1,$str_, $matches].new;
        } else {
            MTup[0,$str, undef-match].new; 
        }
    }
    ].new;
}

sub trimStart(Str $str --> Str) {
	say "<$str>";
	$str ~~ /^\s* $<r> = [ .* ]/;
	my \str2 = ~$<r>;
	say "<$str> <> " ~ str2;
	str2;
}

our sub char(Str \ch --> LComb) {
    Comb[ sub (Str \str1 --> MTup) {
            my \c = substr(str1,0,1);
			my \cs = substr(str1,1);
            if (c eq ch) {
				my \matches=Array[Matches](Match[ch].new);
                    MTup[1,cs,matches].new;
               } else {
                    MTup[0,str,undef-match].new;
					}
					}
	].new;
}

sub parens (LComb \p --> LComb) is export {
    Comb[ sub (Str \str1 --> MTup) {
		my MTup \mtup1 = apply(char('('), str1);
		say '1.',mtup1.raku;
		my (\status, \str3, \ch) = unmtup(mtup1);
		if (status==1) {                
			my \str4 = trimStart( str3);
			my MTup \mtup2 = apply( p, str4);
			say '2.',mtup2.raku;
			my (\st,\str4s,\matches) = unmtup(mtup2);
			my \status2=status*st;                
			if (status2==1) {                  
				my MTup \mtup3 = apply(char(')'), str4s);      
				say '3.',mtup3.raku;
				my (\st, \str5, \ch)= unmtup(mtup3);
				my \status3 = status2*st;                        
				if (status3==1) {#OK!
						my \str6 = trimStart(str5);
						return MTup[1,str6,matches].new;
				} else { # -- parse failed on closing paren
					return MTup[0,str5,matches].new;
				}
			} else { # -- parse failed on $ref
				return MTup[0,str4,matches].new;          
			}
		} else {# -- parse failed on opening paren
			return MTup[0,str3,undef-match].new;
		}
	}].new;

}

sub sepBy (LComb \sep, LComb \p --> LComb) is export {
    Comb[ sub (Str \str1 --> MTup) {
        my MTup \mtup1 = apply( p, str1);
		my ( \status, \str1b, \m1 ) = unmtup(mtup1);        
		if (status==1) {
			my MTup \mtup2 = apply( sep, str1b);
				my (\st2,\str2,\m2) = unmtup(mtup2);				
				if (st2 == 1) {
					my MTup \mtup3 = MTup[1,str2,Array[Matches].new(|m1,|m2)].new;
					whileMatches( p, sep, mtup3);
				} else {
					MTup[0,str1,m1].new;
				}
		} else  {  # first match failed.
			MTup[ 0, str1, undef-match].new;
		}
	}
	].new;
}      

sub whileMatches( LComb \p, LComb \sep, MTup \mtup --> MTup) {
	my (\st,\str1,\m1) = unmtup(mtup);
	my Str \str2s = trimStart( str1);
	my MTup \mtup2 = apply( p, str2s);
	my ( \st2, \str2, \m2 ) = unmtup(mtup2);

	if (st2==1) {
		 my MTup \mtup3 = apply( sep, str2);
		 my (\status3, \str3, \m3 ) = unmtup(mtup3);
		if (status3==1) {
			my MTup \mtup4 = MTup[1,str3,Array[Matches].new(|m1,|m2,|m3)].new;
			whileMatches( p, sep, mtup4);
		} else {
			MTup[1,str2,Array[Matches].new(|m1,|m2)].new;
		} 
	} else {
			MTup[0,str1,m1].new
	}
}

sub oneOf (Str \patt_str --> LComb) is export { 
    Comb[ sub ( \str1 ){ 
		my \patt_lst = patt_str.split('');
		loopOver( str1, patt_lst);
		}
	].new;
}

sub loopOver (\str1, \c_cs)  {
		my Str \c =  c_cs.head;
		my Str \cs = c_cs.tail;
		my MTup \mtup1 = apply(char( c), str1);
        my (\status, \str2, \matches ) = unmtup(mtup1);
    
        if (status==1) {
			MTup[ 1, str2, matches ].new;
       } else {
			if (cs eq "") {
				MTup[0,str1,undef-match ].new;
			} else{
				loopOver( str1, cs) 
			}
		}
}


# `many`, as in Parsec, parses 0 or more the specified parsers
sub many(LComb \parser --> LComb) is export { 
	Comb[ sub (Str \str1 --> MTup) {
		my MTup \mtup1 = apply( parser, str1);
        my ( \status, \str2, \m1 ) = unmtup(mtup1);
        
		if (status==1) {
            doMany( parser, str2, m1) 
		} else {    # first match failed.
			MTup[ 1, str1, undef-match].new;
		}
	}
	].new;
}
# # `many1`, as in Parsec, parses 1 or more the specified parsers
sub many1(LComb \parser --> LComb) is export { 
	Comb[ sub (Str \str1 --> MTup) {
		my MTup \mtup1 = apply( parser, str1);
        my ( \status, \str2, \m1 ) = unmtup(mtup1);
        
		if (status==1) {
            doMany( parser, str2, m1) 
		} else {    # first match failed.
			MTup[ 0, str1, undef-match].new;
		}
	}
	].new;
}
# many1 parser = 
# 	Comb $ \str -> let
#         ( status, str, m ) = apply parser str
#         in
# 		if status==1 then
#             doMany parser str m 
# 		else     -- first match failed.
#             ( 0, str, [UndefinedMatch] )
                        
sub doMany( \p, \str1, \m1) {
    my MTup \mtup1 = apply( \p, \str1);
	my ( \status, \str2, \m2 ) = unmtup(mtup1);
    
    if (status == 1) {
        doMany( p, str1, Array[Matches].new(|m1,|m2));
	} else {
            MTup[1,str1,m1].new;
	}
}

# This parser parses anything up to the first occurrence of a given literal and trailing whitespace
sub upto (Str \lit_str --> LComb) is export {
    Comb[ 
			sub ( Str \str1 --> MTup ) {
				str1 ~~ /$<m> = [ ^.*? ] \s* lit_str \s* $<r> = [ .* ]/;
				my \mm = ~$<m>;
				my \str2 = ~$<r>;
				
				if (mm ne "") { 
					MTup[ 1, str2,  Array[Matches].new( mm ) ].new;
				} else {
					MTup[ 0, str1, undef-match ].new;
				}
			}
	].new;
}
sub greedyUpto (Str \lit_str --> LComb) is export {
    Comb[ 
			sub ( Str \str1 --> MTup ) {
				str1 ~~ /$<m> = [ ^.* ] \s* lit_str \s* $<r> = [ .* ]/;
				my \mm = ~$<m>;
				my \str2 = ~$<r>;
				
				if (mm ne "") { 
					MTup[ 1, str2,  Array[Matches].new( mm ) ].new;
				} else {
					MTup[ 0, str1, undef-match ].new;
				}
			}
	].new;
}


# -- This parser parses anything up to the last occurrence of a given literal and trailing whitespace
# greedyUpto lit_str =
#     Comb $ \str -> let
#             (_,m,str') = str =~ "^(.*)\\s*lit_str\\s*" :: (String,String,String)
#         in
#         if m /= "" then 
#             MTup ( 1, str', [Match m] )
#         else
#             MTup ( 0, str, [UndefinedMatch] )



sub choice_( Array[LComb] \parsers --> LComb) is export { 
    Comb[ 
		sub (Str \strn --> MTup) {
			choice_helper( parsers, strn);
		}
	].new;
}

multi sub choice_helper( [], \strn){ 
	MTup[0, strn, empty-match].new; 
}
multi sub choice_helper( \pps, \strn ){
	my \p = pps.head;
	my \ps = pps.tail;
	my \res = apply( p, strn);
	my (\status, \str_, \matches) = unmtup(res);    
	if (status == 1) {
		MTup[status, str_, matches].new;
	} else { 
		choice_helper( ps, strn);
	}
}

sub try (LComb \p --> LComb) is export {
    Comb[ 
		sub ( Str \strn --> MTup){
			 my \res = apply( p, strn);
			 my (\status, \rest, \matches) = unmtup(res);
            if (status==1) {
				MTup[1, rest, matches].new;
			} else {
				MTup[0, strn, undef-match].new;
			}
		}
	].new
}

sub maybe (LComb \p --> LComb) is export {

    Comb[ 
		sub ( Str \strn --> MTup){
			 my \res = apply( p, strn);
			 my (\status, \rest, \matches) = unmtup(res);
            if (status==1) {
				MTup[1, rest, matches].new;
			} else {
				MTup[1, strn, undef-match].new;
			}
		}
	].new
}

sub whiteSpace (--> LComb) is export {
    Comb[ sub  (Str \str1 --> MTup) {        
            str1 ~~ /$<ws> = [ ^\s* ] $<r> = [ .* ]/;
			my \spaces = ~$<ws>;
			my \str2 = ~$<r>;
			my \matches = Array[Matches](Match[spaces].new);        
            return MTup[1, str2, matches ].new;
	}].new;
}

# Apply matches on the type of the combinator
multi sub apply(Comb[ Sub ] $p, Str $str --> MTup) is export {
	($p.comb)($str);
}
multi sub apply(Tag[ Str, LComb ] $t, Str $str --> MTup) is export {
	my MTup $res = apply($t.comb,$str); 
	my $status=$res.status;
	my $str2=$res.rest;
	my Array[Matches] \mms = $res.matches;

	my Str $tag = $t.tag;
	my $tm = TaggedMatch[$tag,mms].new;
	my Matches @tms = ($tm);
	MTup[$status,$str2,@tms].new;
}
multi sub apply(Seq[ Array ] $ps, Str $str --> MTup) is export {
	apply( sequence_( $ps.combs), $str);
}



sub _remove_undefined_values(Array[Matches] \ms --> Array[Matches]) {
	say '_remove_undefined_values ms:',ms.raku;
    my \res  = grep {!($_ ~~ UndefinedMatch)}, |ms ;
	my  \ms_ = Array[Matches].new(res);	
    # in 	
	say '_remove_undefined_values ms_:',ms_.raku;
    my \tms_res = map {my \m =$_; 
	say m.raku;
		if (m ~~ Match) {
				m;
		} elsif (m ~~ TaggedMatch) {
				TaggedMatch[ m.tag ,_remove_undefined_values (m.matches)].new;
		}
	}, |ms_;
	say 'tms_res:',tms_res.raku;
	my \tms = Array[Matches].new(tms_res);
	say 'tms:',tms.raku;
	tms;
}
# ms:Array[Matches].new(
# 	TaggedMatch[Str,Array[Matches]].new(
# 		tag => "Type", matches => Array[Matches].new(
# 			Match[Str].new(
# 				match => "integer")
# 				)
# 				), 
# 	Match[Str].new(
# 		match => "kind"), 
# 	Match[Str].new(
# 		match => "="), 
# 	TaggedMatch[Str,Array[Matches]].new(
# 		tag => "Kind", matches => Array[Matches].new(
# 			Match[Str].new(
# 				match => "8"
# 				)
# 			)
# 		)
# 	)

sub _tagged_matches_only(Array[Matches] \ms --> Array[Matches]) {
        my \ms_res =  grep TaggedMatch, |ms; 
		my \ms_ = Array[Matches].new(ms_res);
        if (ms_.elems == 0) {             
				ms ;
		} else {
			# say 'ms_:',ms_.raku;
			my \tms_res = map {TaggedMatch[ $_.tag, _tagged_matches_only( $_.matches)].new}, |ms_;
			my \tms = Array[Matches].new(tms_res);
			# say 'tms:',tms.raku;
			tms;
		}
}

role TaggedEntry {}
role Val[Str @v] does TaggedEntry {
	has Str @.val=@v;
} 
role ValMap [ Hash \vm] does TaggedEntry { #String \k, TaggedEntry \te,
	has %.valmap = vm; 
}

# A list of TaggedMatch must be translated into a Map of TaggedEntry's
# Array[Matches].new(
# 	TaggedMatch[Str,Array[Matches]].new(
# 		tag => "Type", 
# 		matches => Array[Matches].new(
# 			Match[Str].new(match => "integer")
# 			)
# 			), 
# 	TaggedMatch[Str,Array[Matches]].new(
# 		tag => "Kind", 
# 		matches => Array[Matches].new(
# 			Match[Str].new(match => "8"))))

sub _tagged_matches_to_map(Array[Matches] \ms --> TaggedEntry) {
# if there are no TaggedMatch in ms, we should unpack the String from the Match and pack it into a Val [String]
# say "\n _tagged_matches_to_map : ms: ", ms.raku, "\n";
        my \ms_ =  grep TaggedMatch, |ms;#.matches;		
		if (ms_.elems == 0) { 
			# say 'MS:',ms.raku;
			Val[ Array[Str].new(map {$_.match}, |ms)].new;
		} else  {
			ValMap[ 
				reduce  sub (\hm, \tm) {
					# say 'TM:',tm.raku;
					my \t = tm.tag;
					my \ms__ = tm.matches;
					hm{ t } =  _tagged_matches_to_map( ms__) ;
					hm;
					}, %(), |ms_
				].new;
		}
}

# A hack so I can write sequence(p1,p2,...) and it typechecks
sub sequence (*@ps) is export {
	sequence_( Array[LComb](@ps) );	
}
# A hack so I can write choice(p1,p2,...) and it typechecks
sub choice (*@ps where { .all ~~ LComb} ) is export {
	choice_( Array[LComb](@ps));
}  

sub tag(Str \t, LComb \p) is export {
	Tag[t,p].new;
}

                
sub getParseTree (\ms) is export {
	# say "\n",'getParseTree ms:' , ms.raku,"\n";
	my \ms1 = _remove_undefined_values ms;
	# say 'ms1:', ms1.raku;
	my \ms2 =  _tagged_matches_only ms1;
    my \ms3 = _tagged_matches_to_map ms2;
    # in
        if (ms3 ~~ ValMap) {
				ms3.valmap;
			} else {
				%();
			}            
}