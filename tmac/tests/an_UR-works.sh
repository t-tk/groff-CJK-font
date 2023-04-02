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

fail=

wail() {
    echo ...FAILED >&2
    fail=yes
}

input='.TH foo 1 2022-11-22 "groff test suite"
.SH Name
foo \- frobnicate a bar
.SH Description
See
.UR http://\:foo\:.example\:.com
figure 1
.UE .
.
Or
.UR http://\:bar\:.example\:.com
.UE .'

output=$(printf "%s\n" "$input" | "$groff" -Tascii -P-cbou -man -rU0)
echo "$output"

echo "checking formatting of web URI with link text" \
    "(hyperlinks disabled)" >&2
echo "$output" | grep -Fq 'See figure 1 <http://foo.example.com>.' \
    || wail

echo "checking formatting of web URI with no link text" \
    "(hyperlinks disabled)" >&2
echo "$output" | grep -Fq 'Or <http://bar.example.com>.' || wail

output=$(printf "%s\n" "$input" | "$groff" -Tascii -P-cbou -man -rU1)
echo "$output"

echo "checking formatting of web URI with link text" \
    "(hyperlinks enabled)" >&2
echo "$output" | grep -Fq 'See figure 1.' || wail

echo "checking formatting of web URI with no link text" \
    "(hyperlinks enabled)" >&2
echo "$output" | grep -Fq 'Or http://bar.example.com.' || wail

input='.TH foo 1 2022-12-04 "groff test suite"
.SH Name
foo \- frobnicate a bar
.SH "See also"
For our SOSP presentation,
check our
.UR https://\:example\:.com
website
.UE .'

output=$(printf "%s\n" "$input" | "$groff" -man -Thtml)
echo "$output"

echo "checking HTML output of web URI" >&2
echo "$output" \
    | grep -Fqx '<a href="https://example.com">website</a>.</p>' \
    || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
