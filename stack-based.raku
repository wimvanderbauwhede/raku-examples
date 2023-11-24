use v6;
use Stack;

my \res =  6 ¬ 4 ¬ 3 ¬ &ADD ¬ &MUL ¬ &RET ;
say res;
die;
my \res1 =  3 ∘ 2 ∘ 1 ∘ &INC ∘ &ADD ∘ &MUL ∘ 4 ∘ &f ∘ &RET ;
my \res1check = 42;
say 'res1:' ~ res1;
die;
# say "Ex. 2\n";

# my \res2 = ⟂ ∘ 3 ∘ &DUP ∘ &INC ∘ &OVR ∘ 2  ∘  &ADD ∘ &ROT ∘ &MUL ∘ &NIP ;
# my $res2check = 15;
# say res2;

sub f( \x, \y ) {
    ⟂ ∘ x ∘  y ∘  &SUB ∘ 5 ∘ &MUL ∘ 2 ∘ &ADD
}


