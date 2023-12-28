#!/bin/sh
#
# Copyright (C) 2021 Free Software Foundation, Inc.
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

groff="${abs_top_builddir:-.}/test-groff"

set -e

# Regression-test Savannah #60025.
#
# Ensure .Mt renders correctly.

input='.Dd 2021-02-10
.Dt foo 1
.Os groff test suite
.Sh Name
.Nm foo
.Nd frobnicate a bar
.Sh Authors
.An -nosplit
The
.Nm mandoc
utility was written by
.An Kristaps Dzonsons Aq Mt kristaps@bsd.lv
and is maintained by
.An Ingo Schwarze Aq Mt schwarze@openbsd.org .'

output=$(echo "$input" | "$groff" -Tascii -P-cbou -mdoc)
echo "$output"

echo "$output" \
    | grep -Fq 'written by Kristaps Dzonsons <kristaps@bsd.lv>'

echo "$output" \
    | grep -Fq 'is maintained by Ingo Schwarze <schwarze@openbsd.org>.'

# vim:set ai et sw=4 ts=4 tw=72:
