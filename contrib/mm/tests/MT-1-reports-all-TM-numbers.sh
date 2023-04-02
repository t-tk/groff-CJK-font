#!/bin/sh
#
# Copyright (C) 2023 Free Software Foundation, Inc.
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
    echo ...FAILED >&2
    fail=YES
}

# Regression-test Savannah #63613.  The identifiers of all technical
# memoranda should be formatted.

input='.TL
My Memo
.AU "Random Hacker"
.TM 23-SKIDOO 24-URTHRU
.MT 1
This is my memo.
.
There are many like it but this one is mine.'

output=$(printf "%s\n" "$input" | "$groff" -mm -Tascii -P-cbou)
echo "$output"

echo "checking that first TM number is present" >&2
echo "$output" | grep -q "23-SKIDOO" || wail

echo "checking that second TM number is present" >&2
echo "$output" | grep -q "24-URTHRU" || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
