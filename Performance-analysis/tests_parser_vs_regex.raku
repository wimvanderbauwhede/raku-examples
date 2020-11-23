use v6;

constant VER=@*ARGS[0];
constant NITERS = 100_000;


for 1 .. NITERS -> $ct {
# my \chrs_=chrs__.cache;
    my @words=();
   
if VER==0 {
    my $str1='an_array_name_42 ( idx ) = v';

    my $var='';
    if ( $str1 ~~ /^ $<v> = [ <alpha>+\w* ] \s*\(/ ) {
        $var=$<v>.Str;
        $str1 .= substr($var.chars);             
    }
    my $str2='an_array_name_42 = v( idx ) - v';
    if ( $str2 ~~ /^ $<v> = [ <alpha>+\w* ] \s*\(/ ) {
        $var=$<v>.Str;
        $str2 .= substr($var.chars);             
    }
    # say "<$var><$str>"; exit;
} elsif VER==1 {
    # die;
    my $str1='an_array_name_42 ( idx ) = v';
    my $var='';
    if my $idx1 = $str1.index('(') {
        my $before = $str1.substr(0,$idx1);
        $before.=trim-trailing;
        # Now I need to make sure that it has only alphanum
        # and that is not good enough, I need to check that the first char is not a num or _
        # if not grep {
        #     '*' le $_ le '/' 
        #     # or ':' le $_ le '@' 
        #     # or '[' le $_ le '^' 
        #     # or '{' le $_ le '~' 
        #     }, |$before.comb 
        #     and $before.substr(0,1) gt '9'
        #     {
        #         $var = $before;
        #         $str1 .=substr($idx1);
        #     }

        # alternatively, we can iterate through the string:
        my $is_var=True;
        for 0 .. $before.chars-1 -> $idx {
            my $c = $before.substr($idx,1);            
            if '*' le $c le '/' {
                $is_var=False;
                last;
            }            
        }
        if $is_var {
                $var = $before;
                $str1 .=substr($idx1);
        }
    }
    my $str2='an_array_name_42 = v( idx ) - v';
    if my $idx2 = $str2.index('(') {
        my $before = $str2.substr(0,$idx2);
        $before.=trim-trailing;
        # Now I need to make sure that it has only alphanum
        # and that is not good enough, I need to check that the first char is not a num or _
        if not grep {
            '*' le $_ le '/' 
            # or ':' le $_ le '@' 
            # or '[' le $_ le '^' 
            # or '{' le $_ le '~' 
            }, |$before.comb 
            and $before.substr(0,1) gt '9'
            {
                $var = $before;
                $str2 .=substr($idx2);
            }
    }
    # say "<$var><$str>"; exit;
# }

# > map {chr($_)}, (48..57,65..90,95,97..122).flat
# (0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z _ a b c d e f g h i j k l m n o p q r s t u v w x y z)
# { | } ~
# > 
# : ; < = > ? @

# 58 .. 64
# 91 .. 94 
# 96
# 123 .. 127
# (
    # * + , - . /
#  0 1 2 3 4 5 6 7 8 9 : ; < = > ? @ A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 
# [ \ ] ^
#  _ ` a b c d e f g h i j k l m n o p q r s t u v w x y z)
# it can really only  be * + - / . , '*' .. '/', ':' .. '?', 
} elsif VER==2 {
    my $str = '__PH7188____PH42____something else ';
        if $str~~s/^((__PH\d+__)+)// {
            #variable
            my @expr_ast=[33,$/.Str];
            #$expr_ast=['$',$1];
            # Now it is )possible that there are several of these in a row!
            # say @expr_ast;exit;
        }
    
        if $str~~s/^((__PH\d+__)+)// {
            #variable
            my @expr_ast=[33,$/.Str];
            #$expr_ast=['$',$1];
            # Now it is )possible that there are several of these in a row!
            # say @expr_ast;exit;
        }        
} elsif VER==3 {
    my $str = '__PH7188____PH42____something else';
    
    while $str.starts-with('__PH') {
        # now find the number
        my $ns = $str.index('H')+1;
        # from there
        my $ne = $str.index('__',$ns);
        # get the substr, we know it is a number
        my $nn = $ne-$ns;
        my $n = $str.substr($ns,$nn);
        my @expr_ast=[33,'__PH_'~$n~'__']; 
        $str.=substr($nn+6);
        # say @expr_ast;
    }
     while $str.starts-with('__PH') {
        # now find the number
        my $ns = $str.index('H')+1;
        # from there
        my $ne = $str.index('__',$ns);
        # get the substr, we know it is a number
        my $nn = $ne-$ns;
        my $n = $str.substr($ns,$nn);
        my @expr_ast=[33,'__PH_'~$n~'__']; 
        $str.=substr($nn+6);
        # say @expr_ast;
    }

}
elsif VER==4 { # 9s
    my @strs = '(  / 42 , 43 , 44 /)' , '[ 55, 7188 ]', 'no match';    
    for @strs -> $str_ {
        my $str=$str_;
        if ($str~~s/^\(\s*\/// or $str~~s/^\[//) {
            my @expr_ast= [28,$str]; # fake
        }
    }
}
elsif VER==5 { # 2s
    my @strs = '(  / 42 , 43 , 44 /)' , '[ 55, 7188 ]', 'no match';    
    for @strs -> $str_ {
        my $str=$str_;
        if $str.starts-with('[') {
            my @expr_ast= [28,$str]; # fake
            $str .=substr(1,0)
        } elsif $str.starts-with('(') {
            $str .=substr(1,0);
            my $str2 = $str.trim-leading;
            if $str2.starts-with('/') {
                $str2 .=substr(1,0);
                $str=$str2;
                my @expr_ast= [28,$str]; # fake
            } 
            # else {
            #     # restore the string
            # }
        }
    }    
}
elsif VER==6 { # 7.6s
    my @strs = '.true.' , '.false', 'no match';    
    for @strs -> $str_ {
        my $str=$str_;

        if ( $str~~s/^\.(true|false)\.// ) {
            # boolean constants
            my @expr_ast=[31,'.'~$/.Str~'.'];
            #$expr_ast='.'.$1.'.';
        }
    }
}
elsif VER==7 { # 1.8 s
    my @strs = '.true.' , '.false', 'no match';    
    for @strs -> $str_ {
        my $str=$str_;
            # boolean constants
        if $str.starts-with( '.true.' ) {
            my @expr_ast=[31, '.true.'];
        }
        elsif $str.starts-with(  '.false.' ) {
            my @expr_ast=[31, '.false.'];
        }
    }
}



}