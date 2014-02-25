package Calculator;

use JBD::Parser::DSL;
use JBD::Core::Exporter ':omni';

my ($expr, $term, $fact);
my $Expr = parser { $expr->(@_) };
my $Term = parser { $term->(@_) };
my $Fact = parser { $fact->(@_) };

$expr = any cat($Term, is(Op, '+'), $Expr), $Term;
$term = any cat($Fact, is(Op, '*'), $Term), $Fact;
$fact = any is(Int), cat is(Op, '('), $Expr, is(Op, ')');


# Grammatical productions.
sub expr()   { $Expr }
sub term()   { $Term }
sub factor() { $Fact }

# @param string User input, to calculate.
# @return arrayref JBD::Parser::Tokens.
sub calculate($) {
    my $in = shift;
    my $parser = cat expr, is End_of_Input;
    my $input  = input \$in, [Int, Op];
    $parser->($input);
}
