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

# test for upTeX dvi with Japanese, preprocessor
#   "さざ波" -> \343\201\225\343\201\226\346\263\242
jstr='\343\201\225\343\201\226\346\263\242'
echo "testing -Kutf8 -Tdvi -Z" >&2
printf ".ft JPM\n${jstr}" | "$groff" -Kutf8 -Tdvi -Z | tr '\n' ';' | grep -q 'Cu3055;h8000;Cu3055_3099;h8000;Cu6CE2;h8000;'


# test for upTeX dvi with Japanese
echo "testing -Kutf8 -Tdvi" >&2
#printf ".ft JPM\n${jstr}" | "$groff" -Kutf8 -Tdvi > grodvi.dvi && updvitype grodvi.dvi | grep -qx `echo "\[${jstr}\]"`
printf ".ft JPM\n${jstr}" | "$groff" -Kutf8 -Tdvi | od -tx1 | grep -q '81 30 55 81 30 56 81 6c e2'
