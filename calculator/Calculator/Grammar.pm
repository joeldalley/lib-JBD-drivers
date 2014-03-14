package Calculator::Grammar;

# Define grammar.
# @author Joel Dalley
# @version 2014/Feb/27

use JBD::Parser::DSL;
use JBD::Core::Exporter ':omni';

sub op($)     { pair Op, shift }
sub types()   { Signed, Unsigned }
sub operand() { any map type $_, types }

my $atom = operand;
my $term  = $atom ^ star((op '+' | op '*') ^ $atom);

my $expr = trans $term, sub {
    my $tokens = shift;
    my $expr = join ' ', grep $_, map $_->value, @$tokens;
    my $val = eval $expr; die $@ if $@;
    tokens $val, [types];
};

sub expr() { $expr ^ type End_of_Input }

1;
