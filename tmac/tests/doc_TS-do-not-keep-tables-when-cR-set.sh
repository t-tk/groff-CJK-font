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

# Regression-test Savannah #57665, but for mdoc(7).
#
# The interior of this text is fragile with respect to line count.

input='.Dd 2023-04-22
.Dt ts\-hell 1
.Os "groff test suite"
.Sh Name
.Nm ts\-hell
.Nd turn off tbl keeps when continuous rendering
.Sh Description
A long table should not get spurious blank lines inserted into it when
continuously rendering.
.
This arises from
.Xr tbl 1
using \[lq]keeps\[rq].
.
We do not need those when
.Ql cR
is set.
.
.TS
L.
'$(n=1; while [ $n -le 66 ]; do echo $n; n=$(( n + 1 )); done)'
.TE'

output=$(printf "%s\n" "$input" | "$groff" -Tascii -P-cbou -t -mdoc)
echo "$output"
test -z "$(echo "$output" | sed -n '/^  *1$/,/^  *66$/s/^ *$/FNORD/p')"

# vim:set ai et sw=4 ts=4 tw=72:
