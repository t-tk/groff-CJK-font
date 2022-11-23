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
  echo "...FAILED" >&2
  fail=yes
}

# Regression-test Savannah #63011.
#
# A handful of escape sequences bizarrely accept newlines as argument
# delimiters.  Don't throw diagnostics if they are used.

input="\A
ABC
D
.pl \n(nlu"

echo "checking that newline is accepted as delimiter to 'A' escape" >&2
error=$(printf "%s\n" "$input" | "$groff" -Tascii -ww -z 2>&1)
test -z "$error" || wail

echo "checking correct handling of newline delimiter to 'A' escape" >&2
output=$(printf "%s\n" "$input" | "$groff" -Tascii -ww)
test "$output" = "1 D" || wail

input=".sp
\b
ABC
D
.pl \n(nlu"

echo "checking that newline is accepted as delimiter to 'b' escape" >&2
error=$(printf "%s\n" "$input" | "$groff" -Tascii -ww -z 2>&1)
test -z "$error" || wail

echo "checking correct handling of newline delimiter to 'b' escape" >&2
output=$(printf "%s\n" "$input" | "$groff" -Tascii -ww)
echo "$output" | grep -Fqx "B D" || wail

input="\o
ABC
D
.pl \n(nlu"

echo "checking that newline is accepted as delimiter to 'o' escape" >&2
error=$(printf "%s\n" "$input" | "$groff" -Tascii -ww -z 2>&1)
test -z "$error" || wail

echo "checking correct handling of newline delimiter to 'o' escape" >&2
output=$(printf "%s\n" "$input" | "$groff" -Tascii -ww \
  | LC_ALL=C od -t c)
# 7 spaces between C and D.
printf "%s\n" "$output" \
  | grep -Eqx '0000000 +A +\\b +B +\\b +C       D +\\n' || wail

input="\w
ABC
D
.pl \n(nlu"

echo "checking that newline is accepted as delimiter to 'w' escape" >&2
error=$(printf "%s\n" "$input" | "$groff" -Tascii -ww -z 2>&1)
test -z "$error" || wail

echo "checking correct handling of newline delimiter to 'w' escape" >&2
output=$(printf "%s\n" "$input" | "$groff" -Tascii -ww)
test "$output" = "72 D" || wail

input="\X
tty: link http://example.com
D
.pl \n(nlu"

echo "checking that newline is accepted as delimiter to 'X' escape" >&2
error=$(printf "%s\n" "$input" | "$groff" -Tascii -ww -z 2>&1)
test -z "$error" || wail

echo "checking correct handling of newline delimiter to 'X' escape" >&2
output=$(printf "%s\n" "$input" | "$groff" -Tascii -ww -P -c)
test "$output" = ' D' || wail

input="\Z
ABC
D
.pl \n(nlu"

echo "checking that newline is accepted as delimiter to 'Z' escape" >&2
error=$(printf "%s\n" "$input" | "$groff" -Tascii -ww -z 2>&1)
test -z "$error" || wail

# This looks really weird but is consistent.  A newline used as a
# delimiter still gets interpreted as an input line ending.  What we see
# here is: 'ABC' is formatted, the drawing position is reset to the
# beginning of the line, a word space (from filling, overstriking 'A')
# goes on the output, followed by 'D', so it appears as 'ADC'.
#
# `printf '\\Z@ABC@\nD\n'` produces the same output.
echo "checking correct handling of newline delimiter to 'Z' escape" >&2
output=$(printf "%s\n" "$input" | "$groff" -Tascii -ww \
  | LC_ALL=C od -t c)
printf "%s\n" "$output" | grep -Eqx '0000000 +A +B +\\b +D +C +\\n' \
  || wail

test -z "$fail"

# vim:set autoindent expandtab shiftwidth=2 tabstop=2 textwidth=72:
