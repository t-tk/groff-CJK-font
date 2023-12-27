#!/bin/sh
#
# Copyright (C) 2020-2023 Free Software Foundation, Inc.
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

# Regression-test Savannah #57665.
#
# The interior of this text is fragile with respect to line count.

input='.TH ts\-hell 1 2020-10-09 "groff test suite"
.SH Name
ts\-hell \- turn off tbl keeps when continuous rendering
.SH Description
A long table should not get spurious blank lines inserted into it when
continuously rendering.
.
This arises from
.IR tbl (1)
using \[lq]keeps\[rq].
.
We do not need those when
.B cR
is set.
.
.TS
l.
'$(n=1; while [ $n -le 66 ]; do echo $n; n=$(( n + 1 )); done)'
.TE'

output=$(printf "%s\n" "$input" | "$groff" -Tascii -P-cbou -t -man)
echo "$output"
test -z "$(echo "$output" | sed -n '/^  *1$/,/^  *66$/s/^ *$/FNORD/p')"

# vim:set ai et sw=4 ts=4 tw=72:
