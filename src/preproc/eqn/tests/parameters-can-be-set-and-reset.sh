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
    echo "$error"
    fail=yes
}

input='.EQ
a b + c
.EN
.br
.EQ
set medium_space 100
d e + f
.EN
.br
.EQ
reset medium_space
g h + i
.EN'

output=$(printf "%s\n" "$input" | "$groff" -e -T ascii -P -cbou)
echo "$output"

echo "checking that 'medium_space' is alterable" >&2
echo "$output" | grep -Fqx 'de + f' || wail

echo "checking that 'medium_space' can be reset to default" >&2
echo "$output" | grep -Fqx 'gh+i' || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
