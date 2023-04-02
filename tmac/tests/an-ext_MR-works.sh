#!/bin/sh
#
# Copyright (C) 2022 Free Software Foundation, Inc.
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

fail=

wail () {
    echo ...FAILED >&2
    fail=YES
}

input='.TH foo 1 2021-10-06 "groff test suite"
.SH Name
.ec @
foo @- a command with a very short name
.ec
.SH Description
The real work is done by
.MR bar 1 .'

output=$(echo "$input" | "$groff" -rmG=0 -Tascii -man -Z | nl)
echo "$output"

# Expected:
#   88  wf2
#   89  h24
#   90  tbar
#   91  f1
#   92  t(1).

echo "checking for correct man page topic font style" >&2
echo "$output" | grep -Eq '88[[:space:]]+wf2' || wail
echo "$output" | grep -Eq '90[[:space:]]+tbar' || wail
echo "checking for correct man page section font style" >&2
echo "$output" | grep -Eq '91[[:space:]]+f1' || wail
echo "$output" | grep -Eq '92[[:space:]]+t\(1\)' || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
