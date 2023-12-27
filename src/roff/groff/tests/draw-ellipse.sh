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

expected_line_1='t *A'
expected_line_2='D *e *10000  *24000'
expected_line_3='t *B'

actual=$(printf 'A\\D@e 1 2@B\n' | "$groff" -Tps -Z)
echo "$actual"
# '/^t *A/{p;n;/^D *e/{p;n;/^t *B/p;}}'
actual=$(echo "$actual" \
    | sed -n -e '/^t *A/{' -e 'p;n;/^D *e/{' -e 'p;n;/^t *B/p;' -e '}' \
             -e '}')

fail=

echo "$actual" | sed -n '1p' | grep "$expected_line_1" || fail=yes
echo "$actual" | sed -n '2p' | grep "$expected_line_2" || fail=yes
echo "$actual" | sed -n '3p' | grep "$expected_line_3" || fail=yes

test -z "$fail"
