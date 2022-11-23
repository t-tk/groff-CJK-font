#!/bin/sh
#
# Copyright (C) 2022 Free Software Foundation, Inc.
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

fail=

wail () {
    echo "...FAILED" >&2
    fail=yes
}

# Unit test `Nm` macro (and regression-test Savannah #63377).

input='.Dd 2022-11-17
.Dt foo 1
.Os "groff test suite"
.Sh Name
.Nm foo
.Nd frobnicate a bar
.Sh Description
.Nm
is a program.'

output=$(printf "%s\n" "$input" | "$groff" -Tascii -P-cbou -mdoc)
echo "$output"
echo "$output" | grep 'foo is a program\.' || wail

# Handle multiple declarations in "Name" section.

input='.Dd 2022-11-17
.Dt trig.h 3
.Os "groff test suite"
.Sh Name
.Nm sin ,
.Nm cos ,
.Nm tan
.Nd trigonometric functions
.Sh Description
.Nm
returns the sine of its argument,
an angle
.Ms theta .'

output=$(printf "%s\n" "$input" | "$groff" -Tascii -P-cbou -mdoc)
echo "$output"
echo "$output" | grep 'sin returns the sine' || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
