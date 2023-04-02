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

fail=

wail () {
    echo ...FAILED >&2
    fail=YES
}

# Regression-test Savannah #61878.
#
# A boxed, unkept table that overruns the page bottom will produce ugly
# output; it looks especially bizarre in nroff mode.
#
# We set the page length to 2v to force a problem (any boxed table in
# nroff mode needs 3 vees minimum), and put a page break at the start to
# catch an incorrectly initialized starting page number for the table.

input='.pl 2v
.bp
.TS
box nokeep;
L.
Z
.TE'

output=$(printf "%s" "$input" | "$groff" -t -Tascii 2>/dev/null)
error=$(printf "%s" "$input" | "$groff" -t -Tascii 2>&1 >/dev/null)
echo "$output"

echo "checking that a diagnostic message is produced"
echo "$error" | grep -q 'warning: boxed.*page 2$' || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
