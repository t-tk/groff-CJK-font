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

#ifndef GROFF_LIB_H
#define GROFF_LIB_H

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#if defined(__INTERIX) && !defined(_ALL_SOURCE)
#define _ALL_SOURCE
#endif

#ifdef __cplusplus
extern "C" {
#endif
#ifndef HAVE_STRERROR
  char *strerror(int);
#endif
  const char *i_to_a(int);
  const char *ui_to_a(unsigned int);
  const char *if_to_a(int, int);
#ifdef __cplusplus
}
#endif

#define __GETOPT_PREFIX groff_
#include <getopt.h>

#ifdef HAVE_SETLOCALE
#include <locale.h>
#define getlocale(category) setlocale(category, NULL)
#else /* !HAVE_SETLOCALE */
#define LC_ALL 0
#define LC_CTYPE 0
#define setlocale(category, locale) (void)(category, locale)
#define getlocale(category) ((void)(category), (char *)"C")
#endif /* !HAVE_SETLOCALE */

#include <stdbool.h>

char *strsave(const char *s);
bool is_prime(unsigned);
double groff_hypot(double, double);

#include <stdio.h>
#include <string.h>
#ifdef HAVE_STRINGS_H
#include <strings.h>
#endif

#include <stdarg.h>

#ifdef __cplusplus
extern "C" {
#endif

/* LynxOS 4.0.0 doesn't declare vfprintf() */
#ifdef NEED_DECLARATION_VFPRINTF
  int vfprintf(FILE *, const char *, va_list);
#endif

#ifndef HAVE_MKSTEMP
/* since mkstemp() is defined as a real C++ function if taken from
   groff's mkstemp.cpp we need a declaration */
int mkstemp(char *tmpl);
#endif /* HAVE_MKSTEMP */

int mksdir(char *tmpl);

#ifdef __cplusplus
  FILE *xtmpfile(char **namep = 0 /* nullptr */,
		 const char *postfix_long = 0 /* nullptr */,
		 const char *postfix_short = 0 /* nullptr */);
  char *xtmptemplate(const char *postfix_long,
		     const char *postfix_short);
#endif

#ifdef NEED_DECLARATION_POPEN
  FILE *popen(const char *, const char *);
#endif /* NEED_DECLARATION_POPEN */

#ifdef NEED_DECLARATION_PCLOSE
  int pclose (FILE *);
#endif /* NEED_DECLARATION_PCLOSE */

  size_t file_name_max(const char *fname);
  size_t path_name_max(void);

  extern char invalid_char_table[];

  inline bool is_invalid_input_char(int c)
  {
    return (c >= 0 && invalid_char_table[c]);
  }

#ifdef HAVE_STRCASECMP
#ifdef NEED_DECLARATION_STRCASECMP
// Ultrix4.3's string.h fails to declare this.
  int strcasecmp(const char *, const char *); }
#endif /* NEED_DECLARATION_STRCASECMP */
#else /* !HAVE_STRCASECMP */
  int strcasecmp(const char *, const char *);
#endif /* HAVE_STRCASECMP */

#if !defined(_AIX) && !defined(sinix) && !defined(__sinix__)
#ifdef HAVE_STRNCASECMP
#ifdef NEED_DECLARATION_STRNCASECMP
// SunOS's string.h fails to declare this.
  int strncasecmp(const char *, const char *, int);
#endif /* NEED_DECLARATION_STRNCASECMP */
#else /* !HAVE_STRNCASECMP */
  int strncasecmp(const char *, const char *, size_t);
#endif /* HAVE_STRNCASECMP */
#endif /* !_AIX && !sinix && !__sinix__ */

#ifdef __cplusplus
}
#endif

#ifdef HAVE_CC_LIMITS_H
#include <limits.h>
#else /* !HAVE_CC_LIMITS_H */
#define INT_MAX 2147483647
#endif /* !HAVE_CC_LIMITS_H */

/* Maximum number of digits in decimal representations of `int` types
   not including a leading minus sign. */
#define INT_DIGITS 19		/* enough for 64 bit integer */
#define UINT_DIGITS 20

#ifdef PI
#undef PI
#endif

static const double PI = 3.14159265358979323846;

#ifdef __cplusplus
template <typename T, size_t N>
// constexpr // C++11
size_t array_length(T(&)[N]) {
    return N;
}
#endif

#endif /* GROFF_LIB_H */

// Local Variables:
// fill-column: 72
// mode: C++
// End:
// vim: set cindent noexpandtab shiftwidth=2 textwidth=72:
