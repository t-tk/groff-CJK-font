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

# Regression-test Savannah #61853.
#
# The word "no" as the first argument to the `XA` macro should suppresss
# not just the page number, but the leader before it as well.

input='.PP
.XS
This is my TOC entry
.XA no
There are many like it
.XE
But this one is mine.
.TC
'

fail=

wail () {
    echo "...FAILED" >&2
    fail=YES
}

# Be aware of
# <https://unix.stackexchange.com/questions/383217/\
# shell-keep-trailing-newlines-n-in-command-substitution> when comparing
# this to interactive output.
output=$(printf '%s\n' "$input" | "$groff" -Tascii -P-cbou -ms)

echo "checking for presence of supplemental TOC entry" >&2
echo "$output" | grep -q 'There are many like it' || wail

echo "checking for suppressed leader in supplemental TOC entry" >&2
echo "$output" | grep -qx 'There are many like it' || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
