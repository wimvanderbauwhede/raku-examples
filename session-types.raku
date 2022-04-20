use v6;
# Suppose I have a computation like this:

role V0[\v] {
    has Int $.v = v;
}
role V1[\v] {
    has Int $.v = v;
}
role V2[\v] {
    has Int $.v = v;
}

role V34 {
    # has Int $.v = v;
}
role V3[\v] does V34 {
    has Int $.v = v;
}
role V4[\v] does V34 {
    has Int $.v = v;
}

role V5[\v] {
    has Int $.v = v;
}

role Nil {}

sub calc_1(V0 \v_0 --> V1) { 
    V1[v_0.v].new;
}

sub calc_2(V2 \v_2, V1 \v_1 --> V3) { 
    # say 'V3';
    V3[v_2.v*v_1.v].new;
}
sub calc_3(V34 \v_34 --> V5) { 
    say v_34.raku;
    V5[v_34.v].new;
}
sub cond_1(V3 \v_3 --> Bool) { 
    v_3.v == 1;
}
sub cond_2(V5 \v_5 --> Bool) { 
    v_5.v == 1;
}

multi sub send(V1 \v_1) {
    say 'send: '~v_1.v;
}
multi sub send(V5 \v_5) {
    say 'send: '~v_5.v;
}

multi sub recv_V2( --> V2) {
    say 'V2';
    V2[1].new
}
multi sub recv_V4( --> V4) {
    say 'V4';
    V4[1].new
}

sub session(V0 \v_0) {
    my V1 \v_1 = calc_1(v_0);
    send(v_1);
    my V2 \v_2 = recv_V2();
    my V3 \v_3 = calc_2(v_2,v_1);
    say "v_3: "~v_3.v;
    my V34 \v_4 = cond_1(v_3) ?? recv_V4() !! v_3;
    my V5 \v_5 = calc_3(v_4);
    if cond_2(v_5) {
        send(v_5);
    } 
}

session(V0[0].new);
session(V0[1].new);

# If I want a type, one way might be like this:
sub perform(\calc_lst) {
    my @regs;
    my $ct=0;
    my @args;
    for calc_lst -> \calc_tup {
        my (\T, \calc, \arg_idxs) = calc_tup;
        say '';
        # say "T:"~T.raku;
        # say "Regs:"~@regs.raku;
        # say "Arg idxs:"~ arg_idxs;
        @args = arg_idxs.elems>0 ?? map( -> \idx {@regs[idx]},|arg_idxs) !! [];
        # say "Args:"~@args.raku;
        my \res = calc(@args);
        say "Res: "~res.raku;
        # say "Check:" ,(T.raku ~~ res.WHAT.raku);
        say "Type Check: " ,(res.WHAT ~~ T) || (Nil ~~ T);
        @regs[$ct++]=res;
        
        # @args = map( -> \idx {@regs[idx]},@arg_idxs);
    }

}
sub session_T(V0 \v_0) {# -> TypedArray[DC,Send[V1],Revc[V2],DC,Or[Recv[V34],V34],DC,Or[Send[V5],Nil]]) {
    [
        [V0,-> \v {v_0},[]],
        [V1,-> \v {calc_1(v[0])},[0]],
        [Nil,->\v {send(v[0])},[1]],
        [V2,->\v {recv_V2()},[]],
        [V3, ->\v {calc_2(v[0],v[1])},[3,1]],
        [Int,->\v {say "v_3: "~v[0].v},[4]],
        [V34,-> \v { if cond_1(v[0]) { recv_V4() } else { v[0] } },[4]],
        [V5,->\v{calc_3(v[0])},[6]],
        [Nil,->\v { if cond_2(v[0]) { send(v[0]) } },[7]]
    ];
}

say '';
say "Typed session";
my \calc = session_T(V0[1].new);
perform(calc);

# say 'ADT:' ,(V3[Int] ~~ V34); # this gives True
# say 'ADT:' ,(V2[Int] ~~ V2); # this gives True