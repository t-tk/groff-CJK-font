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

# Test going back and forth from man(7) to mdoc(7).

input='.TH foo 1 2022-12-11 "groff test suite"
.SH Name
foo \- frobinicate a bar
.bp
.SH Description
It took a while to get here.
.Dd 2022-12-11
.Dt bar 1
.Os "groff test suite"
.Sh Name
.Nm bar
.Nd erect something for people to walk into
.bp
.Sh Description
It took a while to get here.
.TH baz 7 2022-12-11 "groff test suite"
.SH Name
baz \- what they do not play at Mos Eisley spaceport cantina
.bp
.SH Description
It took a while to get here.'

# First, check without continuous numbering.  Each page starts at P.

output=$(printf "%s\n" "$input" | "$groff" -rcR=0 -rP13 -mandoc \
    -Tascii -P-cbou)
echo "$output"

echo "checking first document, first page footer (discontinuous)" >&2
echo "$output" | grep -En "^groff test suite +2022-12-11 +13$" \
    | grep '^63:' || wail

echo "checking first document, second page footer (discontinuous)" >&2
echo "$output" | grep -En "^groff test suite +2022-12-11 +14$" \
    | grep '^129:' || wail

echo "checking second document, first page footer (discontinuous)" >&2
echo "$output" | grep -En "^groff test suite +2022-12-11 +13$" \
    | grep '^195:' || wail

echo "checking second document, second page footer (discontinuous)" >&2
echo "$output" | grep -En "^groff test suite +2022-12-11 +14$" \
    | grep '^261:' || wail

echo "checking third document, first page footer (discontinuous)" >&2
echo "$output" | grep -En "^groff test suite +2022-12-11 +13$" \
    | grep '^327:' || wail

echo "checking third document, second page footer (discontinuous)" >&2
echo "$output" | grep -En "^groff test suite +2022-12-11 +14$" \
    | grep '^393:' || wail

# Now, check _with_ continuous numbering.  Only the first page is
# numbered P.

output=$(printf "%s\n" "$input" | "$groff" -rcR=0 -rC1 -rP13 -mandoc \
    -Tascii -P-cbou)
echo "$output"

echo "checking first document, first page footer (continuous)" >&2
echo "$output" | grep -En "^groff test suite +2022-12-11 +13$" \
    | grep '^63:' || wail

echo "checking first document, second page footer (continuous)" >&2
echo "$output" | grep -En "^groff test suite +2022-12-11 +14$" \
    | grep '^129:' || wail

echo "checking second document, first page footer (continuous)" >&2
echo "$output" | grep -En "^groff test suite +2022-12-11 +15$" \
    | grep '^195:' || wail

echo "checking second document, second page footer (continuous)" >&2
echo "$output" | grep -En "^groff test suite +2022-12-11 +16$" \
    | grep '^261:' || wail

echo "checking third document, first page footer (continuous)" >&2
echo "$output" | grep -En "^groff test suite +2022-12-11 +17$" \
    | grep '^327:' || wail

echo "checking third document, second page footer (continuous)" >&2
echo "$output" | grep -En "^groff test suite +2022-12-11 +18$" \
    | grep '^393:' || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
