#!/bin/sh
#
# Copyright (C) 2022 Free Software Foundation, Inc.
#
# This file is part of groff.
#
# groff is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# groff is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

set -e

preconv="${abs_top_builddir:-.}/preconv"

fail=

wail () {
    echo FAILED >&2
    fail=YES
}

# Scrape debugging output to see if we're skipping unseekable streams.
# This is fragile, but we don't want to lock the language of diagnostic
# messages (especially debugging ones).  If this test fails, check the
# text of the command's debugging output for a mismatch before
# investigating deeper problems.

echo "testing seekability of file operand '-'" >&2
output=$(printf '' | "$preconv" -d - 2>&1)
echo "$output" | grep -q "stream is not seekable" || wail

echo "testing seekability of standard input stream" >&2
output=$(printf '' | "$preconv" -d /dev/stdin 2>&1)
echo "$output" | grep -q "stream is not seekable" || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
