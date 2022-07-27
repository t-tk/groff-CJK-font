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

# Page lengths that are too short cause loss of header/footer text and
# infinite trap recursion in extreme cases.
#
# As of the time of this writing, bad behavior (a superfluous page
# break) sets in at 14v, and we start to lose headers/footers at a
# length of 13v.  Get down to 7v and the traps infinitely recurse.

input='.pl 7v
.ds CF footer
.P1 \" ensure header on page 1
.LP
foobar
'

fail=

wail () {
    echo "...FAILED" >&2
    fail=YES
}

output=$(printf '%s\n' "$input" | "$groff" -Tascii -P-cbou -ms 2>&1)
status=$?

echo "checking for nonzero exit status" >&2
test $status -ne 0 || wail

# grepping diagnostic messages is a tar pit.  I hope I don't come to
# regret this.

echo "checking for lack of diagnostic about infinite loop" >&2
echo "$output" | grep -q 'troff.*fatal.*infinite' && wail

echo "checking for diagnostic about page length" >&2
echo "$output" | grep -q 's\.tmac.*page length' || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
