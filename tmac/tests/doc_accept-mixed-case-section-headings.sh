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

# Ensure we recognize mixed-case section headings ("Name" as well as
# "NAME").

EXAMPLE='\
.Dd September 14, 2020
.Dt mdoc\-test 7
.Os
.Sh Name
.Nm mdoc\-test
.Nd a smoke test for groff'"'"'s mdoc implementation
.Sh Description
This page has mixed-case section headings.
.Pp
This paragraph works around Savannah #59106.
.Dd September 14, 2020
.Dt mdoc\-test 7
.Os
.Sh NAME
.Nm mdoc\-test
.Nd a smoke test for groff'"'"'s mdoc implementation
.Sh DESCRIPTION
This page has fully-capitalized section headings.\
'

OUTPUT=$(printf "%s\n" "$EXAMPLE" | "$groff" -Tascii -P-cbou -mdoc)
FAIL=

if [ -z "$(echo "$OUTPUT" | sed -n '/Name/{N;/smoke/p;}')" ]
then
    FAIL=yes
    echo "section \"Name\" check failed" >&2
fi

if [ -z "$(echo "$OUTPUT" | sed -n '/Description/{N;/mixed-case/p;}')" ]
then
    FAIL=yes
    echo "section \"Description\" check failed" >&2
fi

if [ -z "$(echo "$OUTPUT" | sed -n '/NAME/{N;/smoke/p;}')" ]
then
    FAIL=yes
    echo "section \"NAME\" check failed" >&2
fi

if [ -z "$(echo "$OUTPUT" | sed -n '/DESCRIPTION/{N;/fully-cap/p;}')" ]
then
    FAIL=yes
    echo "section \"DESCRIPTION\" check failed" >&2
fi

test -z "$FAIL"

# vim:set ai et sw=4 ts=4 tw=72:
