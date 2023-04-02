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

# Regression-test Savannah #58962.

# Keep preconv from being run.
unset GROFF_ENCODING

input='.if " "\~" .tm input no-break space matches \\~
.if "­"\%" .tm input soft hyphen matches \\%'

fail=

wail () {
   echo "...FAILED"
   fail=yes
}

output=$(printf "%s\n" "$input" | "$groff" -Z 2>&1)
echo "$output"

printf "checking that input no-break space is mapped to \\~\n"
echo "$output" | grep -qx 'input no-break space matches \\~' || wail

printf "checking that input soft hyphen is mapped to \\%%\n"
echo "$output" | grep -qx 'input soft hyphen matches \\%' || wail

test -z "$fail"
