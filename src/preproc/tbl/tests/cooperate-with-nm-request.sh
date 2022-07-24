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

set -e

# Regression-test Savannah #59812.
#
# A nonzero value of \n[ln] should not cause spurious numbering of table
# rows.

DOC='\
.nf
foo
.nm 1
bar
.nm
baz
.TS
l.
qux
.TE
'

OUTPUT=$(printf "%s" "$DOC" | "$groff" -Tascii -t)

echo "$OUTPUT" | grep -Fqx qux

# vim:set ai noet sw=4 ts=4 tw=72:
