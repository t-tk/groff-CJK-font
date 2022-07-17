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

# Regression-test Savannah #59016.
#
# Ensure that a partially-collected line at the end of a file gets
# flushed, and page footers written,  before proceeding to the next
# document.  Check going from man(7) to mdoc(7) documents and back.

EXAMPLE=\
'.TH man\-flush\-test 7 2020-10-11 "groff test page 1"
.SH Name
man\-flush-test \- a sanity test for groff_man(7)
.SH Description
This gratuitously loquacious sentence should end up with a
partially-collected output line.
.Dd October 11, 2020
.Dt mdoc\-test 7
.Os "groff test page 2"
.Sh Name
.Nm mdoc\-test
.Nd a sanity test for groff_mdoc(7)
.Sh Description
This additional gratuitously loquacious sentence should end up with a
partially-collected output line.
.TH man\-flush\-test2 7 2020-10-11 "groff test page 3"
.SH Name
man\-flush-test2 \- a second sanity test for groff_man(7)
.SH Description
This supernumerary loquacious sentence should end up with a
partially-collected output line.'

OUTPUT=$(printf "%s\n" "$EXAMPLE" | "$groff" -Tascii -P-cbou -man)

FAIL=

# Strip blank lines from the output first; all we care about for this
# test is the presence, adjacency, and ordering of non-blank lines.

if [ -z "$(echo "$OUTPUT" \
    | sed '/^$/d' \
    | sed -n '/collected/{N;/test page 1/p}')" ]
then
    FAIL=yes
    echo "man to mdoc transition failed" >&2
fi

if [ -z "$(echo "$OUTPUT" \
    | sed '/^$/d' \
    | sed -n '/partially-collected/{N;/test page 2/p}')" ]
then
    FAIL=yes
    echo "mdoc to man transition failed" >&2
fi

test -z "$FAIL"

# vim:set ai et sw=4 ts=4 tw=72:
