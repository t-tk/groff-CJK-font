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

set -e

# Ensure we get diagnostics when we expect to, and not when we don't.
#
# Do NOT pattern-match the text of the diagnostic messages; those should
# be left flexible.  (Some day they might even be localized.)

# As of this writing, there are 5 distinct format-time diagnostic
# messages that tbl writes roff code to generate, one of which can be
# produced two different ways.

# Diagnostic #1: a row overruns the page bottom
input='.pl 2v
.TS
;
L.
T{
.nf
1
2
3
T}
.TE
'

echo "checking for diagnostic when row with text box overruns page" \
    "bottom"
output=$(printf "%s" "$input" | "$groff" -Tascii -t 2>&1 >/dev/null)
nlines=$(echo "$output" | grep . | wc -l)
test $nlines -eq 1

echo "checking 'nowarn' suppression of  diagnostic when row with text" \
    "box overruns page bottom"
input_nowarn=$(printf "%s" "$input" | sed 's/;/nowarn;/')
output=$(printf "%s" "$input_nowarn" \
    | "$groff" -Tascii -t 2>&1 >/dev/null)
nlines=$(echo "$output" | grep . | wc -l)
test $nlines -eq 0

echo "checking 'nokeep' suppression of diagnostic when row with text" \
    "box overruns page bottom"
input_nowarn=$(printf "%s" "$input" | sed 's/;/nokeep;/')
output=$(printf "%s" "$input_nowarn" \
    | "$groff" -Tascii -t 2>&1 >/dev/null)
nlines=$(echo "$output" | grep . | wc -l)
test $nlines -eq 0

# The other way to get "diagnostic #1" is to have a row that is too
# tall _without_ involving a text block, for instance by having a font
# or vertical spacing that is too high.
input='.pl 2v
.vs 3v
.TS
;
L.
1
.TE
'

echo "checking for diagnostic when row with large vertical spacing" \
    "overruns page bottom"
output=$(printf "%s" "$input" | "$groff" -Tascii -t 2>&1 >/dev/null)
nlines=$(echo "$output" | grep . | wc -l)
test $nlines -eq 1

echo "checking 'nowarn' suppression of diagnostic when row with large" \
    "vertical spacing overruns page bottom"
input_nowarn=$(printf "%s" "$input" | sed 's/;/nowarn;/')
output=$(printf "%s" "$input_nowarn" \
    | "$groff" -Tascii -t 2>&1 >/dev/null)
nlines=$(echo "$output" | grep . | wc -l)
test $nlines -eq 0

echo "checking 'nokeep' suppression of diagnostic when row with large" \
    "vertical spacing overruns page bottom"
input_nowarn=$(printf "%s" "$input" | sed 's/;/nokeep;/')
output=$(printf "%s" "$input_nowarn" \
    | "$groff" -Tascii -t 2>&1 >/dev/null)
nlines=$(echo "$output" | grep . | wc -l)
test $nlines -eq 0

# Diagnostic #2: a boxed table won't fit on a page

input='.pl 2v
.vs 3v
.TS
box;
L.
1
.TE
'

echo "checking for diagnostic when boxed table won't fit on page"
output=$(printf "%s" "$input" | "$groff" -Tascii -t 2>&1 >/dev/null)
nlines=$(echo "$output" | grep . | wc -l)
test $nlines -eq 1

# The above is an error, so the "nowarn" region option won't shut it up.
#
# However, "nokeep" does--but arguably shouldn't.  See
# <https://savannah.gnu.org/bugs/?61878>.  If that gets fixed, we should
# test that we still get a diagnostic even with the option given.

# Diagnostic #3: unexpanded columns overrun the line length
#
# Case 1: no 'x' column modifiers used

input='.pl 2v
.ll 10n
.TS
;
L.
12345678901
.TE
'

echo "checking for diagnostic when unexpanded columns overrun line" \
    "length (1)"
output=$(printf "%s" "$input" | "$groff" -Tascii -t 2>&1 >/dev/null)
nlines=$(echo "$output" | grep . | wc -l)
test $nlines -eq 1

echo "checking 'nowarn' suppression of diagnostic when unexpanded" \
    "columns overrun line length (1)"
input_nowarn=$(printf "%s" "$input" | sed 's/;/nowarn;/')
output=$(printf "%s" "$input_nowarn" \
    | "$groff" -Tascii -t 2>&1 >/dev/null)
nlines=$(echo "$output" | grep . | wc -l)
test $nlines -eq 0

