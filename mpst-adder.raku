use v6;

=begin pod

global protocol Adder(role C, role S) {
    choice at C {
        Add(Int, Int) from C to S;
        Res(Int) from S to C;
        do Adder(C, S);
    } or {
        Bye() from C to S;
    }
}

What would be really nice is if we had two threads for this.

=end pod 
# Create types for all states. This would be generated from the MPST description
role ST_While { has Int $._ }
role ST_Send_1 { has Int $._ }
role ST_Send_2 { has Int $._ }
role ST_Recv { has Int $._ }
role ST_Bye { has Int $._ }

# An choice type. 
role Choice {}
role Cont does Choice {}
role Stop does Choice {}

# I think we can encode any state transition this way
# Either with two choices might be too restrictive, so maybe we need to broaden this
# This would also be generated from Scribble
our $currentState=Nil;
sub nextState(::ST, ::CHT = Nil ) {    
   my \nextState = do {given ST {
      when ST_While {
         given CHT {
            when Cont { ST_Send_1 }
            when Stop { ST_Bye }
            when Nil { note "This state requires a choice: " ~ ST.raku; exit 1 }
            default { note "Not a valid alternative: " ~ CHT.raku; exit 1 }
         }
      }
      when ST_Send_1 { ST_Send_2 }
      when ST_Send_2 { ST_Recv }
      when ST_Recv { ST_While}
      when ST_Bye { note "This is the final state, no further transitions"; exit 1}
      default { note "Not a valid state: " ~ ST.raku ; exit 1}
   }
   }
   $currentState = nextState;
   return nextState;
}

sub typedNextState (\msg, ::ST, ::CHT = Nil ) {
   do {
      note  &?ROUTINE.name ~ " type error: " ~ msg.WHAT.raku ~ '=/=' ~ ST.new._.raku; 
      exit 1
   } unless msg ~~ ST.new._;      
   nextState(ST,CHT);
}

our $add = 0;

sub send(\msg,::ST, ::CHT = Nil) {
   say "Sending {msg}";
   $add+=msg;
   typedNextState(msg,ST,CHT);
}
sub recv(::ST, ::CHT = Nil) {   
   my Int \msg = $add+0; #without the +0, \msg is a reference to $add!
   say "Receiving {msg}";
   $add=0; 
   (typedNextState(msg,ST,CHT),msg);
}
sub cont(::ST, ::CHT = Nil) {
   nextState(ST,CHT);
}


my Int \inc=6;

my \n_iters = 3;
my $iter = 0;
my $res = 0;
my $st_0 = ST_Send_1;

while $iter++ < n_iters {
    my ST_Send_2 \st_send_2 = send($res,$st_0);
    my ST_Recv \st_recv = send(inc,st_send_2);
    my (ST_While \st_, \_res) = recv(st_recv);
    $res = _res;
    say "Result is $res\n";
   if $iter == n_iters {
      $st_0 = cont(st_,Stop); # ST_Bye
   } else {
       $st_0 = cont(st_,Cont); # ST_Send_1
   }   
}
my ST_Bye \st_bye = $st_0;
say "Final state: " ~ $currentState.raku;
say $res;

$iter=0;
my ST_Send_1 \st_0=ST_Send_1;
while $iter++ < n_iters {
    my \st_1 = send($res,st_0);
    my \st_2 = send(inc,st_1);    
    my (\st_3,\_res) = recv(st_2);    
    $res = _res;
    say "Result is $res\n";
}
# my ST_Bye \st_bye2 = $st_0;
say "Final state: " ~ $currentState.raku;
say $res;