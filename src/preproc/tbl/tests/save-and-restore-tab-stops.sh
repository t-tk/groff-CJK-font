#!/bin/sh
#
# Copyright (C) 2020 Free Software Foundation, Inc.
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

# Regression-test Savannah #42978.
#
# When tbl changes the tab stops, it needs to restore them.
#
# Based on an example by Bjarni Igni Gislason.

input='.TH tbl\-tabs\-test 1 2020-10-20 "groff test suite"
.SH Name
tbl\-tabs\-test \- see if tbl messes up the tab stops
.SH Description
Do not use tabs in man pages outside of
.BR .TS / .TE
regions.
.PP
But	if	you	do.\|.\|.
.PP
.TS
l l l.
table entries	long enough	to change the tab stops
.TE
.PP
.EX
#!/bin/sh
case $#
1)
	if foo
	then
		bar
	else
		if baz
		then
			qux
		fi
	fi
;;
esac
.EE'

output=$(printf "%s\n" "$input" | "$groff" -Tascii -P-cbou -t -man)
echo "$output"

fail=

if ! echo "$output" | grep -Eq '^ {10}if foo$'
then
    fail=yes
    echo "first tab stop is wrong" >&2
fi

if ! echo "$output" | grep -Eq '^ {15}bar$'
then
    fail=yes
    echo "second tab stop is wrong" >&2
fi

if ! echo "$output" | grep -Eq '^ {20}qux$'
then
    fail=yes
    echo "third tab stop is wrong" >&2
fi

test -z "$fail"

# vim:set ai noet sw=4 ts=4 tw=72:
