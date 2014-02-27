package Report;

use JBD::Core::stern;
use JBD::Core::Exporter ':omni';

sub value_str($$) {
    my ($tok, $text) = @_;
    ref $tok
      ? join ', ', map $_->value, grep $_->value, @$tok
      : "Unable to get tokens from input `$text`";
}

sub report($) {
    my $tokens = shift;

    print ref $tokens 
        ? join ' ', map $_->value,
          grep $_->value, @$tokens 
        : 'No tokens.';
    print "\n";

    ref $tokens;
}

1;
