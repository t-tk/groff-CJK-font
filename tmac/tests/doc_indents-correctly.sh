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

# Regression-test Debian #1022179.
#
# Ensure that subsection headings are indent correctly even if they
# break across output lines.

input='.Dd 2022-10-28
.Dt foo 1
.Os
.Sh "A long section heading that wraps to illustrate the fact that the\
 indentation of said title is consistent even if it breaks across lines"
Discussion should be indented as ordinary paragraph.
.Ss "A long subsection heading that wraps to illustrate the fact that\
 the indentation of said title is consistent even if it breaks across\
 lines"
Further discussion should be indented as ordinary paragraph.'

output=$(printf "%s\n" "$input" | "$groff" -Tascii -P-cbou -mdoc)
fail=

# Verify that default `Sh` indentation is zero.
if ! echo "$output" | grep -Eq '^A +long +section +heading'
then
    fail=yes
    echo "default 'Sh' indentation check failed on 1st line" >&2
fi

if ! echo "$output" | grep -Eq '^of said title is consistent'
then
    fail=yes
    echo "default 'Sh' indentation check failed on 2nd line" >&2
fi

# Verify that paragraph indentation after section heading is correct.
# 7 spaces in string literal.
if ! echo "$output" | grep -Eq '^       Discussion should be indented'
then
    fail=yes
    echo "'Pp' indentation after 'Sh' check failed" >&2
fi

# Verify that default `Ss` indentation is three ens.
# 3 spaces in string literal.
if ! echo "$output" | grep -Eq '^   A +long +subsection +heading'
then
    fail=yes
    echo "default 'Ss' indentation check failed on 1st line" >&2
fi

# 3 spaces in string literal.
if ! echo "$output" | grep -Eq '^   indentation of said title is'
then
    fail=yes
    echo "default 'Ss' indentation check failed on 2nd line" >&2
fi

# Verify that paragraph indentation after subsection heading is correct.
# 7 spaces in string literal.
if ! echo "$output" | grep -Eq '^       Further discussion should be'
then
    fail=yes
    echo "'Pp' indentation after 'Ss' check failed" >&2
fi

test -z "$fail"
exit

# vim:set ai et sw=4 ts=4 tw=72:
