use Calculator::App 'calculate';
my $text = shift;
$ans = calculate $text;
print defined $ans ? "$ans\n" : "Undefined\n";
