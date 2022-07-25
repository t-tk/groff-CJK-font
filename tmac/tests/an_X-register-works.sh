#!/bin/sh
#
# Copyright (C) 2020-2021 Free Software Foundation, Inc.
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

# Ensure the X register takes effect on the right page and looks right.

INPUT='.TH foo 1 2021-05-19 "groff foo test suite"
.TH bar 1 2021-05-19 "groff bar test suite"'

FAIL=

OUTPUT=$(printf "%s\n" "$INPUT" \
    | "$groff" -Tascii -P-cbou -rcR=0 -rC1 -rX1 -man)

if ! echo "$OUTPUT" | grep -Eqx 'groff foo test suite +2021-05-19 +1'
then
    FAIL=yes
    echo "first page footer test failed" >&2
fi

if ! echo "$OUTPUT" | grep -Eqx 'groff bar test suite +2021-05-19 +1a'
then
    FAIL=yes
    echo "second page footer test failed" >&2
fi

INPUT='.TH baz 1 2021-05-19 "groff baz test suite"
.SH Name
baz \- neglect third stepchild
.SH Description
This program is the lowly third in line.'

OUTPUT=$(printf "%s\n" "$INPUT" \
    | "$groff" -Thtml -rcR=0 -rC1 -rX1 -man)

if echo "$OUTPUT" | grep -q 'groff baz test suite'
then
    FAIL=yes
    echo "HTML output unexpectedly contains footer text" >&2
fi

test -z "$FAIL"

# vim:set ai et sw=4 ts=4 tw=72:
