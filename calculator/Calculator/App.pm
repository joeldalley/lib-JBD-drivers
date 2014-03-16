package Calculator::App;

# Provides calculate, which turns a user-inputted 
# expression into a value, if the expression parses.
# @author Joel Dalley
# @version 2014/Feb/28

use JBD::Parser::DSL;
use Calculator::Grammar qw(init types expr);
use JBD::Core::Exporter ':omni';
use JBD::Core::List 'pairsof';

our %math = (
    '+' => sub {$_[0] + $_[1]},
    '-' => sub {$_[0] - $_[1]},
    '*' => sub {$_[0] * $_[1]},
    '/' => sub {$_[0] / $_[1]}
    );

init Product  => \&reduce,
     enclosed => \&unenclose;


# @param arrayref Array of JBD::Parser::Tokens.
# @return arrayref Token values, for defined values.
sub phrase($) { 
    [map $_->value, grep defined $_->value, @{$_[0]}];
}

# @param arrayref $tokens Array of JBD::Parser::Tokens.
# @return mixed An arrayref of 1 JBD::Parser::Token, or undef.
sub reduce($) {
    my $phrase = phrase shift;

    # Crunch numbers.
    my $value = shift @$phrase;
    my $pairs = pairsof @$phrase;
    while (my $pair = $pairs->()) {
        my ($op, $num) = @$pair;
        $value = $math{$op}->($value, $num);
    }

    tokens $value, [types];
}

# @param arrayref $tokens Array of JBD::Parser::Tokens.
# @return arrayref Given array, minus "(" and ")" tokens.
sub unenclose($) { shift @{$_[0]}, pop @{$_[0]}; shift }

# @param string $text User input, e.g., '3 + (.24 * -2)'
# @return scalar Calculation result.
sub calculate($) {
    my $text    = shift;
    my $lexed   = tokens $text, [types, Op];
    my $state   = parser_state [@$lexed, token End_of_Input];
    my $parsed  = (expr ^ type End_of_Input)->($state) 
                  or die $state->error_string;
    my $result  = shift @{reduce $parsed} 
                  or die "Unable to reduce `@$parsed`";
    $result->value;
}

1;
