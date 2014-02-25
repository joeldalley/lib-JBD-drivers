use JBD::Core::stern;
use JBD::Core::Storable;
use Data::Dumper;

my $file = './test.store';
my $store = JBD::Core::Storable->new($file, {
    call => sub {{a => 1, b => 2, c => 3}},
    mode => 0775,
    ttl  => 1, 
});

my $data = $store->load;
print Dumper $data;
unlink $file if -e $file;
