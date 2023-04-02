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

input='.TH foo 1 2022-12-11 "groff test suite"
.SH Name
foo \- frobinicate a bar
.Dd 2022-12-11
.Dt bar 1
.Os "groff test suite"
.Sh Name
.Nm bar
.Nd erect a thing to be walked into'

output=$(printf "%s\n" "$input" | "$groff" -mandoc -Tascii -P-cbou)
echo "$output"

echo "checking for one foo(1) header" >&2
test $(echo "$output" \
         | grep -Ec "foo\(1\) +General Commands Manual +foo\(1\)") \
    -eq 1 || fail

echo "checking for one foo(1) footer" >&2
test $(echo "$output" \
         | grep -Ec "groff test suite +2022-12-11 +foo\(1\)") -eq 1 \
    || fail

echo "checking for one bar(1) header" >&2
test $(echo "$output" \
         | grep -Ec "bar\(1\) +General Commands Manual +bar\(1\)") \
    -eq 1 || fail

echo "checking for one bar(1) barter" >&2
test $(echo "$output" \
         | grep -Ec "groff test suite +2022-12-11 +bar\(1\)") -eq 1 \
    || fail

echo "checking for uninitialized header and footer fields"
echo "$output" | grep -E "(UNTITLED|UNDATED|LOCAL)" && fail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
