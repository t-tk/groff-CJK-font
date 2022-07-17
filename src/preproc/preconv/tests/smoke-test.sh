#!/bin/sh
#
# Copyright (C) 2020 Free Software Foundation, Inc.
#
# This file is part of groff.
#
# groff is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# groff is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

# Ensure a predictable character encoding.
export LC_ALL=C

set -e

preconv="${abs_top_builddir:-.}/preconv"

echo "testing -e flag override of BOM detection" >&2
printf '\376\377\0\100\0\n' \
    | "$preconv" -d -e euc-kr 2>&1 > /dev/null \
    | grep -q "no search for coding tag"

echo "testing detection of UTF-32BE BOM" >&2
printf '\0\0\376\377\0\0\0\100\0\0\0\n' \
    | "$preconv" -d 2>&1 > /dev/null \
    | grep -q "found BOM"

echo "testing detection of UTF-32LE BOM" >&2
printf '\377\376\0\0\100\0\0\0\n\0\0\0' \
    | "$preconv" -d 2>&1 > /dev/null \
    | grep -q "found BOM"

echo "testing detection of UTF-16BE BOM" >&2
printf '\376\377\0\100\0\n' \
    | "$preconv" -d 2>&1 > /dev/null \
    | grep -q "found BOM"

echo "testing detection of UTF-16LE BOM" >&2
printf '\377\376\100\0\n\0' \
    | "$preconv" -d 2>&1 > /dev/null \
    | grep -q "found BOM"

echo "testing detection of UTF-8 BOM" >&2
printf '\357\273\277@\n' \
    | "$preconv" -d 2>&1 > /dev/null \
    | grep -q "found BOM"

# We do not find a coding tag on piped input because it isn't seekable.
echo "testing detection of Emacs coding tag in piped input" >&2
printf '.\\" -*- coding: euc-kr; -*-\\n' \
    | "$preconv" -d 2>&1 >/dev/null \
    | grep -q "no coding tag"

# We need uchardet to work to get past this point.
echo "testing uchardet detection of encoding" >&2
"$preconv" -v | grep -q 'with uchardet support' || exit 77

# Instead of using temporary files, which in all fastidiousness means
# cleaning them up even if we're interrupted, which in turn means
# setting up signal handlers, we use files in the build tree.

doc=contrib/mm/groff_mmse.7
echo "testing uchardet detection on Latin-1 document $doc" >&2
"$preconv" -d -D us-ascii 2>&1 >/dev/null $doc \
    | grep -q 'charset: ISO-8859-1'

# uchardet can't seek on a pipe either.
echo "testing uchardet detection on pipe (expect fallback to -D)" >&2
printf 'Eat at the caf\351.\n' \
    | "$preconv" -d -D euc-kr 2>&1 > /dev/null \
    | grep -q "encoding used: 'EUC-KR'"

# Fall back to the locale.  preconv assumes Latin-1 for C instead of
# US-ASCII.
echo "testing fallback to locale setting in environment" >&2
printf 'Eat at the caf\351.\n' \
    | "$preconv" -d 2>&1 > /dev/null \
    | grep -q "encoding used: 'ISO-8859-1'"
