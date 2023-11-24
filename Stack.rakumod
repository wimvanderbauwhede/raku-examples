use v6;
unit module Stack;
use Uxn;

$Stack::uxn = Uxn.new;

constant \_ is export = Nil ;
constant \ￌ is export = Nil;
our sub term:<⟂>(--> Nil) is export { };

our sub infix:<¬>(\x, \y)  is export {
    state Int @wst;
    state Int @rst;
    state Bool $isFirst = True;

 if $isFirst and @wst.elems == 0 {
        say 'first const:' ~ x ;
        say 'pre elems:' ~ @wst.elems;
        @wst.push(x);
        say 'post elems:' ~ @wst.raku ; 
        $Stack::uxn.isFirst = False;
    }

    if y ~~ Sub {
        my &f = y;
        my @args;
        say 'NAME:' ~ &f.name;
        my Bool $isRet =  (&f.name eq 'RET');
        my Bool $isOp = ((&f.name.substr(0) ~~ / <:Lu>+ /) and not $isRet);
        my $st = ($isOp and &f.name.substr(*-1) eq 'r' ) ?? @rst !! @wst;
        say &f.raku;
        say 'ar:' ~ &f.signature.arity;
        say &f.name ~' pre elems:' ~ $st.elems;
        map {@args.push($st.pop)}, 1 .. &f.signature.arity;
        say @args.raku;
        my \res = f(|@args) ;
        say &f.name ~' stack:' ~ $st.raku;
        if $isOp and not (res ~~ Nil) {
            $st.push(res);
        } elsif $isRet {
            return res
        }
        say &f.name ~' post elems:' ~ $st.raku;
     } else {
        say 'const:' ~ y ~ ' (' ~ x ~')';
        say 'pre elems:' ~ @wst.elems;
        @wst.push(y);
        say 'post elems:' ~ @wst.raku ; 
    }
    return @wst[0]

}
our sub infix:<∘>(\x, \y) is export {
    if $Stack::uxn.isFirst and $Stack::uxn.wst.elems == 0 {
        say 'first const:' ~ x ;
        say 'pre elems:' ~ $Stack::uxn.wst.elems;
        $Stack::uxn.wst.push(x);
        say 'post elems:' ~ $Stack::uxn.wst.raku ; 
        $Stack::uxn.isFirst = False;
    }

    if y ~~ Sub {
        my &f = y;
        my @args;
        say 'NAME:' ~ &f.name;
        my Bool $isRet =  (&f.name eq 'RET');
        my Bool $isOp = ((&f.name.substr(0) ~~ / <:Lu>+ /) and not $isRet);
        my $st = ($isOp and &f.name.substr(*-1) eq 'r' ) ?? $Stack::uxn.rst !! $Stack::uxn.wst;
        say &f.raku;
        say 'ar:' ~ &f.signature.arity;
        say &f.name ~' pre elems:' ~ $st.elems;
        map {@args.push($st.pop)}, 1 .. &f.signature.arity;
        my \res = f(|@args) ;
        say &f.name ~' stack:' ~ $st.raku;
        if $isOp and not (res ~~ Nil) {
            $st.push(res);
        } elsif $isRet {
            return res
        }
        say &f.name ~' post elems:' ~ $st.raku;
     } else {
        say 'const:' ~ y ~ ' (' ~ x ~')';
        say 'pre elems:' ~ $Stack::uxn.wst.elems;
        $Stack::uxn.wst.push(y);
        say 'post elems:' ~ $Stack::uxn.wst.raku ; 
    }
    return $Stack::uxn.wst[0]
}


our sub INC ( \x ) is export  { x + 1 }
our sub ADD ( \x, \y ) is export { x + y } 
constant \ADD2 is export = &ADD;
our sub MUL( \x, \y ) is export { x * y }
constant \MUL2 is export = &MUL;
our sub SUB( \x, \y ) is export { x - y }

our sub DUP (\x ) is export { 
    $Stack::uxn.wst.push(x); 
    x
}
our sub POP (\x ) is export { Nil }
our sub NIP (\x,\y ) is export { x }
our sub OVR (\x,\y ) is export { 
    $Stack::uxn.wst.push(y);
    $Stack::uxn.wst.push(x); 
    y
}
our sub ROT (\x,\y,\z) is export {
    $Stack::uxn.wst.push(y); 
    $Stack::uxn.wst.push(x);
    z
}

our sub RET (\x)  is export {
    say 'RET:' ~ $Stack::uxn.wst.raku ~ ';' ~ x;
    $Stack::uxn.wst=();
    $Stack::uxn.isFirst = True;
    return x
}

# our sub RET  is export {
#     my \res = $Stack::uxn.wst[0] ;
#     $Stack::uxn.wst=();
#     return res;
# }