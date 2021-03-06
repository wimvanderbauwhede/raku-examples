https://docs.raku.org/type/Array
class Array
Sequence of itemized values

class Array is List {}
An Array is a List which forces all its elements to be scalar containers, which means you can assign to array elements.


------
https://docs.raku.org/type/List#Items,_flattening_and_sigils
In Raku, assigning a List to a scalar variable does not lose information. The difference is that iteration generally treats a list (or any other list-like object, like a Seq or an Array) inside a scalar as a single element.

my $s = (1, 2, 3);
for $s { }      # one iteration 
for $s.list { } # three iterations 
 
my $t = [1, 2, 3];
for $t { }      # one iteration 
for $t.list { } # three iterations 
 
my @a = 1, 2, 3;
for @a { }      # three iterations 
for @a.item { } # one iteration
This operation is called itemization or putting in an item context. .item does the job for objects, as well as $( ... ) and, on array variables, $@a.

Lists generally don't interpolate (flatten) into other lists, except when they are in list context and the single argument to an operation such as append:

my $a = (1, 2, 3);
my $nested = ($a, $a);  # two elements 
 
my $flat = $nested.map({ .Slip });  # six elements, with explicit Slip 
 
my @b = <a b>;
@b.append: $a.list;     # The array variable @b has 5 elements, because 
                        # the list $a is the sole argument to append 
 
say @b.elems;           # OUTPUT: «5␤» 
 
my @c = <a b>;
@c.append: $a.list, 7;  # The array variable @c has 4 elements, because 
                        # the list $a wasn't the only argument and thus 
                        # wasn't flatten by the append operation 
 
say @c.elems;           # OUTPUT: «4␤» 
 
my @d = <a b>;
@d.append: $a;          # The array variable @d has 3 elements, because 
                        # $a is in an item context and as far as append is 
                        # concerned a single element 
 
say @d.elems;           # OUTPUT: «3␤»

------
https://docs.raku.org/language/list#The_@_sigil
The @ sigil
Variables in Raku whose names bear the @ sigil are expected to contain some sort of list-like object. Of course, other variables may also contain these objects, but @-sigiled variables always do, and are expected to act the part.

By default, when you assign a List to an @-sigiled variable, you create an Array. Those are described below. If instead you want to refer directly to a List object using an @-sigiled variable, you can use binding with := instead.

my @a := 1, 2, 3;

Arrays
Arrays differ from lists in three major ways: Their elements may be typed, they automatically itemize their elements, and they are mutable. Otherwise they are Lists and are accepted wherever lists are.

https://docs.raku.org/language/list#Itemization
Itemization

For most uses, Arrays consist of a number of slots each containing a Scalar of the correct type. Every such Scalar, in turn, contains a value of that type. Raku will automatically type-check values and create Scalars to contain them when Arrays are initialized, assigned to, or constructed.

This is actually one of the trickiest parts of Raku list handling to get a firm understanding of.

First, be aware that because itemization in Arrays is assumed, it essentially means that $(…)s are being put around everything that you assign to an array, if you do not put them there yourself. On the other side, Array.raku does not put $ to explicitly show scalars, unlike List.raku:

((1, 2), $(3, 4)).raku.say; # says "((1, 2), $(3, 4))" 
[(1, 2), $(3, 4)].raku.say; # says "[(1, 2), (3, 4)]" 
                            # ...but actually means: "[$(1, 2), $(3, 4)]"
It was decided all those extra dollar signs and parentheses were more of an eye sore than a benefit to the user. Basically, when you see a square bracket, remember the invisible dollar signs.



Second, remember that these invisible dollar signs also protect against flattening, so you cannot really flatten the elements inside of an Array with a normal call to flat or .flat.

((1, 2), $(3, 4)).flat.raku.say; # OUTPUT: «(1, 2, $(3, 4)).Seq␤» 
[(1, 2), $(3, 4)].flat.raku.say; # OUTPUT: «($(1, 2), $(3, 4)).Seq␤»
Since the square brackets do not themselves protect against flattening, you can still spill the elements out of an Array into a surrounding list using flat.

(0, [(1, 2), $(3, 4)], 5).flat.raku.say; # OUTPUT: «(0, $(1, 2), $(3, 4), 5).Seq␤»
...the elements themselves, however, stay in one piece.

This can irk users of data you provide if you have deeply nested Arrays where they want flat data. Currently they have to deeply map the structure by hand to undo the nesting:

say gather [0, [(1, 2), [3, 4]], $(5, 6)].deepmap: *.take; # OUTPUT: «(0 1 2 3 4 5 6)␤»
... Future versions of Raku might find a way to make this easier. However, not returning Arrays or itemized lists from functions, when non-itemized lists are sufficient, is something that one should consider as a courtesy to their users:

Use Slips when you want to always merge with surrounding lists.

Use non-itemized lists when you want to make it easy for the user to flatten.

Use itemized lists to protect things the user probably will not want flattened.

Use Arrays as non-itemized lists of itemized lists, if appropriate.

Use Arrays if the user is going to want to mutate the result without copying it first.

The fact that all elements of an array are itemized (in Scalar containers) is more a gentleman's agreement than a universally enforced rule, and it is less well enforced that typechecks in typed arrays. See the section below on binding to Array slots.

Literal arrays
Literal Arrays are constructed with a List inside square brackets. The List is eagerly iterated (at compile time if possible) and values in it are each type-checked and itemized. The square brackets themselves will spill elements into surrounding lists when flattened, but the elements themselves will not spill due to the itemization.
------
https://docs.raku.org/routine/[%20]
routine [ ]

(Operators) circumfix [ ]
The Array constructor returns an itemized Array that does not flatten in list context. Check this:

say .raku for [3,2,[1,0]]; # OUTPUT: «3␤2␤$[1, 0]␤»
This array is itemized, in the sense that every element constitutes an item, as shown by the $ preceding the last element of the array, the (list) item contextualizer.
------

https://docs.raku.org/language/mop#index-entry-is_itemized%3F
VAR
Returns the underlying Scalar object, if there is one.

The presence of a Scalar object indicates that the object is "itemized".

.say for (1, 2, 3);           # OUTPUT: «1␤2␤3␤», not itemized 
.say for $(1, 2, 3);          # OUTPUT: «(1 2 3)␤», itemized 
say (1, 2, 3).VAR ~~ Scalar;  # OUTPUT: «False␤» 
say $(1, 2, 3).VAR ~~ Scalar; # OUTPUT: «True␤»
------
https://docs.raku.org/routine/item#(Any)_sub_item
routine item

class Mu
From Mu

(Mu) method item
method item(Mu \item:) is raw
Forces the invocant to be evaluated in item context and returns the value of it.

say [1,2,3].item.raku;          # OUTPUT: «$[1, 2, 3]␤» 
say %( apple => 10 ).item.raku; # OUTPUT: «${:apple(10)}␤» 
say "abc".item.raku;            # OUTPUT: «"abc"␤»
class Any
From Any

(Any) sub item
Defined as:

multi item(\x)
multi item(|c)
multi item(Mu $a)
Forces given object to be evaluated in item context and returns the value of it.

say item([1,2,3]).raku;              # OUTPUT: «$[1, 2, 3]␤» 
say item( %( apple => 10 ) ).raku;   # OUTPUT: «${:apple(10)}␤» 
say item("abc").raku;                # OUTPUT: «"abc"␤»

You can also use $ as item contextualizer.

say $[1,2,3].raku;                   # OUTPUT: «$[1, 2, 3]␤» 
say $("abc").raku;                   # OUTPUT: «"abc"␤»

--------
https://docs.raku.org/language/list#Flattening_%22context%22
Flattening "context"
When you have a list that contains sub-lists, but you only want one flat list, you may flatten the list to produce a sequence of values as if all parentheses were removed. This works no matter how many levels deep the parentheses are nested.

say (1, (2, (3, 4)), 5).flat eqv (1, 2, 3, 4, 5) # OUTPUT: «True␤»
This is not really a syntactical "context" as much as it is a process of iteration, but it has the appearance of a context.

Note that Scalars around a list will make it immune to flattening:

for (1, (2, $(3, 4)), 5).flat { .say } # OUTPUT: «1␤2␤(3 4)␤5␤»
...but an @-sigiled variable will spill its elements.

my @l := 2, (3, 4);
for (1, @l, 5).flat { .say };      # OUTPUT: «1␤2␤3␤4␤5␤» 
my @a = 2, (3, 4);                 # Arrays are special, see below 
for (1, @a, 5).flat { .say };      # OUTPUT: «1␤2␤(3 4)␤5␤»


--------

https://docs.raku.org/type/Slip#sub_slip

class Slip
A kind of List that automatically flattens into an outer container

class Slip is List {}
A Slip is a List that automatically flattens into an outer List (or other list-like container or iterable).


To create a Slip, either coerce another list-like type to it by calling the Slip method, or use the slip subroutine:

# This says "1" and then says "2", rather than saying "(1 2)" 
.say for gather {
    take slip(1, 2);
}
A Slip may also be created by using the prefix:<|> operator. This differs from the slip subroutine in both precedence and treatment of single arguments. In fact, prefix:<|> only takes a single argument, so in that way, it behaves closer to the .Slip method than the slip subroutine.

my $l = (1, 2, 3);
say (1, slip 2, 3).raku;  # says (1, 2, 3)      , slips 2, 3 into (1, …) 
say (0, slip $l).raku;    # says (0, $(1, 2, 3)), $l does not break apart 
say (0, $l.Slip).raku;    # says (0, 1, 2, 3)   , slips from $l into (0, …) 
say (|$l).raku;           # says slip(1, 2, 3)  , breaks apart $l 
say (0, (|$l, 4), 5);     # says (0 (1 2 3 4) 5), slips from $l into (…, 4) 
say (0, ($l.Slip, 4), 5); # says (0 (1 2 3 4) 5), slips from $l into (…, 4) 
say (0, (slip $l, 4), 5); # says (0 (1 2 3) 4 5), slips ($l, 4) into (0, …, 5) 
say (0, ($l, 4).Slip, 5); # says (0 (1 2 3) 4 5), slips ($l, 4) into (0, …, 5) 


--------


class Seq
An iterable, potentially lazy sequence of values

class Seq is Cool does Iterable does Sequence { }
A Seq represents anything that can produce a sequence of values. A Seq is born in a state where iterating it will consume the values. Calling .cache on a Seq will make it store the generated values for later access.

Assigning the values of a Seq to an array consumes a Seq that is not lazy. Use the lazy statement prefix to avoid a Seq from being iterated during the assignment:

# The Seq created by gather ... take is consumed on the spot here. 
my @a = gather do { say 'consuming...'; take 'one' };  # OUTPUT: «consuming...␤» 
 
# The Seq here is only consumed as we iterate over @a later. 
my @a = lazy gather do { say 'consuming...'; take 'one' };  # outputs nothing. 
.say for @a;  # OUTPUT: «consuming...␤one␤» 
