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
    echo ...FAILED >&2
    fail=YES
}

# Regression-test Savannah #61909.
#
# Inter-sentence space should not be applied to the content of ordinary
# table entries.  They are set "rigidly" (tbl(1)), also without filling,
# adjustment, hyphenation or breaking.  If you want those things, use a
# text block.

input='.ss 12 120
Before one.
Before two.
.TS
L.
.\" two spaces
Foo.  Bar.
.\" four spaces
Baz.    Qux.
.\" two spaces
T{
Ack.  Nak.
T}
.TE
After one.
After two.
'

output=$(printf "%s\n" "$input" | "$groff" -Tascii -P-cbou -t)
echo "$output"

echo "checking that inter-sentence space is altered too early"
echo "$output" \
    | grep -Fqx 'Before one.           Before two.' || wail # 11 spaces

echo "checking that inter-sentence space is not applied to ordinary" \
    "table entries (1)"
echo "$output" | grep -Fqx 'Foo.  Bar.' || wail # 2 spaces

echo "checking that inter-sentence space is not applied to ordinary" \
    "table entries (2)"
echo "$output" | grep -Fqx 'Baz.    Qux.' || wail # 4 spaces

echo "checking that inter-sentence space is applied to text blocks"
echo "$output" | grep -Fqx 'Ack.           Nak.' || wail # 11 spaces

echo "checking that inter-sentence space is restored after table"
echo "$output" \
    | grep -Fqx 'After one.           After two.' || wail # 11 spaces

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
