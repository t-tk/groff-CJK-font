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

groff="${abs_top_builddir:-.}/test-groff"

DOCUMENT=\
'.Dd 2020-11-17
.Dt sample 1
.Os "groff test suite"
.Sh Name
.Nm sample
.Nd test subject for groff
.bp
.Sh Description
This program does many things.'

# Regression-test Debian #919890.
#
# Put page numbers in the correct places when double-sided rendering.

echo "confirming page number on right on recto (odd-numbered) pages" >&2
echo "$DOCUMENT" | "$groff" -rcR=0 -rD1 -Tascii -P-cbou -mdoc \
    | grep -q '^groff test suite *2020-11-17 *1$' || exit 1

echo "confirming page number on left on verso (even-numbered) pages" >&2
echo "$DOCUMENT" | "$groff" -rcR=0 -rD1 -Tascii -P-cbou -mdoc \
    | grep -q '^2 *2020-11-17 *groff test suite$' || exit 1

# vim:set ai et sw=4 ts=4 tw=72:
