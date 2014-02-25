use JBD::Core::stern;
use JBD::Core::Db;

my $DSN = 'DBI:SQLite2:/home/joel/projects/soma/db/soma.db';
my $db = JBD::Core::Db->new($DSN);

my $count = $db->count('song');
print "$count songs\n";

my $iter = $db->iterator('song', ['title'], ["title LIKE '%butterfly%'"]);
while (my $row = $iter->()) { print "@$row\n" }
