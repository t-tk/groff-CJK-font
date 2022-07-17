#!/bin/sh
#
# Copyright (C) 2020 Free Software Foundation, Inc.
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

# Ensure a predictable character encoding.
export LC_ALL=C

set -e

export GROFF_TEST_GROFF=${abs_top_builddir:-.}/test-groff

# The $PATH used by an installed nroff at runtime does not match what
# we're trying to test, which should be using the groff and runtime
# support from the build tree.  Therefore the $PATH that nroff -V
# reports will _always_ be wrong for test purposes.  Skip over it.
#
# If the build environment has a directory in the $PATH matching
# "test-groff " (with the trailing space), failure may result if sed
# doesn't match greedily.  POSIX says it should.
sedexpr='s/^PATH=.*test-groff /test-groff /'
PATH=${abs_top_builddir:-.}:$PATH

nroff_ver=$(nroff -v | awk 'NR == 1 {print $NF}')
groff_ver=$(nroff -v | awk 'NR == 2 {print $NF}')

echo nroff: $nroff_ver >&2
echo groff: $groff_ver >&2
test "$nroff_ver" = "$groff_ver"

echo "testing 'nroff -V'" >&2
nroff -V | sed "$sedexpr" | grep -x "test-groff -Tascii -mtty-char"

echo "testing 'nroff -V 1'" >&2
nroff -V 1 | sed "$sedexpr" | grep -x "test-groff -Tascii -mtty-char 1"

echo "testing 'nroff -V \"1a 1b\"'" >&2
nroff -V \"1a 1b\" | sed "$sedexpr" \
    | grep -x "test-groff -Tascii -mtty-char \"1a 1b\""

echo "testing 'nroff -V \"1a 1b\" 2'" >&2
nroff -V \"1a 1b\" 2 | sed "$sedexpr" \
    | grep -x "test-groff -Tascii -mtty-char \"1a 1b\" 2"

echo "testing 'nroff -V 1a\\\"1b 2'" >&2
nroff -V 1a\"1b 2 | sed "$sedexpr" \
    | grep -x "test-groff -Tascii -mtty-char 1a\"1b 2"
