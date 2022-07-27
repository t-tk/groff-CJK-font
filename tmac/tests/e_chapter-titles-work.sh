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

# Ensure that chapter (and appendix) titles aren't broken by
# localization rigamarole.

input='.de $C
.  tm $C: \\$@
..
.++ C
.+c "The Boy Sickens"
.+c "The Boy Dies"
.++ A
.+c "Pathology of Boy Aged 11 Years"'

fail=

wail () {
    echo "...FAILED" >&2
    fail=YES
}

output=$(printf "%s\n" "$input" | "$groff" -Tascii -P-cbou -me 2>&1)

echo "checking for correct arguments given to \$C hook macro (1)" >&2
echo "$output" | grep -Fqx '$C: "Chapter" "1" "The Boy Sickens"' || wail

# Ensure that the chapter number got incremented.
echo "checking for correct arguments given to \$C hook macro (2)" >&2
echo "$output" | grep -Fqx '$C: "Chapter" "2" "The Boy Dies"' || wail

# Ensure that an appendix chapter uses uppercase alphabetical numbers.
echo "checking for correct arguments given to \$C hook macro (3)" >&2
echo "$output" \
    | grep -Fqx '$C: "Appendix" "A" "Pathology of Boy Aged 11 Years"' \
    || wail

echo "checking formatted chapter heading output (1)" >&2
echo "$output" | grep -Fq "Chapter 1" || wail

echo "checking formatted chapter heading output (2)" >&2
echo "$output" | grep -Fq "Chapter 2" || wail

echo "checking formatted appendix heading output" >&2
echo "$output" | grep -Fq "Appendix A" || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
