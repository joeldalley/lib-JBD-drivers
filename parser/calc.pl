use lib 'lib';
use Calculator 'calculate';

my $text = shift || '0';
my $res = calculate $text;
print "Calculate `$text`  ==>  $res\n";
