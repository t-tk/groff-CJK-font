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

groff="${abs_top_builddir:-.}/test-groff"

input='.Dd June 6, 1944
.Dt timerdday 3bsd
.Os
.Sh Name
.Nm timerdday
.Nd compute time of launch operation within window
.Sh Synopsis
.Ft void
.Fn timerdday "\%struct-timespec *earliest" \
"\%struct-timespec *latest" "\%struct-timespec *resolution"
.Sh Description
Compute the optimal start time for a desired event to occur between
times
.Va earliest No and Va latest
to within a granularity of
.Va resolution .'

# Regression-test Savannah #63957.
#
# Adjustment should be disabled in Synopsis sections.

output=$(echo "$input" | "$groff" -Tascii -mdoc -P-cbou)
echo "$output"

str=' {5}timerdday\(struct-timespec \*earliest, struct-timespec \*latest,'
echo "$output" | grep -Eqx "$str"

# vim:set ai et sw=4 ts=4 tw=72:
