use v6;
use Uxn;

# my \res0 =  1 ∘ &f1 ∘ JSR ∘ BRK ;

# say 'res0: ' , res0;

# sub f1 {
#     &f2 ∘ JSR ∘ 7 ∘ MUL ∘ RET
# }
# sub f2 { #( \x, \y )
#     #y ∘  x ∘  
#     &ft ∘ JCN ∘ &ff ∘ JMP
# }

# sub ft {
#     6 ∘ RET
# }
# sub ff { 
#     7 ∘ RET
# }

# my \res1 =  4 ∘ 2 ∘ 2 ∘ INC ∘ SWP ∘ NIP ∘ DUP ∘ INC ∘ OVR ∘ POP ∘ ROT ∘ ADD ∘ MUL ∘ 4 ∘ &f2 ∘ JSR ∘ BRK ;
# say 'res1: ', res1;

# my \res2 = 4 ∘ DUP2 ∘ ADD ∘ DUP2 ∘  POP2 ∘ BRK;
# say res2;

# my @a = 11,22,33;
# my \res3 = @a ∘ 1 ∘ ADD ∘ LDA ∘ DUP ∘ ADD ∘ 2 ∘ SUB ∘ BRK;

# say res3;

        my @hello-word = "Hello,",0x20,"World!", 0x0a,0x00;

        &hello ∘ JSR2 ∘ BRK;


        sub hello {
            @hello-word ∘ &print-text ∘ JSR2 ∘ RET; # ["Hello World!", 0x00]
        }

        sub print-text { # str* --
            &loop ∘ JSR2 ∘ POP2 ∘ RET
        }

        sub loop {
            DUP2 ∘ LDA ∘ 0x18 ∘ DEO ∘ INC2 ∘ DUP2 ∘ LDA ∘ &loop ∘ JCN2 ∘ RET;
        }