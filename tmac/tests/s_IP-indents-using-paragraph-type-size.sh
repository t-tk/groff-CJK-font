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
export GROFF_TYPESETTER=

# Regression-test Savannah #59604.
#
# Ensure that the indentation amount used by IP is based on the type
# size of the _paragraph_, not a preceding heading (which might have
# been affected by GROWPS).

EXAMPLE=\
'.nr PSINCR 3p
.nr GROWPS 3
.SH 1
Text
.IP 1. 4
Filling
.IP 2. 4
Sentences'

OUTPUT=$(echo "$EXAMPLE" | "$groff" -ms -Z \
    | sed -n '/^H92000$/{
                         N
                         /\ntFilling$/{
                                       p
                                       b
                                      }
                        }')
test -n "$OUTPUT"

# vim:set ai et sw=4 ts=4 tw=72:
