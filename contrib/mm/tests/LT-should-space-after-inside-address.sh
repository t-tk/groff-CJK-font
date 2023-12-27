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

# Regression-test Savannah #63695.
#
# One vertical line of space should follow the letter header.

input='.ND "17 May 2023"
.WA "Epi G. Netic" "Head of Research"
123 Main Street
Anytown, ST  10101
.WE
.IA "Rufus T. Arbogast" "Guru"
456 Elsewhere Avenue
Nirvana, PA  20406
.IE
.LT
.P
We have a research leak!
.FC
.SG
.NS
sundry careless people
.NE'

output=$(echo "$input" | "$groff" -mm -Tascii -P-cbou)
echo "$output"
echo "$output" \
    | sed -n -e '/.*Nirvana/{' -e 'n;/^$/{' -e 'n;p;' -e '}' -e '}' \
    | grep -q leak

# vim:set ai et sw=4 ts=4 tw=72:
