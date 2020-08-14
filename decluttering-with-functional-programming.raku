use v6;


## Raku: a quick introduction

sub square ($x) {
    $x*$x;
}

# anonymous subroutine 
my $anon_square = sub ($x) {
    $x*$x;
}

my \x = 42; # sigilless
my $y = 43; 
say x + $y; 

my @array1 = 1,2,3; #=> an array because of the '@' sigil
my \array2 = [1,2,3]; #=> an array, because of the '[...]'

my \range1 = 1 .. 10; #=> a range 1 .. 10
my @array3 = 1 .. 10; #=> an array from a range, because of the '@' sigil

my \list1 = 1,2,3; #=> a list
my $list2 = (1,2,3); #=> also a list
my \list3 = |(1 .. 10);  #=> an array from a range because of the '|' flattening operation

## A function, by any other name -- functions as values

sub choose (\t, \f, \d) {
	if (d) {t} else {f}
}

# Raku
my \tstr = "True!";
my \fstr = "False!";

my \res_str = choose(tstr, fstr, True);

say res_str; #=> says "True!"

sub tt (\s) { say "True {s}!" }
sub ff (\s) { say "False {s}!" }

my &res_f = choose(&tt, &ff, False);

say &res_f; #=> says &ff
res_f("rumour"); #=> says "False rumour!"

## Functions don't need a name


my \tt = sub (\s) { say "True {s}!" };
my \ff = -> \s { say "False {s}!" };

my &res_ff = choose(tt, ff, True);

say &res_ff; #=> says sub { }
res_ff("story"); #=> says "True story!"

## Examples: `map`, `grep` and `reduce`


### `map` : applying a function to all elements of a list

my \res = map -> \x {x*x} , 1 .. 10;

# Raku
my \res_mut = [];
for 1 .. 10 -> \x {
	res_mut.push(x*x);
}


### `grep` : filtering a list

my \res_grep = grep -> \x { x % 5 == 0 }, 1 .. 30;
#
my \res_grep_mut = [];
for 1 .. 30 -> \x {
	if (x % 5 == 0) {
	res_grep_mut.push(x);
	}
}

my \res_chain = grep -> \x { x % 5 == 0 }, map -> \x {x*x}, 1..30;
say res_chain;


### `reduce` : combining all elements of a list into a single value

my \sum = reduce sub (\acc,\elt) {acc+elt}, 1 .. 10;

say sum; #=> says 55

### Writing your own

my \assoc_func = -> \x,\y {x+y}
my \non_assoc_func = -> \x,\y { x < y ?? x+y !! x }

#### Left fold

sub foldll (&f, \iacc, \lst) { 
  my $acc = iacc; 
  for lst -> \elt {
    $acc = f($acc,elt);
  }
  $acc;
}

# # When the list is empty, return the accumulator
multi sub foldl (&f, \acc, ()) { acc }
multi sub foldl (&f, \acc, \lst) {
  #'s way of splitting a list in the first elt and the rest
  # The '*' is a shorthand for the end of the list
  #  my (\elt,\rest) = lst[0, 1 .. Inf ];
   my \elt = lst[0];
   my \rest = lst[1 .. Inf];
   # The actual recursion
   foldl( &f, f(acc, elt), rest);
}

#### Right fold

sub foldrl (&f, \acc, \lst) { 
  my $res = acc;
  for  lst.reverse -> \elt {
    $res = f($res,elt);
  }
  $res;
}

#
multi sub foldr ( &f, \acc, ()) { acc }
multi sub foldr (&f, \acc, \lst) {
    my (\rest,\elt) = lst[0..^*-1, *  ];
    foldr( &f, f(acc, elt), rest);
}

#### `map` and `grep` are folds

#
sub map_ (&f,\lst) {
    foldl( sub (\acc,\elt) {
            (|acc,f(elt))
            }, (), lst);
}
#
sub grep_ (&f,\lst) {
    foldl( sub (\acc,\elt) {
      if (f(elt)) {
          (|acc,elt)
      } else {
          acc
      }
    }, (), lst);
}

## Functions returning functions


# Raku
sub add_1 (\x) {x+1}
sub add_2 (\x) {x+2}
sub add_3 (\x) {x+3}
sub add_4 (\x) {x+4}
sub add_5 (\x) {x+5}

say add_1(4); #=> says 5

# Raku
my \add_n =
sub (\x) {x},
sub (\x) {x+1},
sub (\x) {x+2},
sub (\x) {x+3},
sub (\x) {x+4},
sub (\x) {x+5};

say add_n[0].(4); #=> says 5

# Raku
my \add_mut = [];
for 0 .. 5 -> \n {
  add_mut.push(sub (\x) {x+n});
}

say add_mut[1].(4); #=> says 5

# Raku
sub gen_add(\n) {  
  sub (\x) {x+n}
}

my \add_i = map &gen_add, 0..5;

say add_i[1].(4); #=> says 5

### Laziness

# Raku
my \add = map &gen_add, 0 .. ∞;  

say add[244].(7124); #=> says 7368

## Function composition

# Raku
my \res_map_chain = map -> \x { x + 5 }, map -> \x {x*x}, 1..30;


my \res_map_comp = map -> \x { x + 5 } ∘ -> \x { x * x }, 1..30;


sub f {};
sub g {};

my &h = &f ∘ &g;


sub h_ (\x) {
    f(g(x))
}

# Raku
sub compose(&f,&g) {
    sub (\x) { f(g(x)) }
}
