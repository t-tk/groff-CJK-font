#!/bin/sh
#
# Copyright (C) 2021-2023 Free Software Foundation, Inc.
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

fail=

wail () {
    echo ...FAILED >&2
    fail=YES
}

# Regression-test Savannah #60874.
#
# groff should start up in any supported locale, in compatibility mode
# or not, without producing diagnostics.

# Keep preconv from being run.
#
# The "unset" in Solaris /usr/xpg4/bin/sh can actually fail.
if ! unset GROFF_ENCODING
then
    echo "unable to clear environment; skipping" >&2
    exit 77
fi

for compat in "" " -C"
do
  for locale in cs de en fr it ja sv zh
  do
    echo testing \"-m $locale$compat\" >&2
    output=$("$groff" -ww -m $locale$compat -a </dev/null 2>/dev/null)
    error=$("$groff" -ww -m $locale$compat -z </dev/null 2>&1)
    test -n "$error" && echo "$error"
    test -n "$output" && echo "$output"
    test -n "$error$output" && wail
  done
done

test -z "$fail"

# vim:set autoindent expandtab shiftwidth=4 tabstop=4 textwidth=72:
