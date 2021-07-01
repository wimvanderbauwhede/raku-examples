So the question is how to nest expression tokens for Haku

A function declaration is currently not treated as an expression
As my idea is to emit Scheme so function declarations will map to `define`

For operator expressions, I think I will keep it simple: parentheses are mandatory.
We can do the same for function application. So an operator expression can contain:



So what is the highest-level expression? That would be a let or an if-then;

let is either "moshi ..." or "●..." so that can't be mistaken for if-then which must start with a condition. However, in principle that condition could be a let; I can save myself a world of trouble by not allowing this:
- An `if-then` condition can be one of the following:

    token condition_expression {    
    <comparison_expression> |
    <apply_expression> |   
    <operator_expression> |
    <parens_expression> |
    <atomic_expression>
    }
    
- The next level is the RHS of a binding and the final return expression of the let. In principle, both of these should be allowed to contain their own let_expressions
So it is rather crucial that

token expression = {
    <let_expression> |
    <operator_expression> |
    <apply_expression> |
    <operator_expression> |
    <parens_expression> |
    <atomic_expression> 
}

should work. 

So let's design that first

token let_expression {
    'let' <bind_expression>+ 'in' <expression>
}

token bind_expression {
    <variable> '=' <expression>
}





Looking at the three others, 

- comparison_expression cannot contain if-then or let in its sub-epxressions, so what remains are
    <atomic_expression>
    <apply_expression>
    <operator_expression>
    <parens_expression>

- apply cannot contain if-then or let or apply in its sub-epxressions, so what remains are 
    <atomic_expression>
    <operator_expression>
    <parens_expression>
    
and then of course also things like
    <list_expression>

I think I can required that anywhere but on the LHS, the cons-expression is parenthesised; same for function composition.


I think I need a simple test case:

[a , b] , [c , d] , e

token kaku_parens_expression { <.open_kaku> <list_expression>  <.close_kaku> }

token list_elt_expression {
    <kaku_parens_expression> | <atomic_expression>
}

token list_expression { <list_elt_expression> [ <list_operator> <list_elt_expression> ]+ }





