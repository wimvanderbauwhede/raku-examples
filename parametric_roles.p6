use v6;

role Container[::Contents] {
    method top_up(Contents $substance) {
        say "Yay...more {Contents.perl}!";
    }
}

role Cup[::Contents] does Container[::Contents] {}
role Mug[::Contents] does Container[::Contents] {}

role Coffee { }
role Tea { }

my Cup[Coffee] $espr = Cup[Coffee].new;
my Mug[Tea] $cuppa .= new; # shorter
my Cup of Coffee $capp .= new; # nicer

$espr.top_up(Coffee.new); # OK
$cuppa.top_up(Tea.new); # OK
$cuppa.top_up(Coffee.new); # Type error

