#!/bin/sh
#
# Copyright (C) 2022 Free Software Foundation, Inc.
#
# This file is part of groff.
#
# groff is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your
# option) any later version.
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

fail=

wail () {
    echo FAILED >&2
    fail=YES
}

# Regression-test Savannah #60657.  Ensure data from a bibliographic
# entry don't carry over to the next.

# Locate directory containing our test artifacts.
artifact_dir=

for buildroot in . .. ../..
do
    d=$buildroot/contrib/mm/tests/artifacts
    if [ -d "$d" ]
    then
        artifact_dir=$d
        break
    fi
done

# If we can't find it, we can't test.
test -z "$artifact_dir" && exit 77 # skip

input=".R1
bibliography $artifact_dir/60657.ref
.R2"

output=$(echo "$input" | "$groff" -R -mm -Tascii -P-cbou)

echo "checking first entry"
echo "$output" \
    | grep -q "1\. First Author in First Book\. Test one\.$" \
    || wail

echo "checking second entry"
echo "$output" \
    | grep -q "2\. Second Author in Second Book\.$" \
    || wail

echo "checking third entry"
echo "$output" \
    | grep -q "3\. Third Author\.$" \
    || wail

test -z "$fail" || exit 1

# vim:set ai et sw=4 ts=4 tw=72:
