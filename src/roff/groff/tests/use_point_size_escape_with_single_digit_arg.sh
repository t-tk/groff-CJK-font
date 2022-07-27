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
export GROFF_TYPESETTER=

# The vertical space is so that the 36-point 'A' won't be truncated by
# the top of the page.  That could be confusing and misleading to anyone
# who ever has to troubleshoot this test case.
DOC=".vs 10v
\s36A"

set -e

# Verify that the idiosyncratic behavior of \sN is supported in
# compatibility mode...
echo "testing \s36A in compatiblity mode (36-point 'A')" >&2
echo "$DOC" | "$groff" -C -Z | grep -qx 's36000'

# ...and not in regular mode.
echo "testing \s36A in non-compatiblity mode (3-point '6A')" >&2
echo "$DOC" | "$groff" -Z | grep -qx 's3000'

# Check that we get a diagnostic when relying on the ambiguous form.
echo "testing for diagnostic on \s36 in compatiblity mode" >&2
echo "$DOC" | "$groff" -C -Z 2>&1 >/dev/null \
    | grep -q 'ambiguous type size in escape sequence'
