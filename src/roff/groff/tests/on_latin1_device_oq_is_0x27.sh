#!/bin/sh
#
# Copyright (C) 2019-2020 Free Software Foundation, Inc.
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

# This test fails with some versions of GNU Bash, such as 3.2; the here
# document nested within a command substitution confuses it.
#
# https://lists.gnu.org/archive/html/bug-bash/2017-02/msg00024.html

expected="' = '"
actual=$(printf '.pl 1v\n\\[oq] = '"'"'\n' | "$groff" -Tlatin1)
test "$actual" = "$expected"
