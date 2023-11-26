# Stack-based programming in Raku

When `@lizmat` asked me to write a post for the Raku advent calendar I was initially a bit at a loss. I have spent most of the year not writing Raku but working on my own language [Funktal](https://limited.systems/articles/funktal/), a postfix functional language that compiles to [Uxntal](https://wiki.xxiivv.com/site/uxntal.html), the stack-based assembly language for the tiny [Uxn](https://wiki.xxiivv.com/site/uxn.html) virtual machine.

But as Raku is nothing if not flexible, could we do stack-based programming in it? Of course I could embed the entire Uxntal language in Raku using [a slang](https://raku.land/zef:lizmat/Slangify). But could we have a more shallow embedding?

## Stack-oriented programming

An example of simple arithmetic in Uxntal is

```perl6
    6 4 3 ADD MUL
```

This should be self-explanatory: it is called postfix, stack-based or reverse Polish notation. In infix notation, that is `6*(4+3)`. In prefix notation, it's `MUL(6, ADD(4,3))`. The integer literals are pushed on a stack, and the primitive operations `ADD` and `MUL` pop the arguments they need off the stack an push the result.

## The mighty `∘` operator, part I: definition

In Raku, we can't redefine the whitespace to act as an operator. I could of course do something like

```perl6
    my \stack-based-code = <6 4 3 ADD MUL>;
```

but I don't want to write an interpreter starting from strings. So instead, I will define an infix operator `∘`. Something like this:

```perl6
    6 ∘ 4 ∘ 3 ∘ ADD ∘ MUL
```

The operator either puts literals on the stack or calls the operation on the values on the stack.

By necessity, `∘` is a binary operator, but it will put only one element on the stack. I chose to have it process its second argument, and ignore the first one,because in that way it is easy to terminate the calculation. However, because of that, the first element of each sequence needs to be handled separately. As it can only be a literal, all we have to do is put it on the stack.

## Returning the result

To obtain a chain of calculations, the operator needs to put the result of every computation on the stack. This means that in the example, the result of `MUL` will be on the stack, and not returned to the program. To return the result, I introduce the `RET` opcode. On encountering this opcode, the value of the computation is returned and the stack is cleared. So a working example of the above code is

```perl6
    my \res = 6 ∘ 4 ∘ 3 ∘ ADD ∘ MUL ∘ RET
```

## Abstraction with functions

To allow abstraction of common functionality we can simply define custom functions:

```perl6
my \res =  3 ¬ 2 ¬ 1 ¬ INC ¬ ADD ¬ MUL ¬ 4 ¬ &f ¬ RET ;

sub f( \x, \y ) {
    y ¬  x ¬  SUB ¬ 5 ¬ MUL ¬ 2 ¬ ADD
}
```

We use the signature to determine the number of arguments to pop off that stack. 
[[ WV: is this necessary? Can we no do this simpler?]]

[[ To do this right, I need to keep a stack of callers; it also means that I should call functions using

&f JSR or &f JMP or &f JCN



]]


## Stack manipulation operations

## The mighty `∘` operator, part II: implementation