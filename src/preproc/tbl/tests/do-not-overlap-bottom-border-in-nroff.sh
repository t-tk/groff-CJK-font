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

# Regression-test Savannah #49390.

input='foo
.TS
box;
L.
bar
.TE
baz
.pl \n(nlu
'

echo "checking for post-table text non-overlap of (single) box border"
output=$(printf "%s" "$input" | "$groff" -t -Tascii)
echo "$output" | grep -q baz || wail

input='foo
.TS
doublebox;
L.
bar
.TE
baz
.pl \n(nlu
'

echo "checking for post-table text non-overlap of double box border"
output=$(printf "%s" "$input" | "$groff" -t -Tascii)
echo "$output" | grep -q baz || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
