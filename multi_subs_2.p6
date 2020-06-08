use v6;

multi sub fact (0) { 1 }
multi sub fact (\n) { n*fact(n-1) }

say fact 5 # 120
