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

# Ensure that groff's PDF device has the copies it needs of PostScript
# device font descriptions.
#
# We need all of them except SS and ZDR.

devps_fontsrcdir="${abs_top_srcdir:-..}"/font/devps
devpdf_fontbuilddir="${abs_top_builddir:-.}"/font/devpdf

psfonts=$(cd "$devps_fontsrcdir" && ls [A-Z]* \
    | grep -Evx '(DESC\.in|SS|ZDR)')

fail=

for f in $psfonts
do
    printf "checking for font description %s...\n" "$f" >&2
    if ! test -f "$devpdf_fontbuilddir"/"$f"
    then
        echo test -f "$devpdf_fontbuilddir"/"$f"
        echo FAILED >&2
        fail=yes
    fi
done

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
