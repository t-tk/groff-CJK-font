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
# Give the output a name that won't collide with another test.
gnu_pdf="${abs_top_builddir:-.}/doc/gnu-no-choke-on-pdfinfo.pdf"

# Regression-test Savannah #58206.

# We need gs(1) and pdfpic.tmac needs pdfinfo(1).
for cmd in gs pdfinfo
do
    if ! command -v $cmd >/dev/null
    then
        echo "cannot locate '$cmd' command" >&2
        exit 77 # skip
    fi
done

# Locate directory containing our test artifacts.
artifact_dir=

for buildroot in . .. ../..
do
    d=$buildroot/doc
    if [ -f $d/gnu.eps ]
    then
        artifact_dir=$d
        gnu_eps=$artifact_dir/gnu.eps
        break
    fi
done

# If we can't find it, we can't test.
test -z "$artifact_dir" && exit 77 # skip

if [ -e "$gnu_pdf" ]
then
    echo "temporary output file '$gnu_pdf' already exists" >&2
    exit 77 # skip
fi

fail=

input='.am pdfpic@error
.  ab
..
Here is a picture of a wildebeest.
.PDFPIC '"$gnu_pdf"

if ! gs -q -o - -sDEVICE=pdfwrite -f "$gnu_eps" \
    -c "[ /Title (\000B\000U\000S\000T\000E\000D) /DOCINFO pdfmark" \
    > "$gnu_pdf"
then
    echo "gs command failed" >&2
    rm -f "$gnu_pdf"
    exit 77 # skip
fi

test -z "$fail" \
    && printf '%s\n' "$input" | "$groff" -Tpdf -U -z || fail=YES

rm -f "$gnu_pdf"
test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
