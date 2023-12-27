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

fail=

wail () {
    echo ...FAILED >&2
    fail=YES
}

# Regression-test Debian #1038391.
#
# Text blocks should honor row staggering.

input='.
.\" based on a test case from наб <nabijaczleweli@nabijaczleweli.xyz>
The capital letters should appear struck-through due to row staggering.
.sp
.TS
tab(@);
L  L  C  R  A  L
Lu Lu Cu Ru Au Lu .
a@b@c@d@e@f
_
A@T{
B
T}@T{
C
T}@T{
D
T}@T{
E
T}@F
.TE'

output=$(printf "%s\n" "$input" | "$groff" -tZ -T ps)

# This sadly seems fragile and device-dependent.  But a table entry
# generally doesn't know where on the page it is typeset.
echo "$output"
test $(echo "$output" | grep -c 'V *44000') -eq 5

# vim:set ai et sw=4 ts=4 tw=72:
