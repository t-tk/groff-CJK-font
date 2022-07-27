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

# Regression-test Savannah #61424.
#
# The `fp` request should not be able to access font description files
# outside of the device and font description search path (configurable
# with the -F option and GROFF_FONT_PATH environment variable).

# An absolute file name _won't_ work: it gets dev\*[.T]/ stuck on the
# front of it by libgroff.  (We have no idea where in a file system we
# might be getting built anyway.)  So we hunt around for our test
# artifact directory in some common locations.
font_dir=
base=src/roff/groff/tests
device=artifacts

for buildroot in . .. ../..
do
    d=$buildroot/$base/$device
    if [ -d "$d" ]
    then
        font_dir=$d
        break
    fi
done

# If we can't find it, we can't test.
test -z "$font_dir" && exit 77 # skip

input='.fp 5 ../HONEYPOT
.ft 5
word
.fp 5 HONEYPOT ../HONEYPOT
.ft HONEYPOT
.br
my word is able
.pl \n[nl]u'

output=$(printf "%s" "$input" | "$groff" -b -ww -F "$font_dir" -Tascii)
echo "$output" | grep -Fx word

# vim:set ai et sw=4 ts=4 tw=72:
