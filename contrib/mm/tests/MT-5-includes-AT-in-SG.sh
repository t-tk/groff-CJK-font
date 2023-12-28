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

# Regression-test Savannah #57034.
#
# Ensure that an author's title (if any) is written in the signature.
#
# Thanks to Ken Mandelberg for the reproducer.

EXAMPLE='.TL
Inquiry
.AU "John SMITH"
.AT "Director"
.MT 5
.P
sentence
.FC Sincerely,
.SG'

echo "$EXAMPLE" \
    | "$groff" -Tascii -P-cbou -mm \
    | grep -Eqx '[[:space:]]+Director[[:space:]]*'

# vim:set ai et sw=4 ts=4 tw=72:
