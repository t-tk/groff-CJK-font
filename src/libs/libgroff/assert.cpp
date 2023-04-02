/* Copyright (C) 1989-2020 Free Software Foundation, Inc.
     Written by James Clark (jjc@jclark.com)

This file is part of groff.

groff is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License, or
(at your option) any later version.

groff is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>. */

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

extern "C" const char *program_name;

void assertion_failed(int lineno, const char *filename,
                      const char *function, const char *msg)
{
  if (program_name != 0)
    fprintf(stderr, "%s: ", program_name);
  fprintf(stderr, "%s:%d: %s(): assertion failed: '%s'\n", filename,
	  lineno, function, msg);
  fflush(stderr);
  abort();
}
