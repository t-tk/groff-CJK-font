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

# Regression-test Savannah #24048.  Pages that are too short to
# accommodate minimal header and footer requirements should not cause
# infinite trap recursion.

input='.COVER
.TL
Title
.AU "R. Thurston Howell"
.AT "Professor of Agnotology" "Publisher, Posterior Analytics Weekly"
.COVEND
.P
Main matter goes here.'

echo "checking that sample document fits using default length" >&2
output=$(printf "%s\n" "$input" \
    | "$groff" -b -mm -Tascii -P-cbou) || wail

echo "checking that sample document fits using -rL5v" >&2
output=$(printf "%s\n" "$input" \
    | "$groff" -b -rL5v -mm -Tascii -P-cbou) || wail

echo "checking that sample document fails gracefully using -rL4v" >&2
error=$(printf "%s\n" "$input" \
    | "$groff" -b -rL4v -mm -Tascii -P-cbou -z 2>&1)
# Assume that >= 10 lines of stderr must be due to a giant backtrace.
test $(echo "$error" | wc -l) -lt 10 || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
