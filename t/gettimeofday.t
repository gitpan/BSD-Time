use BSD::Time;

use strict;

use vars qw($gt0 $ut0 $gt1 $dgt $dt0 $gt2 @gtod $minuteswest $dsttype);

print "1..7\n";

$ut0 = time();
$gt0 = gettimeofday();
sleep(1);
$gt1 = gettimeofday();

print "# ut0 = $ut0\n";
print "# gt0 = $gt0\n";
print "# gt1 = $gt1\n";

$dgt = $gt1 - $gt0;

print 'not ' unless ($dgt > 0);
print "ok 1\n";

print 'not ' unless ($dgt > 0.99);
print "ok 2\n";

$dt0 = $gt0 - $ut0;

print 'not ' unless ($dt0 < 1);
print "ok 3\n";

print 'not ' unless ($dt0 > 0);
print "ok 4\n";

@gtod = gettimeofday();

print 'not '
	unless (@gtod == 3
	and 
	defined $gtod[0]
	and 
	defined $gtod[1]
	and 
	defined $gtod[2]);
print "ok 5\n";

($gt2, $minuteswest, $dsttype) = @gtod;

print "# minuteswest = $minuteswest\n";
print "# dsttype     = $dsttype\n";

print 'not ' if ($minuteswest < -720 || $minuteswest > 720);
print "ok 6\n";

print 'not ' if ($dsttype < 0 || $dsttype > 10);
print "ok 7\n";

# eof
