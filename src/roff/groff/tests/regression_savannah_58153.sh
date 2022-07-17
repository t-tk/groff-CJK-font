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

# Ensure that we get backtrace output across file and pipe boundaries.
# Savannah #58153.
OUT=$("$groff" -U 2>&1 >/dev/null <<EOF
.pso printf '\\\s[-20]\\\n'
EOF
)

set -e

printf "%s\n" "$OUT" | grep -qw 'backtrace: pipe'
printf "%s\n" "$OUT" | grep -qw 'backtrace: file'
