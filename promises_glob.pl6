use v6;
use IO::Glob;

my IO::Path @file_names=glob("*.pl6").dir();

sub parse_file (IO::Path $file_name) {
   return $file_name.IO.lines;
}

my Promise @threads = map sub ($file_name) { Promise.start( { parse_file($file_name) }) }, @file_names;
my @results = await @threads;
say @results;

my @promises = map { Promise.new  }, @file_names;
map sub ([$fn,$p]) { $p.keep( parse_file($fn) ) }, zip (@file_names, @promises);
my @results2 = @promises».result;
say @results2;
