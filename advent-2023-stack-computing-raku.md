# Stack-based programming in Raku

When @lizmat asked me to write a post for the Raku advent calendar I was initially a bit at a loss. I have spent most of the year not writing Raku but working on my own language [Funktal](), a postfix functional language that compiles to [Uxntal](), the stack-based assembly language for the tiny [Uxn]() virtual machine.

But as Raku is nothing if not flexible, could we do stack-based programming in it? Of course I could embed the entire Uxntal language in Raku using [a slang](). But could we have a more shallow embedding?

An example of simple arithmetic in Uxntal is

    6 4 3 ADD MUL

In infix notation, that is `6*(4+3)`. In prefix notation, it's `MUL(6, ADD(4,3))`. The integer literals are pushed on a stack, and the operations pop however many arguments they need from the stack an push the result.

In Raku, we can't redefine the whitespace to act as an operator. I could of course do something like

    my \stack-based-code = <6 4 3 ADD MUL>;

but I don't want to write an interpreter starting from strings. So instead, I create an infix operator. Something like this:

    6 ∘ 4 ∘ 3 ∘ ADD ∘ MUL

The idea is that `ADD` and `MUL` are variables that contain a function, and that the operator either puts literals on the stack or calls the function on the values on the stack.

The binary operator processes its second argument. The first element of each sequence needs to be handled separately. But as it can only be a literal, all we have to do is put it on the stack.
On encountering a `RET` opcode, the value of the computation is returned and the stack is cleared.

