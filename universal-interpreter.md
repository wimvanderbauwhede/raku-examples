---
layout: article
title: "A Universal Interpreter"
date: 2020-06-05
modified: 2020-06-05
tags: [ coding, hacking, programming, raku ]
excerpt: ""
current: ""
current_image: universal-interpreter_1600x600.jpg
comments: false
toc: false
categories: articles
image:
  feature: universal-interpreter_1600x600.jpg
  teaser: universal-interpreter_400x150.jpg
  thumb: universal-interpreter_400x150.jpg
---


This is the final article in a series about functional programming and in particular algebraic data types and function types in [Raku](https://raku.org/). It builds on my earlier articles on [algebraic data types]({{site.url}}/articles/roles-as-adts-in-raku/) in on [Raku](https://raku.org/) and their use in the practical example of [list-based parser combinators]({{site.url}}/articles/list-based-parser-combinators/). It also makes heavily use of [function types]({{site.url}}/articles/function-types).
If you are not familiar with functional programming (or with [Raku](https://raku.org/)), I suggest you read my introduction ["Cleaner code with functional programming"]({{site.url}}/articles/decluttering-with-functional-programming/). If you are not familiar with algebraic data types or function types, you might want to read the other articles as well. For most of the article, I provide examples in Raku and Haskell.

In this article, I want to explain a technique called [Böhm-Berarducci encoding](http://okmij.org/ftp/tagless-final/course/Boehm-Berarducci.html) of algebraic data types. The link above is to Oleg Kiselyov's explanation, which makes interesting reading but is not required for what follows. Oleg says:

_"Boehm-Berarducci's paper has many great insights. Alas, the generality of the presentation makes the paper very hard to understand. It has a Zen-like quality: it is incomprehensible unless you already know its results."_

For the purpose of this article, it is sufficient to say that the Böhm-Berarducci encoding is a way to encode an algebraic data type as a function type. This means that the data itself is also encoded as a function. As a result, the function encoding the data type becomes a "universal interpreter". This makes it is easy to create various interpreters for algebraic data types. 

I will illustrate this with a few simple examples and then use it to construct a pretty printer and evaluator for a polynomial expression.

The basic idea behind the Böhm-Berarducci (BB) encoding is to create a type which represents a function with an argument for every alternative in a sum type.
Every argument is itself a function which takes as arguments the arguments of each alternative, and returns a type. However, the return type is polymorphic, so we decide what it will be when we use the BB type. 

For example, if we have a sum type `S` with three alternatives `A1`, `A2` and `A3`: 

```haskell
    data S = A1 Int | A2 String | A3
```

then the corresponding BB type will be

```haskell
    -- A1 Int
    (Int -> a) -> 
    -- A2 String
    (String -> a) -> 
    -- A3
    (a) -> 
    -- The return type
    a
```

I have put parentheses to show which part of the type is the function type corresponding to each alterative. 
Because the constructor for `A3` takes no arguments, the corresponding function signature in the BB encoding is simply `a`: a function wich takes no arguments and returns something of type `a`. The final `a` is the return value of the top-level function: every type alternative is an argument to the function. When applying the function, it must return a value of a given type. This type is `a` because `a` is the return type of every function representing an alternative. 

Let's look at a few examples to see how this works in practice.

## Some simple examples

### OpinionatedBool 

In a [previous post]({{site.url}}/articles/roles-as-adts-in-raku/) I showed how you can use Raku's _role_ feature to implement algebraic data types. I gave the example of 
`OpinionatedBool`:

```haskell
data OpinionatedBool = AbsolutelyTrue | TotallyFalse
```

which in Raku becomes

```perl6
role OpinionatedBool {}
role AbsolutelyTrue does OpinionatedBool {}
role TotallyFalse does OpinionatedBool {}
```

This is a sum type with two alternatives. 

In Haskell, the type declaration of the BB type lists the types of all the arguments representing the alternatives. As in this case the constructors for the alternatives take no arguments, the corresponding functions also take no arguments:

```haskell
    newtype OpinionatedBoolBB b = OpinionatedBoolBB {
        unBoolBB :: forall a . 
           a -- AbsolutelyTrue
        -> a -- TotallyFalse
        -> a
    }
```

Raku's type system is powerful enough to implement the BB type.
We can either implement it very simply as a role with a single accessor:

```perl6
    role BoolBB[\b] {
        has $.unBoolBB = b;
    }
```

Note that this is so general that _any_ BB type would have this representation, so there is no type safety. It also is hard to read because it is not clear how many arguments the function takes.

We can be more explicit by using a method with a typed signature:

```perl6    
    role BoolBB[&b] {
        method unBoolBB(Any \t, Any \f --> Any) {
            b(t,f);
        }
    }
```    

This tells us a lot more:

- the parameter to the role has an `&` sigil so it of type `Callable` (i.e. it is a function)
- the method's type tells us that there are two arguments of type Any. The method itself also returns a value of type `Any`, i.e. there is no constraint on the type of the return value. 

The type safety is not as strong as in Haskell, where we guarantee that all these return values will be of the same type, but the main purpose for using the types here is to make it provide documentation. We will enforce the type safety at a different point.

Now, the whole idea is that this role `BoolBB` will serve the same purpose as an ordinary Boolean. So instead of saying

```perl6
my OpinionatedBool \trueOB = AbsolutelyTrue;
```

I want something like 

```perl6
my BoolBB \trueBB = BBTrue;
```

So in this example, `BBTrue` will be an instance of `BoolBB` with a specific function as parameter. Let's call that function `true`, so we have

```perl6
my \BBTrue = BoolBB[ true ].new;
```

and similar for the `false` case. We can make this a little nicer using a helper function to create `BoolBB` instances:

```perl6
sub bbb(\tf --> BoolBB) { BoolBB[ tf ].new };
```

In this way we can write

```perl6
my BoolBB \BBTrue = bbb true;
my BoolBB \BBFalse = bbb false;
```

So what are the functions `true` and `false`? We know they are of type `a -> a -> a`; an obvious choice is:

```perl6
my \true  = -> Any \t, Any \f --> Any { t }
my \false = sub (Any \t,Any \f --> Any ) { f }
```

This is the same choice we made in [the article ""]({{site.urel}}/articles/).

In practice, we often want to convert between BB types and their algebraic counterparts.
To turn a Bool into a BoolBB:

```perl6
sub boolBB (Bool \tf --> BoolBB){ tf ?? BBTrue !! BBFalse }
```

To turn the BB Boolean into an actual Boolean:

```perl6
sub bool(BoolBB \b --> Bool) { 
    b.unBoolBB( True, False) 
}
```

So we have:

```perl6
say bool BBTrue; # => True
say bool BBFalse; # => False
say bool boolBB( bool BBTrue); # => True
say bool boolBB( bool BBFalse); # => False
```

### The Maybe type

The Boolean type above had two constructors without arguments. A simple algebraic data type where  one of the constructors has an argument is the `Maybe` type:

```haskell
data Maybe b = Just b | Nothing
```

This type is used to express that a function does not always return a value of a given type. 

The BB type becomes in Haskell:

```haskell
    newtype MayBB b = MayBB {
    unMayBB :: forall a .  
    (b -> a) -- Just b 
    -> a -- Nothing 
    -> a
```

and in Raku:

```perl6
role MayBB[ &mb ] {
    method unMayBB(&j:(Any --> Any),Any \n --> Any) {
        mb(&j,n);
    }
}
```
As before for the BB Boolean, we create some helper functions. 

First we have what I call _selectors_, functions that select a field from the BB type.

```perl6
# selectors
sub bbj( \x ) { -> &j:(Any --> Any), Any \n --> Any { &j(x)} }
sub bbn { -> &j:(Any --> Any),Any \n --> Any {n} }
```

Then we have a wrapper to make role construction nicer:

```perl6
sub mbb (&jm --> MayBB) {
    MayBB[ &jm ].new;
}
```

With these we can easily write the final BB type constructors:

```perl6
sub Just(\v) {mbb( bbj( v) )}
sub Nothing {mbb( bbn )}
```

With these we can create values of this type, e.g.

```perl6
my MayBB \mbb = Just 42;
my MayBB \mbbn = Nothing;
```

Let's make a simple printer for this type:

```perl6
sub printBB(MayBB \mb --> Str) {
    mb.unMayBB( sub (Any \x --> Any) { "{x}" }, 'NaN' );
}

say printBB mbb; # => 42
say printBB mbbn; # => NaN
```

### A pair, the simplest product type

The two previous examples were for sum types. Let's look at a simple product type, a pair of two values also known as a tuple. Assuming the tuple has type parameters `t1` and `t2`, the BB type in Haskell is:

```haskell
newtype PairBB t1 t2 = PairBB {
    unPairBB :: forall a . (t1 -> t2 -> a) -> a
}
```

and in Raku:

```perl6
role PairBB[ &p ] {
    method unPairBB(&p_:(Any,Any --> Any)  --> Any) {
        p(&p_);
    }
}
```

The selectors (we reuse the `true` and `false` functions used for the `BoolBB`):

```perl6
# To get the elements out of the pair
sub fst( \p ){ p.unPairBB(true) }
sub snd( \p ){ p.unPairBB(false) }
```

The pair constructor takes the values `x` and `y` to be put in the pair, and uses them in an anonymous function used as the parameter for the role. The single argument of this anonymous function is a selector function `&p`, which is applied to `x` and `y` in its body. 

```perl6
# Final pair constructor
sub pair(\x,\y --> PairBB) {
    PairBB[ -> &p { p(x, y) } ].new;
}
```
We can use this to build pairs e.g.

```perl6
my PairBB \bbp = pair 42,"forty-two";

# print it
say "({fst bbp},{snd bbp})"; # => (42,forty-two)
```

## An interpreter and pretty printer for a polynomial expression

Now that we have seen how simple sum and product types are BB-encoded, let's try something more complex: a parser and interpreter for expressions of the form `a*x^2+b*x+c`. 

The algebraic data for the parse tree for expressions like this in Haskell:

```haskell
data Term = 
      Var String
    | Par String 
    | Const Int
    | Pow Term Int
    | Add [Term]
    | Mult [Term]
```
and in Raku:

```perl6
role Term {}
role Var [Str \v] does Term {
    has Str $.var = v;
}
role Par [Str \p] does Term {
    has Str $.par = p;
}
role Const [Int \c] does Term {
    has Int $.const = c;
}
role Pow [Term \t, Int \n] does Term {
    has Term $.term = t;
    has Int $.exp = n;
}
role Add [Array[Term] \ts] does Term {
    has Array[Term] $.terms = ts;
}
role Mult [Array[Term] \ts] does Term {
    has Array[Term] $.terms = ts;
}
```

The BB encoding of `Term` in Raku is:

```perl6
role TermBB[&f] {
    method unTermBB(
        &var:(Str --> Any),
        &par:(Str --> Any),
        &const:(Int --> Any),
        &pow:(Term,Int --> Any),
        &add:(Str --> Any),
        &mult:(Str --> Any) 
    ) {
        f(&var,&par,&const,&pow,&add,&mult);
    }
}
```

As before, we create our little helpers:

```perl6
# Selectors
sub _var(Str \s --> TermBB) { 
    TermBB[ 
        sub (\v, \c, \n, \p, \a, \m) { v.(s) }
    ].new;
    }
sub _par(Str \s --> TermBB) { 
    TermBB[ 
        sub (\v, \c, \n, \p, \a, \m) { c.(s) }
    ].new;
    }
sub _cons(Int \i --> TermBB) { 
    TermBB[ 
        sub (\v, \c, \n, \p, \a, \m) { n.(i) }
    ].new;
    }    
sub _pow( TermBB \t, Int \i --> TermBB) {
    TermBB[  sub (\v, \c, \n, \p, \a, \m) { 
        p.( t.unTermBB( v, c, n, p, a, m ), i);
    }
    ].new;
}
# Properly typed
sub _add( Array[TermBB] \ts --> TermBB) {
    TermBB[  sub (\v, \c, \n, \p, \a, \m) { 
        a.( map {$_.unTermBB( v, c, n, p, a, m )}, ts )
    }
    ].new;
}
# But this works as well
sub _mult(  @ts --> TermBB) {
    TermBB[  sub (\v, \c, \n, \p, \a, \m) { 
        m.( map {$_.unTermBB( v, c, n, p, a, m )}, @ts )
    }
    ].new;
}
# helper-helper, casts the output of the map call to an Array
sub typed-map (\T,\lst,&f) {
    Array[T].new(map {f($_) }, |lst )
}
```

and using these we can convert the algebraic data type into its BB encoding:

```perl6
# Turn a Term into a BB Term
multi sub termToBB(Var \t) { _var(t.var)}
multi sub termToBB(Par \c) { _par( c.par)}
multi sub termToBB(Const \n) {_cons(n.const)}
multi sub termToBB(Pow \pw){ _pow( termToBB(pw.term), pw.exp)}
multi sub termToBB(Add \t){ _add( typed-map( TermBB, t.terms, &termToBB ))}
multi sub termToBB(Mult \t){ _mult(map {termToBB($_)}, |t.terms)}
```

As an example, let's create the parse tree for a few expressions:

```perl6
# a*x^2 + b*x + x
my \qterm1 = Add[ 
    Array[Term].new(
    Mult[ Array[Term].new(Par[ "a"].new, Pow[ Var[ "x"].new, 2].new) 
        ].new,
    Mult[
        Array[Term].new(Par[ "b"].new, Var[ "x"].new) 
        ].new,
    Par[ "c"].new
    )
    ].new;

#   x^3 + 1    
my \qterm2 = Add[ 
    Array[Term].new(
    Pow[ Var[ "x"].new, 3].new, 
    Const[ 1].new
    )
    ].new;

#   qterm1 * qterm2    
my \qterm = Mult[ 
    Array[Term].new(
        qterm1, qterm2
    )
    ].new;

say qterm.raku;
```

Now convert this into the BB encoding:
```perl6
my \qtermbb = termToBB( qterm);

say qtermbb.raku;
```

```perl6
# A pretty-printer
sub ppTermBB(TermBB \t --> Str){ 
        sub var( \x ) { x }
        sub par( \x ) { x }
        sub const( $x ) { "$x" }
        sub pow( \t, $m ) { t ~ "^$m" } 
        sub add( \ts ) { "("~join( " + ", ts)~")" }
        sub mult( \ts ) { join( " * ", ts) }
        t.unTermBB( &var, &par, &const, &pow, &add, &mult);
}
```

```perl6
# evalTermBB :: H.Map String Int -> H.Map String Int -> TermBB -> Int
sub evalTermBB( %vars,  %pars, \t) {
    t.unTermBB( 
        -> \x {%vars{x}}, 
        -> \x {%pars{x}},
        -> \x {x},
        -> \t,\m { t ** m},
        -> \ts { [+] ts},
        -> \ts { [*] ts}
    );
}
```

```perl6
# Now let's combine them!
sub evalAndppTermBB(%vars,  %pars, TermBB \t ){ 
    t.unTermBB( 
        -> \x {[%vars{x},x]}, 
        -> \x {[%pars{x},x]},
        -> \x {[x,"{x}"]},
        -> \t,\m {[t[0] ** m, t[1] ~ "^{m}"] },
        -> \ts { 
            my \p = 
        reduce { [ $^a[0] + $^b[0], $^a[1] ~ " + " ~ $^b[1]] }, ts[0],  |ts[1..*];
        [ p[0], "("~p[1]~")" ]; 
        }, 
        -> \ts { reduce { [ $^a[0] * $^b[0], $^a[1] ~ " * " ~ $^b[1]] }, ts[0],  |ts[1..*]}
    )
}

say ppTermBB( qtermbb);
say evalTermBB(
    {"x" => 2}, {"a" =>2,"b"=>3,"c"=>4},  qtermbb
);
say evalAndppTermBB(
    {"x" => 2}, {"a" =>2,"b"=>3,"c"=>4},  qtermbb
);
```

```perl6
# This is for parsing into AST, the link between Term and the TaggedEntry
role TaggedEntry {}
role Val[Str @v] does TaggedEntry {
	has Str @.val=@v;
} 
# valmap :: [(String,TaggedEntry)]
role ValMap [  @vm] does TaggedEntry { #String \k, TaggedEntry \te,
	has @.valmap = @vm; 
}

multi sub taggedEntryToTerm (Var ,\val_strs) { Var[ val_strs.val.head].new }
multi sub taggedEntryToTerm (Par ,\par_strs) { Par[par_strs.val.head].new }
multi sub taggedEntryToTerm (Const ,\const_strs) {Const[ Int(const_strs.val.head)].new } 
# multi sub taggedEntryToTerm (Pow , ValMap [t1,(_,Val [v2])]) { Pow[ taggedEntryToTerm(...,....), Int(...)].new}        
# multi sub taggedEntryToTerm (Add , ValMap hmap) = Add $ map taggedEntryToTerm hmap
# multi sub taggedEntryToTerm (Mult , ValMap hmap) = Mult $ map taggedEntryToTerm hmap
my Str @val_strs = "42";
my \v = taggedEntryToTerm(Const, Val[@val_strs].new);
say v.raku; 
```