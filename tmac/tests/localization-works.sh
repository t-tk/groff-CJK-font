#!/bin/sh
#
# Copyright (C) 2021 Free Software Foundation, Inc.
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
    echo "...FAILED" >&2
    fail=YES
}

input='.tm .hy=\\n[.hy]'

output=$(echo "$input" | "$groff" -Tascii -P-cbou -mcs 2>&1)
echo 'checking raw troff with -mcs' >&2
echo "$output" | grep -Fqx '.hy=1' || wail

output=$(echo "$input" | "$groff" -Tascii -P-cbou -mde 2>&1)
echo 'checking raw troff with -mde' >&2
echo "$output" | grep -Fqx '.hy=1' || wail

output=$(echo "$input" | "$groff" -Tascii -P-cbou -men 2>&1)
echo 'checking raw troff with -men' >&2
echo "$output" | grep -Fqx '.hy=4' || wail

output=$(echo "$input" | "$groff" -Tascii -P-cbou -mfr 2>&1)
echo 'checking raw troff with -mfr' >&2
echo "$output" | grep -Fqx '.hy=4' || wail

output=$(echo "$input" | "$groff" -Tascii -P-cbou -mit 2>&1)
echo 'checking raw troff with -mit' >&2
echo "$output" | grep -Fqx '.hy=1' || wail

output=$(echo "$input" | "$groff" -Tascii -P-cbou -msv 2>&1)
echo 'checking raw troff with -msv' >&2
echo "$output" | grep -Fqx '.hy=32' || wail

output=$(echo "$input" | "$groff" -Tascii -P-cbou -me -mcs 2>&1)
echo 'checking -me with -mcs' >&2
echo "$output" | grep -Fqx '.hy=2' || wail

output=$(echo "$input" | "$groff" -Tascii -P-cbou -me -mde 2>&1)
echo 'checking -me with -mde' >&2
echo "$output" | grep -Fqx '.hy=2' || wail

output=$(echo "$input" | "$groff" -Tascii -P-cbou -me -men 2>&1)
echo 'checking -me with -men' >&2
echo "$output" | grep -Fqx '.hy=6' || wail

output=$(echo "$input" | "$groff" -Tascii -P-cbou -me -mfr 2>&1)
echo 'checking -me with -mfr' >&2
echo "$output" | grep -Fqx '.hy=6' || wail

output=$(echo "$input" | "$groff" -Tascii -P-cbou -me -mit 2>&1)
echo 'checking -me with -mit' >&2
echo "$output" | grep -Fqx '.hy=2' || wail

output=$(echo "$input" | "$groff" -Tascii -P-cbou -me -msv 2>&1)
echo 'checking -me with -msv' >&2
echo "$output" | grep -Fqx '.hy=34' || wail

output=$(echo "$input" | "$groff" -Tascii -P-cbou -ms -mcs 2>&1)
echo 'checking -ms with -mcs' >&2
echo "$output" | grep -Fqx '.hy=2' || wail

output=$(echo "$input" | "$groff" -Tascii -P-cbou -ms -mde 2>&1)
echo 'checking -ms with -mde' >&2
echo "$output" | grep -Fqx '.hy=2' || wail

output=$(echo "$input" | "$groff" -Tascii -P-cbou -ms -men 2>&1)
echo 'checking -ms with -men' >&2
echo "$output" | grep -Fqx '.hy=6' || wail

output=$(echo "$input" | "$groff" -Tascii -P-cbou -ms -mfr 2>&1)
echo 'checking -ms with -mfr' >&2
echo "$output" | grep -Fqx '.hy=6' || wail

output=$(echo "$input" | "$groff" -Tascii -P-cbou -ms -mit 2>&1)
echo 'checking -ms with -mit' >&2
echo "$output" | grep -Fqx '.hy=2' || wail

output=$(echo "$input" | "$groff" -Tascii -P-cbou -ms -msv 2>&1)
echo 'checking -ms with -msv' >&2
echo "$output" | grep -Fqx '.hy=34' || wail

input='.TH foo 1 2022-01-06 "groff test suite"
.tm .hy=\\n[.hy]'

output=$(echo "$input" | "$groff" -Tascii -P-cbou -rcR=0 -man -mcs 2>&1)
echo 'checking -man with -rcR=0 -mcs' >&2
echo "$output" | grep -Fqx '.hy=2' || wail

output=$(echo "$input" | "$groff" -Tascii -P-cbou -rcR=0 -man -mde 2>&1)
echo 'checking -man with -rcR=0 -mde' >&2
echo "$output" | grep -Fqx '.hy=2' || wail

output=$(echo "$input" | "$groff" -Tascii -P-cbou -rcR=0 -man -men 2>&1)
echo 'checking -man with -rcR=0 -men' >&2
echo "$output" | grep -Fqx '.hy=6' || wail

output=$(echo "$input" | "$groff" -Tascii -P-cbou -rcR=0 -man -mfr 2>&1)
echo 'checking -man with -rcR=0 -mfr' >&2
echo "$output" | grep -Fqx '.hy=6' || wail

output=$(echo "$input" | "$groff" -Tascii -P-cbou -rcR=0 -man -mit 2>&1)
echo 'checking -man with -rcR=0 -mit' >&2
echo "$output" | grep -Fqx '.hy=2' || wail

output=$(echo "$input" | "$groff" -Tascii -P-cbou -rcR=0 -man -msv 2>&1)
echo 'checking -man with -rcR=0 -msv' >&2
echo "$output" | grep -Fqx '.hy=34' || wail

output=$(echo "$input" | "$groff" -Tascii -P-cbou -rcR=1 -man -mcs 2>&1)
echo 'checking -man with -rcR=1 -mcs' >&2
echo "$output" | grep -Fqx '.hy=1' || wail

output=$(echo "$input" | "$groff" -Tascii -P-cbou -rcR=1 -man -mde 2>&1)
echo 'checking -man with -rcR=1 -mde' >&2
echo "$output" | grep -Fqx '.hy=1' || wail

output=$(echo "$input" | "$groff" -Tascii -P-cbou -rcR=1 -man -men 2>&1)
echo 'checking -man with -rcR=1 -men' >&2
echo "$output" | grep -Fqx '.hy=4' || wail

output=$(echo "$input" | "$groff" -Tascii -P-cbou -rcR=1 -man -mfr 2>&1)
echo 'checking -man with -rcR=1 -mfr' >&2
echo "$output" | grep -Fqx '.hy=4' || wail

output=$(echo "$input" | "$groff" -Tascii -P-cbou -rcR=1 -man -mit 2>&1)
echo 'checking -man with -rcR=1 -mit' >&2
echo "$output" | grep -Fqx '.hy=1' || wail

output=$(echo "$input" | "$groff" -Tascii -P-cbou -rcR=1 -man -msv 2>&1)
echo 'checking -man with -rcR=1 -msv' >&2
echo "$output" | grep -Fqx '.hy=32' || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
