use v6;

=begin pod
A toy functional programming language based on Japanese

I call it 'haku', so it can be a pun on Haskell + Raku, or it can be the Haku from Spirited Away, or Dr. or any other kanji with that reading. 
=end pod

# variables must start with katakana then katakana, number kanji and 達 

role Characters {
    token reserved_kanji {
        '開' | '閉' | '長' | '頭' | '尻' | '尾' |
        '或' |
        '和' | '差' | '積' | '除' |
        '足' | '引' | '掛' | '割' |
        '後' | '為' | '等' | '若' |
        '本' | 
        '見' | '合' | '割' | '書' | '読'
    }

    token kanji {  
        <:Block('CJK Unified Ideographs') - reserved_kanji >
        }    

    token katakana { 
        <:Block('Katakana')> 
        }

    # I might allow A-Z as well for identifiers
    token romaji {
        <[A..Z]>
    }
    #     > "１".uniprop('Block');
    # Halfwidth and Fullwidth Forms
    # 算用数字
    token sanyousuji {
        '０' | '１' | '２' | '３' | '４' | '５' | '６' | '７' | '８' | '９'
    }

    token hiragana {
        <:Block('Hiragana')>
        # <[あ..を]>
        }    
}

role Numbers {
    token number_kanji { 
        '一' | 'ニ' | '三' | '四' | '五' | '六' | '七' | '八' | '九' | '十' | 
        '百' | '千' | '万' | '億' | 
        '兆' | '京' | '垓' | '𥝱' | '穣' | '溝' | '澗' | '正' | '載' | '極' 
        }
    token zero { '○' | '零' | 'ゼロ' | 'マル'  }
    token minus {'マイナス'}
    token plus {'プラス'}
    token integer { (<number_kanji> | <zero>)+ }
    token signed_integer { (<minus> | <plus>) <integer> }
    token rational { <signed_integer>+ '点' <integer>+ }
    token number { 
        <rational> | <signed_integer> | <integer> 
    }
}


# I think I will use the full stop and semicolon as equivalent for newline.
role Punctuation {

    token full_stop { '。' }
    token comma { '、' }
    token semicolon { '；' }    
    token colon { '：' }
    token interpunct { '・' } # nakaguro
    token punctuation { <full_stop> | <comma> | <semicolon> | <colon> }
    token delim { <full_stop> | <comma> | <semicolon> }

    # ︵	U+FE35	1-1-42 包摂	&#xFE35;
    # &#65077;	始め小括弧、始め丸括弧
    # PRESENTATION FORM FOR VERTICAL LEFT PARENTHESIS
    # ︶	U+FE36	1-1-43 包摂	&#xFE36;
    # &#65078;	終わり小括弧、終わり丸括弧
    # PRESENTATION FORM FOR VERTICAL RIGHT PARENTHESIS

    # Marukakko (丸括弧) 
    token open_maru { '（' }
    token close_maru { '）' }
    # Namikakko (波括弧)
    token open_nami { '｛' }
    token close_nami { '｝' }

    # ﹇	U+FE47	1-1-46 包摂	&#xFE47;
    # &#65095;	始め大括弧、始め角括弧
    # PRESENTATION FORM FOR VERTICAL LEFT SQUARE BRACKET
    # ﹈	U+FE48	1-1-47 包摂	&#xFE48;
    # &#65096;	終わり大括弧、終わり角括弧
    # PRESENTATION FORM FOR VERTICAL RIGHT SQUARE BRACKET

    # Kakukakko (角括弧)
    token open_kaku { '［' }
    token close_kaku { '］' }

#  etc, see https://ja.wikipedia.org/wiki/%E6%8B%AC%E5%BC%A7

    # sumitsukikakko (隅付き括弧)
    token open_sumitsuki { '【　' }
    token close_sumitsuki { '】' }
}

