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

# Verify that the EC fonts get loaded by using their Euro and per mille
# glyphs (which aren't in the CM fonts) to detect them.
input='.ec @
.de EM
.  ft @@$1
.  nop @[Eu] @[%0]
..
.nf
.EM TR
.EM TI
.EM TB
.EM TBI
.EM HR
.EM HI
.EM HB
.EM HBI
.EM CW
.EM CWI'

output=$(printf "%s\n" "$input" | "$groff" -mec -Tdvi -z 2>&1)
test -z "$output"

# vim:set ai et sw=4 ts=4 tw=72:
