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

# Verify that the characters trailing the period are all transparent for
# purposes of end-of-sentence recognition.  We use UTF-8 so we won't get
# warnings about \[dg] and \[dd] missing from other encodings.
#
# Also confirm that we get _two_ spaces after the end of a sentence.

"$groff" -Tutf8 <<EOF | grep -qE 'Eat\.[^ ]+  Drink\.'
.pl 1v
Eat."')]*\[dg]\[dd]\[rq]\[cq]
Drink.
EOF
