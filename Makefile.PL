#
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
#

require 5.002;

$PACKAGE = 'BSD::Time';
$VERSION = '0.04';

use Config;
use ExtUtils::MakeMaker;

sub TMPDIR {
    my $TMPDIR =
	(grep(defined $_ && -d $_ && -w $_,
	      ((defined $ENV{'TMPDIR'} ? $ENV{'TMPDIR'} : undef),
	       qw(/var/tmp /usr/tmp /tmp))))[0]
		   unless defined $TMPDIR;
    $TMPDIR || die "Cannot find writable temporary directory.\n";
}

sub try_compile_and_link {
    my ($c, $cccmd) = @_;

    my ($ok) = 0;
    my ($tmp) = TMPDIR . '/' . "tmp$$";
    local(*TMPC);

    unlink("$tmp.c", "$tmp.o");

    if (open(TMPC, ">$tmp.c")) {
	print TMPC $c;
	close(TMPC);
	my $COREincdir = $Config{'archlibexp'} . '/' . 'CORE';
	my $ccflags = $Config{'ccflags'} . ' ' . "-I$COREincdir";
	$cccmd =
	    "$Config{'cc'} -c -o $tmp.o $ccflags $tmp.c @$LIBS 2>/dev/null"
		unless (defined $cccmd);
	system($cccmd);
	$ok = -s "$tmp.o";
	unlink("$tmp.c", "$tmp.o");
    }
    
    $ok;
}

sub has_gettimeofday {
    # confusing but true (if condition true ==> -DHAS_GETTIMEOFDAY already)
    return 0 if $Config{'d_gettimeod'} eq 'define';

    return 1 if
    try_compile_and_link(<<EOM);
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#ifdef I_SYS_TYPES
#   include <sys/types.h>
#endif

#ifdef I_SYS_TIME
#   include <sys/time.h>
#endif

#ifdef I_SYS_SELECT
#   include <sys/select.h>	/* struct timeval might be hidden in here */
#endif
static int foo()
{
    struct timeval tv;
    gettimeofday(&tv, 0);
}
EOM
    return 0;
}

sub init {
    $DEFINE = '';

    # ucb is poison for Solaris.
    $LIBS = $Config{'osname'} eq 'solaris' ? [''] : ['-lucb -lbsd'];

    if ($Config{'d_gettimeod'} eq 'define') {
	# do nothing special, everything should be fine
    } elsif (has_gettimeofday) {
	$DEFINE .= ' -DHAS_GETTIMEOFDAY';
    } else {
	die <<EOD
Your operating system does not seem to have the gettimeofday() function.
(or, at least, I cannot find it)

There is no way $PACKAGE is going to work.

I am awfully sorry but I cannot go further.

Aborting configuration of $PACKAGE $VERSION

EOD
    }
}

sub doMakefile {
    print  <<EOM if ($$LIBS[0] ne '');
Looking for libraries...
Note: it is ok if none of the libraries '@$LIBS' is found.

EOM
    WriteMakefile(
    'NAME'	=> $PACKAGE,
    'VERSION'	=> $VERSION,
    'LIBS'	=> $LIBS,
    'DEFINE'	=> $DEFINE,
# do not even think about 'INC' => '-I/usr/ucbinclude', Solaris will avenge.
);
}

sub main {
    print <<EOM;

Configuring $PACKAGE $VERSION...

EOM

    init;
    configure;
    doMakefile;
print  <<EOM;

Done configuring $PACKAGE $VERSION.

Now you may issue 'make'. Do not forget also 'make test'.

EOM
}

&main;

# EOF
