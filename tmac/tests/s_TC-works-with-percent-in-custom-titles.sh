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

# Regression-test Savannah #59345.
#
# Ensure that .TC succeeds in assigning the 'i' format to the page
# number register when '%' is used in a custom header or footer.

EXAMPLE=\
'.OH ##%##
.NH 1
Foo
.XS
Foo
.XE
.LP
Bar.
.TC
'

OUTPUT=$(echo "$EXAMPLE" | "$groff" -Tascii -P-cbou -ms)
# Strip blank lines from the output first; all we care about for this
# test is the presence, adjacency, and ordering of non-blank lines.
FILTERED_OUTPUT=$(echo "$OUTPUT" \
    | sed '/^$/d' \
    | sed -n '/i/{
N;/Table of Contents/{
N;/Foo[. ][. ]*1/p;
};
}')
test -n "$FILTERED_OUTPUT"

# vim:set ai et sw=4 ts=4 tw=72:
