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

void fatal_with_file_and_line(const char *, int, const char *,
			      const errarg & = empty_errarg,
			      const errarg & = empty_errarg,
			      const errarg & = empty_errarg);

void error_with_file_and_line(const char *, int, const char *,
			      const errarg & = empty_errarg,
			      const errarg & = empty_errarg,
			      const errarg & = empty_errarg);

void warning_with_file_and_line(const char *, int, const char *,
				const errarg & = empty_errarg,
				const errarg & = empty_errarg,
				const errarg & = empty_errarg);

void debug_with_file_and_line(const char *, int, const char *,
			      const errarg & = empty_errarg,
			      const errarg & = empty_errarg,
			      const errarg & = empty_errarg);

void fatal(const char *,
	   const errarg & = empty_errarg,
	   const errarg & = empty_errarg,
	   const errarg & = empty_errarg);

void error(const char *,
	   const errarg & = empty_errarg,
	   const errarg & = empty_errarg,
	   const errarg & = empty_errarg);

void warning(const char *,
	     const errarg & = empty_errarg,
	     const errarg & = empty_errarg,
	     const errarg & = empty_errarg);

void debug(const char *,
	   const errarg & = empty_errarg,
	   const errarg & = empty_errarg,
	   const errarg & = empty_errarg);


extern "C" const char *program_name;
extern int current_lineno;
extern const char *current_filename;
extern const char *current_source_filename;

// Local Variables:
// fill-column: 72
// mode: C++
// End:
// vim: set cindent noexpandtab shiftwidth=2 textwidth=72:
