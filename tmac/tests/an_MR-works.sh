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

# Keep preconv from being run.
unset GROFF_ENCODING

INPUT='.TH foo 1 2021-10-06 "groff test suite"
.SH Name
foo \\- a command with a very short name
.SH Description
The real work is done by
.MR bar 1 .'

OUTPUT=$(echo "$INPUT" | "$groff" -Tascii -rU1 -man -Z | nl)
echo "$OUTPUT"

# Expected:
#   91  x X tty: link man:bar(1)
#   92  f2
#   93  tbar
#   94  f1
#   95  t(1)
#   96  V280
#   97  H912
#   98  x X tty: link

set -e
echo "checking for opening 'link' device control command" >&2
echo "$OUTPUT" | grep -Eq '91[[:space:]]+x X tty: link man:bar\(1\)$'
echo "checking for correct man page title font style" >&2
echo "$OUTPUT" | grep -Eq '92[[:space:]]+f2'
echo "$OUTPUT" | grep -Eq '93[[:space:]]+tbar'
echo "checking for correct man page section font style" >&2
echo "$OUTPUT" | grep -Eq '94[[:space:]]+f1'
echo "$OUTPUT" | grep -Eq '95[[:space:]]+t\(1\)'
echo "checking for closing 'link' device control command" >&2
echo "$OUTPUT" | grep -Eq '98[[:space:]]+x X tty: link$'

set +e

fail=

wail () {
    echo ...FAILED >&2
    fail=yes
}

output=$(echo "$INPUT" | "$groff" -man -Thtml)
echo "$output"

echo "checking for correctly formatted man URI in HTML output" >&2
echo "$output" | grep -Fq '<a href="man:bar(1)"><i>bar</i>(1)</a>.'

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
