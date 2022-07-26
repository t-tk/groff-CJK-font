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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "errarg.h"
#include "error.h"

extern void fatal_error_exit();

enum error_type { DEBUG, WARNING, ERROR, FATAL };

static void do_error_with_file_and_line(const char *filename,
					const char *source_filename,
					int lineno,
					error_type type,
					const char *format,
					const errarg &arg1,
					const errarg &arg2,
					const errarg &arg3)
{
  bool need_space = false;
  if (program_name) {
    fprintf(stderr, "%s:", program_name);
    need_space = true;
  }
  if (filename != 0) {
    if (strcmp(filename, "-") == 0)
      filename = "<standard input>";
    fprintf(stderr, "%s", filename);
    if (source_filename != 0)
      fprintf(stderr, ":(%s)", source_filename);
    if (lineno > 0)
      fprintf(stderr, ":%d", lineno);
    fputc(':', stderr);
    need_space = true;
  }
  if (need_space)
    fputc(' ', stderr);
  switch (type) {
  case FATAL:
    fputs("fatal error: ", stderr);
    break;
  case ERROR:
    fputs("error: ", stderr);
    break;
  case WARNING:
    fputs("warning: ", stderr);
    break;
  case DEBUG:
    fputs("debug: ", stderr);
    break;
  }
  errprint(format, arg1, arg2, arg3);
  fputc('\n', stderr);
  fflush(stderr);
  if (type == FATAL)
    fatal_error_exit();
}
      

static void do_error(error_type type, 
		     const char *format, 
		     const errarg &arg1,
		     const errarg &arg2,
		     const errarg &arg3)
{
  do_error_with_file_and_line(current_filename, current_source_filename,
			      current_lineno, type, format, arg1, arg2, arg3);
}

void debug(const char *format,
	   const errarg &arg1,
	   const errarg &arg2,
	   const errarg &arg3)
{
  do_error(DEBUG, format, arg1, arg2, arg3);
}

void error(const char *format, 
	   const errarg &arg1,
	   const errarg &arg2,
	   const errarg &arg3)
{
  do_error(ERROR, format, arg1, arg2, arg3);
}

void warning(const char *format, 
	     const errarg &arg1,
	     const errarg &arg2,
	     const errarg &arg3)
{
  do_error(WARNING, format, arg1, arg2, arg3);
}

void fatal(const char *format, 
	   const errarg &arg1,
	   const errarg &arg2,
	   const errarg &arg3)
{
  do_error(FATAL, format, arg1, arg2, arg3);
}

void debug_with_file_and_line(const char *filename,
			      int lineno,
			      const char *format,
			      const errarg &arg1,
			      const errarg &arg2,
			      const errarg &arg3)
{
  do_error_with_file_and_line(filename, 0, lineno,
			      DEBUG, format, arg1, arg2, arg3);
}

void error_with_file_and_line(const char *filename,
			      int lineno,
			      const char *format, 
			      const errarg &arg1,
			      const errarg &arg2,
			      const errarg &arg3)
{
  do_error_with_file_and_line(filename, 0, lineno, 
			      ERROR, format, arg1, arg2, arg3);
}

void warning_with_file_and_line(const char *filename,
				int lineno,
				const char *format, 
				const errarg &arg1,
				const errarg &arg2,
				const errarg &arg3)
{
  do_error_with_file_and_line(filename, 0, lineno, 
			      WARNING, format, arg1, arg2, arg3);
}

void fatal_with_file_and_line(const char *filename,
			      int lineno,
			      const char *format, 
			      const errarg &arg1,
			      const errarg &arg2,
			      const errarg &arg3)
{
  do_error_with_file_and_line(filename, 0, lineno, 
			      FATAL, format, arg1, arg2, arg3);
}

// Local Variables:
// fill-column: 72
// mode: C++
// End:
// vim: set cindent noexpandtab shiftwidth=2 textwidth=72:
