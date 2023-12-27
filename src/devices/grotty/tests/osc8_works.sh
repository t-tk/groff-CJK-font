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

grotty="${abs_top_builddir:-.}/grotty"

fail=

wail () {
  echo "...FAILED" >&2
  fail=yes
}

input="x T utf8
x res 240 24 40
x init
p1
x font 1 R
f1
s10
V40
H0
md
DFd
tA
n40 0
x X tty: link
x X tty: link h
x X tty: link http://example.com/1
x X tty: link
x X tty: link http://example.com/2
tB
x X tty: link
x X tty: link mailto:g.branden.robinson@gmail.com
tBranden
x X tty: link
x trailer
V2640
x stop"

# We expect diagnostics from the first few "x X tty: link" lines.  The
# first should complain about a link ending without having been started.
# The second is bogus ("h") but it's not grotty's job to validate the
# structure of a URI.  The third should draw complaint because we didn't
# end the (bogus) URI that we started with the second.

# The remaining input is well-formed.  The URI ending in "1" is
# effectively hidden because no character cells are drawn while it is
# active.
echo "expect two diagnostic messages regarding ill-formed links" >&2
output=$(echo "$input" | "$grotty" -F font -F build/font | od -t c)

# Expected:
#0000000   A 033   ]   8   ;   ; 033   \ 033   ]   8   ;   ;   h 033   \
#0000020 033   ]   8   ;   ; 033   \ 033   ]   8   ;   ;   h   t   t   p
#0000040   :   /   /   e   x   a   m   p   l   e   .   c   o   m   /   1
#0000060 033   \ 033   ]   8   ;   ; 033   \ 033   ]   8   ;   ;   h   t
#0000100   t   p   :   /   /   e   x   a   m   p   l   e   .   c   o   m
#0000120   /   2 033   \   B 033   ]   8   ;   ; 033   \ 033   ]   8   ;
#0000140   ;   m   a   i   l   t   o   :   g   .   b   r   a   n   d   e
#0000160   n   .   r   o   b   i   n   s   o   n   @   g   m   a   i   l
#0000200   .   c   o   m 033   \   B   r   a   n   d   e   n 033   ]   8
#0000220   ;   ; 033   \  \n  \n  \n  \n  \n  \n  \n  \n  \n  \n  \n  \n
#0000240  \n  \n  \n  \n  \n  \n  \n  \n  \n  \n  \n  \n  \n  \n  \n  \n
#*
#0000320  \n  \n  \n  \n  \n  \n
#0000326

echo "testing for URI that corresponds to no character cells" >&2
echo "$output" | grep -Eq 'A 033 +] +8 +; +; +033 +\\' || wail

echo "testing http URI (1)" >&2
echo "$output" \
    | grep -Eq '0000020 +.*033 +] +8 +; +; +h + t +t +p' || wail

echo "testing http URI (2)" >&2
echo "$output" \
    | grep -Eq '0000040 +: +/ +/ +e +x +a +m +p +l +e +\. +c' || wail

echo "testing http URI (3)" >&2
echo "$output" | grep -Eq '0000040.* +o +m +/ +1' || wail

echo "testing http URI (4)" >&2
echo "$output" | grep -Eq '0000060 +033 +\\' || wail

echo "testing mailto URI (1)" >&2
echo "$output" | grep -Eq '0000120 +.* +033 +] +8 +;$' || wail

echo "testing mailto URI (2)" >&2
echo "$output" \
    | grep -Eq '0000140 +; +m +a +i +l +t +o +: +g +\. +b' || wail

echo "testing mailto URI (3)" >&2
echo "$output" | grep -Eq '0000140.* +r +a +n +d +e$' || wail

echo "testing mailto URI (4)" >&2
echo "$output" \
    | grep -Eq '0000160 +n +\. +r +o +b +i +n +s +o +n +@' || wail

echo "testing mailto URI (5)" >&2
echo "$output" | grep -Eq '0000160.* +g +m +a +i +l$' || wail

echo "testing mailto URI (6)" >&2
echo "$output" \
    | grep -Eq '0000200 +\. +c +o +m +033 +\\ +B +r +a +n +d' || wail

echo "testing mailto URI (7)" >&2
echo "$output" | grep -Eq '0000200.* +e +n +033 +] +8$' || wail

echo "testing mailto URI (8)" >&2
echo "$output" | grep -Eq '0000220 +; +; +033 +\\' || wail

test -z "$fail"

# vim:set autoindent expandtab shiftwidth=2 tabstop=2 textwidth=72:
