use JBD::Parser::DSL;
use JBD::Core::List 'pairsof';
use Calculator::App 'calculate';
use Test::More;

# Calculator tests.
# @author Joel Dalley
# @version 2014/Mar/02

my $num_tests = shift;

sub NUM_TESTS {$num_tests || 100}
sub MAX_DEPTH {2}
sub PRECISION {8}

sub gen_num { 
    my $num = rand 10; 
    $num = rand 1 > .5 ? int $num : sprintf '%.3f', $num; 
    $num = rand 1 > .5 ? "-$num" : $num;
}

sub expr_body {
    my $e = shift;
    my $pm = rand 1 < .5 ? '+' : '-';
    my $md = rand 1 < .5 ? '*' : '/';
    $e = rand 1 > .5 ? "$e $md " . gen_num : $e;
    $e = rand 1 > .5 ? "$e $pm " . gen_num : $e;
    $e = rand 1 > .25 ? "($e)" : $e;
}

sub gen_expr {
    my ($e, $dep) = @_;
    $e = $dep->(1) > MAX_DEPTH || rand 1 < .5
       ? expr_body $e : gen_expr(expr_body($e), $dep);
    $dep->(-1);
    $e;
}

sub spaces {
    my @e = split //, shift;
    join '', grep $_ !~ /\s/ || rand 1 < .5, @e;
}

sub maxlen {
    my $max = 0;
    for (@_) { 
        my $l = defined $_ ? length $_ : 0; 
        $max = $l if $l > $max;
    }
    $max;
}

sub currdepth { my $d = 0; sub {$d += shift} }

my @tests;
my $dep = currdepth;

while (@tests < (2 * NUM_TESTS)) {
    my $num = gen_num;
    my $expr = gen_expr $num, $dep;
    my $ans = eval $expr;
    next unless defined $ans;
    push @tests, $ans, $expr;
}

my $pairsof = pairsof @tests;
my $maxlen = maxlen @tests;
my $spacer = sub { " " x ($maxlen - length $_[0]) };

while (my $pair = $pairsof->()) {
    my ($correct, $expr) = @$pair;
    my $ans; eval {$ans = calculate $expr};
    my $print_ans = defined $ans ? $ans : 'undefined';
    my $msg = sprintf '`%s`%s => %s', 
              $expr, $spacer->($expr), $print_ans;
    $correct = substr $correct, 0, PRECISION;
    ok $ans && index($ans, $correct) == 0, $msg;
}

done_testing;
