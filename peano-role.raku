#data Vect : Nat -> Type -> Type where
#   Nil  : Vect Z a
#   Cons : a -> Vect k a -> Vect (S k) a
   
   role Nat{}    
   role Z does Nat {}
   role S[Nat $n] does Nat {
   }  
   my Nat \zero = Z;
   my Nat \one = S[Z];
   my Nat \two = S[S[Z]];
   
   my Nat \also-two = S[one];
   say two.raku; say also-two.raku;	
   say two.WHAT; say also-two.WHAT;	
   say two === also-two;
   say two ~~ also-two;		
   say two =:= also-two;
