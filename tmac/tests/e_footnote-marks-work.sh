#!/bin/sh
#
# Copyright (C) 2021 Free Software Foundation, Inc.
#
# This file is part of groff.
#
# groff is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your
# option) any later version.
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

set -e

# Ensure that footnote marks increment as they should.

input='.pp
Jackdaws*
.(f
* foo
.)f
love my big\**
.(f
\** bar
.)f
sphinx**
.(f
** baz
.)f
of quartz.\**
.(f
\** qux
.)f
.+c
.pp
Pack my box with five dozen liquor jugs.\**
.(f
\** ogg
.)f'

output=$(echo "$input" | "$groff" -Tascii -P-cbou -me)

echo "$output" \
    | grep -F 'Jackdaws* love my big[1] sphinx** of quartz.[2]'

echo "$output" \
    | grep -F '* foo'

echo "$output" \
    | grep -F '[1] bar'

echo "$output" \
    | grep -F '** baz'

echo "$output" \
    | grep -F '[2] qux'

echo "$output" \
    | grep -F 'Pack my box with five dozen liquor jugs.[1]'

echo "$output" \
    | grep -F '[1] ogg'

# vim:set ai et sw=4 ts=4 tw=72:
