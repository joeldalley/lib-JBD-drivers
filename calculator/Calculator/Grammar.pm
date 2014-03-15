package Calculator::Grammar;

# Define grammar.
# @author Joel Dalley
# @version 2014/Feb/27

use JBD::Parser::DSL;
use JBD::Core::Exporter ':omni';

my ($Atom, $Expr);
my $atom = parser {$Atom->(@_)};
my $expr = parser {$Expr->(@_)};

sub types()     { Signed, Unsigned }
sub operators() { qw(+ - * /) }
sub num()       { type Unsigned | type Signed }
sub op($)       { pair Op, shift }
sub operator()  { any map op $_, operators }
sub enclosed()  { op '(' ^ $expr ^ op ')' }
sub Expr()      { $atom ^ star(operator ^ $atom) }
sub expr()      { $Expr }

sub init(%) {
    my %trans = @_;

    my $def = sub {
        no strict 'refs';
        my $sub = shift;
        $trans{$sub} ? trans &$sub, $trans{$sub} : &$sub;
    };

    $Atom = num | $def->('enclosed');
    $Expr = $def->('Expr');
}

1;
