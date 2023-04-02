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

input='.TH foo 1 2022-12-04 "groff test suite"
.SH Name
foo \- frobnicate a bar
.SH Authors
.I foo
was written by
.MT jp@\:example\:.com
J.\& Ponderous
.ME (deceased).'

output=$(printf "%s\n" "$input" | "$groff" -rU0 -man -Tascii -P-cbou)
echo "$output"
echo "checking that trailing text hugs link URI (-rU0)"
echo "$output" | grep -q '\.com>(deceased)\.$' || wail

output=$(printf "%s\n" "$input" | "$groff" -rU1 -man -Tascii -P-cbou)
echo "$output" | od -c
echo "checking that trailing text hugs link text (-rU1)"
echo "$output" | grep -q 'Ponderous(deceased).$' || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
