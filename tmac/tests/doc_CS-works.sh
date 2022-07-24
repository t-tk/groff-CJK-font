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
'.Dd 2020-10-31
.Dt sample 1
.Os
.Sh Name
.Nm sample
.Nd test subject for groff'

echo "testing -rCS=0" >&2
echo "$DOCUMENT" | "$groff" -rCS=0 -Tascii -P-cbou -mdoc \
	| grep -q Name || exit 1

echo "testing -rCS=1" >&2
echo "$DOCUMENT" | "$groff" -rCS=1 -Tascii -P-cbou -mdoc \
	| grep -q NAME || exit 1

echo "testing default (no -rCS argument)" >&2
echo "$DOCUMENT" | "$groff" -Tascii -P-cbou -mdoc \
	| grep -q Name || exit 1

# vim:set ai et sw=4 ts=4 tw=72:
