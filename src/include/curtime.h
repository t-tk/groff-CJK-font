/* Copyright (C) 2015-2020 Free Software Foundation, Inc.

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

#include <time.h>

// Get the current time in broken-down time representation.  If the
// SOURCE_DATE_EPOCH environment variable is set, then it is used instead of
// the real time from the system clock; in this case, the user is clearly
// trying to arrange for some kind of reproducible build, so express the
// time in UTC.  Otherwise, use the real time from the system clock, and
// express it relative to the user's time zone.
//
// In either case, as with gmtime() and localtime(), the return value points
// to a statically-allocated struct which might be overwritten by later
// calls.
struct tm *current_time();
