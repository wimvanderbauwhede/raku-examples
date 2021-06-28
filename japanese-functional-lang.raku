use v6;


# A mini Japanese prog lang, I call it 'haku', so it can be a pun on Haskell + Raku, or it can be the Haku from Spirited Away, or Dr. or any other kanji with that reading. 

# variables must start with katakana then katakana, number kanji and 達 

role Characters {
    token kanji {  
        <:Block('CJK Unified Ideographs')>
        }    
    token katakana { 
        <:Block('Katakana')>
        # <[ア..ヲ]> 
        }
    token hiragana {
        <:Block('Hiragana')>
        # <[あ..を]>
        }    
}

role Numbers {
    token number_kanji { '一'|'ニ'|'三'|'四'|'五'|'六'|'七'|'八'|'九'|'十'|'百'|'千'|'万'|'億'|'兆'|'京'|'垓'|'𥝱'|'穣'|'溝'|'澗'|'正'|'載'|'極' }
    token zero { '○' | '零 ' | 'ゼロ' | 'マル'  }
    token minus {'マイナス'}
    token plus {'プラス'}
    token integer { (<number_kanji> | <zero>)+ }
    token signed_integer { (<minus> | <plus>) <integer> }
    token rational { <signed_integer>+ '点' <integer>+ }
    token number { 
        <rational> | <signed_integer> | <integer> 
    }
}

role Identifiers does Numbers does Characters {
    #token katakana { [all katakana chars or better a unicode range] }
    
    #regex katakana { [\c[KATAKANA LETTER SMALL A]..\c[KATAKANA DIGRAPH KOTO] }


    #token number_kanji { '一'|'ニ'|'三'|'四'|'五'|'六'|'七'|'八'|'九'|'十'|'百'|'千'|'万'|'億' }
    token tachi { '達' }
    token variable { <katakana> [ <katakana>  | <number_kanji> ]* <tachi>? }
    # token variable_list { <variable> [ 'と' <variable>　] * } # make this an operator

# }

# grammar Verbs does Characters {
#     token TOP { <verb> }
    token verb_ending {
        'る'|
        'す'|
        'む'|
        'く'|
        'ぐ'|
        'つ'|
        'ぬ'|
        'た'|
        'て'|
        'だ'|
        'で'
    }
    token verb {<kanji> <hiragana>+? <verb_ending> }
    token identifier { <variable> | <verb> }

}

# I think I will use the full stop and semicolon as equivalent for newline.
role Punctuation {

    token full_stop { '。'}
    token comma {'、'}
    token semicolon {'；'}    
    token colon {'：'}
    token interpunct { '・ ' } # nakaguro
    token punctuation {<full_stop> | <comma> | <semicolon> | <colon> }
    token delim {<full_stop> | <comma> | <semicolon> | "\n" }
}

role Auxiliaries {
    token te_kudasai { 'て下さい' | 'てください' }
    token shite_kudasai { 'して下さい' | 'してください' }
    token suru { 'する' }
    token request {
        <suru> | <shite_kudasai> | <shite> | <tekudasai> 
    }
    token desu { 'です' | 'だ'  | 'である' |　'で或る' |　'でございます' }
}

# +: Tasu (足す)
# -: Hiku (ひく or 引く)
# *: Kakeru (掛ける or かける)
# /: Waru (割る or わる)
# product 積　せき
# sum 和
# division　除
# difference : 差 さ

grammar Operators does Characters {

    token operator_noun { '和' | '差' | '積' | '除' }
    token operator_verb_kanji { '足' | '引' | '掛' | '割' }
    token operator_verb { <operator_verb_kanji> <hiragana>+? }    
    token list_operator { 'と' }
}

# Very quickly we'll get into the rabbit hole of operator precedence
grammar Expression is Operators does Identifiers does Numbers does Auxiliaries {

    token TOP { <expression> }
    token verb_operator_expression { <atomic_expression> 'に'　<atomic_expression> 'を' <operator_verb> }
    token noun_operator_expression { <atomic_expression> 'と'　<atomic_expression> 'の' <operator_noun> }
    token operator_expression { <noun_operator_expression> | <verb_operator_expression> }
    token atomic_expression {  <number> | <variable>   }
    token list_expression { <atomic_expression> [ <list_operator> <atomic_expression> ]* }

    token variable_list { <variable> [ <list_operator> <variable> ]* }
    # I need to distinguish between verb expressions and noun expressions
    # suppose I have x de x to x no seki , then it is shite (kudasai)
    # suppose I have x de x ni x wo kakeru , then it should really be x de x ni x wo kakete (kudasai)

    token lambda { '或' <variable_list> 'で' <expression> }
    # token lambda_application { <expression> 'を'　 [ <shite_kudasai> | <te_kudasai> | <suru> ]? }
    token apply { <non_apply_expression> 'を'　[ <variable> | <verb> | <lambda> ] [<shite_kudasai>|<suru>]? }
    token non_apply_expression {
        <lambda>    
        | <operator_expression> 
        | <list_expression>
        | <atomic_expression> 

    }
    token expression {
        <apply> | <non_apply_expression> 
         
    # | <apply>
    # | <lambda_application>
    }

}



grammar Let is Expression does Punctuation  {
    token TOP { <let_expression> }
    token bind { <variable> 'は' <expression> <desu>? <delim> }
    token bind_tara { <variable> 'が' <expression> <moshi_ra> <delim> }
    
    token moshi { 
        'もし' | '若し'
    }
    token nara {
        'なら'
    }
    token tara {
        'たら'
    }

    token dattara {
        'だったら'
    }
    token moshi_ra { <dattara> |<tara> | <nara> }


    
    token kuromaru {  '●' }
    
    token dewa {'では'}        

    token moshi_let {
        <moshi> 'も'? "\n"? <bind_tara>+  <expression>  <delim>
    }
    token kuromaru_let {
         [ <kuromaru> <bind> ]+ <dewa> "\n"? <expression> <delim>
    }

    token let_expression { <kuromaru_let> | <moshi_let> }
}

