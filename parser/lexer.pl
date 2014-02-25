use JBD::Parser::DSL;

print "Type: ", ref Dot, "\n";
print "[.]   ", defined Dot->('.'), "\n";

print "Type : ", ref Space, "\n";
print "[' '] ", defined Space->(' '), "\n";
print '[\n]  ', defined Space->("\n"), "\n";

print "Type: ", ref Word, "\n";
print "[ab.c] ", defined Word->('ab.c'), "\n";