# Avoiding keeps won't get you out of this one.
echo "checking 'nokeep' NON-suppression of diagnostic when unexpanded" \
    "columns overrun line length (1)"
input_nowarn=$(printf "%s" "$input" | sed 's/;/nokeep;/')
output=$(printf "%s" "$input_nowarn" \
    | "$groff" -Tascii -t 2>&1 >/dev/null)
nlines=$(echo "$output" | grep . | wc -l)
test $nlines -eq 1

# Case 2: 'x' column modifier used
#
# This worked as a "get out of jail (warning) free" card in groff 1.22.4
# and earlier; i.e., it incorrectly suppressed the warning.  See
# Savannah #61854.

input='.pl 2v
.ll 10n
.TS
;
Lx.
12345678901
.TE
'

echo "checking for diagnostic when unexpanded columns overrun line" \
    "length (2)"
output=$(printf "%s" "$input" | "$groff" -Tascii -t 2>&1 >/dev/null)
nlines=$(echo "$output" | grep . | wc -l)
test $nlines -eq 1

echo "checking 'nowarn' suppression of diagnostic when unexpanded" \
    "columns overrun line length (2)"
input_nowarn=$(printf "%s" "$input" | sed 's/;/nowarn;/')
output=$(printf "%s" "$input_nowarn" \
    | "$groff" -Tascii -t 2>&1 >/dev/null)
nlines=$(echo "$output" | grep . | wc -l)
test $nlines -eq 0

# Avoiding keeps won't get you out of this one.
echo "checking 'nokeep' NON-suppression of diagnostic when unexpanded" \
    "columns overrun line length (2)"
input_nowarn=$(printf "%s" "$input" | sed 's/;/nokeep;/')
output=$(printf "%s" "$input_nowarn" \
    | "$groff" -Tascii -t 2>&1 >/dev/null)
nlines=$(echo "$output" | grep . | wc -l)
test $nlines -eq 1

# Diagnostic #4: expanded table gets all column separation squashed out

input='.pl 3v
.ll 10n
.TS
tab(;) expand;
L L.
abcde;fghij
.TE
'

echo "checking for diagnostic when region-expanded table has column" \
    "separation eliminated"
output=$(printf "%s" "$input" | "$groff" -Tascii -t 2>&1 >/dev/null)
nlines=$(echo "$output" | grep . | wc -l)
test $nlines -eq 1

echo "checking 'nowarn' suppression of diagnostic when" \
    "region-expanded table has column separation eliminated"
input_nowarn=$(printf "%s" "$input" | sed 's/;$/ nowarn;/')
output=$(printf "%s" "$input_nowarn" \
    | "$groff" -Tascii -t 2>&1 >/dev/null)
nlines=$(echo "$output" | grep . | wc -l)
test $nlines -eq 0

# Avoiding keeps won't get you out of this one.
echo "checking 'nokeep' NON-suppression of diagnostic when" \
    "region-expanded table has column separation eliminated"
input_nowarn=$(printf "%s" "$input" | sed 's/;$/ nokeep;/')
output=$(printf "%s" "$input_nowarn" \
    | "$groff" -Tascii -t 2>&1 >/dev/null)
nlines=$(echo "$output" | grep . | wc -l)
test $nlines -eq 1

# Diagnostic #5: expanded table gets column separation reduced

input='.pl 3v
.ll 10n
.TS
tab(;) expand;
L L.
abcd;efgh
.TE
'

echo "checking for diagnostic when region-expanded table has column" \
    "separation reduced"
output=$(printf "%s" "$input" | "$groff" -Tascii -t 2>&1 >/dev/null)
nlines=$(echo "$output" | grep . | wc -l)
test $nlines -eq 1

echo "checking 'nowarn' suppression of diagnostic when" \
    "region-expanded table has column separation reduced"
input_nowarn=$(printf "%s" "$input" | sed 's/;$/ nowarn;/')
output=$(printf "%s" "$input_nowarn" \
    | "$groff" -Tascii -t 2>&1 >/dev/null)
nlines=$(echo "$output" | grep . | wc -l)
test $nlines -eq 0

# Avoiding keeps won't get you out of this one.
echo "checking 'nokeep' NON-suppression of diagnostic when" \
    "region-expanded table has column separation reduced"
input_nowarn=$(printf "%s" "$input" | sed 's/;$/ nokeep;/')
output=$(printf "%s" "$input_nowarn" \
    | "$groff" -Tascii -t 2>&1 >/dev/null)
nlines=$(echo "$output" | grep . | wc -l)
test $nlines -eq 1

# vim:set ai et sw=4 ts=4 tw=72:
