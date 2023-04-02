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
    fail=YES
}

input='.Dd 2022-12-11
.Dt foo 1
.Os "groff test suite"
.Sh Name
.Nm foo
.Nd frobnicate a bar
.bp
.Sh Description
It took a while to get here.'

output=$(printf "%s\n" "$input" | "$groff" -rcR=0 -rP13 -mdoc -Tascii \
    -P-cbou)
echo "$output"

echo "checking first page footer" >&2
echo "$output" | grep -En "^groff test suite +2022-12-11 +13$" \
    | grep '^64:' || wail

echo "checking second page footer" >&2
echo "$output" | grep -En "^groff test suite +2022-12-11 +14$" \
    | grep '^130:' || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
