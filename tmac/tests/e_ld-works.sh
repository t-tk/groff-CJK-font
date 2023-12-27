#!/bin/sh
#
# Copyright (C) 2021-2023 Free Software Foundation, Inc.
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
The day was \*(dw, \*(td.
.++ A
.+c "How to Write for The Toast"
.pp
Submit it on spec.'

fail=

wail () {
    echo "...FAILED" >&2
    fail=YES
}

output=$(printf "%s\n" "$input" | "$groff" -Tascii -P-cbou -me)
output_cs=$(printf "%s\n" "$input" | "$groff" -Tutf8 -P-cbou -me -mcs)
output_de=$(printf "%s\n" "$input" | "$groff" -Tutf8 -P-cbou -me -mde)
output_es=$(printf "%s\n" "$input" \
    | "$groff" -Tutf8 -P-cbou -me -mes -a)
output_fr=$(printf "%s\n" "$input" | "$groff" -Tutf8 -P-cbou -me -mfr)
output_it=$(printf "%s\n" "$input" | "$groff" -Tutf8 -P-cbou -me -mit)
output_ru=$(printf "%s\n" "$input" \
    | "$groff" -Tutf8 -P-cbou -me -mru -a)
output_sv=$(printf "%s\n" "$input" | "$groff" -Tutf8 -P-cbou -me -msv)

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

# Spanish localization
echo "$output_es"
echo 'checking that `td` string updated correctly for Spanish' >&2
echo "$output_es" \
    | grep -q 'The day was lunes, 15 de diciembre de 2008\.$' || wail

echo 'checking for correct Spanish "Chapter" string' >&2
echo "$output_es" | grep -Eqx " +Cap<'i>tulo 1" || wail

echo 'checking for correct Spanish "Appendix" string' >&2
echo "$output_es" | grep -Eqx ' +Anexo A' || wail

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

# Russian localization
echo 'checking that `td` string updated correctly for Russian' >&2
echo "$output_ru" | sed -n '4p' \
    | grep -Fqx ' The day was <u043F><u043E><u043D><u0435><u0434><u0435><u043B><u044C><u043D><u0438><u043A>, 15 <u0434><u0435><u043A><u0430><u0431><u0440><u044F> 2008.' \
    || wail

echo 'checking for correct Russian "Chapter" string' >&2
echo "$output_ru" | sed -n '2p' \
    | grep -Fqx ' <u0413><u043B><u0430><u0432><u0430> 1' || wail

echo 'checking for correct Russian "Appendix" string' >&2
echo "$output_ru" | sed -n '6p' \
    | grep -Fqx ' <u041F><u0440><u0438><u043B><u043E><u0436><u0435><u043D><u0438><u044F> A' \
    || wail

# Swedish localization
echo 'checking that `td` string updated correctly for Swedish (1)' >&2
echo "$output_sv" | grep -q 'The day was m' || wail

echo 'checking that `td` string updated correctly for Swedish (2)' >&2
echo "$output_sv" | grep -q 'ndag, 15 december 2008\.$' || wail

echo 'checking for correct Swedish "Chapter" string' >&2
echo "$output_sv" | grep -Eqx ' +Kapitel 1' || wail

echo 'checking for correct Swedish "Appendix" string' >&2
echo "$output_sv" | grep -Eqx ' +Bilaga A' || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
