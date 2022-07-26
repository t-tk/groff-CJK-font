#!/bin/sh
#
# Copyright (C) 2021 Free Software Foundation, Inc.
#
# This file is part of groff.
#
# groff is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# groff is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

groff="${abs_top_builddir:-.}/test-groff"

set -e

# Do not core dump when attempting to distribute a space amount of zero
# if someone sets the line length to zero.  See Savannah #61089.
# Reproducer courtesy of John Gardner.

INPUT='.de _
.	na
.	nh
.	ll 0
.	di A
\&\\$1
.	di
.	br
..
._ " XYZ"
.A
'

OUTPUT=$(printf "%s" "$INPUT" | "$groff" -Tascii)
echo "$OUTPUT" | grep -qx XYZ
