#!/bin/sh
#
# Copyright (C) 2023 Free Software Foundation, Inc.
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

# Regression-test Savannah #64421.
#
# Building with `-flto=auto` on multiple (GNU) toolchains causes
# shenangians in the formatter, provoked by an uninitialized global in
# libgroff.  Reproducer courtesy of Günther Noack.

input=".TITLE Example
.DOCTYPE    LETTER
.PRINTSTYLE TYPESET
.PAPER      A4
.START
.DRH"

output=$(printf "%s\n" "$input" | "$groff" -m om -T pdf -Z)
echo "$output"
! echo "$output" | grep -qx 'tblack'

# vim:set autoindent expandtab shiftwidth=2 tabstop=2 textwidth=72:
