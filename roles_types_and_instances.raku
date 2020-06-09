use v6;

role RB {}
role RT does RB {}
role RF does RB {}

my RB \bt = RT;

# This is not necessary because the role body is empty.
my RB \bi = RT.new;

multi sub p(RT $b) {
    say 'True';
}
multi sub p(RF $b) {
    say 'False';
}

p(bt);
p(bi);

if (bt ~~ RT) {
    say 'True'
} elsif (bt ~~ RF) {
    say 'False'
} else {
say 'bt is neither True or False';
}

if (bt =:= RT) {
    say 'True'
} elsif (bt =:= RF) {
    say 'False'
} else {
say 'bt is neither True or False';
}

if (bt === RT) {
    say 'True'
} elsif (bt === RF) {
    say 'False'
} else {
    say 'bt is neither True or False';
}

if (bi ~~ RT) {
    say 'True'
} elsif (bi ~~ RF) {
    say 'False'
} else {
    say 'bi is neither True or False';
}

if (bi ~~ RT.new) {
    say 'True'
} elsif (bi ~~ RF.new) {
    say 'False'
} else {
    say 'bi is neither True or False';
}


if (bi =:= RT.new) {
    say 'True'
} elsif (bi =:= RF.new) {
    say 'False'
} else {
    say 'bi is neither True or False';
}

if (bi === RT.new) {
    say 'True'
} elsif (bi === RF.new) {
    say 'False'
} else {
    say 'bi is neither True or False';
}

