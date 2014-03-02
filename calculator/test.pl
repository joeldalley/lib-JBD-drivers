use JBD::Parser::DSL;
use JBD::Core::List 'pairsof';
use Calculator::App 'calculate';

# Calculator tests.
# @author Joel Dalley
# @version 2014/Mar/02

sub NUM_TESTS {20}
sub MAX_DEPTH {2}

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
    my %tests = @_;
    my @v = sort {length $a <=> length $b} values %tests;
    length pop @v;
}

sub currdepth { my $d = 0; sub {$d += shift} }

my @tests;
my $dep = currdepth;

while (@tests < (2 * NUM_TESTS)) {
    my $num = gen_num;
    my $expr = spaces gen_expr $num, $dep;
    my $ans = eval $expr;
    push @tests, $ans, $expr;
}

my $pairsof = pairsof @tests;
my $maxlen = maxlen @tests;
my $spacer = sub { " " x ($maxlen - length $_[0]) };

my $cnt = 1;
while (my $pair = $pairsof->()) {
    my ($correct, $expr) = @$pair;
    my $ans; eval {$ans = calculate $expr};
    my $print_ans = defined $ans ? $ans : 'undefined';
    my $msg = "[$cnt] `$expr`${\$spacer->($expr)} => $print_ans";
    print "$msg\n";
    $cnt++;
}
