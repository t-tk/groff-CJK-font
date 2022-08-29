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

# test for PostScript with Japanese, preprocessor
echo "testing -Kutf8 -Tps -Z" >&2
printf ".ft JPM\nさざ波" | "$groff" -Kutf8 -Tps -Z | tr '\n' ';' | grep -q 'Cu3055;h10000;Cu3055_3099;h10000;Cu6CE2;h10000;'


# test for PostScript with Japanese, UTF16 encoding
echo "testing -Kutf8 -Tps" >&2
printf ".ft JPM\nさざ波" | "$groff" -Kutf8 -Tps | grep -q '/Ryumin-Light-UniJIS-UTF16-H SF<305530566CE2>'
