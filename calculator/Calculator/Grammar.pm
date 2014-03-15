package Calculator::Grammar;

# Define grammar.
# @author Joel Dalley
# @version 2014/Feb/27

use JBD::Parser::DSL;
use JBD::Core::Exporter ':omni';

sub types() { Signed, Unsigned }
sub num()   { type Unsigned | type Signed }
sub R()     { any map pair(Op, $_), qw(+ - * /) }

my ($a0, $e0);
my $a1 = parser {$a0->(@_)};
my $e1 = parser {$e0->(@_)};

$a0 = num | (pair(Op, '(') ^ $e1 ^ pair(Op, ')'));
$e0 = $a1 ^ star(R ^ $a1);

sub expr() {
    trans $e0, sub {
        my $tokens = shift;
        my $expr = join ' ', grep $_, map $_->value, @$tokens;
        my $val = eval $expr; die $@ if $@;
        tokens $val, [types];
    }
}

1;
