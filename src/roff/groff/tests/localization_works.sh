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

set -e

export LC_ALL LANG

DOC='\*[locale]'

# Test fallback/conflicting cases.

echo "testing that LC_ALL= LANG= loads English localization" >&2
LC_ALL=
LANG=
OUTPUT=$(echo "$DOC" | "$groff" -Tascii)
echo "$OUTPUT" | grep -qx english

echo "testing that LC_ALL=en_US loads English localization" >&2
LC_ALL=en_US
LANG=
OUTPUT=$(echo "$DOC" | "$groff" -Tascii)
echo "$OUTPUT" | grep -qx english

echo "testing that LC_ALL=en_US LANG=fr_FR loads English localization" \
  >&2
LC_ALL=en_US
LANG=fr_FR
OUTPUT=$(echo "$DOC" | "$groff" -Tascii)
echo "$OUTPUT" | grep -qx english

# Test straightforward cases.

echo "testing that LC_ALL= LANG=cs_CZ loads Czech localization" >&2
LC_ALL=
LANG=cs_CZ
OUTPUT=$(echo "$DOC" | "$groff" -Tascii)
echo "$OUTPUT" | grep -qx czech

echo "testing that LC_ALL= LANG=de_DE loads German localization" >&2
LC_ALL=
LANG=de_DE
OUTPUT=$(echo "$DOC" | "$groff" -Tascii)
echo "$OUTPUT" | grep -qx german

echo "testing that LC_ALL= LANG=en_US loads English localization" >&2
LC_ALL=
LANG=en_US
OUTPUT=$(echo "$DOC" | "$groff" -Tascii)
echo "$OUTPUT" | grep -qx english

echo "testing that LC_ALL= LANG=fr_FR loads French localization" >&2
LC_ALL=
LANG=fr_FR
OUTPUT=$(echo "$DOC" | "$groff" -Tascii)
echo "$OUTPUT" | grep -qx french

echo "testing that LC_ALL= LANG=ja_JP loads Japanese localization" >&2
LC_ALL=
LANG=ja_JP
OUTPUT=$(echo "$DOC" | "$groff" -Tascii)
echo "$OUTPUT" | grep -qx japanese

echo "testing that LC_ALL= LANG=sv_SE loads Swedish localization" >&2
LC_ALL=
LANG=sv_SE
OUTPUT=$(echo "$DOC" | "$groff" -Tascii)
echo "$OUTPUT" | grep -qx swedish

echo "testing that LC_ALL= LANG=zh_ZH loads Chinese localization" >&2
LC_ALL=
LANG=zh_ZH
OUTPUT=$(echo "$DOC" | "$groff" -Tascii)
echo "$OUTPUT" | grep -qx chinese