role Particles {

    token ga { 'が' }
    token ha { 'は' }
    token no { 'の' }
    token to_ { 'と' }
    token mo { 'も' }
    token wo { 'を' }
    token de { 'で' }
    token ni { 'に' }
    token kara { 'から' }
    token deha { 'では' }
    token node { 'ので' }
    token noha { 'のは' }

}

role Nouns {
    token sa { 'さ' }
    token noun { <kanji>+ <sa>? }
}

role Verbs {
    token verb_ending {
        'る'| 'す'| 'む'| 'く'| 'ぐ'| 'つ'| 'ぬ'|
        'た'| 'いだ'| 'んだ'|
        'て'| 'いで' | 'んで'
    }
    token noun { <kanji>+ <sa>? }
    token verb { <kanji> <hiragana>+? <verb_ending> }

}

role Identifiers does Numbers does Characters does Verbs does Nouns {
    
    token tachi { '達' }
    
    token variable { <katakana> [ <katakana>  | <number_kanji> ]* <tachi>? }

    token identifier { <variable> | <verb> | <noun> }

}


role Auxiliaries {
    token kudasai { ['下' | 'くだ' ] 'さい' }
    token masu { 'ます' }

    token shite_kudasai { 'して' [ '下' | 'くだ' ] 'さい' }
    token suru { 'する' | '為る' }
    token shimasu { 'します' }
    token sura {
        <suru> | <shimasu> | <shite_kudasai> 
    }
    token desu { 'です' | 'だ'  | 'である' |　'で或る' |　'でございます' }
}

# +: Tasu (足す)
# -: Hiku (ひく or 引く)
# *: Kakeru (掛ける or かける)
# /: Waru (割る or わる)
# product 積　せき
# sum 和 わ
# division　除 じょ
# difference : 差 さ
# number times <x>: <x> <number> 倍 ばい

role Operators does Characters does Punctuation 
{
    token operator_noun { '和' | '差' | '積' | '除' }
    token operator_verb_kanji { '足' | '引' | '掛' | '割' }
    token operator_verb { <operator_verb_kanji> <hiragana>+? }    
    token list_operator { <to_> | <comma>}
    token comp { '後' } # g . f
    token aru { '或' } # the \ operator
    token cons { <interpunct> | <colon> }
}


role Keywords 
does Operators
does Particles
does Auxiliaries
does Verbs 
does Nouns
# I might split these out further
{

    # For Ranges
    token nyoro { '〜' }

    # For Comparisons 

    token hitoshii { '等しい' }
    token yori { 'より' }
    token ooi { '多い' }    
    token sukunai { '少ない' }

    # For Let

    token moshi { 
        [ 'もし' | '若し' ] <mo>?　<ws>?
    }
    token nara { 'なら' }
    token tara { 'たら' }

    token dattara { 'だったら' }
    token moshi_nanira { <dattara> |　<tara> | <nara> }
    
    token kuromaru { '●' }    

    # For IfThenElse

    token kedo { 'けど' | 'けれど' <mo>? }
    token baaiha { '場合は' }
    token soudenai { 'そうでない' }

    # For Maps and Folds

    token nokaku { 'の各' }
    token nominnaga { 'の皆が' }
    token shazou { '写像' <sura> }     
    token tatamu { '畳' <mu_endings> }
    # For Function

    token toha { 'とは' }

    token koto { 'こと' }

    # For Haku

    token hontoha { '本とは' <.ws>? }

    # Built-in verbs

    token mu_endings {
        'む' | 'んで'  <kudasai>? | 'み' <masu>
    }

    token ru_endings {
         'る' | 'て' <kudasai>? | 'り' <masu>
    }

    token ku_endings {
         'く' | 'いて' <kudasai>? | 'き' <masu>
    }

    token tsu_endings {
         'つ' | 'って' <kudasai>? | 'ち' <masu>
    }

    token miseru { '見せ' }

    # Built-in nouns

    # List operations; strings are lists.
    token nagasa { '長さ' }

    token atama { '頭' }
    token shippo  { '尻尾' }
    
    token awaseru { '合わせ' <ru_endings> }
    token waru { '割' <ru_endings> }

    # File operations
    token akeru { '開け' <ru_endings> }
    token shimeru { '閉め' <ru_endings> }
    token kaku { '書' <ku_endings> }
    token yomu { '読' <mu_endings> }


} # End of Keywords

