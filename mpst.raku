use v6;

=begin pod

Suppose the session is:

I send a request for an url
I receive a 451
I try again
I receive

=end pod 
# Create types for all states. This would be generated from the MPST description
role ST0 {}
role ST1 {}
role ST2 {}
role ST3 {}
role ST4 {}
role ST5 {}
role ST6 {}

# An choice type. 
role Either {}
role Left does Either {}
role Right does Either {}

# I think we can encode any state transition this way
# Either with two choices might be too restrictive, so maybe we need to broaden this
sub nextState(::T1, ::T2 = Nil ) {
   given T1 {
      when ST0 { ST1 }
      when ST1 { ST2 }
      when ST2 { 
         given T2 {
            when Left { ST3 }
            when Right { ST4 }
            default { die "Not a valid alternative: " ~ T2.raku }
         }
      }
      when ST3 { ST5 }
      when ST4 { ST1 }
      when ST5 { ST6 }
      default { die "Not a valid state: " ~ T1.raku}
   }
}

my ST1 \st0 = nextState(ST0);
my ST2 \st1 = nextState(ST1);
my ST3 \st3 = nextState(ST2, Left);
my ST4 \st4 = nextState(ST2, Right);

sub send($msg,::ST, ::CHT = Nil) {
   say "Sending $msg";
   nextState(ST,CHT);
}
sub recv(::ST, ::CHT = Nil) {   
   my $msg = "World";
   say "Receiving $msg";
   (nextState(ST,CHT),$msg);
}
sub cont(::ST, ::CHT = Nil) {
   nextState(ST,CHT);
}

sub getStatus(\msg) { state $st++;
   if $st==1 {
      say "451";
      451;
   } else {
      say "200";
      200;
   }
}
sub getMsgText(\msg) {msg}

my ST1 \st_1 = send("Hello",ST0);
my (ST2 \st_2,\msg) = recv(st_1);
say msg;
if (msg ne "") { # a valid message, send again
   my ST3 \st_3 = send("Hello",st_2,Left);
   my (ST5 \st_5,\msg) = recv(st_3);
   # if ($msg ne "") { # a valid message, we're done

   # } else { # something went wrong, give up

   # }
} else { # something went wrong, give up
   my ST4 \st_4 = cont(st_2,Right);
}

my $status = 0;
my $st_0 = ST0;
my $msg="";
while $status != 200 {
   my ST1 \st_1 = send("http://127.0.0.1/req1",$st_0);
   my (ST2 \st_2, \_msg) = recv(st_1);
   $msg = _msg;
   $status = getStatus(msg);
   if $status != 200 {
      $st_0 = cont(st_2,Left);
      $st_0 = ST0
   } else {
      $st_0 = cont(st_2,Right);
      # OK, this is trivial to fool
      $st_0 = ST4      
   }
}
# so here $st_0 must be ST4
my ST4 \st_4 = $st_0;
# # status 200
if (getMsgText(msg) ne "") {
say $msg;
} else {
die "BOOM!"
}