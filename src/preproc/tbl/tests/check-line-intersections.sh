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
    fail=yes
}

input='.TS
allbox tab(@);
L L L.
a@b@c
d@e@f
g@h@i
.TE
'

output=$(printf "%s" "$input" | "$groff" -Tascii -t)

for l in 1 3 5 7
do
    echo "checking intersections on line $l"
    echo "$output" | sed -n ${l}p | grep -Fqx '+--+---+---+' || wail
done

# TODO: Check `-Tutf8` output for correct crossing glyph identities.

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
