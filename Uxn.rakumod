use v6;

class Uxn {
    has @.wst;
    has $!r1; 
    has $!r2; 
    has $!ct=0;
    has @!cst;

    method run() {
        if @!wst {
            my $elt = @!wst.pop;
            if @!wst.elems ==0 and @!cst.elems==0 {
                return $elt;
            }
            say "ELT: "~$elt.raku;
            if $elt ~~ Int { 
                $!ct++;
                if $!ct==1 {
                    $!r1=$elt;
                    # say @!cst[*-1].gist;
                    if @!cst and @!cst[*-1].gist ~~ '&INC' {
                        say "UNARY";
                        $!ct=0;
                        my $opc = @!cst.pop();
                        @!wst.push($opc($!r1))
                    }
                } elsif $!ct==2 {
                    $!r2=$elt;
                    say 'BINARY';
                    $!ct=0;
                    my $opc = @!cst.pop();
                    @!wst.push($opc($!r2,$!r1))
                } else {
                    die "Can only be 1 or 2: $!ct";
                }
            } else {
                    say "STASH";
                    @!cst.push( $elt);
                    say @!wst.raku;
                    say @!cst.raku;
            }
            self.run()
        }
    }
}
