use JBD::Parser::DSL;
use Data::Dumper; 

use lib 'lib';
use Report 'value_str';

my ($text, $cat, $any, $tok);

$text = 'Abc';
$any = mapany Word, 'abc', Word, 'ABC', Word, 'Abc';
($tok) = $any->(input $text, [Word]);
print value_str($tok, $text), "\n";

$text = '1 2';
$cat = mapcat Int, 1, Int, 2;
($tok) = $cat->(input $text, [Int]);
print value_str($tok, $text), "\n";

$text = '5 . -3. 9.9';
$cat = mapcat Int, 5, Dot, '.', Float, '-3.', Float, '9.9';
($tok) = $cat->(input $text, [Float, Int, Dot]);
print value_str($tok, $text), "\n";
