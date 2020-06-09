use v6;

# A simple role-based boolean type
role OpinionatedBool {}
role AbsolutelyTrue does OpinionatedBool {}
role TotallyFalse does OpinionatedBool {}

# In Raku, types are values, so this is OK
my OpinionatedBool \bt = AbsolutelyTrue;

# This is not necessary because the role body is empty, and has actually disadvantages, see further
my OpinionatedBool \bi = AbsolutelyTrue.new;

# Pattern matching against the alternatives
multi sub p(AbsolutelyTrue $b) {
    say 'True';
}
multi sub p(TotallyFalse $b) {
    say 'False';
}

# Trying it out:
say "\nPattern matching with multi subs works for both type-as-value and instance:";
p(bt); # prints True
p(bi); # also prints True

say "\nSmart matching against a type alternative works for the type-as-value case:";
if (bt ~~ AbsolutelyTrue) {
    say 'True'
} elsif (bt ~~ TotallyFalse) {
    say 'False'
} else {
say 'bt is neither True or False';
}
# It also works for the type-as-instance case
say "\nSmart matching against a type alternative also works for the instance case:";
if (bi ~~ AbsolutelyTrue) {
    say 'True'
} elsif (bi ~~ TotallyFalse) {
    say 'False'
} else {
    say 'bi is neither True or False';
}


# Testing 'container identity', i.e. type identity
say "\nComparison at type level (=:=) against a type alternative works for the type-as-value case:";

if (bt =:= AbsolutelyTrue) {
    say 'True'
} elsif (bt =:= TotallyFalse) {
    say 'False'
} else {
say 'bt is neither True or False';
}

# Testing 'value identity' also works because the type is a value
say "\nComparison at value level (===) against a type alternative works for the type-as-value case:";
if (bt === AbsolutelyTrue) {
    say 'True'
} elsif (bt === TotallyFalse) {
    say 'False'
} else {
    say 'bt is neither True or False';
}

# However, none of the following works

say "\nTesting an instance against a type with =:= or === does not work:";

if (bi =:= AbsolutelyTrue) {
    say 'True'
} elsif (bi =:= TotallyFalse) {
    say 'False'
} else {
    say '=:= does not work because bi is an instance, not a type'  ;
}

if (bi === AbsolutelyTrue) {
    say 'True'
} elsif (bi === TotallyFalse) {
    say 'False'
} else {
    say '=== does not work because bi is an instance, not a type';
}

say "\nTesting against an instance of the type always fails:";

if (bi ~~ AbsolutelyTrue.new) {
    say 'True'
} elsif (bi ~~ TotallyFalse.new) {
    say 'False'
} else {
    say '~~ fails because the instances are different';
}


if (bi =:= AbsolutelyTrue.new) {
    say 'True'
} elsif (bi =:= TotallyFalse.new) {
    say 'False'
} else {
    say '=:= fails because AbsolutelyTrue.new is an instance, not a type';
}

if (bi === AbsolutelyTrue.new) {
    say 'True'
} elsif (bi === TotallyFalse.new) {
    say 'False'
} else {
    say '=== fails because the instances are different';
}