# # Very quickly we'll get into the rabbit hole of operator precedence
grammar Expression does Identifiers does Keywords 
{

    token TOP { <expression> }
    token atomic_expression {  <number> | <identifier> }
    token parens_expression { <.open_maru> <operator_expression> <.close_maru> }
    token kaku_parens_expression { <.open_kaku> [<list_expression> | <range_expression>] <.close_kaku> }
    token verb_operator_expression { <atomic_expression> <ni>　<atomic_expression> <wo> <operator_verb> }
    token verb_operator_expression_infix { <atomic_expression> <operator_verb> <atomic_expression> }
    token noun_operator_expression { <atomic_expression> <to_>　<atomic_expression> <no> <operator_noun> }
    token operator_expression { <noun_operator_expression> | <verb_operator_expression> | <verb_operator_expression_infix> }
    
    
    token list_expression { <atomic_expression> [ <list_operator> <atomic_expression> ]* }
    token cons_list_expression { <variable> [ <cons> <variable> ]+ }
    
    token variable_list { <variable> [ <list_operator> <variable> ]* }
    # I need to distinguish between verb expressions and noun expressions
    # suppose I have x de x to x no seki , then it is shite (kudasai)
    # suppose I have x de x ni x wo kakeru , then it should really be x de x ni x wo kakete (kudasai)
    
    token lambda_expression { <aru> <variable_list> <de> <expression> }
    # token lambda_application { <expression> 'を'　 [ <shite_kudasai> | <te_kudasai> | <sura> ]? }
    token apply_expression {<expression> [ <wo> | <no> ]　[ <identifier> | <lambda_expression> ] [<shite_kudasai>|<sura>]? }
    # token apply {<l3_expression> [ <wo> | <no> ]　 <identifier> }

    token expression {
                     
          <lambda_expression>    
        | <apply_expression>
        | <comparison_expression>
        | <atomic_expression>
        # | <operator_expression> 
        # | <list_expression>
        # | <cons_list_expression>        
    }

    # token l2_expression {
    #     | <apply_expression>
    #     | <l3_expression>
    # }

    # token l3_expression {
    #     <atomic_expression>
    # }

    # token expression {
    #       <non_apply_expression> 
    #     | <apply_expression>
    # }
    token comp_expression {
        <identifier> [<comp> <identifier>]+
    }
    token range_expression {
        <atomic_expression> <nyoro> <atomic_expression>
    }

    token comparison_expression {
        <expression> <ga> <expression> 
        [ <ni> <hitoshii> | <yori> [ <sukunai> | <ooi> ]  ]        
    }    
# }
# grammar Let is Expression does Punctuation  {
    # token TOP { <let_expression> }
    token bind { <variable> <ha> <expression> <desu>? <delim> }
    token bind_tara { <variable> <ga> <expression> <moshi_nanira> <delim>?　<ws>? }
    
    token moshi_let {
        <moshi> <bind_tara>+  <expression>  <delim>?
    }
    token kuromaru_let {
         [ <kuromaru> <bind> ]+ <dewa> <expression> <delim>?
    }

    token let_expression { <kuromaru_let> | <moshi_let> }
# }
# # # if cond then xtrue else xfalse
# # # cond場合はxtrue、そうでない場合はxfalse
# grammar IfThen is Let {
    token ifthen {
        <expression> <baaiha>  [<let_expression> | <expression>] [<desu> [<ga> | <kedo> ]]? <comma>? <ws>?
        <soudenai> <baaiha> <comma>? <ws>?　[<let_expression> | <expression>]
    }
# }
# grammar Maps {
    token map_expression {
        [ <variable> | <list_expression> | <range_expression> ] 
        [ <nokaku> <lambda_expression> 
        |
        <nominnaga>　[ <identifier> | <comp_expression> ] 
        ]
        <wo> <shazou> 
    }
# }
# grammar Folds {
    token fold_expression {
        [ <variable> | <list_expression> | <range_expression> ] 
        <nominnaga>
        [ <operator_noun> | <identifier> | <verb> <no> ] <wo> <expression> <to_> <tatamu> 
    } 

} # End of Expression

grammar Function is Expression does Keywords  does Punctuation { 
    # is Let {
    token TOP { <function> }
    token function {
        [ <verb> | <noun> ] <.toha>
        <variable_list> <.de>　<.ws>? [<let_expression> | <expression>]　<.function_end>
    }

    token function_end {
         <.ws>? <no>? <koto> <desu> <full_stop>
    }
}

grammar Haku is Function {

    token TOP {
        <function>*? | 
        <hon> 
        | <function>*?
    }

    token hon { 
        　<.hontoha> 
          <expression>+?
        <.function_end>                 
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

# my $haku = Haku.parse("本とは
#     四十ニを見せる
#     のことです。");#");#四十ニ"); # 
# say $haku;

# my $f = Function.parse("加えるとはア達とサでア達が零に等しいのことです。"); #の長さ does not work as currently restricted to atomic expressions
# に等しい
#  my $c = Expression.parse("市者",:rule('noun'));
#  say $c;
# # my $f = Expression.parse("ア達がサに等しい",:rule('comparison_expression'));#
# say $f;
# my $f1 = Expression.subparse("ア達の長さがサに等しい");#
# say $f1;
        # 場合は
        # サで、
        # そうでない場合は
        # もし
        # ア・アア達はア達だったら、
        # アア達とサ足すアを加える


# をエッフする。

# my $bind_tara = Let.parse("エッフがアでアにアを掛けたら。",:rule('bind_tara'));
# # でアにアを掛け
# say $bind_tara;
# エクスとワイの積。");#をエッフする
# say $let_moshi;


=begin pod

Comment line: 注 or 註 or even just 言

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
x2s ha 
    xs kara minna 
        x de x nibai desu.
        
Or
x2s ha 
    xs no kaku-x de x nibai desu.

With a named function, e.g. 増える
ニア達はア達から皆んなを増える
x2s ha 
    xs kara minna 
        wo fueru 

から皆
の各

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

res ha acc to xs kara minna  wo 
レスはアックとエクス達から皆んなをヴァーブ

or again

res ha acc to xs no kaku-x de wo 

〇をフィボるのは一です。一をフィボるのは一です。
エンをフィボるのはエンと一の差をフィボてとエンと二の差をフィボてです。
十三をフィボるのを見せて下さい。

Example: Fibonacci

fibo 0 = 1
fibo 1 = 1
fibo n = fibo n-1 + fibo n-2

sum xs = fold (+) 0 xs 
sum toha xs de acc to xs no kaku-x de acc to x wo tasu

fold [ (+) | plus | \x y -> x+y ] 0 xs

xs kara minna wa wo rei to oru 
ア達から皆和を零と折る
atachi kara minna tasuno wo zero to oru

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

Let's try a proper, simple recursion:

f xs acc = 
    if length xs == 0 
        then acc 
        else 
            let
                x:xs' = xs
            in
                f xs' (acc+x)

多い (ooi): many / more than   [10より多い  = more than 10]
少ない (sukunai): few / less than  [5より少ない = less than 5]
等しい (hitoshii): equal   [also イコール]

5足す5
5に５を足す
５と５の私

は10に等しいです

加えるとは
    ア達とサで
        ア達の長さが零に等しい場合は
        サで、
        そうでない場合は
            もし
                ア・アア達はア達だったら、
                アア達とサ足すアを加える
                のことです。




=end pod


