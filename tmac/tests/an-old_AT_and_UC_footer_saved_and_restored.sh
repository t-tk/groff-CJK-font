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
# groff is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

groff="${abs_top_builddir:-.}/test-groff"

# Regression-test Savannah #57416.
#
# The (deprecated) macros .AT and .UC, intended only for rendering of
# legacy man pages, alter strings used in man page footers.  Verify that
# they modify and restore these strings correctly.

EXAMPLE_ATT_PAGE='.TH att 1 2020-01-16 "groff test suite"
.AT
.SH Name
att \- aim Death Star at planet'

EXAMPLE_FSF_PAGE='.TH fsf 1 2020-01-16 "groff test suite"
.SH Name
fsf \- liberate laser printer firmware'

EXAMPLE_WFJ_PAGE='.TH wfj 1 2020-01-16 "groff test suite"
.UC
.SH Name
wfj \- call 1-800-ITS-UNIX'

EXAMPLE_GNU_PAGE='.TH gnu 1 2020-01-16 "groff test suite"
.SH Name
gnu \- join us now and share the software'

EXAMPLE_UCB_PAGE='.TH ucb 1 2020-01-16 "groff test suite"
.UC 7
.SH Name
ucb \- blow up Death Star'

# We turn off continuous rendering (-rcR=0) so that the page footers are
# visible in nroff mode.  We turn on continuous numbering so we can tell
# that the footers are on the expected pages.

OUTPUT=$(printf "%s\n" \
    "$EXAMPLE_ATT_PAGE" \
    "$EXAMPLE_FSF_PAGE" \
    "$EXAMPLE_WFJ_PAGE" \
    "$EXAMPLE_GNU_PAGE" \
    "$EXAMPLE_UCB_PAGE" \
    "$EXAMPLE_GNU_PAGE" \
    | "$groff" -Tascii -P-cbou -man -rC1 -rcR=0)

FAIL=

if ! echo "$OUTPUT" | grep -qE '7th Edition +2020-01-16 +1'
then
    FAIL=yes
    echo "att (.AT) test failed" >&2
fi

if ! echo "$OUTPUT" | grep -qE 'groff test suite +2020-01-16 +2'
then
    FAIL=yes
    echo "FSF test failed" >&2
fi

if ! echo "$OUTPUT" | grep -qE '3rd Berkeley Distribution +2020-01-16 +3'
then
    FAIL=yes
    echo "WFJ (.UC) test failed" >&2
fi

if ! echo "$OUTPUT" | grep -qE 'groff test suite +2020-01-16 +4'
then
    FAIL=yes
    echo "1st GNU test failed" >&2
fi

if ! echo "$OUTPUT" | grep -qE '4.4 Berkeley Distribution +2020-01-16 +5'
then
    FAIL=yes
    echo "UCB (.UC) test failed" >&2
fi

if ! echo "$OUTPUT" | grep -qE 'groff test suite +2020-01-16 +6'
then
    FAIL=yes
    echo "2nd GNU test failed" >&2
fi

test -z "$FAIL"

# vim:set ai et sw=4 ts=4 tw=80:
