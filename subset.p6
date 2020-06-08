use v6;

subset Prob of Rat where sub ($p) { 0 < $p < 1}

sub test_prob(Prob $p --> Bool) { $p > 0.5 }

say test_prob(0.314); # OK
say test_prob(3.14); # Type error!
