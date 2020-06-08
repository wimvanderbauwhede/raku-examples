use v6;

my $p = Promise.start({ sleep 10; 42});
$p.then({ say .result });   # will print 42 once the block finished
say $p.status;              # Planned
$p.result;                  # waits for the computation to finish
say $p.status;              # Kept
