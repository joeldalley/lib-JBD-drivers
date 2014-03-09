package Calculator::App;

# Provides calculate, which turns a user-inputted 
# expression into a value, if the expression parses.
# @author Joel Dalley
# @version 2014/Feb/28

use Carp 'croak';
use JBD::Core::Exporter ':omni';
use JBD::Core::List 'zip';

use JBD::Parser::DSL;
use Calculator::Grammar 
    qw(expr term factor types op primitive_operators);

use constant {
    Nicht => token(Nothing),
    Prims => [primitive_operators]
};

# Replace two subs with ones that compute intermediate
# values for sub-expressions; this way, we control
# the order of evaluation by ensuring that 
# parenthesized sub-expressions are evaulated first,
# and that a sequence of * and/or / Ops is evaluated
# from left to right, and thus, ultimately, that each
# full expression $EXPR evaluates to the same value 
# that eval($EXPR) would produce.

Calculator::Grammar::init(
    enclosed_expr => sub {
        parser {
            my $in = shift;
            my ($tok) = cat(op '(', expr, op ')')->($in);
            replace($tok, $in);
        };
    },
    fact_op_term => sub {
        my $op = op '*' | op '/';
        my $p = factor ^ star($op ^ (factor | term));

        parser {
            my $in = shift;
            my ($tok) = $p->($in);
            replace($tok, $in);
        };
    }
); 


#///////////////////////////////////////////////////////////////
# Interface ////////////////////////////////////////////////////

# @param string $text User input, e.g., '3 * (.5 + 2) * -2'
# @return scalar Calculation result.
sub calculate($) {
    my $text = shift;

    my $parser = expr ^ type End_of_Input;
    my $in_opts = {tail => [token End_of_Input]};
    my ($tok) = $parser->(input $text, [types, Op], $in_opts);
    ref $tok or croak $input->parse_error;

    compute("calculate($text)", $tok)->value;
}


#///////////////////////////////////////////////////////////////
#/ Internally used /////////////////////////////////////////////

# @param string $caller For the error message, if needed.
# @param arrayref $tokens JBD::Parser::Tokens.
# @return A JBD::Parser::Token containing the computed value.
sub compute($$) {
    my ($caller, $tokens) = @_;

    # Perl primitive arithmetic ops.
    my %math = (
        '+' => sub { $_[0] + $_[1] },
        '-' => sub { $_[0] - $_[1] },
        '*' => sub { $_[0] * $_[1] },
        '/' => sub { $_[0] / $_[1] }
        );

    # Compute.
    my @values = grep defined $_, map $_->value, @$tokens;
    my $val = shift @values;
    while (@values) {
        my ($op, $num) = (shift @values, shift @values);
        $val = eval $math{$op}->($val, $num);
        warn $@ if $@  # Division by zero.
    }
    my $res = tokens $val, [types] if defined $val;

    # Ensure computation is closed under %math ops.
    my $range_error = sub {"Range error `$_[0]` - $_[1]"};
    die $range_error->($expr, 'undefined') if !defined $val;
    die $range_error->($expr, "no token for `$val`") if !$res;

    shift @$res;
}

# @param arrayref $tok JBD::Parser::Tokens.
# @param JBD::Parser:Input $in.
# @return mixed Array of ([JBD::Parser::Tokens], JBD::Parser::Input),
#               or undef (on failure to parse).
sub replace {
    my ($tok, $in) = @_;

    if (ref $tok) {
        my @rators = grep $_->anyof([Op], Prims), @$tok;
        my @rands  = grep $_->typeis(types), @$tok;
        my $res = $rands[0];

        if (@rators) {
            my $str = join ' ', map "[$_]", @$tok;
            my $expr_tok = [zip @rands, @rators, undef];
            pop @$expr_tok; # Remove that undef.
            $res = compute("replace($str)", $expr_tok);
        }

        return ([$res, map Nicht, (0 .. @$tok-2)], $in);
    }

    undef;
}

1;
