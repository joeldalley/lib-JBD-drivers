use JBD::Core::stern;
use JBD::Core::List qw(uniq collect flatmap zip pairsof);

sub tester($$) {
    my ($label, $sub) = @_;
    print "\nTESTING: $label\n";
    $sub->();
}

sub printer_cfg() {
    [' @', ' @', sub { 
        my ($code, @args) = @_;
        grep defined $_, (@_ = $code->(@args));
    }],
    [' @', '\@', sub { 
        my ($code, @args) = @_;
        [grep defined $_, (@_ = $code->(@args))];
    }],
    ['\@', ' @', sub { 
        my $code = shift;
        grep defined $_, @{$_ = $code->(\@_)};
    }],
    ['\@', '\@', sub {
        my $code = shift;
        [grep defined $_, @{$_ = $code->(\@_)}];
    }];
}

sub printer(&@) {
    my ($code, $for) = (shift, shift);

    my %IN = map { 
        do { my @m = ($_ =~ /(\w+)/go); 
             my @n = ($_ =~ /(\W+)/go);
             join '', @m, @n } => $_;
    } @_;

    for my $key (sort keys %IN) {
        my $str = $IN{$key};
        print "Input: $str\n";

        for my $cfg (printer_cfg) {
            my ($in, $out, $callback) = @$cfg;
            my @res = $callback->($code, eval $str);
            @res = @res == 1 ? (@{$res[0]}) : @res;
            print "\t$for -> $in -> $out -> { @res }\n";
        }
    }
}

# Test uniq().
my $uniq = sub {
    printer {uniq @_} 'uniq'
         => 'qw(a a b c)';
};

# Test pairsof().
my $pairsof = sub {
    printer {flatmap collect pairsof @_} 'pairsof'
         => 'qw(uneven sized list)'
         => 'qw(a 1 b 2 c 3)';
};

# Test zip().
my $zip = sub {
    printer {zip @_} 'zip'
         => 'qw(a b c 1 2 3)',
         => 'qw(uneven sized list 1 2)',
};

# Test flatmap().
my $flat = sub {
    printer {flatmap @_} 'flatmap'
         => '([1, 2], [[3]], [4, [6]], 7)'
         => '(1, 2, 3, 5, 8, 13)';

};

tester 'uniq()',    $uniq;
tester 'pairsof()', $pairsof;
tester 'zip()',     $zip;
tester 'flatmap()', $flat;
