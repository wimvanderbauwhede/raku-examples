use v6;
unit module Uxn;
enum StackManipOps is export <POP NIP DUP SWP OVR ROT POP2 NIP2 DUP2 SWP2 OVR2 ROT2 BRK> ;
# missing: SFT AND ORA EOR EQU NEQ GTH LTH
enum StackCalcOps is export <ADD SUB MUL INC DIV ADD2 SUB2 MUL2 INC2 DIV2>;
# missing: STH
enum JumpOps is export <JSR JSR2 JMP JMP2 JCN JCN2 RET>;
# missing: DEI
enum MemOps is export <LDA STA LDR STR LDZ STZ DEO LDA2 STA2 LDR2 STR2 LDZ2 STZ2 DEO2>;

our sub infix:<∘>(\xx, \yy)  is export {
    state $prevCaller = 'None';
    state @wst = ();
    state @rst = ();
    my @args = yy;

    state Bool $isFirst = True;
    state $skipInstrs = False;
    if $skipInstrs {
        if yy ~~ JMP {
            $skipInstrs=False
        } elsif yy ~~ RET {
            $skipInstrs=False
        }
    } else {

        if $isFirst {
            # @wst.push(x);
            $isFirst = False;
            # Nil ∘ x; # dear attentive reader, this is buggy so I replaced it with the for loop approach
            @args = xx,yy;
        }
        for @args -> \y {
            given y {
                when StackManipOps {
                    given y {
                        when POP|POP2 { @wst.pop }
                        when NIP { my \e1 = @wst.pop; @wst.pop; @wst.push(e1) }
                        when DUP|DUP2 { my \e1 = @wst[*-1]; @wst.push(e1) }
                        when SWP { my \e1 = @wst.pop; my \e2 = @wst.pop; @wst.push(e1); @wst.push(e2)}
                        when OVR {  my \e2 = @wst[*-2]; @wst.push(e2)}
                        when ROT {
                            my \e1 = @wst.pop; my \e2 = @wst.pop; my \e3 = @wst.pop;
                            @wst.push(e2); @wst.push(e1); @wst.push(e3)
                        }
                        when BRK {
                            my \res = @wst.pop;
                            @wst=();
                            $isFirst = True;
                            return res;
                        }
                    }
                }
                when StackCalcOps {

                    given y {
                        when INC|INC2 { my \e1 = @wst.pop;@wst.push( calc_INC(e1)) }
                        when ADD { my \e1 = @wst.pop; my \e2 = @wst.pop; @wst.push(calc_ADD(e2 , e1)) }
                        when MUL { my \e1 = @wst.pop; my \e2 = @wst.pop; @wst.push(e2 * e1) }
                        when SUB { my \e1 = @wst.pop; my \e2 = @wst.pop; @wst.push(calc_SUB(e2 , e1)) }
                        when DIV { my \e1 = @wst.pop; my \e2 = @wst.pop; @wst.push(e2 / e1) }
                    }
                }
                when JumpOps {
                    given y {
                        when JSR|JSR2 {
                            $isFirst = True;
                            my &f =  @wst.pop;
                            f();
                        }
                        when JCN|JCN2 {
                            my &f =  @wst.pop;
                            my $cond = @wst.pop;
                            if (not ($cond ~~ Int)) or $cond>0 {
                                $isFirst = True;
                                f();
                                $skipInstrs = True;
                            }
                        }
                        when JMP {
                            $isFirst = True;
                            my &f =  @wst.pop;
                            f();
                        }
                        when RET { }
                    }
                }
                when MemOps {
                    given y {
                        when LDA|LDR|LDZ { my \e1 = @wst.pop; @wst.push(calc_LDA(e1)) }
                        when STA|STR|STZ { my \e1 = @wst.pop; my \e2 = @wst.pop; calc_STA(e2,e1) }
                        when DEO {my \e1 = @wst.pop; my \e2 = @wst.pop;  calc_DEO(e2,e1) }
                    }
                }
                when Sub {
                    my &f = y;
                    @wst.push(y);
                }
                default {
                    @wst.push(y);
                }
            }
        } # for
    }
   if @wst {return @wst[*-1]}

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
        my List \res = (e1,1); res
    } else {
        die "Type error: ",e1.raku;
    }
}

sub calc_LDA(\addr) {
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
        res
    } else {
        calc_final_offset(addr.head,offset+addr.head.tail);
    }
}

sub calc_DEO(\arg,\port) {
    if port != 0x18 {
        die "Only port 0x18 is supported.\n"
    }
    given arg {
        when Str { print arg }
        when Int { print arg.chr }
        when List|Array { print calc_LDA(arg) }
    }
}