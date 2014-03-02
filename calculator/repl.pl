use Calculator::App 'calculate';

# Calculator REPL.
# @author Joel Dalley
# @version 2014/Mar/02

# e|E is allowed, because sometimes floats have e in them.
my $alph = join '|', grep $_ ne 'e', ('a' .. 'z');

# Intro. Classy.
print join "\n\n", 
           join(' ', split //, "\tCALCULATOR"),
           "\t Example :> (1 + 2.5) * 3 / 4", '';

# Read, eval, print loop.
while (1) {
    print "\t :> ";
    chomp(my $text = <STDIN>);
    last if $text =~ m{^[$alph]}io;
    my $ans; eval {$ans = calculate $text};
    print "\t :> ERROR: $@" if $@;
    print "\t :> $ans\n" if !$@;
}
