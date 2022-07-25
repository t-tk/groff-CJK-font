#!/bin/sh
#
# Copyright (C) 2021 Free Software Foundation, Inc.
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

grog="${abs_top_builddir:-.}/grog"

# Regression test Savannah #57873.
#
# Don't mangle groff options.

echo | "$grog" -ww -fN -P-pa5 -ra5=0 \
    | grep -Fqx 'groff -ww -fN -P-pa5 -ra5=0 -'

# vim:set ai et sw=4 ts=4 tw=72:
