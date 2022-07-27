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

# Test the `ld` macro.

input='.nr yr 108
.nr mo 12
.nr dy 15
.nr dw 2
.ld
.++ C
.+c "Fleeing the Impoverished, Drunken Countryside for Dublin"
.pp
The day was \\*(dw, \\*(td.
.++ A
.+c "How to Write for The Toast"
.pp
Submit it on spec.'

fail=

wail () {
    echo "...FAILED" >&2
    fail=YES
}

output=$(echo "$input" | "$groff" -Tascii -P-cbou -me)
output_cs=$(echo "$input" | "$groff" -Tutf8 -P-cbou -me -mcs)
output_de=$(echo "$input" | "$groff" -Tutf8 -P-cbou -me -mde)
output_fr=$(echo "$input" | "$groff" -Tutf8 -P-cbou -me -mfr)
output_it=$(echo "$input" | "$groff" -Tutf8 -P-cbou -me -mit)
output_sv=$(echo "$input" | "$groff" -Tutf8 -P-cbou -me -msv)

echo 'checking that `td` string updated correctly for English' >&2
echo "$output" | grep -q 'The day was Monday, December 15, 2008\.$' \
    || wail

echo 'checking for correct English "Chapter" string' >&2
echo "$output" | grep -Eqx ' +Chapter 1' || wail

echo 'checking for correct English "Appendix" string' >&2
echo "$output" | grep -Eqx ' +Appendix A' || wail

# POSIX grep (as of Issue 7) does not provide any locale-independent
# mechanism for matching 8-bit characters--they do not even match "any"
# character ('.').  When checking the date strings, we therefore skip
# them.  (Fortunately, at present, none of the translations of "Chapter"
# or "Appendix" require non-Basic Latin letters.)

# Czech localization
echo 'checking that `td` string updated correctly for Czech (1)' >&2
echo "$output_cs" | grep -q 'The day was Pond' || wail

echo 'checking that `td` string updated correctly for Czech (2)' >&2
echo "$output_cs" | grep -q ', 15 Prosinec 2008\.$' || wail

echo 'checking for correct Czech "Chapter" string' >&2
echo "$output_cs" | grep -Eqx ' +Kapitola 1' || wail

echo 'checking for correct Czech "Appendix" string' >&2
echo "$output_cs" | grep -Eqx ' +Dodatek A' || wail

# German localization
echo 'checking that `td` string updated correctly for German' >&2
echo "$output_de" \
    | grep -q 'The day was Montag, 15\. Dezember\. 2008\.$' || wail

echo 'checking for correct German "Chapter" string' >&2
echo "$output_de" | grep -Eqx ' +Kapitel 1' || wail

echo 'checking for correct German "Appendix" string' >&2
echo "$output_de" | grep -Eqx ' +Anhang A' || wail

# French localization
echo 'checking that `td` string updated correctly for French (1)' >&2
echo "$output_fr" | grep -q 'The day was Lundi, 15 D'

echo 'checking that `td` string updated correctly for French (2)' >&2
echo "$output_fr" | grep -q 'cembre 2008\.$' || wail

echo 'checking for correct French "Chapter" string' >&2
echo "$output_fr" | grep -Eqx ' +Chapitre 1' || wail

echo 'checking for correct French "Appendix" string' >&2
echo "$output_fr" | grep -Eqx ' +Annexe A' || wail

# Italian localization
echo 'checking that `td` string updated correctly for Italian' >&2
echo "$output_it" | grep -q 'The day was Lunedì, 15 Dicembre 2008\.$'

echo 'checking for correct Italian "Chapter" string' >&2
echo "$output_it" | grep -Eqx ' +Capitolo 1' || wail

echo 'checking for correct Italian "Appendix" string' >&2
echo "$output_it" | grep -Eqx ' +Appendice A' || wail

# Swedish localization
echo 'checking that `td` string updated correctly for Swedish (1)' >&2
echo "$output_sv" | grep -q 'The day was m'

echo 'checking that `td` string updated correctly for Swedish (2)' >&2
echo "$output_sv" | grep -q 'ndag, 15 december 2008\.$' || wail

echo 'checking for correct Swedish "Chapter" string' >&2
echo "$output_sv" | grep -Eqx ' +Kapitel 1' || wail

echo 'checking for correct Swedish "Appendix" string' >&2
echo "$output_sv" | grep -Eqx ' +Bilaga A' || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
