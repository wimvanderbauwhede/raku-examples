use v6;
use Uxn;

    &hello ∘ JSR2 ∘ 
BRK;

sub hello {
    (hello-world) ∘ &print-text ∘ JSR2 ∘ 
    RET
}

sub print-text { # str* --
    &loop ∘ JSR2 ∘ 
    RET
}

sub loop {
    DUP2 ∘ LDA ∘ 0x18 ∘ DEO ∘ 
    INC2 ∘ DUP2 ∘ LDA ∘ &loop ∘ JCN2 ∘ 
    RET
}

sub hello-world { ["Hello,",0x20,"World!", 0x0a,0x00] }
