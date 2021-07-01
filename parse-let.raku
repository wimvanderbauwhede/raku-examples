use v6;

grammar Expression {
    token TOP { <expression> }

    token expression  {
        <let_expression> |
        
        [
            <operator_expression> ||
            <apply_expression>
        ] |
        <parens_expression> |
        <atomic_expression> 
    }
    token open_maru { '('}
    token close_maru { ')'}
    token number {
        \d+
    }
    token identifier { \w+ }
    token list_operator { ',' }

    token atomic_expression {
        <number> | 
        <identifier>
    }
    token arg_expression_list {
        <arg_expression> [<list_operator> <arg_expression>]*
    }

    token parens_expression { <.open_maru>  <operator_expression>  <.close_maru> }

    token apply_expression {
        <identifier> '(' <arg_expression_list> ')'
    }
    token arg_expression {
        <parens_expression> |
        <apply_expression> |
        <atomic_expression>
    }
    token op {
        '+' | '-' | '*' | '/'
    }
    token operator_expression {
        <arg_expression> <op> <arg_expression>
    }

    token let_expression {
        'let' <.ws> <bind_expression>+ 'in' <.ws> <expression> <.ws>
    }

    token bind_expression {
        <identifier> '=' <expression> <.ws>?
    }

}

my $let1 = Expression.parse("let
x=6
y=7
in
x*y
");
# say $let1;


my $let2 = Expression.parse("let
x=let
a=3
in
a*a
y=h(11)+(f(7)+3)
in
x*y
");
say $let2;

# my $let3 = Expression.subparse("x=f(7)+g(11)",:rule('bind_expression'));
# say $let3;
