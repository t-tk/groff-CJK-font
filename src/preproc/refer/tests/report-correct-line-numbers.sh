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

refer="${abs_top_builddir:-.}/refer"

fail=

wail () {
    echo FAILED >&2
    fail=YES
}

# Regression-test Savannah #62124.  Ensure correct line numbers in
# diagnostics on bibliography files.

# Locate directory containing our test artifacts.
artifact_dir=

for buildroot in . .. ../..
do
    d=$buildroot/src/preproc/refer/tests/artifacts
    if [ -d "$d" ]
    then
        artifact_dir=$d
        break
    fi
done

# If we can't find it, we can't test.
test -z "$artifact_dir" && exit 77 # skip

input=".
.R1
bibliography $artifact_dir/62124.ref
cattywumpus
.R2
.
.R1
bibliography $artifact_dir/62124.ref
cattywumpus
.R2"

# We want standard error _only_.
output=$(echo "$input" | "$refer" -e -p "$artifact_dir"/62124.ref \
    2>&1 >/dev/null)

# We should get every complaint about the bibliography twice because it
# is dumped twice; the line numbers should not change because they're
# problems with the bibliography file, not the input file.

# We're pattern-matching diagnostic output here, which is a delicate
# thing to do.  If a test failure occurs, ensure the diagnostic message
# text hasn't changed before assuming a deeper logic problem.

echo "checking detection of invalid character on line 1"
count=$(echo "$output" | grep -c "refer:.*/62124.ref:1:.*code 129")
test $count -eq 2 || wail

echo "checking detection of first invalid character on line 2"
count=$(echo "$output" | grep -c "refer:.*/62124.ref:2:.*code 136")
test $count -eq 2 || wail

echo "checking detection of second invalid character on line 2"
count=$(echo "$output" | grep -c "refer:.*/62124.ref:2:.*code 137")
test $count -eq 2 || wail

echo "checking detection of first invalid character on line 3"
count=$(echo "$output" | grep -c "refer:.*/62124.ref:3:.*code 136")
test $count -eq 2 || wail

echo "checking detection of second invalid character on line 3"
count=$(echo "$output" | grep -c "refer:.*/62124.ref:3:.*code 137")
test $count -eq 2 || wail

# Problems with the input file should also be accurately located.

echo "checking detection of 1st invalid refer(1) command in input file"
echo "$output" | grep -q "refer:.*:4:.*unknown command" || wail

echo "checking detection of 2nd invalid refer(1) command in input file"
echo "$output" | grep -q "refer:.*:9:.*unknown command" || wail

test -z "$fail" || exit 1

# vim:set ai et sw=4 ts=4 tw=72:
