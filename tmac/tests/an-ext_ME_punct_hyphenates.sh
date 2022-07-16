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

EXAMPLE='.TH me\-punct 1 2020-08-15 "groff test suite"
.SH Name
me\-punct \- mailto: trailing material is subject to hyphenation
.SH Description
Do not try to
.MT groff+morestuff@gnu.org
hyphenate a ridiculous word* without machine assistance
.ME (*pneumonoultramicroscopicsilicovolcanoconiosis).'

# Turn off break warnings; we expect an adjustment problem.
# I kind of wish adjustment warnings were a different category from
# break warnings.
printf "%s\n" "$EXAMPLE" | "$groff" -Tascii -Wbreak -P-cbou -man \
    | grep -qE 'pn.*-'

# vim:set ai et sw=4 ts=4 tw=72:
