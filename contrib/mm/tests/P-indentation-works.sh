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

# Regression-test Savannah #54909.  Check other cases as well.

input='.P
P1 not indented.
.P 0
P2 not indented.
.P 1
P3 indented.
.nr Pt 2
.P
P4 indented.
.H 1 Heading
.P
P5 not indented.
.P
P6 indented.
.H 3 "Run-in heading."
Some text.
.P
P7 indented.
.DS
display
.DE
.P
P8 not indented.
.P
P9 indented.
.BL
.LI
list item
.LE
.P
P10 not indented.
.P
P11 indented.'

output=$(printf "%s\n" "$input" | "$groff" -mm -Tascii -P-cbou)
echo "$output"

#       P1 not indented.
#
#       P2 not indented.
#
#            P3 indented.
#
#            P4 indented.
#
#
#       1.  Heading
#
#       P5 not indented.
#
#            P6 indented.
#
#       1.0.1  Run-in heading.  Some text.
#
#            P7 indented.
#
#       display
#
#       P8 not indented.
#
#            P9 indented.
#
#          o list item
#
#       P10 not indented.
#
#            P11 indented.

echo "checking that initial untyped paragraph not indented" >&2
echo "$output" | grep -Eqx ' {7}P1 not indented\.' || wail

echo "checking that initial type 0 paragraph not indented" >&2
echo "$output" | grep -Eqx ' {7}P2 not indented\.' || wail

echo "checking that first paragraph after Pt=2 indented" >&2
echo "$output" | grep -Eqx ' {12}P3 indented\.' || wail

echo "checking that second paragraph after Pt=2 indented" >&2
echo "$output" | grep -Eqx ' {12}P4 indented\.' || wail

echo "checking that first paragraph after heading not indented" >&2
echo "$output" | grep -Eqx ' {7}P5 not indented\.' || wail

echo "checking that second paragraph after heading indented" >&2
echo "$output" | grep -Eqx ' {12}P6 indented\.' || wail

echo "checking that paragraph after run-in heading indented" >&2
echo "$output" | grep -Eqx ' {12}P7 indented\.' || wail

echo "checking that first paragraph after display not indented" >&2
echo "$output" | grep -Eqx ' {7}P8 not indented\.' || wail

echo "checking that second paragraph after display indented" >&2
echo "$output" | grep -Eqx ' {12}P9 indented\.' || wail

echo "checking that first paragraph after list not indented" >&2
echo "$output" | grep -Eqx ' {7}P10 not indented\.' || wail

echo "checking that second paragraph after list indented" >&2
echo "$output" | grep -Eqx ' {12}P11 indented\.' || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
