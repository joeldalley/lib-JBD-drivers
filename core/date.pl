use JBD::Core::stern;
use JBD::Core::Date;

my @formatted;
my $date = JBD::Core::Date->new(time - 365*86400);
push @formatted, $date->formatted('%Y-%m-%d');
push @formatted, $date->formatted('%F');
push @formatted, $date->formatted('%D');
push @formatted, $date->formatted('%H:%M:%S');
push @formatted, $date->formatted('%a, %b %o, %Y');

print "$_\n" for @formatted;
