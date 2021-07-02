use v6;

grammar ListExpression {

    token TOP {
        <list_expression>
    }
    token number {
        \d+
    }
    token variable { \w+ }
    token list_operator { ',' }

    token atomic_expression {
        <number> | 
        <variable>
    }
    token open_kaku { '['}
    token close_kaku { ']'}

    token kaku_parens_expression { <.open_kaku> <list_expression>  <.close_kaku> }

    # Without this, we can't do singleton lists
    token kaku_parens_singleton_expression { <.open_kaku> <list_elt_expression>?  <.close_kaku> }

    token list_elt_expression {
        <kaku_parens_expression> | 
        <kaku_parens_singleton_expression> |
        <atomic_expression>
    }

# the alternative here is to allow us to parse [...] as a list, but not a bare number or variable
    token list_expression {  
        
        [<list_elt_expression> [ <.list_operator> <list_elt_expression> ]+ ]         
        # Crucially, with '|' this does NOT work!        
        || <kaku_parens_expression> 
    }
}

my $lm = ListExpression.parse("[[[x,var],vbr,[42,43]],0]");
say $lm;
my $lm1 = ListExpression.parse("1,[[[x,var],vbr,[42,43]],0]");
say $lm1;

my $lm2 = ListExpression.parse("[x],1,[[[x,var],vbr,[42,43]],0],vvv,[[11]],[]");
say $lm2;
