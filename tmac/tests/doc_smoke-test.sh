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
    fail=yes
}

# Regression-test Savannah #51003.
#
# Ensure we can render mdoc man pages from a build tree.

input='.Dd August 25, 2020
.Dt mdoc\-test 7
.Os
.Sh Name
.Nm mdoc\-test
.Nd a smoke test for groff'"'"'s mdoc implementation
.Sh Description
If you can read this without a hailstorm of warnings,
things are probably working.'

output=$(printf "%s\n" "$input" | "$groff" -Tascii -P-cbou -mdoc)
echo "$output"
fail=

echo "checking header for correct content" >&2
echo "$output" | grep -qE '^mdoc-test\(7\) +Miscellaneous' || wail

echo "checking for section heading \"Name\"" >&2
echo "$output" | grep -qE '^Name$' || wail

echo "checking for section heading \"Description\"" >&2
echo "$output" | grep -qE '^Description$' || wail

echo "checking paragraph body for correct content" >&2
echo "$output" | grep -qE 'you can read this' || wail

echo "checking footer for correct content" >&2
echo "$output" | grep -qE '^GNU +August 25, 2020 +mdoc-test\(7\)' \
    || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
