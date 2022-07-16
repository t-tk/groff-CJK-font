#!/bin/sh
#
# Copyright (C) 2020 Free Software Foundation, Inc.
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

# We can't run these tests if the environment doesn't support UTF-8.
LC_CTYPE=C.UTF-8
test "$(locale charmap)" = UTF-8 || exit 77 # skip

set -e

# Check two forms of character transformation.
#
# dash's built-in printf doesn't support \x or \u escapes, so likely
# other shells don't either, and expecting one that does to be in the
# $PATH seems optimistic.  So use UTF-8 octal bytes directly.
echo "testing -k -Thtml" >&2
printf '\303\241' | "$groff" -k -Thtml | grep -qx '<p>&aacute;</p>'

# We test compatibility-mode HTML output somewhat differently since
# preconv only emits groffish \[uXXXX] escapes for non-ASCII codepoints.
echo "testing -C -k -Thtml" >&2
printf "\('a" | "$groff" -C -k -Thtml | grep -qx '<p>&aacute;</p>'
