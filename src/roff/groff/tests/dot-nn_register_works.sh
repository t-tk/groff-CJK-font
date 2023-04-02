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

# Unit test .nn register.

fail=

wail () {
  echo ...FAILED >&2
  fail=YES
}

input='.ec @
.de is-numbered
.  nop This line
.  ie (@@n[.nm] & (1-@@n[.nn])) IS
.  el                           ISN'"'"'T
.  nop numbered.
.  br
..
Test line numbering.
.is-numbered
.nm 1
.nn 2
.is-numbered
.is-numbered
.is-numbered
.nm
.is-numbered
.pl @n[nl]u'

# Apply line numbers to the output externally for easy grepping.
output=$(echo "$input" | $groff -Tascii | nl)
echo "$output"

echo "verifying that line 1 isn't numbered" >&2
echo "$output" | \
  grep -Eq "[[:space:]]+1[[:space:]]+Test line numbering\." || wail

echo "verifying that line 2 isn't numbered" >&2
echo "$output" | \
  grep -Eq "[[:space:]]+2[[:space:]]+This line ISN'T" || wail

echo "verifying that line 3 isn't numbered" >&2
echo "$output" | \
  grep -Eq "[[:space:]]+3[[:space:]]+This line ISN'T" || wail

echo "verifying that line 4 is numbered" >&2
echo "$output" | \
  grep -Eq "[[:space:]]+4[[:space:]]+1 +This line IS numbered" || wail

echo "verifying that line 5 isn't numbered" >&2
echo "$output" | \
  grep -Eq "[[:space:]]+5[[:space:]]+This line ISN'T" || wail

test -z "$fail"

# vim:set autoindent expandtab shiftwidth=2 tabstop=2 textwidth=72:
