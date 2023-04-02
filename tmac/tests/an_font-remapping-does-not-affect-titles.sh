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
#

groff="${abs_top_builddir:-.}/test-groff"

# Regression-test Savannah #61279.
#
# If a SH or SS (sub)section heading was about to be output at the
# bottom of a page but wasn't because of the vertical space .ne-eded,
# we want to ensure that font remapping for the headings doesn't affect
# page footers and headers.

# Keep preconv from being run.
unset GROFF_ENCODING

input='.TH \\fIfoo\\fP 1 2021-10-04 "groff test suite"
.SH Name
foo \\- a command with a very short name
.sp 50v
.SH "\\fIgroff\\fP integration"
A complicated situation.'

output=$(echo "$input" | "$groff" -Tascii -man -rcR=0)
echo "$output"
output=$(echo "$input" | "$groff" -Tascii -man -rcR=0 -Z | nl)
echo "$output"

# Expected:
#   74  V2640
#   75  p2
#   76  x font 2 I
#   77  f2
#   78  s10
#   79  V160
#   80  H0
#   81  tfoo
#   82  x font 1 R
#   83  f1
#   84  t(1)

echo "$output" | grep -E '77[[:space:]]+f2'

# vim:set ai et sw=4 ts=4 tw=72:
