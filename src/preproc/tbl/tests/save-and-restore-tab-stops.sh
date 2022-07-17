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

EXAMPLE='.TH tbl\-tabs\-test 1 2020-10-20 "groff test suite"
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

OUTPUT=$(printf "%s\n" "$EXAMPLE" | "$groff" -Tascii -P-cbou -t -man)
FAIL=

if ! echo "$OUTPUT" | grep -Eq '^ {12}if foo$'
then
    FAIL=yes
    echo "first tab stop is wrong" >&2
fi

if ! echo "$OUTPUT" | grep -Eq '^ {17}bar$'
then
    FAIL=yes
    echo "second tab stop is wrong" >&2
fi

if ! echo "$OUTPUT" | grep -Eq '^ {22}qux$'
then
    FAIL=yes
    echo "third tab stop is wrong" >&2
fi

test -z "$FAIL"

# vim:set ai noet sw=4 ts=4 tw=72:
