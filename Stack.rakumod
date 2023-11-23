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
        my $st = (&f.name.substr(0) ~~ / <:Lu>+ / and &f.name.substr(*-1) eq 'r' ) ?? $Stack::uxn.rst !! $Stack::uxn.wst;
        say y.raku;
        say 'ar:' ~ &f.signature.arity;
        say 'pre elems:' ~ $st.elems;
        map {@args.push($st.pop)}, 1 .. &f.signature.arity;
        my \res = f(|@args) ;
        if not (res ~~ Nil) {
            $st.push(res);
        }
        say 'post elems:' ~ $st.elems;
     } else {
         say 'const:' ~ y;
          say 'pre elems:' ~ $Stack::uxn.wst.elems;
        $Stack::uxn.wst.push(y);
         say 'post elems:' ~ $Stack::uxn.wst.elems;
    }
    return $Stack::uxn.wst[0]
}

our sub INC ( \x ) is export  { x + 1 }
our sub ADD ( \x, \y ) is export { x + y } 
our sub ADD2 is export { -> \x, \y { x + y } } 
our sub MUL( \x, \y ) is export { x * y }
our sub SUB( \x, \y ) is export { x - y }

our sub DUP (\x ) is export { 
    $Stack::uxn.wst.push(x); 
    x
}
our sub POP (\x ) is export { Nil }
our sub NIP (\x,\y ) is export { y }
our sub OVR (\x,\y ) is export { 
    $Stack::uxn.wst.push(x); 
    $Stack::uxn.wst.push(y);
    x
}
our sub ROT (\x,\y,\z) is export {
    $Stack::uxn.wst.push(y); 
    $Stack::uxn.wst.push(z);
    x
}