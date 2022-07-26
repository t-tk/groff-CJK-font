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

input=$(cat <<EOF
.TH foo 1 2021-11-05 "groff test suite"
.TP
.UR https://\:github.com/\:Alhadis/\:Roff\:.js/
.I Roff.js
.UE
is a viewer for intermediate output written in JavaScript.
EOF
)

fail=

wail () {
    echo "...FAILED" >&2
    fail=YES
}

# Check for regressions when OSC 8 disabled
uflag=-rU0

output=$(printf "%s" "$input" \
    | "$groff" -bww -Tascii -P-cbou $uflag -man)

echo "checking for paragraph tag on line by itself ($uflag)" >&2
echo "$output" | grep -qx '       Roff\.js' || wail # 7 spaces

echo "checking for presence of typeset URI ($uflag)" >&2
echo "$output" \
    | grep -q '^              <https://github\.com/Alhadis/Roff\.js/>' \
    || wail # 14 spaces

output=$(printf "%s" "$input" \
    | "$groff" -bww -Tascii -P-cbou -rU0 -rLL=130n -man)

# Sloppy handling of UE, ME macro arguments can cause unwanted space.
echo "checking for normative (no extra) spacing after URI ($uflag)" >&2
echo "$output" | grep -q '> is a viewer for intermediate' || wail

# Now check for good formatting when URIs are hyperlinked.
uflag=-rU1

output=$(printf "%s" "$input" \
    | "$groff" -bww -Tutf8 -P-cbou $uflag -man)

echo "checking for paragraph tag on line by itself ($uflag)" >&2
echo "$output" | grep -qx '       Roff\.js' || wail # 7 spaces

# Hyperlinking paragraph tags was not supported in groff 1.22.4 and
# still isn't.
#echo "checking for absence of typeset URI" >&2
#! echo "$output" | grep -q https || wail

output=$(printf "%s" "$input" \
    | "$groff" -bww -Tascii -P-cbou $uflag -rLL=130n -man)

echo "checking for normative (no extra) spacing after URI ($uflag)" >&2
# This is what we expect when linking the tag works.
#echo "$output" \
#    | grep -q '^              is a viewer for intermediate' \
#    || wail # 14 spaces
# ...but in the meantime...
echo "$output" | grep -q '[^[:space:]] is a viewer for' || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
