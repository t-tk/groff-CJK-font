#!/bin/sh
#
# Copyright (C) 2020, 2022 Free Software Foundation, Inc.
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

input='.TH ue\-punct 1 2020-08-15 "groff test suite"
.SH Name
ue\-punct \- URL trailing material is subject to hyphenation
.SH Description
Do not try to
.UR https://www.gnu.org/software/groff/
hyphenate a ridiculous word* without machine assistance
.UE (*pneumonoultramicroscopicsilicovolcanoconiosis).'

# Turn off break warnings; we expect an adjustment problem.
echo "testing hyphenation of trailing text by an.tmac's UE macro"
output=$(printf "%s\n" "$input" | "$groff" -Tascii -Wbreak -P-cbou -man)
echo "$output"
echo "$output" | grep -qE 'pn.*-'

echo "testing hyphenation of trailing text by an-ext.tmac's UE macro"
output=$(printf "%s\n" "$input" \
    | "$groff" -rmG=0 -Tascii -Wbreak -P-cbou -man)
echo "$output"
echo "$output" | grep -qE 'pn.*-'

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
