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

# Regression-test Savannah #63194.  Use of '-man -mec -Tdvi' should not
# make the italic font unavailable in ordinary text.
#
# The per mille sign is available only in the EC fonts, so if we
# failed to switch them in, we'll get an undefined special character
# warning.

input=$(
  printf '.TH foo 1 2022-10-10 "groff test suite"\n';
  printf '.SH N\\['"'"'E]V \\f[BI]groff\\f[] \\fBGNU\\fP\n';
  printf 'foo \\- \\[%%0]\\fIgroff\n';
)

output=$(printf "%s\n" "$input" | "$groff" -man -mec -Tdvi -z 2>&1)
echo "$output"
test -z "$output"

# vim:set ai et sw=4 ts=4 tw=72:
