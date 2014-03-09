package Calculator::Grammar;

# Defines a grammar, and provides subs for each production.
# @author Joel Dalley
# @version 2014/Feb/27

use JBD::Parser::DSL;
use JBD::Core::Exporter ':omni';

my ($E, $T, $F);

# Calculator operand types.
sub types() { Signed, Unsigned }

# Calulator operators.
sub primitive_operators() { qw(+ - * /) }


# Grammatical productions.
sub expr()          { $E }
sub term()          { $T }
sub factor()        { $F }
sub op(;$)          { pair Op, shift }
sub operand()       { any map type $_, types }
sub enclosed_expr() { op '(' ^ $E ^ op ')' }
sub term_op_expr()  { $T ^ (op '+' | op '-') ^ $E }
sub fact_op_term()  { $F ^ (op '*' | op '/') ^ $T }


# Initialize parsers and define grammar rules.
# @param hash [opt] %replace Map of {symbol => coderef}.
sub init(%) {
    my %replace = @_;

    # Replacer. 
    my $def = sub {
        no strict 'refs';
        my $sub = shift;
        $replace{$sub} ? &{$replace{$sub}} : &$sub;
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
