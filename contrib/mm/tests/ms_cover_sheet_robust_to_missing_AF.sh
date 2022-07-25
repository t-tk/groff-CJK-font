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

# Regression-test Savannah #60915.
#
# Ensure that a missing firm definition doesn't disrupt cover sheet
# layout.

EXAMPLE='.COVER
.ND 2020-07-17
.TL
The Great American Novel
.AU "Eileen M. Plausible"
.COVEND'

echo "$EXAMPLE" \
    | "$groff" -Tascii -P-cbou -mm \
    | grep -Fqx '       2020-07-17' # 7 spaces

# vim:set ai et sw=4 ts=4 tw=72:
