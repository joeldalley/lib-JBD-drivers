use JBD::Core::stern;
use JBD::Core::Template 'render';

my $p = '../../website-JBD/hosted_files/subdomains/tempo/tmpl';

print render "$p/h1.html", '<!--H1-->', $_ for qw(Testing Foo Bar);
