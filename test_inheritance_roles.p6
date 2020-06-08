use v6;

class Dog {
    method bark { say 'Woof!' }
}

role Guard {
    method guard_toddler { say 'Keeping guard' }
}

class Guarddog is Dog does Guard {
    method guard_toddler { say 'Good boy!' }
    method bark { say '...' }
}

my $d1 = Dog.new; $d1.bark;
my $d2 = Guarddog.new; $d2.guard_toddler;$d2.bark;
my $d3 = Dog.new; $d3 does Guard; $d3.guard_toddler;$d3.bark;

exit;

class Person {
    method eat { ... }
    method sleep { ... }
}

class Parent is Person does Guard {
    method wipe_nose { say 'Wipe your nose!' }
    method tie_shoes { say 'Let me tie your shoes' }
}

class Child is Person {
    method wipe_nose   { say 'I wiped my nose' }
    method play_in_mud { say 'Playing ...' }
}



my Person $p = Child.new;
my Child $c = Child.new;
my Parent $f = Parent.new;
my Person $m = Parent.new;
my Guard $g = Parent.new;
#my Parent $g1 = Guardian.new;
#my Person $g2 = Guardian.new;

my Guard $d4 = Guarddog.new; $d4.guard_toddler;$d4.bark;

