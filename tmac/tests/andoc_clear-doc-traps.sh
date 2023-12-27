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

fail=

wail () {
    echo ...FAILED >&2
    fail=YES
}

# Regression-test Savannah #59246.
#
# andoc should remove mdoc(7) traps before rendering a man(7) page.
# Continuous rendering has to be _off_ to catch this.
#
# We also deliberately omit a fourth argument to the man(7) TH call to
# sniff out a stale footer component from mdoc(7).

input='.Dd October 11, 2020
.Dt mdoc\-test 7
.Os
.Sh Name
.Nm mdoc\-test
.Nd lay mine
.Sh Description
Just testing.
.TH man\-test 7 2020-10-12
.SH Name
man-test \- drive sheep across minefield
.SH Description
\[lq]doc\-footer\[rq] should definitely not be sprung by this document.'

output=$(printf "%s\n" "$input" \
    | "$groff" -Tascii -P-cbou -rC1 -rcR=0 -mandoc)
echo "$output"

echo 'checking for correct mdoc(7) footer on first document' >&2
echo "$output" | grep -Eqx 'GNU +October 11, 2020 +1' || wail

echo 'checking for correct man(7) footer on second document' >&2
echo "$output" | grep -Eqx ' +2020-10-12 +2' || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
