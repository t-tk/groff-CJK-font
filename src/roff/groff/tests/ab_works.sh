#!/bin/sh
#
# Copyright (C) 2021-2022 Free Software Foundation, Inc.
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

# Verify exit status and regression-test Savannah #60782.
#
# We don't test the the X11 devices because groff launches an X client,
# which has to be killed.  Using "-z" to avoid this masks the bug.

for d in ascii cp1047 dvi html latin1 lbp lj4 pdf ps utf8
do
  echo "verifying exit status of .ab request using $d device" >&2
  printf '.ab\n' | "$groff" -T$d
  test $? -eq 1 || exit 1
done

echo "verifying empty output of .ab request with no arguments" >&2
OUT=$(printf '.ab\n' | "$groff" -Tascii 2>&1)
test "$OUT" = "" || exit 1

echo "verifying that arguments to .ab request go to stderr" >&2
OUT=$(printf '.ab foo\n' | "$groff" -Tascii 2>&1 > /dev/null)
test "$OUT" = "foo" || exit 1

# vim:set autoindent expandtab shiftwidth=2 tabstop=2 textwidth=72:
