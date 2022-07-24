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

# Regression-test Savannah #58992.
#
# Our man macros should no longer attempt to read the .l register on
# nroff devices to set the line length.  That register may or may not
# have been set by a user .ll request; we can't tell whether a value of
# 65n came from nroff or the user.
#
# Instead, the LL register must be used to set the line length.
#
# In this test we _expect_ the .ll request to be ignored and overridden.
# We choose a value that is not nroff's default nor man's default.

EXAMPLE='
.ll 70n
.TH ll\-hell 1 2020-08-22 "groff test suite"
.SH Name
ll\-hell \- see how long the lines are
.SH Description
LL=\n[LL]u
.PP
\&.l=\n[.l]u'

printf "%s\n" "$EXAMPLE" | "$groff" -Tascii -P-cbou -man \
    | grep -q 'LL=1872u'

# vim:set ai et sw=4 ts=4 tw=72:
