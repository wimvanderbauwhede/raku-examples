use v6;

use experimental :macros;

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

sub error (\msg){
   note 'ERROR: ' ~ msg;
   # say Backtrace.new.Str;
   exit 1;
}

role Send {}
role Recv {}
role None {}

# For multi-party interactions, we need to identify the party to communicate with
enum Party <Party1 Party2 NA>;

# Create types for all states. This would be generated from the MPST description
role ST_While { has Int $._; has None $.trx; has Party $.party = NA; }
role ST_Send_1 { has Int $._; has Send $.trx; has Party $.part }
role ST_Send_2 { has Int $._; has Send $.trx; }
role ST_Recv { has Int $._; has Recv $.trx; }
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
            when Nil { error "This state requires a choice: " ~ ST.raku }
            default { error "Not a valid alternative: " ~ CHT.raku }
         }
      }
      when ST_Send_1 { ST_Send_2 }
      when ST_Send_2 { ST_Recv }
      when ST_Recv { ST_While}
      when ST_Bye { error "This is the final state, no further transitions"}
      default { error "Not a valid state: " ~ ST.raku }
   }
   }
   $currentState = nextState;
   return nextState;
}

sub typedNextState (\msg, ::ST, ::CHT = Nil ) {
   do {
      error  &?ROUTINE.name ~ ": " ~ msg.WHAT.raku ~ '=/=' ~ ST.new._.raku
   } unless msg ~~ ST.new._;      
   nextState(ST,CHT);
}

our $add = 0;

sub send(\msg,::ST, ::CHT = Nil) {
   say "Sending {msg}";
   $add+=msg;
   do {
      error  &?ROUTINE.name ~ ": " ~  ST.raku ~ " is not a Send state" ;
   } unless ST.new.trx ~~ Send;     
   typedNextState(msg,ST,CHT);
}
sub recv(::ST, ::CHT = Nil) {   
   my Int \msg = $add+0; #without the +0, \ms"g is a reference to $add!
   say "Receiving {msg}";
   $add=0; 
   say "State in Recv: "~ST.raku;
   do {
      error  &?ROUTINE.name ~ ": " ~  ST.raku ~ " is not a Recv state";
   } unless ST.new.trx ~~ Recv;     
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

say "\nTry without while\n";

sub whilst(\args,\body) {
   sub (\w) {
      w.(args,w)
   }(body)
}

my Int \iter_init = 0;
my Int \res_init = 1;
my ST_While \st_init = ST_While;

my (ST_Bye \st_fin, \res_fin) = whilst( [iter_init,res_init,st_init],
   sub (\args,\f) {    
      my (\i,\r,\st)= args;
      say "State: "~st.raku;
      if i==n_iters {
         say "End State: "~st.raku;
         (cont(st,Stop),r)
      } else {
         my ST_Send_1 \st_0 = cont(st,Cont);
         my ST_Send_2 \st_1 = send(r,st_0);
         my ST_Recv \st_2 = send(inc,st_1);    
         my (ST_While \st_3,\_res) = recv(st_2);    
         
         say "Result is {_res}\n";
         say "State: "~st_3.raku;
         f.([i+1,_res,st_3],f)
      }
   }
);
say "Final state: " ~ $currentState.raku;
say res_fin;
