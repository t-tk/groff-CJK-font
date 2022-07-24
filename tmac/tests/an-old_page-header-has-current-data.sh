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
# groff is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

groff="${abs_top_builddir:-.}/test-groff"

# Misconfiguration of traps or our man(7) implementation's page-flushing macros,
# or poor ordering of logic in its TH macro, can cause page headers to render
# with incorrect information.

INPUT='.TH foo 1 2021-05-16 "groff test suite" "Volume 1"
.SH Name
foo \- a frobnicating thing
.TH bar 1 2021-05-16 "groff test suite" "Volume 2"
.SH Name
bar \- a wretched hive of scum and villainy'

OUTPUT=$(echo "$INPUT" | "$groff" -Tascii -P-cbou -man)
echo "$OUTPUT"

FAIL=

if ! echo "$OUTPUT" | grep -Eqx 'foo\(1\) +Volume 1 +foo\(1\)'
then
    FAIL=yes
    echo "first page header test failed (continuous rendering on)" >&2
fi

if ! echo "$OUTPUT" | sed '1,/^groff test suite/d' \
    | grep -Eqx 'bar\(1\) +Volume 2 +bar\(1\)'
then
    FAIL=yes
    echo "second page header test failed (continuous rendering on)" >&2
fi

OUTPUT=$(echo "$INPUT" | "$groff" -Tascii -P-cbou -man -rcR=0)
echo "$OUTPUT"

if ! echo "$OUTPUT" | grep -Eqx 'foo\(1\) +Volume 1 +foo\(1\)'
then
    FAIL=yes
    echo "first page header test failed (continuous rendering off)" >&2
fi

if ! echo "$OUTPUT" | sed '1,/^groff test suite/d' \
    | grep -Eqx 'bar\(1\) +Volume 2 +bar\(1\)'
then
    FAIL=yes
    echo "second page header test failed (continuous rendering off)" >&2
fi

test -z "$FAIL"

# vim:set ai et sw=4 ts=4 tw=80:
