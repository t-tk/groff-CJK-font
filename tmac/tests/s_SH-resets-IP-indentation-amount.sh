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

# Regression-test Savannah #60222.
#
# SH should reset IP indentation amount as other paragraphing macros do.

EXAMPLE=\
'.IP @ 3n
3n indentation
.SH
Section heading
.IP
default indentation
'

echo "$EXAMPLE" \
    | "$groff" -Tascii -P-cbou -ms \
    | grep -qx '     default indentation' # 5 spaces

# vim:set ai et sw=4 ts=4 tw=72:
