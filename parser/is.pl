use JBD::Parser::DSL;

use lib 'lib';
use Report 'report';

my $opts = {tail => [token End_of_Input]}; 

my @inputs = (
    input('2.',    [Float],    $opts),
    input('-1',    [Int],      $opts),
    input('sub',   [Word],     $opts),
    input('22/-7', [Int, Op],  $opts),
    input('3.14',  [Int, Dot], $opts),
    );

my @parsers = (
   type Float,
   type Int,                                     
   pair(Word, 'sub'),
   (star type Int ^ pair(Op, '/') ^ star type Int), 
   (star type Int ^ type Dot ^ star type Int), 
   );

print scalar type Float, "\n";

while (@inputs) {
    my $in = shift @inputs;
    my $p = shift @parsers;
    while ($in->num_left) {
        my $cat = $p ^ type End_of_Input;
        my ($tok) = $cat->($in);
        last unless report $tok;
    }
}
