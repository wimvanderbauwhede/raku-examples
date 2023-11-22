use v6;
use Stack;

say _ 
∘ 3 ∘ 2 ∘ 1 ∘ &INC ∘ &ADD ∘ &MUL ∘ 4 ∘ &f
;

sub f( \x, \y ) {
    _ ∘ &SUB
}


