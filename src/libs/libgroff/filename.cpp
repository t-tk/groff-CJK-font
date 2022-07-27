/* Copyright (C) 2014-2022 Free Software Foundation, Inc.

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

// This global stores the name of the input file being processed by
// troff, an output driver, or other program.
const char *current_filename = 0 /* nullptr */;

// This global stores the name of the troff input file corresponding to
// the part of a device-independent troff output being processed; it is
// used only by output drivers.
const char *current_source_filename = 0 /* nullptr */;

// Local Variables:
// fill-column: 72
// mode: C++
// End:
// vim: set cindent noexpandtab shiftwidth=2 textwidth=72:
