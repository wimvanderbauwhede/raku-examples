use v6;

role BTree[::T] { }
role Node[::T,  $l,  $r] does BTree[T] { 
    has BTree[T] $.l = $l;
    has BTree[T] $.r = $r;
}
role Leaf[::T $v] does BTree[T] { 
    has T $.leaf=$v;
}

sub mkNode ($T,$l,$r) {
    Node[$T,$l,$r].new;
} 

sub mkLeaf ($v) {
    Leaf[$v].new;
} 

my BTree[Int] $t=Node[Int,Leaf[11].new,Node[Int,Leaf[22].new,Leaf[33].new].new].new;
say $t;

my BTree[Int] $t2=mkNode(Int,mkLeaf(11),mkNode(Int,mkLeaf(22),mkLeaf(33)));
say $t2;