grammar Function is Let {
    token function {
        <verb> 'のは'
        <variable_list> 'で' [<let_expression> | <expression>]　<desu> '。'
    }
}

grammar Haku is Function {

    token TOP {
        <function>*? | <hon> | <function>*?
    }

    token hon {
        '本では'　"\n"?　<expression>　'のこと'  <desu> <full_stop>
         
        
    }
}
# say "Try parsing 六と七の積";
# my $m = Expression.parse("六と七の積");
# say $m;
# say "Try parsing 六に七を掛ける";
# my $m2 = Expression.parse("六に七を掛ける");
# say $m2;
 
# my $let_kuromaru = Let.parse("●エクスは三です
# ●ワイは四千です
# では
# エクスとワイの積。");
# say $let_kuromaru;
# my $let_moshi = Let.parse("もし
# エクスが三だったら
# ワイが四千だったら
# エッフが或アでアにアを掛けたら
# エクスとワイの積をエッフする。");#
# say $let_moshi;

my $haku = Haku.parse("本では四十ニを見せるのことです。");
say $haku;
# をエッフする。

# my $bind_tara = Let.parse("エッフがアでアにアを掛けたら。",:rule('bind_tara'));
# # でアにアを掛け
# say $bind_tara;
# エクスとワイの積。");#をエッフする
# say $let_moshi;


=begin pod
 = : は…です。
→：が or maybe better で

I might purely for easy of parsing do

\ : 或（ある）but we don't need this if we use で
, : と
““ : 『』
‘’ : 「」
() : （）
[] : ＜＞

if cond then xtrue else xfalse
cond場合はxtrue、そうでない場合はxfalse

function calls:

f x y
x to y wo f shite (kudasai)
エクスとワイを何々して　

or a lambda:

f = \x y → ...

f wa x to y de ...

I could of course implement map as a recursive function but I’d rather have it as a primitive, and the same for fold. I guess I can do:

map f xs

xs no kaku-x de nani-nani shite 
エクス達の各エクスで何々して下さい

Strings and numbers are easy. 

What about lists? I must have some kind of syntax for the start and end of a list.［］is fine I guess

head, tail is of course just that: 頭、尾
length is 丈
For tuples just parens （）

For files we need open, close and some way to iterate over a handle, which I guess we could so with map 
開ける akete
閉める shimete
assuming that the file is a list of strings.

Quickly we might need some way to manipulate strings
割る to split a string 
str wo pattern de warite (kudasai)

str を pattern で 割りて (kudasai)

But I would like it if an assigment would be

chunksはstr を pattern で 割るのです。
( ~no because then I can always use dictionary form for any function.
Basically, ~te form is for functions not returning a result, dict+no is when assigned)

But a string should be a list, so we need some list operations, at least 
head, tail and ++
の頭
の尾
lst1とlst2を合わせて





Lambda

\x -> 2*x
xが expr in x です。
アがア掛ける二です。

Map
x2s = map (\x -> 2*x) xs
ニア達はア達から皆んな或アがア二倍です。
x2s ha xs kara minna x ga x nibai desu.
Or
x2s ha xs no kaku-x de x nibai desu.

With a named function, e.g. 増える
ニア達はア達から皆んなを増える
x2s ha xs kara minna wo fueru 

Conditionals
\x y -> if x<y then x else y

if cond then xtrue else xfalse
cond場合はxtrue、そうでない場合はxfalse

2,3: x,y -> x < y then x else y
二、三はア、カがアはカより少ないの場合はアでそうでない場合はカです。

Print
x を見せて

I would make 下さい optional

Named function definition

アを増えるは　
x wo fueru ha
 a*x*x to b*x to c no wa desu
a とxとxの積と、bとxの積と、cの 和です

+: Tasu (足す)
-: Hiku (ひく or 引く)
*: Kakeru (掛ける or かける)
/: Waru (割る or わる)
product 積　せき
sum 和
difference : 差 さ
A fun one is the equivalent of $s x $n in Perl: we use the counter tsu

xsはx nつです。

Fold

fold function accumulator list 

I could use a word like “combine” or “reduce” I suppose
Or I could try to say it like for map

res ha acc to xs  kara minna  wo 
レスはアックとエクス達から皆んなをヴァーブ

or again

res ha acc to xs no kaku-x de   wo 

〇をフィボるのは一です。一をフィボるのは一です。
エンをフィボるのはエンと一の差をフィボてとエンと二の差をフィボてです。
十三をフィボるのを見せて下さい。

Example: Fibonacci

fibo 0 = 1
fibo 1 = 1
fibo n = fibo n-1 + fibo n-2

sum = fold + 0 
xs no sum ha acc to xs no kaku-ex de acc to x wo tasu


Now what we need to glue it all together is a let expression.


let
X
in
Y

この　Y に X  して

or one I like even if it is not really let ... in:
もし　or 若し
エクスは何々
ワイは何々
なら or ならば
エクスにワイを足て下さい。

or

sono X dewa Y

or maybe a typgraphic list:

●エクスは何々
●ワイは何々
では
エクスとワイの和です
or
エクスにワイを足て

moshi
f ha x de x to x no seki nara
f 6

moshi
f ha x de x ni x wo katetara
f 6





=end pod


