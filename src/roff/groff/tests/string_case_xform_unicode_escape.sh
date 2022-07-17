#!/usr/bin/env bash
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

# The following is what we expect in the future when we support Unicode
# case transformations.
expected="attaché ATTACHÉ"

# For now, we expect problems like this:
# troff: backtrace: '<standard input>':4: string 'attache'
# troff: backtrace: file '<standard input>':5
# troff: <standard input>:5: warning: can't find special character
#     'U0065_0301'

actual=$("$groff" -Tutf8 2>&1 > /dev/null <<EOF
.pl 1v
.ds attache attach\\[u0065_0301]\\\"
\\*[attache]
.stringup attache
\\*[attache]
EOF
)

diff -u <(echo "$expected") <(echo "$actual")
