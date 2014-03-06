package Calculator::App;

# Provides calculate, which turns a user-inputted 
# expression into a value, if the expression parses.
# @author Joel Dalley
# @version 2014/Feb/28

use Carp 'croak';
use JBD::Parser::DSL;
use JBD::Core::Exporter ':omni';

use Calculator::Grammar qw(expr types operators);
Calculator::Grammar::init();

#///////////////////////////////////////////////////////////////
#// Interface //////////////////////////////////////////////////

# @param string $text User input, e.g., '3 * (.5 + 2) * -2'
# @return scalar Calculation result.
sub calculate($) {
    my $text = shift;

    # Tokenize user input string.
    my $input = input $text, [types, Op], {
        tail => [token End_of_Input]
    };

    # Parse tokens.
    my $parser = expr ^ type End_of_Input;
    my ($tok) = $parser->($input);
    ref $tok or croak parse_error($text, $input);

    # Evaluate & tokenize value string.
    my $expr = join ' ', map  $_->value, 
               grep $_->anyof([Op], [operators])
                 || $_->typeis(types), @$tok;
    my $val = eval $expr; 
    my $res = shift tokens $val, [types] if defined $val;

    # Legit?
    croak "Calculator::App::calculate(`$text`): "
        . " eval(`$expr`) produces an error" if $@;
    die range_error($expr, 'undefined') if !defined $val;
    die range_error($expr, "no token for `$val`") if !$res;

    $res->value;
}


#///////////////////////////////////////////////////////////////
#/ Used internaly //////////////////////////////////////////////

# Returns parse error message w/ the given detail.
sub parse_error($$) {
    my ($text, $in) = @_;
    my ($tok, $max) = ($in->tokens, $in->max);
    my $lo = $max ? $max-1 : 0;
    my $hi = $#$tok - $lo > 2 ? $lo + 2 : $#$tok;
    my $el = @$tok > 4 ? ' ... ' : '';
    my $left = join ' ', map $_->value, 
               grep $_->value, @$tok[$lo .. $hi];
    'Parse error: Parsed ' . scalar @$tok .
    " tokens before error at `$el$left`";
}

# Returns range error message w/ the given detail.
sub range_error($$) { "Range error `$_[0]` - $_[1]" }

1;
