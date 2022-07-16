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

# Regression-test Savannah #59348.
#
# Ensure that .R actually handles its arguments.

EXAMPLE=\
'.LP
of the form
.I
.R * id\\c module
.R
\&.
'

# That \c's a killer.  Can't use echo.
printf "%s" "$EXAMPLE" \
    | "$groff" -Tascii -P-cbou -ms \
    | grep -Fqx 'of the form module*id.'

# vim:set ai et sw=4 ts=4 tw=72:
