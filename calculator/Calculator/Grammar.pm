package Calculator::Grammar;

# Defines a grammar, and provides subs for each production.
# @author Joel Dalley
# @version 2014/Feb/27

use JBD::Parser::DSL;
use JBD::Core::Exporter ':omni';

my ($E, $T, $F);

# Grammatical productions.
sub expr()          { $E }
sub term()          { $T }
sub factor()        { $F }
sub op(;$)          { pair Op, shift }
sub enclosed_expr() { op '(' ^ $E ^ op ')' }
sub term_op_expr()  { $T ^ (op '+' | op '-') ^ $E }
sub fact_op_term()  { $F ^ (op '*' | op '/') ^ $T }


# @return array Types the calculator can compute values for.
sub operands() { Float, Int }

# @return JBD::Parser coderef A rule that parses any operand.
sub operand() { any map type $_, operands }

# @return array Operators the calculator supports.
sub operators() { (qw(+ * - /)) }


# Initialize parsers and define grammar rules.
# @param hash [opt] %transformers Token transformer subs.
sub init(%) {
    my %transformers = @_;

    # Transformer helper.
    my $def = sub {
        no strict 'refs';
        my $name = shift;
        return &$name if !$transformers{$name};
        trans &$name, $transformers{$name};
    };

    # Parsers.
    my ($expr, $term, $fact);
    $E = parser { $expr->(@_) };
    $T = parser { $term->(@_) };
    $F = parser { $fact->(@_) };

    # Grammar rules.
    $expr = $def->('term_op_expr') | $T;
    $term = $def->('fact_op_term') | $F;
    $fact = operand | $def->('enclosed_expr');
}

1;
