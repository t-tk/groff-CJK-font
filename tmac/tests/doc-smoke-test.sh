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

# Regression-test Savannah #51003.
#
# Ensure we can render mdoc man pages from a build tree.

EXAMPLE='\
.Dd August 25, 2020
.Dt mdoc\-test 7
.Os
.Sh Name
.Nm mdoc\-test
.Nd a smoke test for groff'"'"'s mdoc implementation
.Sh Description
If you can read this without a hailstorm of warnings,
things are probably working.'

OUTPUT=$(printf "%s\n" "$EXAMPLE" | "$groff" -Tascii -P-cbou -mdoc)
FAIL=

if ! echo "$OUTPUT" | grep -qE '^mdoc-test\(7\) +BSD Miscellaneous'
then
    FAIL=yes
    echo "header check failed" >&2
fi

if ! echo "$OUTPUT" | grep -qE '^Name$'
then
    FAIL=yes
    echo "\"Name\" section heading missing" >&2
fi

if ! echo "$OUTPUT" | grep -qE '^Description$'
then
    FAIL=yes
    echo "\"Description\" section heading missing" >&2
fi

if ! echo "$OUTPUT" | grep -qE 'you can read this'
then
    FAIL=yes
    echo "paragraph body check failed" >&2
fi

if ! echo "$OUTPUT" | grep -qE '^BSD +August 25, 2020'
then
    FAIL=yes
    echo "footer check failed" >&2
fi

test -z "$FAIL"

# vim:set ai et sw=4 ts=4 tw=72:
