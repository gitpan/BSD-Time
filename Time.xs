/*
 * Copyright (c) 1997 Jarkko Hietaniemi. All rights reserved.
 * This program is free software; you can redistribute it and/or
 * modify it under the same terms as Perl itself.
 *
 * BSD:Time Time.xs
 *
 */

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

#define TV2DS(tv) ((double)tv.tv_sec+(double)tv.tv_usec*0.000001)

MODULE = BSD::Time		PACKAGE = BSD::Time

# No, I won't. 5.001m xsubpp chokes on this.
# PROTOTYPES: enable

void
_gettimeofday()
    PPCODE:
	{
#ifdef HAS_GETTIMEOFDAY
	  struct timeval  tv;
	  struct timezone tz;
	  if (gettimeofday(&tv, &tz) == 0) {
	      EXTEND(sp, 1);
	      PUSHs(sv_2mortal(newSVnv(TV2DS(tv))));
	      if (GIMME == G_ARRAY) {
		  EXTEND(sp, 2);
		  PUSHs(sv_2mortal(newSViv(tz.tz_minuteswest)));
		  PUSHs(sv_2mortal(newSViv(tz.tz_dsttime)));
	      }
	  }
#else
	  die(no_func, "gettimeofday");
#endif
	}

int
_settimeofday(now, minuteswest, dsttype)
	double	now
	int	minuteswest
	int	dsttype
    CODE:
	{
#ifdef HAS_GETTIMEOFDAY
	  struct timeval  tv;
	  struct timezone tz;

	  if (geteuid())
	     croak("settimeofday: Permission denied.");

	  if (now < 0 || now > (double)((1L<<31)-1))
	      croak("settimeofday: illegal timeval");
	  tv.tv_sec  = (int)now;
	  tv.tv_usec = (int)(1000000.0 * (now - (double)tv.tv_sec));

	  if (minuteswest < -720 || minuteswest > 720)
	      croak("settimeofday: illegal minuteswest");
	  if (dsttype < 0 || dsttype > 10) /* 10 is pure guess */
	      croak("settimeofday: illegal dsttype");
	  tz.tz_minuteswest = minuteswest;
	  tz.tz_dsttime = dsttype;

	  ST(0) = sv_newmortal();
	  ST(0) = (settimeofday(&tv, &tz) == 0) ? &sv_yes : &sv_no;
#else
	  die(no_func, "settimeofday");
#endif
	}
