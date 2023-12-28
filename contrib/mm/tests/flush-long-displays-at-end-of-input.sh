#!/bin/sh
#
# Copyright (C) 2023 Free Software Foundation, Inc.
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

# Regression-test Savannah #64336.
#
# Emit keeps at end of input even if they internally break the page.

# Double backslashes since this variable goes to printf(1).
input='.P
The modern conservative is engaged in one of man'"'"'s oldest exercises
in moral philosophy;
that is,
the search for a superior moral justification for selfishness.
.br
.nr Ds 0 \\" Turn off vertical space before & after displays.
.\\" This display is exactly long enough to float past the next
.\\" non-displayed line on DWB 3.3 nroff/mm.  Heirloom Doctools loses the
.\\" display entirely, no matter what its length, and puts a spurious
.\\" blank line on the output, too.
.DF
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
.\\" With 3 more lines, groff 1.22.4 mm loses the display, too.  In
.\\" 1.23.0+Git, the display floats as it should and no text is lost.
.if \\n(.g \\{\\
47
48
49
.\\}
.DE
\\(em J.\\& K.\\& Galbraith'

output=$(printf "$input\n" | "$groff" -mm -Tascii -P-cbou)
echo "$output"
echo "$output" | grep -q 49

# vim:set ai et sw=4 ts=4 tw=72:
