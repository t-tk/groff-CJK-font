#!/bin/sh
#
# Copyright (C) 2022 Free Software Foundation, Inc.
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

input='.TH foo 1 2022-07-30 "groff test suite"
.SH Name
foo \- frobnicate a bar
.SH Description
Foo.
.TS
L.
bar
.TE
'

# Bash strips out an empty line, but that's what we're looking for.
output=$(printf "%s" "$input" | "$groff" -t -man -Tascii \
    | sed -n \
        -e '/Foo\./{n;s/^$/FAILURE/;tA;' \
        -e 's/.*/SUCCESS/;:A;' \
        -e 'p;}')
    # Here's a tidier version accepted by GNU sed but rejected
    # contemptuously by macOS sed.  (POSIX doesn't say you _have_ to
    # accept semicolons after label ':' and branch 't' commands, so it
    # doesn't.)
    # sed -n '/Foo\./{n;s/^$/FAILURE/;tA;s/.*/SUCCESS/;:A;p}'
test "$output" = SUCCESS

# vim:set ai et sw=4 ts=4 tw=72:
