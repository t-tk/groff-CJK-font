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
    fail=yes
}

# Ensure the X register takes effect on the right page and looks right.

input='.Dd 2022-12-14
.Dt foo 1
.Os "groff foo test suite"
.Dd 2022-12-14
.Dt bar 1
.Os "groff bar test suite"'

output=$(printf "%s\n" "$input" \
    | "$groff" -Tascii -P-cbou -rcR=0 -rC1 -rX1 -mdoc)
echo "$output"

echo "checking first page footer" >&2
echo "$output" | grep -Eqx 'groff foo test suite +2022-12-14 +1' || wail

echo "checking second page footer" >&2
echo "$output" | grep -Eqx 'groff bar test suite +2022-12-14 +1a' \
    || wail

# XXX: mdoc output does not yet suppress headers and footers.
#
#input='.Dd 2022-12-14
#.Dt baz 1
#.Os "groff baz test suite"
#.Sh Name
#.Nm baz
#.Nd what you will not hear at the Mos Eisley spaceport cantina
#.Sh Description
#This program is a fifth wheel.'
#
#output=$(printf "%s\n" "$input" \
#    | "$groff" -Thtml -rcR=0 -rC1 -rX1 -mdoc)
#echo "$output"
#
#echo "checking for absence of footer text in HTML output" >&2
#echo "$OUTPUT" | grep -q 'groff baz test suite' || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
