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
  echo ...FAILED >&2
  fail=yes
}

input='.pl 3v
.de bomb
.tm Boom!
..
.nf
.wh 1v bomb
.ptr
.tm A: .trap=\n[.trap]
foo nl=\n[nl]u
.tm B: .trap=\n[.trap]
bar nl=\n[nl]u'

error=$(printf "%s\n" "$input" | "$groff" -T ascii 2>&1 > /dev/null)
echo "$error"

echo "checking operation of .trap register prior to trap"
echo "$error" | grep -Fqx 'A: .trap=bomb' || wail

echo "checking operation of .trap register when no traps remain"
echo "$error" | grep -Fqx 'B: .trap=' || wail

input='.de XX
.tm SNAP!
..
.di DD
.dt 1v XX
.tm A: .trap=\n[.trap]
.nf
foo
.tm B: .trap=\n[.trap]
.di'

error=$(printf "%s\n" "$input" | "$groff" -T ascii 2>&1 > /dev/null)
echo "$error"

echo "checking operation of .trap in diversion, prior to trap"
echo "$error" | grep -Fqx 'A: .trap=XX' || wail

echo "checking operation of .trap in diversion, after trap"
echo "$error" | grep -Fqx 'B: .trap=' || wail

test -z "$FAIL"
