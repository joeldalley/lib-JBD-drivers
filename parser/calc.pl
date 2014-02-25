use JBD::Core::stern;

use lib 'lib';
use Calculator 'calculate';
use Report 'report';

my $text = @ARGV ? shift : '4 * (2+1) * 2';

my ($tok) = calculate $text;
report $tok;
