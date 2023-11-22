use v6;
unit module Stack;
use Uxn;

$Stack::uxn = Uxn.new;

our \_ is export = Nil ;

our sub infix:<∘>(\x, \y) is export {
    $Stack::uxn.wst.push(y)
}

our sub run is export {
    $Stack::uxn.run();
}

our sub INC (\x) is export  {x+1}
our sub ADD (\x,\y) is export {x+y} 
our sub MUL(\x,\y) is export {x*y}


