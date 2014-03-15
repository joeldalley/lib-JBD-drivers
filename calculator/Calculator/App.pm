package Calculator::App;

# Provides calculate, which turns a user-inputted 
# expression into a value, if the expression parses.
# @author Joel Dalley
# @version 2014/Feb/28

use JBD::Parser::DSL;
use Calculator::Grammar qw(expr types);
use JBD::Core::Exporter ':omni';

# @param arrayref $tokens Array of JBD::Parser::Tokens.
# @return mixed A result JBD::Parser::Token, or undef.
sub reduce($) {
    my $tokens = shift;
    my $expr = join ' ', grep defined $_,
               map $_->value, @$tokens;
    my $val = eval $expr; 
    die $@ if $@;
    my $res = tokens $val, [types];
    ref $res ? shift @$res : undef;
}

# @param string $text User input, e.g., '3 + (.24 * -2)'
# @return scalar Calculation result.
sub calculate($) {
    my $text = shift;

    my $lexed = tokens $text, [types, Op];
    my $state = parser_state [@$lexed, token End_of_Input];
    my $parsed = (expr ^ type End_of_Input)->($state) 
        or die $state->error_string;

    my $result = reduce $parsed 
        or die qq|Unable to reduce "@$parsed"|;
    $result->value;
}

1;
