#!/bin/sh
#
# Copyright (C) 2022-2023 Free Software Foundation, Inc.
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

eqn="${abs_top_builddir:-.}/eqn"
groff="${abs_top_builddir:-.}/test-groff"
fail=

wail () {
    echo "...FAILED" >&2
    echo "$error"
    fail=yes
}

# Verify that correct input file line numbers are reported.

echo "checking for correct line number when no EQ/EN input" >&2
error=$(printf '.\n.tm FNORD:\\n(.c\n' \
    | "$eqn" -Tascii | "$groff" -Tascii -z 2>&1 > /dev/null)
echo "$error" | grep -qx FNORD:2 || wail

echo "checking for correct line number when EQ/EN input empty" >&2
error=$(printf '.\n.EQ\n.EN\n.tm FNORD:\\n(.c\n' \
    | "$eqn" -Tascii | "$groff" -Tascii -z 2>&1 > /dev/null)
echo "$error" | grep -qx FNORD:4 || wail

echo "checking for correct line number when EQ/EN input simple" >&2
error=$(printf '.\n.EQ\nx\n.EN\n.tm FNORD:\\n(.c\n' \
    | "$eqn" -Tascii | "$groff" -Tascii -z 2>&1 > /dev/null)
echo "$error" | grep -qx FNORD:5 || wail

echo "checking for absent line number in early EOF diagnostic" >&2
input='.EQ'
error=$(printf '%s\n' "$input" | "$eqn" 2>&1 > /dev/null)
echo "$error" | grep -Eq '^[^:]+:[^:]+: fatal' || wail

echo "checking for correct line number in nested 'EQ' diagnostic" >&2
input='.EQ
.EQ'
error=$(printf '%s\n' "$input" | "$eqn" 2>&1 > /dev/null)
echo "$error" | grep -Eq '^[^:]+:[^:]+:2: fatal' || wail

echo "checking for correct line number in invalid input character" \
    "diagnostic" >&2
error=$(printf '.EQ\nx\n.EN\n\200\n' | "$eqn" 2>&1 > /dev/null)
echo "$error" | grep -Eq '^[^:]+:[^:]+:4: error' || wail

echo "checking for correct line number in invalid input character" \
    "diagnostic when 'lf' request used beforehand" >&2
error=$(printf '.EQ\nx\n.EN\n.lf 99\n\200\n' | "$eqn" 2>&1 > /dev/null)
echo "$error" | grep -Eq '^[^:]+:[^:]+:99: error' || wail

echo "checking for correct line number when invalid 'lf' request used" \
    >&2
error=$(printf '.lf xyz\n.EQ\n.EQ\n' | "$eqn" 2>&1 > /dev/null)
echo "$error" | grep -Eq '^[^:]+:[^:]+:3: fatal error' || wail

echo "checking for correct line number when input begins with" \
    "delimited equation and '-N' not used" >&2
error=$(printf '$ x =\n' | "$eqn" -Tascii -d'$$' 2>&1 > /dev/null)
echo "$error" | grep -Eq '^[^:]+:[^:]+:1: fatal error' || wail

echo "checking for correct line number when input begins with" \
    "delimited equation and '-N' is used" >&2
error=$(printf '$ x =\n' | "$eqn" -Tascii -d'$$' -N 2>&1 > /dev/null)
echo "$error" | grep -Eq '^[^:]+:[^:]+:1: error' || wail

test -z "$fail"
exit

# tests for future use

echo "checking for correct line number when later input contains" \
    "delimited equation and '-N' not used" >&2
error=$(printf '.EQ\ndelim $$\n.EN\n$x =\n' \
    | "$eqn" -Tascii 2>&1 > /dev/null)
echo "$error" | grep -Eq '^[^:]+:[^:]+:4: fatal error' || wail

echo "checking for correct line number when later input contains" \
    "delimited equation and '-N' is used" >&2
error=$(printf '.EQ\ndelim $$\n.EN\n$x =\n' \
    | "$eqn" -Tascii 2>&1 > /dev/null)
echo "$error" | grep -Eq '^[^:]+:[^:]+:4: error' || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
