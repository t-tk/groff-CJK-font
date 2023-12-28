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

# Regression-test Savannah #60373 (1/3).
#
# Ensure that a multi-word subject line (LO SJ) gets rendered.
#
# Thanks to Robert Goulding for the reproducer.

EXAMPLE='.LT SP
.WA "John Doe"
Nowhere,
USA.
.WE
.IA "Jane Smith"
Somewhere,
UK.
.IE
.LO SJ "Letter of Introduction"
.LO SA "Dear Ms.\& Smith"
.P
This is the text of the letter.
.FC "Yours sincerely,"
.SG'

echo "$EXAMPLE" \
    | "$groff" -Tascii -P-cbou -mm \
    | grep -Eqx '[[:space:]]+LETTER OF INTRODUCTION[[:space:]]*'

# vim:set ai et sw=4 ts=4 tw=72:
