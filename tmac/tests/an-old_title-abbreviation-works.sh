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

# Regression-test Savannah #43532.
#
# Excessively long man page titles can overrun other parts of the titles
# (headers and footers).  Verify abbreviation of ones that would.

FAIL=

INPUT='.TH foo 1 2021-05-31 "groff test suite"
.SH Name
foo \- a command with a very short name'

OUTPUT=$(echo "$INPUT" | "$groff" -Tascii -P-cbou -man)

if ! echo "$OUTPUT" \
    | grep -Eq 'foo\(1\) +General Commands Manual +foo\(1\)'
then
    FAIL=yes
    echo "short page title test failed" >&2
fi

INPUT='.TH CosNotifyChannelAdmin_StructuredProxyPushSupplier 3erl \
2021-05-31 "groff test suite" "Erlang Module Definition"
.SH Name
CosNotifyChannelAdmin_StructuredProxyPushSupplier \- OMFG'

OUTPUT=$(echo "$INPUT" | "$groff" -Tascii -P-cbou -man)

TITLE_ABBV="CosNotif...hSupplier(3erl)"
PATTERN="$TITLE_ABBV Erlang Module Definition $TITLE_ABBV"

if ! echo "$OUTPUT" | grep -Fq "$PATTERN"
then
    FAIL=yes
    echo "long page title test failed" >&2
fi

test -z "$FAIL"

# vim:set ai et sw=4 ts=4 tw=72:
