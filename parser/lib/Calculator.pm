package Calculator;

# Provides 'calculate', which takes a string and returns a value.
#
# Defines a grammar, and provides subs for each production.
#
# Utilizes transformer subs to transform the token array mid-parse,
# so that operators and their operands are evaluted, and replaced
# with tokens bearing the evaluated values. A successful parse 
# will result in 1 returned token: the fully computed value token.
#
# @author Joel Dalley
# @version 2014/Feb/27

use JBD::Parser::DSL;
use JBD::Core::List qw(zip flatmap);
use JBD::Core::Exporter ':omni';
use Carp 'croak';

#///////////////////////////////////////////////////////////////
#// Interface //////////////////////////////////////////////////

# @return array Types the calculator can perform operations on.
sub operands() { Float, Int }

# @param string $text User input, e.g., '3 * (.5 + 2) + -1.*2'
# @return mixed Calculation result, if the input parsed.
sub calculate($) {
    my $text = shift;
    my $parser = cat &expr, is End_of_Input;
    my $input = input $text, [operands, Op];
    my ($tok) = $parser->($input);
    croak "Input doesn't parse `$text`" unless ref $tok;
    (shift @$tok)->value;
}


#///////////////////////////////////////////////////////////////
#// Calculator Grammar /////////////////////////////////////////

my ($expr, $term, $fact);
my $Expr = parser { $expr->(@_) };
my $Term = parser { $term->(@_) };
my $Fact = parser { $fact->(@_) };

# Grammatical productions.
sub expr()          { $Expr }
sub term()          { $Term }
sub factor()        { $Fact }
sub op(;$)          { is(Op, shift) }
sub term_R_expr()   { cat $Term, any(op('+'), op('-')), $Expr }
sub fact_R_term()   { cat $Fact, any(op('*'), op('/')), $Term }
sub enclosed_expr() { cat op('('), $Expr, op(')') }

$expr = any trans(term_R_expr, \&_eval), $Term;
$term = any trans(fact_R_term, \&_eval), $Fact;
$fact = any map(is($_), operands), trans enclosed_expr, \&_strip;


#///////////////////////////////////////////////////////////////
#// Token Transformers /////////////////////////////////////////

# Replace '(', and ')' with Nothing tokens.
# @param arrayref $tok Array of JBD::Parser::Tokens.
# @return arrayref Transformed tokens array.
sub _strip {
    my $tok = shift or return;
    for ($tok->[0], $tok->[@$tok-1]) {
        next unless $_->anyof([Op], [qw|( )|]);
        $_ = JBD::Parser::Token->nothing; 
    }
    $tok;
}

# Replace operands and mathematical operators with their values, and
# replace tokens consumed in producing the value with Nothing tokens.
# @param arrayref $tok Array of JBD::Parser::Tokens.
# @return arrayref Transformed tokens array.
sub _eval {
    my $tok = shift or return;

    my @op       = grep $_->typeis(Op), @$tok;
    my @not      = grep $_->typeis(Nothing), @$tok;
    my @operands = grep $_->typeis(operands), @$tok;

    my $expr = join shift(@op)->value, map $_->value, @operands;
    my $val = eval $expr; croak $@ if $@;

    my $type;
    for (operands) { if (is $_, $val) { $type = $_; last } }
    croak "No operand type for value `$val`" unless $type;

    [JBD::Parser::Token->new(ref $type, $val), 
     map JBD::Parser::Token->nothing, @not, @op, @operands];
}
