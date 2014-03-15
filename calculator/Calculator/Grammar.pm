package Calculator::Grammar;

# Define grammar.
# @author Joel Dalley
# @version 2014/Feb/27

use JBD::Parser::DSL;
use JBD::Core::Exporter ':omni';

my ($Atom, $Expr);
my $atom = parser {$Atom->(@_)};
my $expr = parser {$Expr->(@_)};

sub types()    { Signed, Unsigned }
sub num()      { type Unsigned | type Signed }
sub combine()  { any map pair(Op, $_), qw(+ - * /) }
sub enclosed() { pair(Op, '(') ^ $expr ^ pair(Op, ')') }

$Atom = num | enclosed;
$Expr = $atom ^ star(combine ^ $atom);

sub expr() { $Expr }

1;
