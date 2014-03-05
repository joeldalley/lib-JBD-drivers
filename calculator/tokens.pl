use JBD::Parser::DSL;

my $text = shift;
exit unless defined $text;

$tokens = tokens $text, [Signed, Unsigned, Op];
my $cnt = @$tokens;

print "`$text` lexes into $cnt tokens:",
      "\n\n", join("\n", @$tokens), "\n";
