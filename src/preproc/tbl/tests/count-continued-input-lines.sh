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

set -e

# Regression-test Savannah #62191.
#
# Line continuation in a row of table data should not make the input
# line counter inaccurate.

input='.this-is-line-1
.TS
L.
foo\
bar\
baz\
qux
.TE
.this-is-line-9'

output=$(printf "%s\n" "$input" | "$groff" -Tascii -t -ww -z 2>&1)
echo "$output" | grep -q '^troff.*:9:.*this-is-line-9'

# vim:set ai et sw=4 ts=4 tw=72:
