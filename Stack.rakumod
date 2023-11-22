use v6;
unit module Stack;
use Uxn;

$Stack::uxn = Uxn.new;

constant \_ is export = Nil ;
constant \ￌ is export = Nil;
our sub term:<⟂>(--> Nil) is export { };


our sub infix:<∘>(\x, \y) is export {

    if y ~~ Sub {
        my &f = y;
        my @args;
        say y.raku;
        say 'ar:' ~ &f.signature.arity;
        say 'pre elems:' ~ $Stack::uxn.wst.elems;
        map {@args.push($Stack::uxn.wst.pop)}, 1 .. &f.signature.arity;
        my \res = f(|@args) ;
        
        $Stack::uxn.wst.push(res);
        say 'post elems:' ~ $Stack::uxn.wst.elems;
     } else {
         say 'const:' ~ y;
          say 'pre elems:' ~ $Stack::uxn.wst.elems;
        $Stack::uxn.wst.push(y);
         say 'post elems:' ~ $Stack::uxn.wst.elems;
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

our sub DUP (\x ) is export { 
    $Stack::uxn.wst.push(x); x
}

