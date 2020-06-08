use v6;

# Matches
role Matches {}
role Match[Str $str] does Matches {
    has Str $.match=$str;
} 
role TaggedMatch[Str $tag, Matches @ms] does Matches {
    has Str $.tag = $tag;
    has Matches @.matches = @ms;
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
sub unmtup (MTup $t --> Array) {
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

# Define some combinators
#
# The most important one
sub sequence (LComb @combs --> LComb) {
	Comb[
		sub (Str $str --> MTup) {

			#say "* sequence( '$str' )" if $V;
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
my LComb \word = Comb[  sub (Str $str --> MTup) {
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

my LComb \natural = Comb[  sub (Str $str --> MTup) {
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

sub comma {
    Comb[ sub (Str $str --> MTup) {
        my $m = $str ~~ /^\s*\,\s* $<r> = [.*]/;
	my $str_ = ~$<r>;
	my $st = $m ?? 1 !! 0;
	MTup[$st, $str_, undef-match ].new;
    }
    ].new;
}

sub semi {
    Comb[ sub (Str $str --> MTup) {
        my $st = ($str ~~ /^\s*\;\s* $<r> = [.*]/) ??1 !! 0;
	my $str_ = ~$<r>;
	MTup[$st, $str_, undef-match ].new;
    }
    ].new;
}




# As in Parsec, parses a literal and removes trailing whitespace
sub symbol (Str $lit_str --> LComb) {
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

# Apply matches on the type of the combinator
multi sub apply(Comb[ Sub ] $p, Str $str --> MTup) {
	($p.comb)($str);
}
multi sub apply(Tag[ Str, LComb ] $t, Str $str --> MTup) {
	my MTup $res = apply($t.comb,$str); 
	my $status=$res.status;
	my $str2=$res.rest;
	my @mms = $res.matches;

	my $tag = $t.tag;
	my $tm = TaggedMatch[$tag,@mms].new;
	my Matches @tms = ($tm);
	MTup[$status,$str2,@tms].new;
}
multi sub apply(Seq[ Array ] $ps, Str $str --> MTup) {
	apply( sequence( $ps.combs), $str);
}

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
