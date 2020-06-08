use v6;
#use IO::Glob;
#my @file_names=glob("*.p6").dir();
my Str @file_names= <but.p6
currying.p6
laziness.p6
maybe.p6
multi_subs.p6
multi_subs_2.p6
parametric_roles.p6
promises.p6
reductions.p6
rf4a_snippets.p6
seq_list_array.p6
sigils.p6
snippets.p6
strict.p6
subset.p6
test_inheritance_roles.p6
type_capture.p6>;

sub parse_file (Str $file_name ) {
   return $file_name.IO.lines;
}

my Promise @threads = map sub ($file_name) {Promise.start( { parse_file($file_name) })}, @file_names;

my @results = await @threads;

say @results.perl

