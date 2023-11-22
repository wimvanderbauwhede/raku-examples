use v6;
unit module Stack;
use Uxn;

$Stack::uxn = Uxn.new;

constant \_ is export = Nil ;

our sub infix:<∘>(\x, \y) is export {

    if y ~~ Sub {
        my &f = y;
        my \res = f(|$Stack::uxn.wst.reverse()[0..&f.signature.arity-1].reverse) ;
        map {$Stack::uxn.wst.pop}, 1 .. &f.signature.arity;
        $Stack::uxn.wst.push(res)
     } else {
        $Stack::uxn.wst.push(y)
    }
    return $Stack::uxn.wst[0]
}

#our sub run is export {
#    $Stack::uxn.run();
#}

our sub INC ( \x ) is export  { x + 1 }
our sub ADD ( \x, \y ) is export { x + y } 
our sub MUL( \x, \y ) is export { x * y }
our sub SUB( \x, \y ) is export { x - y }


