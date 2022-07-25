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

# This test is based on a contribution by Jim Avera; see
# <https://savannah.gnu.org/bugs/?60802>.

"$groff" -z -ww <<'EOF'
.
.nr debug 1
.de debugmsg
.  if \\n[debug] .tm \\$*
..
.de errormsg
.  tm ERROR: \\$*
.  nr nerrors (\\n[nerrors]+1)
..
.nr nerrors 0
.
.\" .substring xx n1 [n2]
.\"    Replace contents of string named xx with the substring bounded by
.\"    zero-based indicies indices n1 and n2.  Negative indices count
.\"    backwards from the end of the string.  If omitted, n2 is `-1`.
.\"
.\"    If n1 > n2, n1 and n2 are swapped.  If n1 equals or exceeds the
.\"    string length, it is set to `-1`.
.\"
.\"  NOT YET IMPLEMENTED:
.\"    If n1 > n2, or if n1 equals or exceeds the string length, then
.\"    any contents of xx are replaced with the empty string.
.\"
.de jtest \" input_string n1 n2 expected_result
.  if \\n[.$]<4 .ab jtest: expected at least 4 arguments, got \\n[.$]
.  ds t*input "\\$1
.  ds t*n1 \\$2
.  ds t*n2 \\$3
.  ds t*expected "\\$4
.  shift 4
.  ds t*comment "\\$*
.
.  ds t*str "\\*[t*input]
.  ie '\\*[t*n2]'' .substring t*str \\*[t*n1]
.  el              .substring t*str \\*[t*n1] \\*[t*n2]
.  ie '\\*[t*str]'\\*[t*expected]' \{\
.    debugmsg .substring '\\*[t*input]' \\*[t*n1] \\*[t*n2] -> \
'\\*[t*str]' (OK) \\*[t*comment]
.  \}
.  el \{\
.    errormsg .substring '\\*[t*input]' \\*[t*n1] \\*[t*n2] yielded \
'\\*[t*str]', EXPECTED '\\*[t*expected]' \\*[t*comment]
.  \}
..
.
.debugmsg --- Pick a single character from non-empty ---
.jtest "abc" 0 0 "a"
.jtest "abc" 1 1 "b"
.jtest "abc" 2 2 "c"
.
.debugmsg --- Pick multiple characters from non-empty ---
.jtest "abcd" 0 1 "ab"
.jtest "abcd" 1 1 "b"
.jtest "abcd" 0 3 "abcd"
.jtest "abcd" 0 -1 "abcd"
.jtest "abcd" 0 "" "abcd"
.jtest "abcd" 1 3 "bcd"
.jtest "abcd" 2 3 "cd"
.jtest "abcd" 3 3 "d"
.
.debugmsg --- Omit n2 with non-empty input and non-empty result ---
.jtest "abc" 0 "" "abc"
.jtest "abc" 1 "" "bc"
.jtest "abc" 2 "" "c"
.jtest "a"   0 "" "a"
.
.\"debugmsg --- Specify empty substring with n2==(n1-1) ---
.\"jtest "abcd" 3 2 ""
.\"jtest "abcd" 2 1 ""
.\"jtest "abcd" 1 0 ""
.debugmsg --- Pick multiple characters from non-empty using inverted \
range ---
.jtest "abcd" 3 2 "cd"
.jtest "abcd" 2 1 "bc"
.jtest "abcd" 1 0 "ab"
.
.\"debugmsg --- Specify empty substring with n1==length and n2 omitted ---
.\"jtest "abcd" 4 "" ""
.\"jtest "abc" 3 "" ""
.\"jtest "ab" 2 "" ""
.\"jtest "a" 1 "" ""
.\"jtest "" 0 "" ""
.debugmsg --- Pick single character using out-of-bounds start index \
(unless string empty) ---
.jtest "abcd" 4 "" "d"
.jtest "abc" 3 "" "c"
.jtest "ab" 2 "" "b"
.jtest "a" 1 "" "a"
.jtest "" 0 "" ""
.jtest "" 0 -1 ""
.jtest "" 0 -2 ""
.
.if \n[nerrors] .ab Aborting, got \n[nerrors] errors.
EOF
