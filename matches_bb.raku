use v6;
    
role Matches[&m] {
    method unMatches(&matchBB
    #:(Str --> Any)
    , &taggedMatches
    #:(Str,Array[Any] --> Any)
    , 
    #Any 
    \undefinedMatchBB 
    #--> Any
    ) {
        m(
            &matchBB,
            &taggedMatches,
            undefinedMatchBB
        );
    }
}
    
        
sub match_(\s) {
#-> &m:(Str --> Any), &t:(Str,Array[Any] --> Any), Any \u --> Any { m(s)}
->&m,&t,\u {m(s)}
}

sub taggedMatches(\s,\ms) {
#-> &m:(Str --> Any), &t:(Str,Array[Any] --> Any), Any \u --> Any { t(s,ms)}
->&m,&t,\u { t(s,ms) }
}

sub _mult(  @ts --> TermBB) {
    TermBB[  sub (\v, \c, \n, \p, \a, \m) { 
        m.( map {.unTermBB( v, c, n, p, a, m )}, @ts )
    }
    ].new;
}

sub undefinedMatchBB() {
#-> &m:(Str --> Any), &t:(Str,Array[Any] --> Any), Any \u --> Any { u }
->&m,&t,\u {u}
}

    
sub mkMatches (&m --> Matches) {
    Matches[ &m ].new;
}

    
sub MatchBB(\s) { mkMatches match_(s) }
sub TaggedMatches(\s,\ms){ mkMatches taggedMatches(s,ms)} 
sub UndefinedMatchBB {  mkMatches undefinedMatchBB() }

my Matches @ms =  
        MatchBB( "hello"),
        TaggedMatches(
            "Adjectives",
            [
                MatchBB( "brave"),
                MatchBB( "new")
             ]
                ),
        MatchBB "world"      
;
        
say @ms[0].unMatches(->\x {x},->\x,\y{x ~ y},'');
say @ms[1].unMatches(->\x {x},->\x,\y{x ~ y},'');
say @ms[2].unMatches(->\x {x},->\x,\y{x ~ y},'');
 
