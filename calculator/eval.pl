use Calculator::App 'calculate';
my $text = shift;
my $ans = 'undefined';
$ans = calculate $text;
print "$ans\n" if defined $ans;
