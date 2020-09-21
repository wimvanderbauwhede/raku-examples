use v6;

# For reference, the non-BB ADT approach

# [wim@hackbox raku-examples]$ time raku ubb-timing.raku 
# 200
# 390600

# real	0m3.780s
# user	0m4.279s
# sys	0m0.112s

# [wim@hackbox raku-examples]$ time raku bb-timing.raku 
# 200
# 390600

# real	0m9.070s
# user	0m9.620s
# sys	0m0.073s

# [wim@hackbox raku-examples]$ time raku no-bb-timing.raku 
# 200
# 390600

# real	0m3.078s
# user	0m3.602s
# sys	0m0.076s


my $nruns=200;

# The Term ADT. The type annotations are for documentation.
role Term {}
role Var [Str \v] does Term {
    has Str $.var = v;
}
role Par [Str \p] does Term {
    has Str $.par = p;
}
role Const [Int \c] does Term {
    has Int $.const = c;
}
role Pow [Term \t, Int \n] does Term {
    has Term $.term = t;
    has Int $.exp = n;
}
role Add [@ts] does Term {
    has Term @.terms = @ts;
}
role Mult [@ts] does Term {
    has Term @.terms = @ts;
}

# Wrappers for the constructors

sub TVar($v) {
    Var[ $v].new
}

sub TPar($p) {
    Par[ $p ].new
}

sub TConst($n) {
    Const[$n].new
}

sub TPow ($t,$n) {
    Pow[$t,$n].new
}

sub TAdd (*@ts) {
    Add[@ts].new
}

sub TMult (*@ts) {
    Mult[@ts].new
} 

# Pretty-print a Term 
# multi sub ppTerm(Var \t) { t.var }
# multi sub ppTerm(Par \c) { c.par }
# multi sub ppTerm(Const \n) { "{n.const}" }
# multi sub ppTerm(Pow \pw){ ppTerm(pw.term) ~ '^' ~ "{pw.exp}" }
# multi sub ppTerm(Add \t) { 
#     my @pts = map {ppTerm($_)}, |t.terms;
#     "("~join( " + ", @pts)~")"
# }
# multi sub ppTerm(Mult \t){ 
#     my @pts = map {ppTerm($_)}, |t.terms;
#     join( " * ", @pts)
# }

sub ppTerm(Term \t) {
    given t {
        when Var { t.var }
        when Par { t.par }
        when Const { "{t.const}" }
        when Pow { ppTerm(t.term)  ~ '^' ~ "{t.exp}" }
        when Add {
            my @pts = map {ppTerm($_)}, |t.terms;
            "("~join( " + ", @pts)~")"
        }
        when Mult { 
            my @pts = map {ppTerm($_)}, |t.terms;
            join( " * ", @pts)
        }
    }
}

# # Evaluate a Term 
# multi sub evalTerm(%vars,  %pars, Var \t) { %vars{t.var} }
# multi sub evalTerm(%vars,  %pars,Par \c) { %pars{c.par} }
# multi sub evalTerm(%vars,  %pars,Const \n) { n.const }
# multi sub evalTerm(%vars,  %pars,Pow \pw){ 
#     evalTerm(%vars,  %pars,pw.term) ** pw.exp 
# }
# multi sub evalTerm(%vars,  %pars,Add \t) { 
#     my @pts = map {evalTerm(%vars,  %pars,$_)}, |t.terms;
#     [+] @pts
# }
# multi sub evalTerm(%vars,  %pars,Mult \t){ 
#     my @pts = map {evalTerm(%vars,  %pars,$_)}, |t.terms;
#     [*] @pts
# }

# Evaluate a Term 
sub evalTerm(%vars,  %pars, Term \t) {
    given t {
        when Var { %vars{t.var} }
        when Par { %pars{t.par} }
        when Const { t.const }
        when Pow { evalTerm(%vars,  %pars,t.term) ** t.exp }
        when Add {
            my @pts = map {evalTerm(%vars,  %pars,$_)}, |t.terms;
            [+] @pts
        }
        when Mult { 
            my @pts = map {evalTerm(%vars,  %pars,$_)}, |t.terms;
            [*] @pts
        }
    }
}


my @strs=();
my @vals=();
for 1 .. $nruns -> $c {
my \qterm1 = TAdd(
    TMult(TPar("a"), TPow( TVar( "x"), 2)),
    TMult(
        TPar( "b"), TVar( "x")),
    TPar("c")
    );

#   x^3 + 1    
my \qterm2 = TAdd(
    TPow(TVar("x"), 3), 
    TConst($c)
    );

#   qterm1 * qterm2    
my \qterm = TMult(
        qterm1, qterm2
    );

my $str = ppTerm( qterm);
push @strs, $str;

my $val = evalTerm(
    {"x" => 2}, {"a" =>2,"b"=>3,"c"=>4},  qterm
);
push @vals, $val;

}

say @strs.elems;
say [+] @vals;

