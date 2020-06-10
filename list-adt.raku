use v6;

role List[::a] {}
role EmptyList[::a] does List[a] {}
role Cons[ ::a \elt, List[] \lst ] does List[a] {
    has $.elt = elt;
    has $.lst = lst;
}

# Now we can create a List of any length and type:

my List[Str] \str = 
        Cons[ 'h', 
        # Cons[ 'e', 
        # Cons[ 'l', 
        # Cons[ 'l', 
        # Cons[ 'o', 
        EmptyList[Str]
        # ].new
        # ].new
        # ].new
        # ].new
        ].new;

 say str;       

