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

fail=

wail () {
    echo ...FAILED >&2
    fail=YES
}

# Regression-test Savannah #59971.
#
# Hyphenation needs to be restored between (and after) text blocks just
# as adjustment is.

input='.nr LL 78n
.hw a-bc-def-ghij-klmno-pqrstu-vwxyz
.LP
Here is a table with hyphenation disabled in its text block.
.
.TS
tab(@);
L Lx.
foo@T{
.nh
abcdefghijklmnopqrstuvwxyz
abcdefghijklmnopqrstuvwxyz
abcdefghijklmnopqrstuvwxyz
T}
.TE
.
Let us see if hyphenation is enabled again as it should be.
abcdefghijklmnopqrstuvwxyz'

output=$(printf "%s\n" "$input" | "$groff" -Tascii -P-cbou -t -ms)

echo "$output"

echo "checking whether hyphenation disabled in table text block" >&2
echo "$output" | grep '^foo' | grep -- '-$' && wail

echo "checking whether hyphenation enabled after table" >&2
echo "$output" | grep -qx 'Let us see.*lmno-' || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
