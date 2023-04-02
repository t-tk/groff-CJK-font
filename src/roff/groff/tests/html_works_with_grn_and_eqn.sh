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

# Keep this list of programs in sync with GROFF_CHECK_GROHTML_PROGRAMS
# in m4/groff.m4.
for cmd in pnmcrop pnmcut pnmtopng pnmtops psselect
do
    if ! command -v $cmd >/dev/null
    then
        echo "cannot locate '$cmd' command; skipping test" >&2
        exit 77 # skip
    fi
done

# Commit c71b4ef4aa provoked an infinite loop in post-grohtml with these
# preprocessors.

input='.EQ
gsize 12
delim $$
.EN
.pp
.pp
The faster clocks are $ PN $'

output=$("$groff" -b -ww -Thtml -eg -me "$input")
test -n "$output"
