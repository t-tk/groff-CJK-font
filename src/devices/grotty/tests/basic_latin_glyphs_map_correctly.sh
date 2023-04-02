#!/bin/sh
#
# Copyright (C) 2022 Free Software Foundation, Inc.
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
    printf "FAILED " >&2
    fail=YES
}

# Ensure that characters are mapped to glyphs normatively.

input='x T @DEVICE@
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
t!#$%&()*+,./0123456789:;<=>?@
n40 0
V80
H0
tABCDEFGHIJKLMNOPQRSTUVWXYZ[]_
n40 0
V120
H0
tabcdefghijklmnopqrstuvwxyz{|}
n40 0
V160
H0
tneutral
wh24
tdouble
wh24
tquote:
wh24
Cdq
h24
n40 0
V200
H0
tclosing
wh24
tsingle
wh24
tquote:
wh24
t'"'"'
n40 0
V240
H0
thyphen:
wh24
t-
n40 0
V280
H0
tbackslash:
wh24
Crs
h24
n40 0
V320
H0
tmodifier
wh24
tcircumflex:
wh24
t^
n40 0
V360
H0
topening
wh24
tsingle
wh24
tquote:
wh24
t`
n40 0
V400
H0
tmodifier
wh24
ttilde:
wh24
t~
n40 0
x trailer
V2640
x stop'

# TODO: Test cp1047 when we have access to a host environment using it.

for D in ascii latin1 utf8
do
    if [ "$D" = "utf8" ]
    then
        # We can't test UTF-8 if the environment doesn't support it.
        if [ "$(locale charmap)" != UTF-8 ]
        then
            # If we've already seen a failure case, report it.
            if [ -n "$fail" ]
            then
                exit 1 # fail
            else
                exit 77 # skip
            fi
        fi
    fi

    printf 'checking "%s" output device...' $D >&2
    output=$(echo "$input" | sed s/@DEVICE@/$D/ \
        | "$grotty" -F font -F build/font)
    printf 'group1 ' >&2
    echo "$output" | grep -Fqx '!#$%&()*+,./0123456789:;<=>?@' || wail
    printf 'group2 ' >&2
    echo "$output" | grep -Fqx 'ABCDEFGHIJKLMNOPQRSTUVWXYZ[]_' || wail
    printf 'group3 ' >&2
    echo "$output" | grep -Fqx 'abcdefghijklmnopqrstuvwxyz{|}' || wail
    printf '" ' >&2
    echo "$output" | grep -Fqx 'neutral double quote: "' || wail
    printf '\\ ' >&2
    echo "$output" | grep -Fqx 'backslash: \' || wail
    case $D in
    (utf8)
# Expected:
#0000000   !   #   $   %   &   (   )   *   +   ,   .   /   0   1   2   3
#0000020   4   5   6   7   8   9   :   ;   <   =   >   ?   @  \n   A   B
#0000040   C   D   E   F   G   H   I   J   K   L   M   N   O   P   Q   R
#0000060   S   T   U   V   W   X   Y   Z   [   ]   _  \n   a   b   c   d
#0000100   e   f   g   h   i   j   k   l   m   n   o   p   q   r   s   t
#0000120   u   v   w   x   y   z   {   |   }  \n   n   e   u   t   r   a
#0000140   l       d   o   u   b   l   e       q   u   o   t   e   :
#0000160   "  \n   c   l   o   s   i   n   g       s   i   n   g   l   e
#0000200       q   u   o   t   e   :     342 200 231  \n   h   y   p   h
#0000220   e   n   :     342 200 220  \n   b   a   c   k   s   l   a   s
#0000240   h   :       \  \n   m   o   d   i   f   i   e   r       c   i
#0000260   r   c   u   m   f   l   e   x   :     313 206  \n   o   p   e
#0000300   n   i   n   g       s   i   n   g   l   e       q   u   o   t
#0000320   e   :     342 200 230  \n   m   o   d   i   f   i   e   r
#0000340   t   i   l   d   e   :     313 234  \n
#0000352
        output_od=$(echo "$output" | LC_ALL=C od -t c)
        printf "' " >&2
        printf '%s\n' "$output_od" \
            | grep -Eq '0000200 +q +u +o +t +e +: +342 +200 +231' \
            || wail
        printf '` ' >&2
        printf '%s\n' "$output_od" \
            | grep -Eq '0000320 +e +: +342 +200 +230' || wail
        printf "%s " '-' >&2
        printf '%s\n' "$output_od" \
            | grep -Eq '0000220 +e +n +: +342 +200 +220' || wail
        printf '^ ' >&2
        printf '%s\n' "$output_od" \
            | grep -Eq '0000260 +r +c +u +m +f +l +e +x +: +313 +206' \
            || wail
        printf "~ " >&2
        printf '%s\n' "$output_od" \
            | grep -Eq '0000340 +t +i +l +d +e +: +313 +234' || wail
        ;;
    (*)
        printf '` ' >&2
        echo "$output" | grep -Fqx 'opening single quote: `' || wail
        printf "' " >&2
        echo "$output" | grep -Fqx "closing single quote: '" || wail
        printf "%s " '-' >&2
        echo "$output" | grep -Fqx "hyphen: -" || wail
        printf '^ ' >&2
        echo "$output" | grep -Fqx "modifier circumflex: ^" || wail
        printf "~ " >&2
        echo "$output" | grep -Fqx "modifier tilde: ~" || wail
        ;;
    esac
    echo >&2
done

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
