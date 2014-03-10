use JBD::Core::stern;
use JBD::Core::List qw(zip pairsof);

sub tester($$) {
    my ($label, $sub) = @_;
    print "TESTING: $label\n";
    $sub->();
}

sub pair_printer($) {
    my ($k, $v) = @{$_[0]};
    $v = 'UNDEF' if !defined $v;
    print "$k=$v\n";
}

# Test pairsof().
my $pairsof = sub {
    my @kv = qw(a 1 b 2 c 3);
    my $it = pairsof @kv;
    while ($_ = $it->()) { pair_printer $_ }
    print "\n";

    @kv = qw(a uneven b number c of d elements e);
    $it = pairsof @kv;
    while ($_ = $it->()) { pair_printer $_ }
    print "\n";
};

# Test zip().
my $zip = sub {
    my @k  = qw(a b c);
    my @v  = qw(1 2 3);
    my @Z  = zip @k, @v;
    my $it = pairsof @Z;
    while ($_ = $it->()) { pair_printer $_ }
    print "\n";

    @v  = qw(only two_now);
    @Z  = zip @k, @v;
    $it = pairsof @Z;
    while ($_ = $it->()) { pair_printer $_ }
    print "\n";
};

tester 'zip()',     $zip;
tester 'pairsof()', $pairsof; 
