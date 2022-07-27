#!/bin/sh
#
# Copyright (C) 2022 Free Software Foundation, Inc.
#
# This file is part of groff.
#
# groff is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your
# option) any later version.
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
    echo FAILED >&2
    fail=YES
}

# Regression-test Savannah #62190.  Check left- and center-aligned
# displayed equations as well.

input='.DS L
.EQ (1)
p = q
.EN
.DE
.DS I
.EQ (2)
w = z
.EN
.DE
.DS C
.EQ (3)
x = y
.EN
.DE'

output=$(printf "%s\n" "$input" | "$groff" -e -mm -Tascii -P-cbou)

echo "checking left-aligned displayed equation" >&2
echo "$output" | grep -Eq 'p=q {54}\(1\)' || wail

echo "checking indented displayed equation" >&2
echo "$output" | grep -Eq 'w=z {49}\(2\)' || wail

echo "checking centered displayed equation" >&2
echo "$output" | grep -Eq 'x=y {26}\(3\)' || wail

test -z "$fail" || exit 1

# vim:set ai et sw=4 ts=4 tw=72:
