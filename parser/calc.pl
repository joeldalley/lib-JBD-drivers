use lib 'lib';
use Calculator::App 'calculate';

# e is allowed, because sometimes floats have e in them.
my $alph = join '|', grep $_ ne 'e', ('a' .. 'z');

# Intro. Classy.
print "\n\tC A L C U L A T O R",
      "\n\n\tExample :> (1+2.5) * 3 / (4 + 8.20) - 1\n\n";

# Read, eval, print loop.
while (1) {
    print "\t:> ";
    my $res = 'undefined';
    chomp(my $text = <STDIN>);
    last if $text =~ m{^[$alph]}io;
    eval { $res = calculate $text };
    print "\t:> ERROR: $@" if $@;
    print "\t:> $res\n";
}
