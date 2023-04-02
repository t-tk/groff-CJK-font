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

groff="${abs_top_builddir:-.}/test-groff"

input=$(cat <<EOF
.TH ridonk 1 2021-10-31 "groff test suite"
.SH Name
ridonk \- check the typesetting of absurdly long URIs
.SH Description
.UR https://\:www\:.adobe\:.com/\:content/\:dam/\:acom/\:en/\:devnet/\:\
actionscript/\:articles/\:5001\:.DSC_Spec\:.pdf
Commerce
.UE ,
n.:
A kind of transaction in which A plunders from B the goods of C,
and for compensation B picks the pocket of D of money belonging to E.
.P
.UR https://1\:2\:3\:4\:5\:6\:7\:8\:9\:1\:1\:2\:3\:4\:5\:6\:7\:8\:9\:\
2\:1\:2\:3\:4\:5\:6\:7\:8\:9\:3\:1\:2\:3\:4\:5\:6\:7\:8\:9\:4\:1\:2\:\
3\:4\:5\:6\:7\:8\:9\:5\:1\:2\:3\:4\:5\:6\:7\:8\:9\:6\:1\:2\:3\:4\:5\:\
6\:7\:8\:9\:7\:1\:2\:3\:4\:5\:6\:7\:8\:9\:8\:1\:2\:3\:4\:5\:6\:7\:8\:\
9\:9\:1\:2\:3\:4\:5\:6\:7\:8\:9\:0
.UE
EOF
)

fail=

wail () {
    echo "...$* FAILED" >&2
    fail=yes
}

output=$(printf "%s" "$input" | "$groff" -Tascii -P-cbou -man)
echo "$output"
error=$(printf "%s" "$input" \
    | "$groff" -Tascii -P-cbou -man -ww -z 2>&1)

echo "testing that no diagnostic messages are produced" >&2
test -z "$error" || wail
echo "testing that lines break where expected" >&2
break1=$(echo "$output" | grep -x "  *Commerce  *<https.*devnet/")
break2=$(echo "$output" | grep -x "  *actionscript/.* transaction  *in")
break3=$(echo "$output" | grep -x "  *<https.*612")
test -n "$break1" || wail "first break"
test -n "$break2" || wail "second break"
test -n "$break3" || wail "third break"

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
