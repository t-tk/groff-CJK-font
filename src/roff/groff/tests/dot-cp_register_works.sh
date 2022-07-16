#!/bin/sh
#
# Copyright (C) 2020 Free Software Foundation, Inc.
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

DOC='.pl 1v
A
.do if 1 \n[.cp] \" Get initial compatibility state (depends on -C).
B
.do if 1 \n[.cp] \" Did observing the state change it?
.cp 1
C
.do if 1 \n[.cp] \" Saved compatibility state should be 1 now.
.cp 0
D
.do if 1 \n[.cp] \" Verify 1->0 transition.
.cp 1
E
.do if 1 \n[.cp] \" Verify 0->1 transition.
.cp 0
F
.if !\n[.C] \n[.cp] \" Outside of .do context, should return -1.
'

set -e

printf "%s" "$DOC" | "$groff" -Tascii \
    | grep -x "A 0 B 0 C 1 D 0 E 1 F -1"

printf "%s" "$DOC" | "$groff" -C -Tascii \
    | grep -x "A 1 B 1 C 1 D 0 E 1 F -1"
