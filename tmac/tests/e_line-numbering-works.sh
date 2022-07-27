#!/bin/sh
#
# Copyright (C) 2021 Free Software Foundation, Inc.
#
# This file is part of groff.
#
# groff is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your
# option) any later version.
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

# Test the line numbering feature.

input='.nr pp 18 \\" to make troff output consistent with nroff
.if r mypo .po \\n[mypo]u
.if !d C .ds C\\" empty
.pp
Feck, vex loping bad jazz: quench my thirst.
Feck, vex loping bad jazz: quench my thirst.
.pp
.n1 \\*C
Jackdaws love my big sphinx of quartz.
Jackdaws love my big sphinx of quartz.
Jackdaws love my big sphinx of quartz.
.pp
How vexingly quick daft zebras jump!
.pp
.n2 +6
Waltz, bad nymph, for quick jigs vex.
Waltz, bad nymph, for quick jigs vex.
.pp
.n2 99
Pack my box with five dozen liquor jugs.
Pack my box with five dozen liquor jugs.
Pack my box with five dozen liquor jugs.
.pp
.n2
The five boxing wizards jump quickly.
The five boxing wizards jump quickly.'

fail=

wail () {
    echo "...FAILED" >&2
    fail=YES
}

echo '*** basic output (line number field prepended)' >&2
output=$(echo "$input" | "$groff" -Tascii -P-cbou -me)

# We expect the foregoing to produce a me(7) diagnostic complaining of a
# negative page offset but we're not testing for that.

echo 'checking for 0 page offset and 5n paragraph indentation (1)' >&2
echo "$output" | grep -q '^     Feck.*vex$' || wail # 5 spaces

# troff uses backspaces to emit the line number, so we can't anchor the
# matches to the beginning of the line with '^'.

# These patterns have 6 embedded spaces until further notice.
echo 'checking for line number field plus 60n line length' >&2
echo "$output" | grep -q '1      Jackdaws.*love$' || wail

echo 'checking for non-numbering of blank lines' >&2
echo "$output" | grep -q '4      How.*jump!$' || wail

echo 'checking offset-advanced two-digit line number' >&2
echo "$output" | grep -q '^10      Waltz,.*bad nymph$'

echo 'checking three-digit line number' >&2
echo "$output" | grep -q '^100      with.*dozen$'

echo 'checking for 0 page offset and 5n paragraph indentation (2)' >&2
echo "$output" | grep -q '^     The.*boxing$' || wail # 5 spaces

echo '*** roff(1)-compatible output (shorter line length)' >&2
output=$(echo "$input" | "$groff" -dCC -Tascii -P-cbou -me)

echo 'checking for 0 page offset and 5n paragraph indentation (1)' >&2
echo "$output" | grep -q '^     Feck.*vex' || wail # 5 spaces

echo 'checking for line number field plus 56n line length' >&2
echo "$output" \
    | grep -q '  1      Jackdaws.*Jackdaws$' || wail # 2, then 6 spaces

# These patterns have 6 embedded spaces until further notice.
echo 'checking for non-numbering of blank lines' >&2
echo "$output" | grep -q '4      How.*jump!$' || wail

echo 'checking offset-advanced two-digit line number' >&2
echo "$output" | grep -q ' 10      Waltz,.*bad$' || wail

echo 'checking three-digit line number' >&2
echo "$output" | grep -q '^100      box.*dozen$'

echo 'checking for 0 page offset and 5n paragraph indentation (2)' >&2
echo "$output" | grep -q '^     The.*boxing$' || wail # 5 spaces

echo '*** output with 4n page offset' >&2
output=$(echo "$input" | "$groff" -rmypo=4n -Tascii -P-cbou -me)

echo "$output"

echo 'checking for 4n page offset and 5n paragraph indentation (1)' >&2
echo "$output" | grep -q '^         Feck.*vex' || wail # 9 spaces

echo 'checking for line number field plus 60n line length' >&2
echo "$output" \
    | grep -q '  1      Jackdaws.*love$' || wail # 2, then 6 spaces

# These patterns have 6 embedded spaces until further notice.
echo 'checking for non-numbering of blank lines' >&2
echo "$output" | grep -q '4      How.*jump!$' || wail

echo 'checking offset-advanced two-digit line number' >&2
echo "$output" | grep -q ' 10      Waltz,.*bad$' || wail

echo 'checking three-digit line number' >&2
echo "$output" | grep -q '^100      box.*dozen$'

echo 'checking for 4n page offset and 5n paragraph indentation (2)' >&2
echo "$output" | grep -q '^         The.*boxing$' || wail # 9 spaces

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
