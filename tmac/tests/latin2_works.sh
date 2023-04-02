#!/bin/sh
#
# Copyright (C) 2022-2023 Free Software Foundation, Inc.
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

fail=

wail () {
    echo "...FAILED $*"
    fail=yes
}

input=$(\
    printf '\\[A ho]\\[ab]\\[/L]\\[S aa]';
    printf '\\[vS]\\[S ac]\\[T ah]\\[Z aa]\\[vZ]\\[Z a.]\n';
    printf '\\[a ho]\\[ho]\\[/l]\\[s aa]';
    printf '\\[vs]\\[s ac]\\[t ah]\\[z aa]\\[a"]\\[vZ]\\[z a.]\n';
    printf '\\[R aa]\\[A ab]\\[L aa]\\[C aa]';
    printf '\\[C ah]\\[E ho]\\[E ah]\\[D ah]\n';
    printf '\\[u0110]\\[N aa]\\[N ah]\\[O a"]';
    printf '\\[R ah]\\[U ao]\\[U a"]\\[T ac]\n';
    printf '\\[r aa]\\[a ab]\\[l aa]\\[c aa]';
    printf '\\[c ah]\\[e ho]\\[e ah]\\[d ah]\n';
    printf '\\[u0111]\\[n aa]\\[n ah]\\[o a"]';
    printf '\\[r ah]\\[u ao]\\[u a"]\\[t ac]\\[a.]\n';
)

output=$(printf "%s\n" "$input" | "$groff" -Tlatin1 -mlatin2 \
    | LC_ALL=C od -t o1)
printf "%s\n" "$output"
printf "$output" \
    | grep -Eq '^0000000 +241 242 243 246 251 252 253 254 256 257 +' \
    || wail "in block 0xA0"
printf "$output" \
    | grep -Eq '^0000000 +.* 261 262 263 266 271$' \
    || wail "in block 0xB0 (address 0..017)"
printf "$output" \
    | grep -Eq '^0000020 +272 273 274 275 256 277 +' \
    || wail "in block 0xB0 (address 020..037)"
printf "$output" \
    | grep -Eq '^0000020 +.* 300 303 305 306 310 312 314 317 040$' \
    || wail "in block 0xC0"
printf "$output" \
    | grep -Eq '^0000040 +320 321 322 325 330 331 333 336 +' \
    || wail "in block 0xD0"
printf "$output" \
    | grep -Eq '^0000040 +.* 340 343 345 346 350 352 354$' \
    || wail "in block 0xE0 (address 040..057)"
printf "$output" \
    | grep -Eq '^0000060 +357 +' \
    || wail "in block 0xE0 (address 060..077)"
printf "$output" \
    | grep -Eq \
        '^0000060 +.* 360 361 362 365 370 371 373 376 377( 012)+$' \
    || wail "in block 0xF0"

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
