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

wail() {
    echo ...FAILED >&2
    fail=yes
}

input='.TH foo 1 2022-11-22 "groff test suite"
.SH Name
foo \- frobnicate a bar
.SH Description
Mail
.MT modok@\:example\:.com
the boss
.ME .
.
Complaints to
.MT nobody@\:example\:.com
.ME .'

output=$(printf "%s\n" "$input" \
    | "$groff" -rmG=0 -Tascii -P-cbou -man -rU0)
echo "$output"

echo "checking formatting of mail URI with link text" >&2
echo "$output" | grep -Fq 'Mail the boss <modok@example.com>.' || wail

echo "checking formatting of mail URI with no link text" >&2
echo "$output" | grep -Fq 'Complaints to <nobody@example.com>.' || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
