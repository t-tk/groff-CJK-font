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

#include "lib.h"

#include <stddef.h>
#include <stdlib.h>

#include "posix.h"
#include "nonposix.h"

extern "C" const char *program_name;

static void ewrite(const char *s)
{
  write(2, s, strlen(s));
}

void *operator new(size_t size)
{
  // Avoid relying on the behaviour of malloc(0).
  if (size == 0)
    size++;
  char *p = (char *)malloc(unsigned(size));
  if (p == 0) {
    if (program_name) {
      ewrite(program_name);
      ewrite(": ");
    }
    ewrite("out of memory\n");
    _exit(-1);
  }
  return p;
}

void operator delete(void *p)
{
  if (p)
    free(p);
}

void operator delete(void *p,
		     __attribute__((__unused__)) long unsigned int size)
{
  // It's ugly to duplicate the code from delete(void *) above, but if
  // we don't, g++ 6.3 can't figure out we're calling through it to
  // free().
  //
  // In function 'void operator delete(void*, long unsigned int)':
  //   warning: deleting 'void*' is undefined [-Wdelete-incomplete]
  //delete p;
  if (p)
    free(p);
}
