use v6;
unit module Stack;
use Uxn;

$Stack::uxn = Uxn.new;

constant \_ is export = Nil ;
constant \ￌ is export = Nil;
our sub term:<⟂>(--> Nil) is export { };

enum StackManipOps is export <POP NIP DUP SWP OVR ROT BRK> ;
enum StackCalcOps is export <ADD SUB MUL INC DIV>;
enum JumpOps is export <JSR JMP JCN RET>;

our sub infix:<∘>(\x, \y)  is export {
    state $prevCaller = 'None';
    state @wst = ();
    state @rst = ();
    state Bool $isFirst = True;
    state $skipInstrs = False;
    say "skipInstrs: $skipInstrs ",y.raku;
    if $skipInstrs {
        if y ~~ JMP {
            $skipInstrs=False
        } elsif y ~~ RET {
            $skipInstrs=False
        }
        # else {
            # @wst.pop;
            # return
        # }
    } else {
    # my $frame   = callframe(1   ); # OR just callframe() 
    # my $caller;
    # if $frame.code ~~ Routine {
    #     $caller = $frame.code.name;
    # }
    # say "CALLER: $prevCaller <> $caller";
    # if $prevCaller ne $caller {
    #     $prevCaller=$caller;
    #     $isFirst = False; # needed?
    #     Nil ∘ x;
    # }

    if $isFirst and not (x ~~ Nil) { #and @wst.elems == 0
        say 'first elt:' ~ x.raku ;
        say 'wst:' ~ @wst.raku;
        @wst.push(x);
        # say 'post elems:' ~ @wst.raku ; 
        $isFirst = False;
        Nil ∘ x
    }

    if y ~~ StackManipOps {
        say 'manip '~y~' pre:' ~ @wst.raku;
        given y {
            when POP { @wst.pop }
            when NIP { my \e1 = @wst.pop; @wst.pop; @wst.push(e1) }
            when DUP { my \e1 = @wst[*-1]; @wst.push(e1) }
            when SWP { my \e1 = @wst.pop; my \e2 = @wst.pop; @wst.push(e1); @wst.push(e2)}
            when OVR {  my \e2 = @wst[*-2]; @wst.push(e2)}
            when ROT {
                my \e1 = @wst.pop; 
                my \e2 = @wst.pop; 
                my \e3 = @wst.pop; 
                @wst.push(e2); 
                @wst.push(e1);
                @wst.push(e3)
            }
            when BRK {
                my \res = @wst.pop;
                @wst=();
                $isFirst = True;
                return res;
            }
        }
        say 'manip '~y~' post:' ~ @wst.raku;
    } elsif y ~~ StackCalcOps {
        say 'calc '~y~' pre:' ~ @wst.raku;

        given y {
            when INC { @wst.push(@wst.pop + 1) }
            when ADD { my \e1 = @wst.pop; my \e2 = @wst.pop; @wst.push(e2 + e1) } 
            when MUL { my \e1 = @wst.pop; my \e2 = @wst.pop; @wst.push(e2 * e1) }
            when SUB { my \e1 = @wst.pop; my \e2 = @wst.pop; @wst.push(e2 - e1) }
            when DIV { my \e1 = @wst.pop; my \e2 = @wst.pop; @wst.push(e2 / e1) }
        }
        say 'calc '~y~' post:' ~ @wst.raku;
    } elsif y ~~ JumpOps {
        say 'jmp '~y~' pre:' ~ @wst.raku;
        given y {
            when JSR {
                $isFirst = True;
                my &f =  @wst.pop;
                say &f.name;
                say 'jmp '~y~' pop:' ~ @wst.raku;
                f();
            }
            when JCN {
                my &f =  @wst.pop;
                my $cond = @wst.pop;
                say 'JCN:',&f.name,':',$cond;
                if $cond>0 {
                    say 'jmp '~y~' pop:' ~ @wst.raku;
                    $isFirst = True;
                    f();
                    say 'jmp '~y~' after call:' ~ @wst.raku;
                    $skipInstrs = True;
                }
            }
            when JMP { 
                $isFirst = True;
                my &f =  @wst.pop;
                say &f.name;
                say 'jmp '~y~' pop:' ~ @wst.raku;
                f();
            }
            when RET { say y }
        }
         say 'jmp '~y~' post:' ~ @wst.raku;
    } elsif y ~~ Sub {
        my &f = y;
    #     my @args;
        say 'NAME:' ~ &f.name;
        say 'pre elems:' ~ @wst.raku;
        @wst.push(y);
        say 'post elems:' ~ @wst.raku ;         
    #     # my Bool $isRet =  (&f.name eq 'RET');
    #     my Bool $isOp = False; # TODO stackCalcOps{&f.name};# ~~  StackCalcOps;# / ^ <:Lu>+ /;
    #     say $isOp;
    #     my $st = ($isOp and &f.name.substr(*-1) eq 'r' ) ?? @rst !! @wst;
    #     say &f.raku;
    #     say 'ar:' ~ &f.signature.arity;
    #     say &f.name ~' pre:' ~ $st.raku;
    #     map {@args.push($st.pop)}, 1 .. &f.signature.arity;
    #     say 'ARGS:' ~ @args.raku;
    #     # my \res = f(|@args) ;
    #     f();
    #     # say &f.name ~' stack:' ~ $st.raku ~ ';' ~ res;
    #     # if $isOp and not (res ~~ Nil) {
    #     #     $st.push(res);
    #     # }
    #     say &f.name ~' post:' ~ $st.raku;
    } else {
        say 'const:' ~ y ~ ' (' ~ x.raku ~')';
        say 'pre ' ~ @wst.raku;
        @wst.push(y);
        say 'post :' ~ @wst.raku ; 
    }
    }
    return @wst[0]

}

our sub infix:<¬∘>(\x, \y) is export {
    if $Stack::uxn.isFirst and $Stack::uxn.wst.elems == 0 {
        say 'first const:' ~ x ;
        say 'pre :' ~ $Stack::uxn.wst.raku;
        $Stack::uxn.wst.push(x);
        say 'post :' ~ $Stack::uxn.wst.raku ; 
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


# our sub _INC ( \x ) is export  { x + 1 }
# our sub _ADD ( \x, \y ) is export { x + y } 
# our sub _MUL( \x, \y ) is export { x * y }
# our sub _SUB( \x, \y ) is export { x - y }
# our sub _DIV( \x, \y ) is export { x / y }
# constant \INC is export = &_INC;
# constant \ADD is export = &_ADD;
# constant \MUL is export = &_MUL;
# constant \SUB is export = &_SUB;
# constant \DIV is export = &_DIV;

