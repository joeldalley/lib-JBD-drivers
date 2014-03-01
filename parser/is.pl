use JBD::Parser::DSL;

use lib 'lib';
use Report 'report';

my $opts = {tail => [JBD::Parser::Token->end_of_input]};

my @inputs = (
    input('2.',    [Float],    $opts),
    input('-1',    [Int],      $opts),
    input('sub',   [Word],     $opts),
    input('22/-7', [Int, Op],  $opts),
    input('3.14',  [Int, Dot], $opts),
    );

my @parsers = (
   is(Float),
   is(Int),                                     
   is(Word, 'sub'),
   (star(is Int) & is(Op, '/') & star is Int), 
   (star(is Int) & is(Dot) & star is Int), 
   );

while (@inputs) {
    my $in = shift @inputs;
    my $p = shift @parsers;
    while ($in->num_left) {
        my ($tok) = cat($p, is End_of_Input)->($in);
        last unless report $tok;
    }
}
