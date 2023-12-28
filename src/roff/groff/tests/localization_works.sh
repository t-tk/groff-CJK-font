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

DOC='\*[locale]'

echo "testing default localization (English)" >&2
OUTPUT=$(echo "$DOC" | "$groff" -Tascii)
echo "$OUTPUT" | grep -qx english

echo "testing Czech localization" >&2
OUTPUT=$(echo "$DOC" | "$groff" -Tascii -m cs)
echo "$OUTPUT" | grep -qx czech

echo "testing German localization" >&2
OUTPUT=$(echo "$DOC" | "$groff" -Tascii -m de)
echo "$OUTPUT" | grep -qx german

echo "testing English localization" >&2
OUTPUT=$(echo "$DOC" | "$groff" -Tascii -m en)
echo "$OUTPUT" | grep -qx english

echo "testing Spanish localization" >&2
OUTPUT=$(echo "$DOC" | "$groff" -Tascii -m es)
echo "$OUTPUT" | grep -qx spanish

echo "testing French localization" >&2
OUTPUT=$(echo "$DOC" | "$groff" -Tascii -m fr)
echo "$OUTPUT" | grep -qx french

echo "testing Italian localization" >&2
OUTPUT=$(echo "$DOC" | "$groff" -Tascii -m it)
echo "$OUTPUT" | grep -qx italian

echo "testing Japanese localization" >&2
OUTPUT=$(echo "$DOC" | "$groff" -Tascii -m ja)
echo "$OUTPUT" | grep -qx japanese

echo "testing Russian localization" >&2
OUTPUT=$(echo "$DOC" | "$groff" -Tascii -m ru)
echo "$OUTPUT" | grep -qx russian

echo "testing Swedish localization" >&2
OUTPUT=$(echo "$DOC" | "$groff" -Tascii -m sv)
echo "$OUTPUT" | grep -qx swedish

echo "testing Chinese localization" >&2
OUTPUT=$(echo "$DOC" | "$groff" -Tascii -m zh)
echo "$OUTPUT" | grep -qx chinese
