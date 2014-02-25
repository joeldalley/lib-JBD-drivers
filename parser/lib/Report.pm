package Report;

use JBD::Core::stern;
use JBD::Core::Exporter ':omni';

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
