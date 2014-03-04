package Calculator::App;

# Provides calculate, which turns a user-inputted 
# expression into a value, if the expression parses.
# @author Joel Dalley
# @version 2014/Feb/28

use Carp 'croak';
use JBD::Parser::DSL;
use Calculator::Grammar 'expr';
use JBD::Core::Exporter ':omni';

# Using init, alter the calculator's grammar so that the parsing
# process is now also a reduction process, where we reduce valid
# expressions, terms and factors down to a single value-bearing
# operand token (the simple case of factor()), whose value is
# the result of the computation.

Calculator::Grammar::init(
    term_op_expr  => \&replace_with_value,
    fact_op_term  => \&replace_with_value,
    enclosed_expr => \&remove_parentheses,
);


#///////////////////////////////////////////////////////////////
#// Interface //////////////////////////////////////////////////

# @param string $text User input, e.g., '3 * (.5 + 2) + -1. * 2'
# @return scalar Calculation result.
sub calculate($) {
    my $text = shift;

    # Tokenize user input.
    $input = input $text, [Num, Op], {
        tail => [token End_of_Input]
    };

    # Parse tokens.
    my $parser = expr ^ type End_of_Input;
    my ($tok) = $parser->($input);
    croak "Input doesn't parse `$text`" unless ref $tok;

    # The result.
    $tok = [grep $_->typeis(Num), @$tok];
    die "Exactly one token expected" unless @$tok == 1;
    my $res = shift(@$tok)->value;

    # Ensure the calculator is closed under its operations.
    die "Undefined result for `$text`" if !defined $res;
    die "Range error `$res`" unless Num->($res);
    $res;
}

#///////////////////////////////////////////////////////////////
#/ Parser Transformers /////////////////////////////////////////


# @param arrayref $tok Array of JBD::Parser::Tokens.
# @return arrayref Transformed tokens array.
sub remove_parentheses($) {
    my $tok = shift or return;
    for ($tok->[0], $tok->[@$tok-1]) { 
        $_ = token Nothing if $_->anyof([Op], [qw{) (}]);
    }
    $tok;
}

# @param arrayref $tok Array of JBD::Parser::Tokens.
# @return arrayref Transformed tokens array.
sub replace_with_value($) {
    my $tok = shift or return;

    # Evaluate.
    my $val = eval join ' ', map $_->value, 
                   grep $_->typeis(Num, Op), @$tok;
    croak $@ if $@;
 
    my $new = shift tokens $val, [Num];
    [$new, map token(Nothing), (1 .. $#$tok)];
}

1;
