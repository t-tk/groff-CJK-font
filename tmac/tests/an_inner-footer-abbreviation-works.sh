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

# Regression-test Savannah #61386.
#
# Excessively long "extra2" arguments to 'TH' (we recommend using this
# for project name and version information) can overrun other parts of
# the titles, such as a date in the center footer.

FAIL=

INPUT='.TH foo 1 2021-10-26 "groff 1.23.0.rc1.1449-84949"
.SH Name
foo \- a command with a very short name'

echo 'testing long inner footer with sufficient space to set it' >&2
OUTPUT=$(echo "$INPUT" | "$groff" -Tascii -P-cbou -man)
PATTERN='groff 1\.23\.0\.rc1\.1449-84949 +2021-10-26 +foo\(1\)'

if ! echo "$OUTPUT" | grep -Eq "$PATTERN"
then
    FAIL=yes
    echo "...FAILED" >&2
fi

echo 'testing long inner footer with insufficient space to set it' >&2
OUTPUT=$(echo "$INPUT" | "$groff" -Tascii -P-cbou -man -rLL=60n)
PATTERN='groff 1\.23\.0\.rc1\.1449\.\.\. +2021-10-26 +foo\(1\)'

if ! echo "$OUTPUT" | grep -Eq "$PATTERN"
then
    FAIL=yes
    echo "...FAILED" >&2
fi

# Regression-test Savannah #61408.
#
# Don't spew diagnostics if the page doesn't supply a 3rd .TH argument.
echo 'testing for graceful behavior when TH has no 3rd argument' >&2
INPUT='.TH patch 1 "" GNU'
OUTPUT=$(echo "$INPUT" | "$groff" -Tascii -P-cbou -man -ww -z 2>&1)

if [ -n "$OUTPUT" ]
then
    FAIL=yes
    echo "...FAILED" >&2
fi

test -z "$FAIL"

# vim:set ai et sw=4 ts=4 tw=72:
