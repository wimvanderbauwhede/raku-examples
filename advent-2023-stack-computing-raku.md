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

To obtain a chain of calculations, the operator needs to put the result of every computation on the stack. This means that in the example, the result of `MUL` will be on the stack, and not returned to the program. To return the result, I slightly abuse Uxntal's `BRK` opcode. On encountering this opcode, the value of the computation is returned and the stack is cleared (in native Uxntal, `BRK` simply terminates the program). So a working example of the above code is

```perl6
    my \res = 6 ∘ 4 ∘ 3 ∘ ADD ∘ MUL ∘ BRK
```

## Some abstraction with subroutines

Uxntal allows to define subroutines. They are just blocks of code that you jump to. In my RakU implementation we can simply define custom subroutines and call them using the Uxntal instructions `JSR` (jump and return), `JMP` (jump and don't return, use for tail calls) and `JCN` (conditional jump).

```perl6
my \res =  3 ¬ 2 ¬ 1 ¬ INC ¬ ADD ¬ MUL ¬ 4 ¬ &f ¬ JMP ;

sub f {
    SUB ¬ 5 ¬ MUL ¬ 2 ¬ ADD ¬ RET
}
```

## Stack manipulation operations

One of the key features of a stack language is that it allows you to manipulate the stack. In Uxntal, there are several operations to duplicate, remove and reorder items on the stack. Here is a contrived example

    my \res =  
        4 ∘ 2 ∘ DUP ∘ INC ∘ # 4 2 3
        OVR ∘  # 4 2 3 2
        ROT ∘ # 4 3 2 2
        ADD ∘ 2 ∘ ADD ∘ MUL ∘ BRK ; # 42

Uxntal has more ALU operations as well as load and store operations to work with memory and special IO operations. It also has a second stack and operations to move data between stacks. I am omitting these for simplicity. 

## The mighty `∘` operator, part II: implementation

With the above, we have enough requirements to design and implement the operator. As usual, I will eschew the use of objects. It was my intention to use all kind of fancy Raku features such as introspection but it turns out I don't need them. 

We start by defining the Uxntal instructions as enums. I could use a single enum but grouping them makes their purpose clearer.

```perl6
enum StackManipOps is export <POP NIP DUP SWP OVR ROT BRK> ;
enum StackCalcOps is export <ADD SUB MUL INC DIV>;
enum JumpOps is export <JSR JMP JCN RET>;
```

We use a stateful custom operator with the stack `@wst` (working stack) as state. The operator returns the top of the stack and is left-associative. Anything that is not an Uxntal instruction is pushed onto the stack.

```perl6
our sub infix:<∘>(\x, \y)  is export {
    state @wst = ();

    if y ~~ StackManipOps {
        given y {
            when POP { ... }
            ...
        }
    } elsif y ~~ StackCalcOps {
        given y {
            when INC { ... }
            ...
        }
    } elsif y ~~ JumpOps {
        given y {
            when JSR { ... }
            ...
        }
    } else {
        @wst.push(y);
    }

    return @wst[0]
}
```

This is not quite good enough: the operator is binary, but the above implementation ignores the first element. This is only relevant for the first element in a sequence. We handle this using a boolean state `$isFirst`. When `True`, we simply call the operator again with `Nil` as the first element.
The `$isFirst` state is reset on every `BRK`.

```perl6
    state Bool $isFirst = True;
    ...
    if $isFirst {
        @wst.push(x);
        $isFirst = False;
        Nil ∘ x
    }
```

The final complication lies in the need to support conditional jumps. The problem is that in e.g.

```perl6
    &ft ∘ JCN ∘ &ff ∘ JMP
```

depending on the condition, `ft` or `ff` should be called. If `ft` is called, nothing after `JCN` should be executed. I solve this by introducing another boolean state variable, `$skipInstrs`, which is set to `True` when `JCN` is called with a true condition. 

```perl6
    when JCN {
        my &f =  @wst.pop;
        my $cond = @wst.pop;
        if $cond>0 {
            $isFirst = True;
            f();
            $skipInstrs = True;
        }
    }
```

The boolean is cleared on encountering a `JMP` or `RET`:

```perl6
    if $skipInstrs {
        if (y ~~ JMP) or (y ~~ RET) {
            $skipInstrs = False
        }
    } else {
        ...
    }
```

This completes the implementation of the operator `∘`. The final structure is:

```perl6
our sub infix:<∘>(\x, \y)  is export {
    state @wst = ();
    state Bool $isFirst = True;
    state $skipInstrs = False;

    if $skipInstrs {
        if (y ~~ JMP) or (y ~~ RET) {
            $skipInstrs = False
        }
    } else {

        if $isFirst and not (x ~~ Nil) {
            @wst.push(x);
            $isFirst = False;
            Nil ∘ x
        }

        if y ~~ StackManipOps {
            given y {
                when POP { ... }
                ...
            }
        } elsif y ~~ StackCalcOps {
            given y {
                when INC { ... }
                ...
            }
        } elsif y ~~ JumpOps {
            given y {
                when JSR { ... }
                ...
            }
        } else {
            @wst.push(y);
        }
    }
    return @wst[0]
}
```

To be support Uxntal in full, the main addition needed is the support for a return stack. This mostly requires creation of instructions with a `r` suffix and select between `@wst` and `@rst` based on the presence of this suffix. 