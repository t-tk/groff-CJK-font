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

# Regression-test Savannah #60612.
#
# Bad values of FT should not trash headers and footers.
EXAMPLE_PAGE_1='.TH foo 1 2021-05-17 "groff foo test"
.SH Name
foo \- frobnicate bits'

EXAMPLE_PAGE_2='.TH bar 1 2021-05-17 "groff bar test"
.SH Name
bar \- what they say north of Macedonia'

# We turn off continuous rendering (-rcR=0) so that FT influences where the page
# footer is output.
INPUT=$(printf "%s\n" \
    "$EXAMPLE_PAGE_1" \
    "$EXAMPLE_PAGE_2" \
)

# FT tells our man(7) where to write the page footer.
#
# -0.5i is the default and should always work.
#
# 0 (in any units) is not sane.  It would step on ("hide") the header trap among
# other problems.
#
# 0.5i (positive) is a likely input from a confused user (I've done it).
#
# "Reasonable" positive values are conceivable but there may not be any user
# demand for them.  ("Always break for the footer at 3i [or 3c] regardless of
# the page length"?)
#
# Somewhere between -0.51v (bad) and -0.55v (okay) a problem gets caused.
#
# Traps that aren't in the page area (-20i, 500c for conventional paper sizes)
# don't get sprung.

for FT in -0.5i -1i 0i 0.5i -0.51v -0.55v 10i -20i
do
    OUTPUT=$(echo "$INPUT" | "$groff" -Tascii -P-cbou -man -rcR=0 -rFT=$FT)
    FAIL=

    if ! echo "$OUTPUT" | grep -qE 'foo\(1\) +General Commands Manual +foo\(1\)'
    then
        FAIL=yes
        echo "first page header test failed (FT=$FT)" >&2
    fi

    if ! echo "$OUTPUT" | grep -qE 'groff foo test +2021-05-17 +1'
    then
        FAIL=yes
        echo "first page footer test failed (FT=$FT)" >&2
    fi

    if ! echo "$OUTPUT" | grep -qE 'bar\(1\) +General Commands Manual +bar\(1\)'
    then
        FAIL=yes
        echo "second page header test failed (FT=$FT)" >&2
    fi

    test -z "$FAIL"

    if ! echo "$OUTPUT" | grep -qE 'groff bar test +2021-05-17 +1'
    then
        FAIL=yes
        echo "second page footer test failed (FT=$FT)" >&2
    fi
done

test -z "$FAIL"

# vim:set ai et sw=4 ts=4 tw=80:
