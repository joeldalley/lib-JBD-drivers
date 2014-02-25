use JBD::Core::stern;
use JBD::Core::Display;

my $p = '/home/joel/projects/website-JBD/hosted_files/subdomains/tempo/tmpl';
my $display = JBD::Core::Display->new($p, '<!--HREF-->' => '/tempo');

print $display->('h1.html', '<!--H1-->' => 'Hello');
print $display->('a.html', '<!--HREF-->' => '#', '<!--TEXT-->' => 'link');
