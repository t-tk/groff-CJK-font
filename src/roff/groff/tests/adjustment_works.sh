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

set -e

DOC='.pl 1v
.ll 9n
foo bar\p
.na
foo bar\p
.ad l
foo bar\p
.na
foo bar\p
.ad b
foo bar\p
.na
foo bar\p
.ad c
foo bar\p
.na
foo bar\p
.ad r
foo bar\p
.na
foo bar\p
.ad
foo bar\p
.ad b
.ad 100
foo bar\p'

OUTPUT=$(echo "$DOC" | "$groff" -Tascii)
B='foo   bar' # 3 spaces
L='foo bar' # left or off
C=' foo bar' # trailing space truncated
R='  foo bar' # 2 leading spaces

echo "verifying default adjustment mode 'b'" >&2
echo "$OUTPUT" | sed -n '1p' | grep -Fqx "$B"

echo "verifying that .na works" >&2
echo "$OUTPUT" | sed -n '2p' | grep -Fqx "$L"

echo "verifying adjustment mode 'l'" >&2
echo "$OUTPUT" | sed -n '3p' | grep -Fqx "$L"

echo "verifying that .na works after '.ad l'" >&2
echo "$OUTPUT" | sed -n '4p' | grep -Fqx "$L"

echo "verifying adjustment mode 'b'" >&2
echo "$OUTPUT" | sed -n '5p' | grep -Fqx "$B"

echo "verifying that .na works after '.ad b'" >&2
echo "$OUTPUT" | sed -n '6p' | grep -Fqx "$L"

echo "verifying adjustment mode 'c'" >&2
echo "$OUTPUT" | sed -n '7p' | grep -Fqx "$C"

echo "verifying that .na works after '.ad c'" >&2
echo "$OUTPUT" | sed -n '8p' | grep -Fqx "$L"

echo "verifying adjustment mode 'r'" >&2
echo "$OUTPUT" | sed -n '9p' | grep -Fqx "$R"

echo "verifying that .na works after '.ad r'" >&2
echo "$OUTPUT" | sed -n '10p' | grep -Fqx "$L"

echo "verifying that '.ad' restores previous adjustment mode" >&2
echo "$OUTPUT" | sed -n '11p' | grep -Fqx "$R"

echo "verifying that out-of-range adjustment mode 100 is ignored" >&2
echo "$OUTPUT" | sed -n '12p' | grep -Fqx "$B"
