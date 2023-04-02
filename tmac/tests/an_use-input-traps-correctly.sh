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
    echo "...FAILED" >&2
    fail=YES
}

# Ensure that input trap-using macros employ the correct request.  B, I,
# SH, SS, SM, and SB need `it`; TP needs `itc`.

# B

input=".TH foo 1 2022-06-07 \"groff test suite\"
.B \\\\n[.fn]\c
\\n[.fn]"

output=$(printf "%s\n" "$input" | "$groff" -man -Tascii -P-cbou 2>&1)

echo "checking that B macro uses correct input trap 'it'" >&2
echo "$output" | grep -Fqx 'BR' || wail

# I

input=".TH foo 1 2022-06-07 \"groff test suite\"
.I \\\\n[.fn]\c
\\n[.fn]"

output=$(printf "%s\n" "$input" | "$groff" -man -Tascii -P-cbou 2>&1)

echo "checking that I macro uses correct input trap 'it'" >&2
echo "$output" | grep -Fqx 'IR' || wail

# SH

input=".TH foo 1 2022-06-07 \"groff test suite\"
.SH Name\c
foo \- frobnicate a bar"

output=$(printf "%s\n" "$input" | "$groff" -man -Tascii -P-cbou 2>&1)

echo "checking that SH macro uses correct input trap 'it'" >&2
echo "$output" | grep -Fqx 'Name' || wail

# SS

input=".TH foo 1 2022-06-07 \"groff test suite\"
.SS Limitations\c
Lorem ipsum gitsum voluptatem."

output=$(printf "%s\n" "$input" | "$groff" -man -Tascii -P-cbou 2>&1)

echo "checking that SS macro uses correct input trap 'it'" >&2
echo "$output" | grep -Fqx '   Limitations' || wail # 3 spaces

# SM

input=".TH foo 1 2022-06-07 \"groff test suite\"
.SM \\\\n[.s]\c
\\n[.s]"

output=$(printf "%s\n" "$input" | "$groff" -man -a -Tps 2>&1)

echo "checking that SM macro uses correct input trap 'it'" >&2
echo "$output" | grep -Fqx '910' || wail

# SB

input=".TH foo 1 2022-06-07 \"groff test suite\"
.SB \\\\n[.fn]\\\\n[.s]\c
\\n[.fn]\\n[.s]"

output=$(printf "%s\n" "$input" | "$groff" -man -a -Tps 2>&1)

echo "checking that SB macro uses correct input trap 'it'" >&2
echo "$output" | grep -Fqx 'TB9TR10' || wail

# TP

input=".TH foo 1 2022-06-07 \"groff test suite\"
.TP
.BR \-\-bar [ =\c
.IR baz ]"

output=$(printf "%s\n" "$input" | "$groff" -man -Tascii -P-cbou 2>&1)

echo "checking that TP macro uses correct input trap 'itc'" >&2
echo "$output" | grep -Fqx '       --bar[=baz]' || wail # 7 spaces

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
