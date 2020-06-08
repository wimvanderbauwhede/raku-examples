use v6;

our $p6devel = Promise.new; # long ago ...

our $christmas = Date.new('2006-12-25').later(:9years); 

$p6devel.keep($christmas); 

our $perl6 = $p6devel.result;

say $perl6;
