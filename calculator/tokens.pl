use JBD::Parser::DSL;

my $text = shift;
exit unless defined $text;

my $sift = sub {!$_->typeis(Space)};
$tokens = tokens $text, [Num, Op], $sift;
my $cnt = @$tokens;

print "`$text` lexes into $cnt tokens:",
      "\n\n", join("\n", @$tokens), "\n";
