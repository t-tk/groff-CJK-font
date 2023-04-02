#!/bin/sh
#
# Copyright (C) 2022-2023 Free Software Foundation, Inc.
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
grotty="${abs_top_builddir:-.}/grotty"

fail=

wail () {
    echo ...FAILED >&2
    fail=YES
}

# Regression-test Savannah #63449.
#
# In nroff mode, a table at the top of the page (i.e., one starting at
# the first possible output line, with no vertical margin) that has
# vertical rules should not overdraw the page top and provoke a warning
# from grotty about "character(s) above [the] first line [being]
# discarded".

# Case 1: No horizontal rules; vertical rule at leading column.
input='.TS
| L.
foo
.TE'

tmp=$(printf "%s\n" "$input" | "$groff" -t -Z -Tascii -P-cbou)
output=$(printf "%s" "$tmp" | "$grotty" -F ./font 2>/dev/null)
error=$(printf "%s" "$tmp" | "$grotty" -F ./font 2>&1 >/dev/null)
echo "$output"

echo "checking that no diagnostic messages are produced by grotty (1)"
echo "$error" | grep -q 'grotty:' && wail

echo "checking that a lone vertical rule starts the first output line"
echo "$output" | sed -n '1p' | grep -Fqx '|' || wail

# Case 2: No horizontal rules; vertical rule between columns.
input='.TS
tab(@);
L | L.
foo@bar
.TE'

tmp=$(printf "%s\n" "$input" | "$groff" -t -Z -Tascii -P-cbou)
output=$(printf "%s" "$tmp" | "$grotty" -F ./font 2>/dev/null)
error=$(printf "%s" "$tmp" | "$grotty" -F ./font 2>&1 >/dev/null)
echo "$output"

echo "checking that no diagnostic messages are produced by grotty (2)"
echo "$error" | grep -q 'grotty:' && wail

echo "checking that a lone vertical rule ends the first output line"
echo "$output" | sed -n '1p' | grep -Eqx ' +\|' || wail

# Case 3: No horizontal rules; vertical rule at trailing column.
input='.TS
L |.
foo
.TE'

tmp=$(printf "%s\n" "$input" | "$groff" -t -Z -Tascii -P-cbou)
output=$(printf "%s" "$tmp" | "$grotty" -F ./font 2>/dev/null)
error=$(printf "%s" "$tmp" | "$grotty" -F ./font 2>&1 >/dev/null)
echo "$output"

echo "checking that no diagnostic messages are produced by grotty (3)"
echo "$error" | grep -q 'grotty:' && wail

echo "checking that a lone vertical rule ends the first output line"
echo "$output" | sed -n '1p' | grep -Eqx ' +\|' || wail

# Case 4: Vertical rule with horizontal rule in row description.
input='.TS
_
L |.
foo
.TE'

tmp=$(printf "%s\n" "$input" | "$groff" -t -Z -Tascii -P-cbou)
output=$(printf "%s" "$tmp" | "$grotty" -F ./font 2>/dev/null)
error=$(printf "%s" "$tmp" | "$grotty" -F ./font 2>&1 >/dev/null)
echo "$output"

echo "checking that no diagnostic messages are produced by grotty (4)"
echo "$error" | grep -q 'grotty:' && wail

echo "checking that intersection is placed on the first output line"
echo "$output" | sed -n '1p' | grep -q '+' || wail

# Case 5: Vertical rule with horizontal rule as first table datum.
input='.TS
L |.
_
foo
.TE'

tmp=$(printf "%s\n" "$input" | "$groff" -t -Z -Tascii -P-cbou)
output=$(printf "%s" "$tmp" | "$grotty" -F ./font 2>/dev/null)
error=$(printf "%s" "$tmp" | "$grotty" -F ./font 2>&1 >/dev/null)
echo "$output"

echo "checking that no diagnostic messages are produced by grotty (5)"
echo "$error" | grep -q 'grotty:' && wail

echo "checking that intersection is placed on the first output line"
echo "$output" | sed -n '1p' | grep -q '+' || wail

# Case 6: Horizontal rule as non-first row description with vertical
# rule.
input='.TS
L,_,L |.
foo
bar
.TE'

tmp=$(printf "%s\n" "$input" | "$groff" -t -Z -Tascii -P-cbou)
output=$(printf "%s" "$tmp" | "$grotty" -F ./font 2>/dev/null)
error=$(printf "%s" "$tmp" | "$grotty" -F ./font 2>&1 >/dev/null)
echo "$output"

echo "checking that no diagnostic messages are produced by grotty (6)"
echo "$error" | grep -q 'grotty:' && wail

echo "checking that table data begin on first output line"
echo "$output" | sed -n '1p' | grep -q 'foo' || wail

# Also ensure that no collateral damage arises in related cases.

# Case 7: Horizontal rule as first table datum with no vertical rule.
input='.TS
L.
_
foo
.TE'

tmp=$(printf "%s\n" "$input" | "$groff" -t -Z -Tascii -P-cbou)
output=$(printf "%s" "$tmp" | "$grotty" -F ./font 2>/dev/null)
error=$(printf "%s" "$tmp" | "$grotty" -F ./font 2>&1 >/dev/null)
echo "$output"

echo "checking that no diagnostic messages are produced by grotty (7)"
echo "$error" | grep -q 'grotty:' && wail

echo "checking that horizontal rule is placed on the first output line"
echo "$output" | sed -n '1p' | grep -q '^---' || wail

# Case 8: Horizontal rule as last table datum with no vertical rule.
input='.TS
L.
foo
_
.TE
.ec @
.pl @n(nlu'

tmp=$(printf "%s\n" "$input" | "$groff" -t -Z -Tascii -P-cbou)
output=$(printf "%s" "$tmp" | "$grotty" -F ./font 2>/dev/null)
error=$(printf "%s" "$tmp" | "$grotty" -F ./font 2>&1 >/dev/null)
echo "$output"

echo "checking that no diagnostic messages are produced by grotty (8)"
echo "$error" | grep -q 'grotty:' && wail

echo "checking that horizontal rule is placed on the last output line"
echo "$output" | sed -n '$p' | grep -q '^---' || wail

# Case 9: Horizontal rule in row description with no vertical rule.
input='.TS
_
L.
foo
.TE'

tmp=$(printf "%s\n" "$input" | "$groff" -t -Z -Tascii -P-cbou)
output=$(printf "%s" "$tmp" | "$grotty" -F ./font 2>/dev/null)
error=$(printf "%s" "$tmp" | "$grotty" -F ./font 2>&1 >/dev/null)
echo "$output"

echo "checking that no diagnostic messages are produced by grotty (9)"
echo "$error" | grep -q 'grotty:' && wail

echo "checking that intersection is placed on the first output line"
echo "$output" | sed -n '1p' | grep -q '^---' || wail

# Case 10: Horizontal rule as non-first row description with no vertical
# rule.
input='.TS
L,_,L.
foo
bar
.TE'

tmp=$(printf "%s\n" "$input" | "$groff" -t -Z -Tascii -P-cbou)
output=$(printf "%s" "$tmp" | "$grotty" -F ./font 2>/dev/null)
error=$(printf "%s" "$tmp" | "$grotty" -F ./font 2>&1 >/dev/null)
echo "$output"

echo "checking that no diagnostic messages are produced by grotty (10)"
echo "$error" | grep -q 'grotty:' && wail

echo "checking that table data begin on first output line"
echo "$output" | sed -n '1p' | grep -q 'foo' || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
