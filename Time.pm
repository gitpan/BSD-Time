#
# Copyright (c) 1997 Jarkko Hietaniemi. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# BSD::Time Time.pm
#

package BSD::Time;

require 5.002;

$VERSION = '0.04';

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
use strict;

require Exporter;
require DynaLoader;

@ISA = qw(Exporter DynaLoader);

@EXPORT = qw(gettimeofday settimeofday);

@EXPORT_OK = qw(time);

bootstrap BSD::Time $VERSION;

sub time () {
    scalar gettimeofday();
}

1;
__END__

=head1 NAME

BSD::Time - BSD gettimeofday, settimeofday functions

=head1 SYNOPSIS

	use BSD::Time;

	# gettimeofday

	$time = gettimeofday();

	($seconds, $microseconds, $minuteswest, $dsttype) = gettimeofday();

	# settimeofday

	settimeofday($seconds, $microseconds, $minuteswest, $dsttime) or
	    die "cannot set time";

=head1 DESCRIPTION

=head2 gettimeofday

	$time = gettimeofday();

In scalar context C<gettimeofday> returns the number of seconds since
the midnight (0 hour), January 1, 1970 UTC (Coordinated Universal Time,
formerly known as Greenwich Mean Time, GMT).  This is identical to the
usual Perl C<time()> function except that also the subsecond fractional
is returned.  The accuracy is nominally one microsecond, one millionth
of a second, but normally the accuracy is lower than that, maybe few
dozen microseconds.

	($seconds, $microseconds, $minuteswest, $dsttype) = gettimeofday();

In list context C<gettimeofday> returns the I<seconds> and
I<microseconds> and the B<timezone information>: the I<minutes west>
of the Greenwich Meridian and the I<Daylight Savings Time Type>.  The
type is a system-dependent integer value that is not actually much of
use these days: it a historical relic.

=head2 settimeofday

	$success = settimeofday($seconds, $microseconds,
				$minuteswest, $dsttime);

C<settimeofday> sets the time, the arguments being as in the list
context of C<gettimeofday>.  C<settimeofday> may be used only by the
superuser.  It returns true if setting succeeded, false if not.

=head2 Overloading C<time()>

The C<time()> function can be overridden to return the subsecond part
of the second.  B<NOTE: THIS IS ONLY FOR THOSE WHO REALLY, *REALLY*
KNOW WHAT THEY ARE DOING.  THIS CAN BREAK CODE (ACTION-AT-A-DISTANCE,
SOME CODE, ANY CODE, NOT EVEN YOUR CODE OR MINE CODE, SOME MODULE CODE
THAT YOU INADVERTENTLY USE, THAT YOU EVEN DO NOT KNOW THAT YOU ARE
USING) THAT TRUSTS THAT time() ONLY RETURNS INTEGERS.  NOTHING IS
GUARANTEED.  YOU HAVE BEEN WARNED>.  Now that you know where you stand
this can done done with: C<use BSD::Time 'time';>

=head1 LIMITATIONS

The time accuracy is nominally one microsecond, one millionth of a
second, but the implementation of your environment may not be that
accurate.

The BSD time-adjusting function C<adjtime()> is not implemented.
This may affect in some environment the C<settimeofday()> in such
a way that setting time time with subsecond accuracy is not possible.

=head1 AUTHOR

Jarkko Hietaniemi C<E<lt>jhi@iki.fiE<gt>>

=head1 ACKNOWLEDGEMENTS

Gisle Aas C<E<lt>gisle@aas.noE<gt>>

=cut
