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

set -e

grog="${abs_top_builddir:-.}/grog"
src="${abs_top_srcdir:-..}"

doc=src/preproc/eqn/neqn.1
echo "testing simple man(7) page $doc" >&2
"$grog" "$doc" | \
	    grep -Fqx 'groff -man '"$doc"

doc=src/preproc/tbl/tbl.1
echo "testing tbl(1)-using man(7) page $doc" >&2
"$grog" "$doc" | \
    grep -Fqx 'groff -t -man '"$doc"

doc=man/groff_diff.7
echo "testing eqn(1)-using man(7) page $doc" >&2
"$grog" "$doc" | \
    grep -Fqx 'groff -e -man '"$doc"

# BUG: grog doesn't yet handle .if, .ie, .while.
#doc=src/preproc/soelim/soelim.1
#echo "testing pic(1)-using man(7) page $doc" >&2
#"$grog" "$doc" | \
#    grep -Fqx 'groff -p -man '"$doc"

doc=tmac/groff_mdoc.7
echo "testing tbl(1)-using mdoc(7) page $doc" >&2
"$grog" "$doc" | \
    grep -Fqx 'groff -t -mdoc '"$doc"

doc=$src/doc/meintro.me
echo "testing me(7) document $doc" >&2
"$grog" "$doc" | \
    grep -Fqx 'groff -me '"$doc"

doc=$src/doc/meintro_fr.me
echo "testing tbl(1)-using me(7) document $doc" >&2
"$grog" "$doc" | \
    grep -Fqx 'groff -t -me '"$doc"

doc=$src/doc/meref.me
echo "testing me(7) document $doc" >&2
"$grog" "$doc" | \
    grep -Fqx 'groff -me '"$doc"

doc=$src/doc/grnexmpl.me
echo "testing grn(1)- and eqn(1)-using me(7) document $doc" >&2
"$grog" "$doc" | \
    grep -Fqx 'groff -e -g -me '"$doc"

doc=$src/contrib/mm/examples/letter.mm
echo "testing mm(7) document $doc" >&2
"$grog" "$doc" | \
    grep -Fqx 'groff -mm '"$doc"

doc=$src/contrib/mom/examples/copyright-chapter.mom
echo "testing mom(7) document $doc" >&2
"$grog" "$doc" | \
    grep -Fqx 'groff -mom '"$doc"

doc=$src/contrib/mom/examples/copyright-default.mom
echo "testing mom(7) document $doc" >&2
"$grog" "$doc" | \
    grep -Fqx 'groff -mom '"$doc"

doc=$src/contrib/mom/examples/letter.mom
echo "testing mom(7) document $doc" >&2
"$grog" "$doc" | \
    grep -Fqx 'groff -mom '"$doc"

doc=$src/contrib/mom/examples/mom-pdf.mom
echo "testing mom(7) document $doc" >&2
"$grog" "$doc" | \
    grep -Fqx 'groff -mom '"$doc"

doc=$src/contrib/mom/examples/mon_premier_doc.mom
echo "testing mom(7) document $doc" >&2
"$grog" "$doc" | \
    grep -Fqx 'groff -mom '"$doc"

doc=$src/contrib/mom/examples/sample_docs.mom
echo "testing mom(7) document $doc" >&2
"$grog" "$doc" | \
    grep -Fqx 'groff -mom '"$doc"

doc=$src/contrib/mom/examples/slide-demo.mom
echo "testing mom(7) document $doc" >&2
"$grog" "$doc" | \
    grep -Fqx 'groff -e -p -t -mom '"$doc"

doc=$src/contrib/mom/examples/typesetting.mom
echo "testing mom(7) document $doc" >&2
"$grog" "$doc" | \
    grep -Fqx 'groff -mom '"$doc"

doc=$src/contrib/pdfmark/cover.ms
echo "testing ms(7) document $doc" >&2
"$grog" "$doc" | \
    grep -Fqx 'groff -ms '"$doc"

doc=$src/contrib/pdfmark/pdfmark.ms
echo "testing ms(7) document $doc" >&2
"$grog" "$doc" | \
    grep -Fqx 'groff -ms '"$doc"

doc=$src/doc/ms.ms
echo "testing tbl(1)-using ms(7) document $doc" >&2
"$grog" "$doc" | \
    grep -Fqx 'groff -t -ms '"$doc"

doc=$src/doc/pic.ms
echo "testing tbl(1)-, eqn(1)-, and pic(1)-using ms(7) document $doc" \
    >&2
"$grog" "$doc" | \
    grep -Fqx 'groff -e -p -t -ms '"$doc"

doc=$src/doc/webpage.ms
echo "testing ms(7) document $doc" >&2
# BUG: Should detect -mwww (and -mpspic?) too.
"$grog" "$doc" | \
    grep -Fqx 'groff -ms '"$doc"

# vim:set ai et sw=4 ts=4 tw=72:
