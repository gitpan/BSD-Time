use BSD::Time 'time';

use vars qw($t0 $t1);

print "1..2\n";

$t0 = CORE::time();
$t1 = time();

print "# t0 = $t0\n";
print "# t1 = $t1\n";

print 'not ' unless ($t1 >= $t0);
print "ok 1\n";

print 'not ' unless ($t1 - $t0 < 1); # oh well, can fail if load is huge..
print "ok 2\n";

# eof
