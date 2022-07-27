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
bibliography $artifact_dir/62124.bib
cattywumpus
.R2
.
.R1
bibliography $artifact_dir/62124.bib
cattywumpus
.R2"

# We want standard error _only_.
output=$(echo "$input" | "$refer" -e -p "$artifact_dir"/62124.bib \
    2>&1 >/dev/null)

# We should get every complaint about the bibliography twice because it
# is dumped twice; the line numbers should not change because they're
# problems with the bibliography file, not the input file.

# We're pattern-matching diagnostic output here, which is a delicate
# thing to do.  If a test failure occurs, ensure the diagnostic message
# text hasn't changed before assuming a deeper logic problem.

echo "checking line number of invalid character on bibliography line 1"
count=$(echo "$output" | grep -c "refer:.*/62124.bib:1:.*code 129")
test $count -eq 2 || wail

echo "checking line number of first invalid character on bibliography" \
  "line 2"
count=$(echo "$output" | grep -c "refer:.*/62124.bib:2:.*code 136")
test $count -eq 2 || wail

echo "checking line number of second invalid character on" \
  "bibliography line 2"
count=$(echo "$output" | grep -c "refer:.*/62124.bib:2:.*code 137")
test $count -eq 2 || wail

echo "checking line number of first invalid character on" \
  "bibliography line 3"
count=$(echo "$output" | grep -c "refer:.*/62124.bib:3:.*code 136")
test $count -eq 2 || wail

echo "checking line number of second invalid character on" \
  "bibliography line 3"
count=$(echo "$output" | grep -c "refer:.*/62124.bib:3:.*code 137")
test $count -eq 2 || wail

# Problems with the input file should also be accurately located.

echo "checking line number of invalid refer(1) command on input line 4"
echo "$output"
echo "$output" | grep -q "refer:.*:4:.*unknown command" || wail

echo "checking line number of invalid refer(1) command on input line 9"
echo "$output"
echo "$output" | grep -q "refer:.*:9:.*unknown command" || wail

# Regression-test Savannah #62391.

output=$(printf '\0201\n' | "$refer" 2>&1 >/dev/null)

echo "checking line number of invalid input character on input line 1"
echo "$output" | grep -q "refer:.*:1:.*invalid input character" \
  || wail

output=$(printf '.R1\nbogus \0200\n.R2\n' | "$refer" 2>&1 >/dev/null)

echo "checking line number of invalid input character after refer(1)" \
  "command on input line 2"
echo "$output" | grep -q "refer:.*:2:.*invalid input character" \
  || wail

output=$(printf '.R1\ndatabase nonexistent.bib\n.R2\n' | "$refer" 2>&1 \
  >/dev/null)

echo "checking line number of attempt to load nonexistent database"
echo "$output" | grep -q "refer:.*:2:.*can't open 'nonexistent\.bib':" \
  || wail

output=$(printf '.R1\ninclude nonexistent.bib\n.R2\n' | "$refer" 2>&1 \
  >/dev/null)

echo "checking line number of attempt to load nonexistent inclusion"
echo "$output" | grep -q "refer:.*:2:.*can't open 'nonexistent\.bib':" \
  || wail
test -z "$fail" || exit 1

# vim:set ai et sw=4 ts=4 tw=72:
