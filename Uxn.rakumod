use v6;
unit module Uxn;

enum StackManipOps is export <POP NIP DUP SWP OVR ROT BRK> ;
# missing: SFT AND ORA EOR EQU NEQ GTH LTH
enum StackCalcOps is export <ADD SUB MUL INC DIV>;
# missing: STH
enum JumpOps is export <JSR JMP JCN RET>;
# missing: LD*, ST*, DEI, DEO

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
    } else {

    if $isFirst {
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
            when INC { @wst.push( calc_INC(@wst.pop)) }
            when ADD { my \e1 = @wst.pop; my \e2 = @wst.pop; @wst.push(calc_ADD(e2 , e1)) } 
            when MUL { my \e1 = @wst.pop; my \e2 = @wst.pop; @wst.push(e2 * e1) }
            when SUB { my \e1 = @wst.pop; my \e2 = @wst.pop; @wst.push(calc_SUB(e2 , e1)) }
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
    } 
    elsif y ~~ Sub {
        my &f = y;
    #     my @args;
        say 'NAME:' ~ &f.name;
        say 'pre elems:' ~ @wst.raku;
        @wst.push(y);
        say 'post elems:' ~ @wst.raku ;
    } else {
        say 'const:' ~ y ~ ' (' ~ x.raku ~')';
        say 'pre ' ~ @wst.raku;
        @wst.push(y);
        say 'post :' ~ @wst.raku ; 
    }
    }
    return @wst[0]

}

sub calc_ADD(\e2,\e1) {
    if (e2 ~~ Int ) and (e1 ~~ Int) {
        e1 + e2
    }
    elsif (e2 ~~ Int ) and (e1 ~~ Array|List) {
        (e1,e2)
    }
    elsif (e1 ~~ Int ) and (e2 ~~ Array|List) {
        (e2,e1)
    } else {
        die "Type error: ",e2.raku,e1.raku;
    }
}

sub calc_SUB(\e2,\e1) {
    if (e2 ~~ Int ) and (e1 ~~ Int) {
        e2 - e1
    }
    elsif (e2 ~~ Int ) and (e1 ~~ Array|List) {
        die "Type error: ",e2.raku,e1.raku;
    }
    elsif (e1 ~~ Int ) and (e2 ~~ Array|List) {
        (e2,-e1)
    } else {
        die "Type error: ",e2.raku,e1.raku;
    }
}

sub calc_INC(\e1) {
    if e1 ~~ Int {
        e1 + 1
    }
    elsif e1 ~~ Array|List {
        (e1,1)
    } else {
        die "Type error: ",e2.raku,e1.raku;
    }
}

sub LDA(\addr) {
    if addr ~~ Array {
        addr[0]
    }
    elsif addr ~~ List {
        my (\array, \idx) = calc_final_offset(addr);
        array[idx]
    }
}

sub STA(\val,\addr) {
    if addr ~~ Array {
        addr[0] = val
    }
    elsif addr ~~ List {
            my (\array, \idx) = calc_final_offset(addr);
            array[idx] = val
    }
}

sub calc_final_offset(addr,offset) {
        if addr.head ~~ Array {
            (addr.head,addr.tail+offset)
        } else {
            calc_final_offset(addr.head,offset+addr.head.tail);
        }
}