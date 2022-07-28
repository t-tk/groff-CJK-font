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

# Ensure that groff's PDF device has URW font descriptions it expects.

devpdf_fontbuilddir="${abs_top_builddir:-.}"/font/devpdf

# TODO: Scrape this list out of Foundry or Foundry.in.  Not possible
# with grep, likely a little tedious with sed.
urwfonts='AB
ABI
AI
AR
BMB
BMBI
BMI
BMR
CB
CBI
CI
CR
HB
HBI
HI
HNB
HNBI
HNI
HNR
HR
NB
NBI
NI
NR
PB
PBI
PI
PR
S
TB
TBI
TI
TR
ZCMI
ZD'

fail=

for basefontname in $urwfonts
do
    f=U-$basefontname
    printf "checking for font description %s...\n" $f >&2
    if ! test -f "$devpdf_fontbuilddir"/$f
    then
        echo test -f "$devpdf_fontbuilddir"/$f
        echo FAILED >&2
        fail=yes
    fi
done

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
