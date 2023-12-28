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

input='.INITI N index
.P
.IND convolution
Laplace
.bp
.P
.IND involution
Rothe
.INDP'

output=$(printf "%s\n" "$input" \
    | "$groff" -rRef=1 -mm -z -Tascii -P-cbou 2>&1)
echo "$output"

# Expected (on standard error):
# .\" IND convolution     1
# .\" IND involution      2
# .\" Index: index.ind

echo "$output" | grep -qx '\.\\"  *IND  *convolution.*1' \
    || wail "check for 'convolution' index entry failed"
echo "$output" | grep -qx '\.\\"  *IND  *involution.*2' \
    || wail "check for 'involution' index entry failed"
echo "$output" | grep -qx '\.\\"  *Index:  *index.ind' \
    || wail "check for index file name failed"

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
