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

# Regression-test Savannah #59179.
#
# Don't lose track of the page number if we're continuously rendering
# _and_ we've been given a page-letter suffixing threshold.

printf ".TH foo 1\n" | "$groff" -Tascii -P-cbou -rX1 -man \
    | tail -n 1 | grep -Eq '^[[:space:]]+1$'

# vim:set ai et sw=4 ts=4 tw=72:
