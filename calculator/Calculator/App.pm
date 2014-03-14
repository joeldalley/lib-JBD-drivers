package Calculator::App;

# Provides calculate, which turns a user-inputted 
# expression into a value, if the expression parses.
# @author Joel Dalley
# @version 2014/Feb/28

use JBD::Parser::DSL;
use Calculator::Grammar qw(expr types);
use JBD::Core::Exporter ':omni';

# @param string $text User input, e.g., '3 + (.24 * -2)'
# @return scalar Calculation result.
sub calculate($) {
    my $text = shift;
    my $lexed = tokens $text, [types, Op];
    my $state = parser_state [@$lexed, token End_of_Input];
    my $parsed = expr->($state) or die $state->error_string;
    return shift(@$parsed)->value if @$parsed == 2;
    die "Expecting result token & end of input token only";
}

1;
