#!/bin/sh
#
# Copyright (C) 2020, 2022 Free Software Foundation, Inc.
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

# Keep this list of programs in sync with GROFF_CHECK_GROHTML_PROGRAMS
# in m4/groff.m4.
for cmd in pnmcrop pnmcut pnmtopng pnmtops psselect
do
    if ! command -v $cmd >/dev/null
    then
        echo "cannot locate '$cmd' command; skipping test" >&2
        exit 77 # skip
    fi
done

fail=

wail () {
  echo ...FAILED >&2
  fail=yes
}

cleanup () {
  rm -f grohtml-[0-9]*-[12].png
  trap - HUP INT QUIT TERM
}

trap 'trap "" HUP INT QUIT TERM; cleanup; kill -s INT $$' \
  HUP INT QUIT TERM

input='.TS
L.
foobar
.TE'

# Inline images are named grohtml-$$-<image sequence number>.png.

echo "checking production of inline image for tbl(1) table" >&2
output=$(echo "$input" | "$groff" -t -Thtml)
echo "$output" | grep -q '<img src="grohtml-[0-9]\+-1.png"' || wail

input='.EQ
x sup 2 + y sup 2 = z sup 2
.EN'

echo "checking production of inline image for eqn(1) equation" >&2
output=$(echo "$input" | "$groff" -e -Thtml)
echo "$output" | grep -q '<img src="grohtml-[0-9]\+-2.png"' || wail

cleanup

# We can't run remaining tests if the environment doesn't support UTF-8.
test "$(locale charmap)" = UTF-8 || exit 77 # skip

# Check two forms of character transformation.
#
# dash's built-in printf doesn't support \x or \u escapes, so likely
# other shells don't either, and expecting one that does to be in the
# $PATH seems optimistic.  So use UTF-8 octal bytes directly.
echo "checking -k -Thtml" >&2
printf '\303\241' | "$groff" -k -Thtml | grep -qx '<p>&aacute;</p>' \
  || wail

# We test compatibility-mode HTML output somewhat differently since
# preconv only emits groffish \[uXXXX] escapes for non-ASCII codepoints.
echo "checking -C -k -Thtml" >&2
printf "\('a" | "$groff" -C -k -Thtml | grep -qx '<p>&aacute;</p>' \
  || wail

# test for Japanese, preprocessor
#   "さざ波" -> \343\201\225\343\201\226\346\263\242
jstr='\343\201\225\343\201\226\346\263\242'
echo "checking -Kutf8 -Thtml -Z" >&2
printf ".ft JPM\n${jstr}" | "$groff" -Kutf8 -Thtml -Z | tr '\n' ';' | grep -q 'Cu3055;H48;Cu3055_3099;h48;Cu6CE2;h48;' \
  || wail

# test for Japanese
echo "checking -Kutf8 -Thtml -P-U" >&2
printf ".ft JPM\n${jstr}" | "$groff" -Kutf8 -Thtml -P-U | grep -qx `echo "<p>${jstr}</p>"` \
  || wail

test -z "$fail"

# vim:set autoindent expandtab shiftwidth=2 tabstop=2 textwidth=72:
