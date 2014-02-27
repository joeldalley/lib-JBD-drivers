use JBD::Parser::DSL;

use JBD::Core::List 'zip';
use lib 'lib';
use Report 'report';

my @inputs = (
    input('2.',   [Float]),
    input('1',    [Int]),
    input('sub',  [Word]),
    input('22/7', [Int, Op]),
    input('3.14', [Int, Dot]),
    );


my @parsers = (
   is(Float),
   is(Int),                                     
   mapcat(zip map(Word, qw(s u b)), qw(s u b)),
   cat(star(is Int), is(Op, '/'), star(is Int)), 
   cat(star(is Int), is(Dot), star(is Int)), 
   );

while (@inputs) {
    my $in = shift @inputs;
    my $p = shift @parsers;
    while ($in->num_left) {
        my ($tok) = cat($p, is End_of_Input)->($in);
        last unless report $tok;
    }
}
