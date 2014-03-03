use JBD::Parser::DSL;
use Calculator::Grammar 'operands';

my $text = shift;
exit unless defined $text;
$input = input $text, [operands, Op], {
    tail => [token End_of_Input]
};

print "`$text`\n\n";
print "$_\n" for @{$input->tokens};
print "\n`$text`\n";
