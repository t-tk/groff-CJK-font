#!/bin/sh
#
# Copyright (C) 2023 Free Software Foundation, Inc.
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

input='.TH foo 1 2023-01-08 "groff test suite"
.SH Name
foo \- frobinicate a bar
.SH Synopsis
.SY foo
.YS
.SH Description
Now is the time for all good citizens to disestablish
antidisestablishmentarianism.'

output=$(printf "%s\n" "$input" | "$groff" -man -Tascii -P-cbou)
echo "$output"

echo "checking hyphenation when HY is default" >&2
echo "$output" | grep -q "antidisestablish-$" || wail

output=$(printf "%s\n" "$input" | "$groff" -rHY=0 -man -Tascii -P-cbou)
echo "$output"

echo "checking hyphenation when HY is 0" >&2
echo "$output" | grep -Eq "to +disestablish$" || wail

input='.TH foo 1 2023-01-08 "groff test suite"
.SH Name
foo \- frobinicate a bar
.SH Synopsis
.SY foo
.SY foo
.I arbitrary-argument
.YS
.SH Description
Now is the time for all good citizens to disestablish
antidisestablishmentarianism.'

output=$(printf "%s\n" "$input" | "$groff" -man -Tascii -P-cbou)
echo "$output"

echo "checking hyphenation when HY is default and .SY nested" >&2
echo "$output" | grep -q "antidisestablish-$" || wail

output=$(printf "%s\n" "$input" | "$groff" -rHY=0 -man -Tascii -P-cbou)
echo "$output"

echo "checking hyphenation when HY is 0 and .SY nested" >&2
echo "$output" | grep -Eq "to +disestablish$" || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
