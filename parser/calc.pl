use JBD::Core::stern;

use lib 'lib';
use Calculator 'calculate';
use Report 'report';

my $text = shift || '1';
report calculate $text;
