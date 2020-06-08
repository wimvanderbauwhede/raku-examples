sub infix:<↑> ( Int:D \n, Int:D \m  --> Int:D )
    #is equiv(&infix:<**>)
    is equiv(&[**])
    is assoc<right>
    { n ** m }

put "2**2**2**2 = ",      2**2**2**2;
put "2↑2↑2↑2 = ",         2↑2↑2↑2;
put "2↑ (2↑ (2↑2) ) = ",  2↑ (2↑ (2↑2) );
