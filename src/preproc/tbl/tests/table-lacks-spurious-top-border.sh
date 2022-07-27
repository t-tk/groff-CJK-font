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
    echo "$output"
    fail=yes
}

# GNU tbl draws vertical lines 1v taller than they need to be on nroff
# devices to enable them to cross a potential horizontal line in the
# table.  This can lead to a spurious top border.

input='.ll 12n
.TS
| L |.
_
1234567890
.TE
.pl \n(nlu
'

echo "checking height of table with plain vertical rules" >&2
output=$(printf "%s" "$input" | "$groff" -Tascii -t)
lines=$(echo "$output" | wc -l)
test $lines -eq 1 || wail

echo "checking content of table with plain vertical rules" >&2
output=$(printf "%s" "$input" | "$groff" -Tascii -t)
# If we fix the horizontal width issue (Savannah #62471), take out " ?".
echo "$output" | sed -n '1p' | grep -Eqx -- '\|1234567890 ?\|' || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
