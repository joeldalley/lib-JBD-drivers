use JBD::Parser::DSL;

my %cfg = (
    123                => [Int], 
    Blah               => [Word],
    '...'              => [Dot],
    '3.14 2.2'         => [Float],
    "Three words what" => [Word],
    );

while (my ($text, $matchers) = each %cfg) {
    my $key = $text;
    my $tokens = tokens $text, $matchers;
    my @vals = map $_->value || 'Undef', @$tokens;
    print "$key  ==> ", join ('', map "{$_}", @vals), "\n\n";
}
