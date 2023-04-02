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
    echo ...FAILED >&2
    fail=YES
}

# Regression-test Savannah #60140.
#
# Line numbering needs to be suspended within a table and restored
# afterward.  Historical implementations handled line numbering in
# tables badly when text blocks were used.

input='.nm 1
Here is a line of output.
Sic transit adispicing meatballs.
We pad it out with more content to ensure that the line breaks.
.TS
L.
This is my table.
There are many like it but this one is mine.
T{
Ut enim ad minima veniam,
quis nostrum exercitationem ullam corporis suscipitlaboriosam,
nisi ut aliquid ex ea commodi consequatur?
T}
.TE
What is the line number now?'

output=$(printf "%s\n" "$input" | "$groff" -Tascii -P-cbou -t)
echo "$output"

echo "testing that line numbering is suppressed in table" >&2
echo "$output" | grep -Fqx 'This is my table.' || wail

echo "testing that line numbering is restored after table" >&2
echo "$output" | grep -Eq '3 +What is the line number now\?' || wail

input='.nf
.nm 1
test of line numbering suppression
five
four
.nn 3
three
.TS
L.
I am a table.
I have two rows.
.TE
two
one
numbering returns here'

output=$(printf "%s\n" "$input" | "$groff" -Tascii -P-cbou -t)
echo "$output"

echo "testing that suppressed numbering is restored correctly" >&2
echo "$output" | grep -Eq '4 +numbering returns here' || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
