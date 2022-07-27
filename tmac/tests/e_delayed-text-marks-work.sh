#!/bin/sh
#
# Copyright (C) 2021 Free Software Foundation, Inc.
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

groff="${abs_top_builddir:-.}/test-groff"

set -e

# Ensure that delayed text marks increment and reset as they should.

input='.pp
paragraph 1
.(d
\*# foo
.)d
.(d
\*# bar
.)d
.pd
.(d
\*# baz
.)d
.pp
paragraph 2
.(d
\*# qux
.)d
.pd
.pp
paragraph 3'

output=$(echo "$input" | "$groff" -Tascii -P-cbou -me)

echo "$output" | grep -Fx '[1] foo'
echo "$output" | grep -Fx '[2] bar'
echo "$output" | grep -Fx '[1] baz'
echo "$output" | grep -Fx '[2] qux'

# vim:set ai et sw=4 ts=4 tw=72:
