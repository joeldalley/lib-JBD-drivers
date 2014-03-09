use Calculator::App 'calculate';
my $text = shift || '0';
print "calc `$text` : ", calculate($text), "\n";
print "eval `$text` : ", eval($text), "\n";
