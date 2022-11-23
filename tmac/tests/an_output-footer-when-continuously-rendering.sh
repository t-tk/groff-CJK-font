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

# Ensure that the page footer is printed even when a pending output line
# is 1v from the page bottom.  (A page ejection inside an end of input
# trap exits the formatter.)

input='.TH foo 1 2022-11-02 "groff test suite"
.SH Name
foo \\- frobnicate a bar
.SH Description
.rs
.sp 60v
line 61
.br
line 62'

output=$(printf "%s\n" "$input" | "$groff" -Tascii -P-cbou -man)
echo "$output"
echo "$output" | grep -Eqx 'groff test suite +2022-11-02 +foo\(1\)'

# vim:set ai et sw=4 ts=4 tw=72:
