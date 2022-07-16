#!/bin/sh
#
# Copyright (C) 2020 Free Software Foundation, Inc.
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

# Regression-test Savannah #59246.
#
# andoc should remove mdoc(7) traps before rendering a man(7) page.
# Continuous rendering has to be _off_ to catch this.

EXAMPLE=\
'.Dd October 11, 2020
.Dt mdoc\-test 7
.Os
.Sh Name
.Nm mdoc\-test
.Nd lay mine
.Sh Description
Just testing.
.TH man\-test 7 2020-10-11
.SH Name
man-test \- drive sheep across minefield
.SH Description
\[lq]doc\-footer\[rq] should definitely not be sprung by this document.'

! printf "%s\n" "$EXAMPLE" \
    | "$groff" -Tascii -P-cbou -mandoc -rcR=0 \
    | grep -E '^BSD +October 11, 2020 +3$'

# vim:set ai et sw=4 ts=4 tw=72:
