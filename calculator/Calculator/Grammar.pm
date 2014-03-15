package Calculator::Grammar;

# Define grammar.
# @author Joel Dalley
# @version 2014/Feb/27

use JBD::Parser::DSL;
use JBD::Core::Exporter ':omni';

sub types() { Signed, Unsigned }
sub num()   { type Unsigned | type Signed }
sub R()     { any map pair(Op, $_), qw(+ - * /) }

my ($Atom, $Expr);
my $atom = parser {$Atom->(@_)};
my $expr = parser {$Expr->(@_)};

$Atom = num | (pair(Op, '(') ^ $expr ^ pair(Op, ')'));
$Expr = $atom ^ star(R ^ $atom);

sub expr() {
    trans $Expr, sub {
        my $tokens = shift;
        my $expr = join ' ', grep defined $_, 
                   map $_->value, @$tokens;
        my $val = eval $expr; die $@ if $@;
        tokens $val, [types];
    }
}

1;
