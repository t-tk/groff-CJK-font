#!/bin/sh
#
# Copyright (C) 2023 Free Software Foundation, Inc.
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

# Regression-test Savannah #64013.
#
# Render an equation label even if the alignment argument is empty.

input='.LP
.EQ "" (1)
x + y = z
.EN'

output=$(printf "%s\n" "$input" | "$groff" -e -ms -Tascii -P-cbou)
echo "$output"
echo "$output" | grep -qx ' *x+y=z *(1)'

# vim:set ai et sw=4 ts=4 tw=72:
