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

groff="${abs_top_builddir:-.}/test-groff"

# Feed groff empty input documents and verify that expected comments
# emerge from the output drivers.

# Expect Creator: and CreationDate: comments.
echo "testing presence of Creator: comment in HTML output" >&2
echo | "$groff" -Thtml | grep -Fq '<!-- Creator:'

echo "testing presence of CreationDate: comment in HTML output" >&2
echo | "$groff" -Thtml | grep -Fq '<!-- CreationDate:'

# Make sure the options are recognized so we can distinguish a match
# failure.  We can't use -Z or -z because they keep the output driver
# from running at all.
for OPT in -C -G
do
    if ! echo | "$groff" -Thtml -P$OPT > /dev/null
    then
        echo "option $OPT not recognized!" >&2
        exit 2
    fi
done

# Now shut them off.
echo "testing absence of Creator: comment in HTML output" >&2
! echo | "$groff" -Thtml -P-G | grep -Fq '<!-- Creator:'

echo "testing absence of CreationDate: comment in HTML output" >&2
! echo | "$groff" -Thtml -P-C | grep -Fq '<!-- CreationDate:'
