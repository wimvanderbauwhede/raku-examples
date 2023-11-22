use v6;
use Stack;


my \res = ⟂ ∘ 3 ∘ 2 ∘ 1 ∘ &INC ∘ &ADD ∘ &MUL ∘ 4 ∘ &f ;

say res;

sub f( \x, \y ) {
    ⟂ ∘ x ∘  y ∘  &SUB ∘ 5 ∘ &MUL ∘ 2 ∘ &ADD 
}


