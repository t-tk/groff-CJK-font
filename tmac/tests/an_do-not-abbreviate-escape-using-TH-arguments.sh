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

groff="${abs_top_builddir:-.}/test-groff"

# Regression-test Savanah #62257.
#
# Do not attempt to abbreviate page titles or inner footers (the 4th
# argument to `TH` that contain non-trivial escape sequences.  See
# Savannah #62264 for why doing so is difficult.

fail=

wail () {
    echo "...FAILED" >&2
    fail=yes
}

input='.TH f\-b 1 2022-04-08 "Bletcherous Glorfinking Dungr'\
'\[u ad]ndel Hoppabotch Greebstank 2.21"'

# The u with dieresis will not be output on the 'ascii' device.
output=$(printf "%s\n" "$input" | "$groff" -Tascii -P-cbou -man)

echo "checking that title with escaped hyphen-minus is preserved" >&2
echo "$output" | grep -q '^f-b(1)' || wail

pattern='Bletcherous Glorfinking Dungrndel 2022-04-08 Greebstank 2.21'
pattern="$pattern            f-b(1)" # 12 spaces
echo "checking for insanely long 4th TH argument" >&2
echo "$output" | grep -Fqx "$pattern" || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
