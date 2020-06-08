use v6;

my Int \t = 4; 
my List \v = [5..*]; 

say t*v[2];
say v.head(t);

class Test { method test() {say 'OK'}}
my Test \c = Test.new;
c.test;
 
sub f(\v) { say v }
f('OK');
