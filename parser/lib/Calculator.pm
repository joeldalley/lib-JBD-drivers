package Calculator;

use JBD::Parser::DSL;
use JBD::Core::List 'flatmap';
use JBD::Core::Exporter ':omni';
use Carp 'croak';

my ($expr, $term, $fact);
my $Expr = parser { $expr->(@_) };
my $Term = parser { $term->(@_) };
my $Fact = parser { $fact->(@_) };

# Grammatical productions.
sub expr()        { $Expr }
sub term()        { $Term }
sub factor()      { $Fact }
sub op(;$)        { is(Op, shift) }
sub term_R_expr() { cat $Term, any(op('+'), op('-')), $Expr }
sub fact_R_term() { cat $Fact, any(op('*'), op('/')), $Term }
sub parens_expr() { cat op('('), $Expr, op(')') }


$expr = any trans(term_R_expr, \&compute), $Term;
$term = any trans(fact_R_term, \&compute), $Fact;
$fact = any is(Int), trans parens_expr, \&strip_parens;


# @param string User input, to calculate.
# @return arrayref JBD::Parser::Tokens.
sub calculate($) {
    my $in = shift;
    my $parser = cat expr, is End_of_Input;
    my $input = input $in, [Int, Op];
    use Data::Dumper; print Dumper $input;
    my ($tokens) = $parser->($input);
    $tokens;
} 

# @param arrayref $tok Array of JBD::Parser::Tokens.
# @return arrayref Transformed tokens array.
sub strip_parens {
    my $tok = shift or return;
    for ($tok->[0], $tok->[@$tok-1]) {
        next unless $_->anyof([Op], [qw|( )|]);
        $_ = JBD::Parser::Token->nothing; 
    }
    $tok;
}

# @param arrayref $tok Array of JBD::Parser::Tokens.
# @return arrayref Transformed tokens array.
sub compute {
    my $tok = shift or return;

    my @op  = grep $_->typeis(Op), @$tok;
    my @int = grep $_->typeis(Int), @$tok;
    my @not = grep $_->typeis(Nothing), @$tok;

    my $expr = join shift(@op)->value, map $_->value, @int;
    print "$expr\n";
    my $val = eval $expr; croak $@ if $@;

    [JBD::Parser::Token->new(ref Int, $val), 
     map JBD::Parser::Token->nothing, (@not, @op, @int)];
}
