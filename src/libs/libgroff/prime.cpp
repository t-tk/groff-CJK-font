/* Copyright (C) 2014-2020 Free Software Foundation, Inc.

This file is part of groff.

groff is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free
Software Foundation, either version 2 of the License, or
(at your option) any later version.

groff is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

The GNU General Public License version 2 (GPL2) is available in the
internet at <http://www.gnu.org/licenses/gpl-2.0.txt>. */

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <assert.h>
#include <math.h>

bool is_prime(unsigned n)
{
  assert(n > 1);
  if (n <= 3)
    return true;
  if (!(n & 1))
    return false;
  if (n % 3 == 0)
    return false;
  unsigned lim = unsigned(sqrt((double)n));
  unsigned d = 5;
  for (;;) {
    if (d > lim)
      break;
    if (n % d == 0)
      return false;
    d += 2;
    if (d > lim)
      break;
    if (n % d == 0)
      return false;
    d += 4;
  }
  return true;
}

// Local Variables:
// fill-column: 72
// mode: C++
// End:
// vim: set cindent noexpandtab shiftwidth=2 textwidth=72:
