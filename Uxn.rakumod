use v6;
unit module Uxn;


enum StackManipOps is export <POP NIP DUP SWP OVR ROT BRK POP2 DUP2> ;
# missing: SFT AND ORA EOR EQU NEQ GTH LTH
enum StackCalcOps is export <ADD SUB MUL INC DIV INC2>;
# missing: STH
enum JumpOps is export <JSR JSR2 JMP JCN JCN2 RET>;
# missing: LD*, ST*, DEI, DEO
enum MemOps is export <LDA STA LDR STR LDZ STZ DEO>;

our sub infix:<∘>(\xx, \yy)  is export {
    state $prevCaller = 'None';
    state @wst = ();
    state @rst = ();
    my @args = yy;

    # state @stash = ();
    state Bool $isFirst = True;
    state $skipInstrs = False;
    say "CALL: ",yy.raku,'; @wst:',@wst.raku;
    if $skipInstrs {
        if yy ~~ JMP {
            $skipInstrs=False
        } elsif yy ~~ RET {
            $skipInstrs=False
        }
    } else {

    if $isFirst {
        # say "FIRST!";
        # say 'first elt:' ~ x.raku ;
        # say 'wst:' ~ @wst.raku;
        # @wst.push(x);
        # say 'wst post :' ~ @wst.raku ; 
        $isFirst = False;
        # @stash=@wst;
        # $useStash=True;
        # Nil ∘ x;
        @args = xx,yy;
    }
    for @args -> \y {
    if y ~~ StackManipOps {
        # say 'manip '~y~' pre:' ~ @wst.raku;
        given y {
            when POP|POP2 { @wst.pop }
            when NIP { my \e1 = @wst.pop; @wst.pop; @wst.push(e1) }
            when DUP|DUP2 { my \e1 = @wst[*-1]; @wst.push(e1) }
            # when DUP { say 'DUP';my \e1 = @wst[*-1]; @wst.push(e1) }
            when SWP { my \e1 = @wst.pop; my \e2 = @wst.pop; @wst.push(e1); @wst.push(e2)}
            when OVR {  my \e2 = @wst[*-2]; @wst.push(e2)}
            when ROT {
                my \e1 = @wst.pop; my \e2 = @wst.pop; my \e3 = @wst.pop; 
                @wst.push(e2); @wst.push(e1); @wst.push(e3)
            }
            when BRK {
                # say 'BRK!';
                my \res = @wst.pop;
                @wst=();
                $isFirst = True;
                return res;
            }
        }
        # say 'manip '~y~' post:' ~ @wst.raku;
    } elsif y ~~ StackCalcOps {
        # say 'calc '~y~' pre:' ~ @wst.raku;

        given y {
            when INC|INC2 { my \e1 = @wst.pop;@wst.push( calc_INC(e1)) }
            when ADD { my \e1 = @wst.pop; my \e2 = @wst.pop; @wst.push(calc_ADD(e2 , e1)) } 
            when MUL { my \e1 = @wst.pop; my \e2 = @wst.pop; @wst.push(e2 * e1) }
            when SUB { my \e1 = @wst.pop; my \e2 = @wst.pop; @wst.push(calc_SUB(e2 , e1)) }
            when DIV { my \e1 = @wst.pop; my \e2 = @wst.pop; @wst.push(e2 / e1) }
        }
        # say 'calc '~y~' post:' ~ @wst.raku;
    } elsif y ~~ JumpOps {
        # say 'jmp '~y~' pre:' ~ @wst.raku;
        given y {
            when JSR|JSR2 {
                $isFirst = True;
                my &f =  @wst.pop;
                # say &f.name;
                # say 'jmp '~y~' pop:' ~ @wst.raku;
                f();
            }
            when JCN|JCN2 {
                my &f =  @wst.pop;
                my $cond = @wst.pop;
                # say 'JCN:',&f.name,':',$cond;
                if $cond ~~ Int and $cond>0 {
                    # say 'jmp '~y~' pop:' ~ @wst.raku;
                    $isFirst = True;
                    f();
                    # say 'jmp '~y~' after call:' ~ @wst.raku;
                    $skipInstrs = True;
                }
            }
            when JMP { 
                $isFirst = True;
                my &f =  @wst.pop;
                # say &f.name;
                # say 'jmp '~y~' pop:' ~ @wst.raku;
                f();
            }
            when RET { 
                # say y 
                }
        }
        #  say 'jmp '~y~' post:' ~ @wst.raku;
    } 
    elsif y ~~ MemOps {
        given y {
            when LDA|LDR|LDZ { my \e1 = @wst.pop; @wst.push(calc_LDA(e1)) }
            when STA|STR|STZ { my \e1 = @wst.pop; my \e2 = @wst.pop; calc_STA(e2,e1) }
            when DEO {my \e1 = @wst.pop; my \e2 = @wst.pop;  calc_DEO(e2,e1) }
        }
    }
    elsif y ~~ Sub {
        my &f = y;
    #     my @args;
        # say 'NAME:' ~ &f.name;
        # say 'pre elems:' ~ @wst.raku;
        @wst.push(y);
        # say 'post elems:' ~ @wst.raku ;
    } else {
        # say 'ARG:' ~ y.raku ~ ' (' ~ x.raku ~')';
        # say 'pre ' ~ @wst.raku;
        @wst.push(y);
        # say 'post :' ~ @wst.raku ; 
    }
    }
    }
    # say 'wst FIN :' ~ @wst.raku ; 
    return @wst[*-1]

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
        die "Type error: ",e2.raku,"  +  ",e1.raku;
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
        # say 'INC ARRAY';
        my List \res = (e1,1); res
    } else {
        die "Type error: ",e1.raku;
    }
}

sub calc_LDA(\addr) {
    say "LDA: ",addr.raku;
    if addr ~~ Array {
        addr[0]
    }
    elsif addr ~~ List {
        my (\array, \idx) = calc_final_offset(addr,0);
        array[idx]
    }
}

sub calc_STA(\val,\addr) {
    if addr ~~ Array {
        addr[0] = val
    }
    elsif addr ~~ List {
        my (\array, \idx) = calc_final_offset(addr,0);
        array[idx] = val
    }
}

sub calc_final_offset(List \addr,Int \offset --> List) {
    
        if addr.head ~~ Array {
            my List \res = (addr.head,addr.tail+offset);
            # say "calc_final_offset:",res;
            res
        } else {
            calc_final_offset(addr.head,offset+addr.head.tail);
        }
}

sub calc_DEO(\arg,\port) {
    say 'DEO:',arg.raku,':',port.raku;
    if port != 0x18 {
        die "Only port 0x18 is supported.\n"
    }
    given arg {
        when Str { print arg }
        when Int { print arg.chr }
        when List|Array { print calc_LDA(arg) }
    }
}