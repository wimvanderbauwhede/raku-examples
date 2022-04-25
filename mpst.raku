use v6;

role ST0[\v] { has $.v=v }
role ST1[\v] { has $.v=v }
role ST2[\v] { has $.v=v }
role ST3[\v] { has $.v=v }
role ST4[\v] { has $.v=v }

role Either {}
role Left does Either {}
role Right does Either {}
#multi sub next(ST0 , \t=Nil) { ST1 }
#multi sub next(ST1 , \t=Nil) { ST2 }
sub next(::T1, ::T2 = Nil ) {
   given T1 {
      when ST2 { 
    given T2 {
        when Left { ST3 }
        when Right { ST4 }
        default { say "BOOM! "; }
    }
      }
      default {T1}
   }
}

say next(ST0);
say next(ST1);
say next(ST2, Left);
say next(ST2, Right);

