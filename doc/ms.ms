.\" Handle font requests with families, for instance in tbl(1) tables.
.if n \{\
.  ftr CR B \" for a visible distinction from roman
.  ftr CB B
.  ftr CI I
.  ftr CBI BI
.  \" Redefine CW so to use bold instead for a visible font change.
.  als CW B
.\}
.\" This document doesn't require the minus sign but we do want a copy-
.\" and-pastable hyphen-minus.
.char \- \N'45'
.\" A very limited output device might not have a dagger glyph.
.fchar \[dg] *
.\".RP
.ie t .nr LL 6.5i
.el   .nr LL 91n
.nr LT \n[LL]
.nr PS 11
.nr VS 13
.ds FR 1
.nr TC-MARGIN \w'00' \" expect 2-digit page numbers at most
.ie t .nr PI 3.5n
.el   .nr PI 4n
.ND October 2021
.EH '%''October 2021'
.EF ''''
.OH 'Using \f[I]groff\f[] with the \f[I]ms\f[] macros''%'
.OF ''''
.TL
Using
.BI groff
with the
.BI ms
Macro Package
.AU
Larry Kollar
.AI
kollar@alltel.net
.AB no
The
.I ms
(\[lq]manuscript\[rq]) package is suitable for the composition of
letters,
memoranda,
reports,
and books.
.
These
.I groff
macros feature cover page and table of contents generation,
automatic section numbering,
several different paragraph styles,
a variety of text styling options,
footnotes,
multi-column page layouts,
and indexing.
.
.I ms
supports the
.I tbl ,
.I eqn ,
.I pic ,
and
.I refer
preprocessors for inclusion of tables,
mathematical equations,
diagrams,
and standardized bibliographic citations.
.
This implementation is mostly compatible with the documented interface
and behavior of AT&T Version\~7 Unix
.I ms .
.
Several extensions from 4.2BSD (Berkeley)
.\" Few changes were made in 4.3, Tahoe, Reno, or 4.4.
and Version\~10 Research Unix have been recreated.
.AE
.
.
.\" ------------------------- End of cover page ------------------------
.NH 1
Introduction
.XS
Introduction
.XE
.
.
.LP
The
.I ms
macros are the oldest surviving package for
.I roff
systems.\**
.
.FS
Although manual pages are even older,
the
.I man
macros originated in Seventh Edition Unix (1979).
.
.I ms
shipped with Sixth Edition (1975) and was documented by Mike Lesk in a
Bell Labs internal memorandum.
.FE
.
While the
.I man
package was designed for brief documents to be perused at a terminal,
the
.I ms
macros are also suitable for longer documents intended for printing and
possible publication.
.
.
.PP
In this document,
a right arrow (\[->]) is used to indicate a tab character in the input.
.
.
.NH 2
Basic information
.XS
	Basic information
.XE
.
.
.LP
.I ms
exposes many aspects of document layout to user control via
.I groff
registers and strings.
.
Most
.I registers
have a default unit of measurement.
.
Specifying a unit explicitly does not cause problems,
and can avoid them in complex situations.
.
The following table summarizes typical units.
.
.
.TS
box center;
cb cb
cf(CR) l .
Unit	Description
_
i	inches (\[sd])
c	centimeters
p	points (1/72\[sd])
P	picas (1/6\[sd])
v	\[lq]vees\[rq]; height of a line using the current font
n	\[lq]ens\[rq]; width of an \[lq]n\[rq] using the current font
m	\[lq]ems\[rq]; width of an \[lq]M\[rq] using the current font
.TE
.
.
.PP
Set registers with the
.CW .nr
request
and strings with the
.CW .ds
request.
.
.
.TS
box center;
lf(CR).
\&.nr PS 12 \[rs]" Use 12-point type.
\&.ds FAM P \[rs]" Use Palatino font family.
.TE
.
.
.\" ------------------------
.if t .bp
.NH 1
General structure of an
.BI ms
document
.XS
General structure of an
.I ms
document
.XE
.
.
.LP
The
.I ms
macro package expects a certain amount of structure,
but not as much as packages such as
.I man
or
.I mdoc .
.
.
.PP
The simplest documents can begin with a paragraph macro
(such as
.CW .LP
or
.CW .PP ),
and consist of text separated by paragraph macros
or even blank lines.
.
Longer documents have a structure as follows.
.
.
.IP "\fBDocument type\fP"
If you call the
.CW .RP
macro at the beginning of your document,
.I ms
prints the document description on its own page;
otherwise it prints the information
(if any)
on the first page with your document text immediately following.
.
Some document types found in other
.I ms
implementations are specific to AT&T or Berkeley,
and are not supported in
.I "groff ms" .
.
.
.IP "\fBFormat and layout\fP"
By setting registers,
you can change your document's type (font and size),
margins, spacing, headers and footers, and footnotes.
.
See section \[lq]Document control settings\[rq] below.
.
.
.IP "\fBDocument description\fP"
A document description consists of any of:
a title,
one or more authors' names and affiliated institutions,
an abstract, and a date or other identifier.
.
See section \[lq]Document description macros\[rq] below.
.
.
.IP "\fBBody\fP"
The main matter of your document follows its description
(if any).
.
You can use the
.I ms
macros to write reports, letters, books, and so forth.
The package is designed for structured documents,
consisting of paragraphs interspersed with headings
and augmented by lists, footnotes, tables, and other
common constructs.
.
See section \[lq]Body text\[rq] below.
.
.
.IP "\fBTable of contents\fP"
Longer documents include a table of contents,
which you can invoke by placing the
.CW .TC
macro at the end of your document.\**
.FS
The
.I ms
macros have minimal indexing facilities, consisting of the
.CW .IX
macro, which prints an entry on standard error.
.FE
.
Printing the table of contents at the end is necessary since
GNU
.I troff
is a single-pass text formatter;
it thus cannot determine the page number of a division of the text until
it has been set and output.
.
Since
.I ms
output was intended for hardcopy,
the standard procedure was to manually relocate the pages containing
the table of contents between the cover page and the
body text.
.
.
.\" ------------------------
.if t .bp
.NH 1
Document control settings
.XS
Document control settings
.XE
.
.
.LP
A list of document control registers and strings follows.
.
They are presented in the syntax used to interpolate them.
.
For any parameter whose default is unsatisfactory,
define its register,
string,
or special character before calling any
.I ms
macro other than
.CW RP .
.
.
.TS H
box;
cb | cb cb cb cb
l | lf(CR) lx l lf(CR).
Type	Parameter	Definition	Effective	Default
_
.TH
Margins	\[rs]n[PO]	Page offset (left margin)	next page	1i
\^	\[rs]n[LL]	Line length	next paragraph	6i
\^	\[rs]n[LT]	Title line length	next paragraph	6i
\^	\[rs]n[HM]	Top (header) margin	next page	1i
\^	\[rs]n[FM]	Bottom (footer) margin	next page	1i
_
T{
Titles
.br
(headers,
.br
footers)
T}	\[rs]*[LH]	Left header text	next header	\f[I]empty
\^	\[rs]*[CH]	Center header text	next header	\-\[rs]n[%]\-
\^	\[rs]*[RH]	Right header text	next header	\f[I]empty
\^	\[rs]*[LF]	Left footer text	next footer	\f[I]empty
\^	\[rs]*[CF]	Center footer text	next footer	\f[I]empty
\^	\[rs]*[RF]	Right footer text	next footer	\f[I]empty
_
Text	\[rs]n[PS]	Point size	next paragraph	10p
\^	\[rs]n[VS]	Vertical spacing (leading)	next paragraph	12p
\^	\[rs]n[HY]	Hyphenation mode	next paragraph	6
\^	\[rs]*[FAM]	Font family	next paragraph	T
_
Paragraphs	\[rs]n[PI]	Indentation	next paragraph	5n
\^	\[rs]n[PD]	Paragraph distance (spacing)	next paragraph	0.3v \f[R](\f[]1v\f[R])
\^	\[rs]n[QI]	Quotation indentation	next paragraph	5n
\^	\[rs]n[PORPHANS]	# of initial lines kept	next paragraph	1
_
Headings	\[rs]n[PSINCR]	Point size increment	next heading	1p
\^	\[rs]n[GROWPS]	Size increase level limit	next heading	0
\^	\[rs]n[HORPHANS]	# of following lines kept	next heading	1
\^	\[rs]*[SN\-STYLE]	Numbering style (alias)	next heading	\[rs]*[SN\-DOT]
_
Footnotes	\[rs]n[FI]	Indentation	next footnote	2n
\^	\[rs]n[FF]	Format	next footnote	0
\^	\[rs]n[FPS]	Point size	next footnote	\[rs]n[PS]\-2p
\^	\[rs]n[FVS]	Vertical spacing (leading)	next footnote	\[rs]n[FPS]+2p
\^	\[rs]n[FPD]	Paragraph distance (spacing)	next footnote	\[rs]n[PD]/2
\^	\[rs]*[FR]	Line length ratio	\f[I]special	11/12
_
Displays	\[rs]n[DD]	Display distance (spacing)	\f[I]special	0.5v \f[R](\f[]1v\f[R])
\^	\[rs]n[DI]	Display indentation	\f[I]special	0.5i
_
Other	\[rs]n[MINGW]	Minimum gutter width	next page	2n
\^	\[rs]n[TC\-MARGIN]	TOC page number margin width\
	next \f[CR]PX\f[] call	\[rs]w\[aq]000\[aq]
\^	\[rs][TC\-LEADER]	TOC leader character	\
next \f[CR]PX\f[] call	.\[rs]h\[aq]1m\[aq]
.TE
.
.
.LP
For entries marked
.I special
in the \[lq]Effective\[rq] column,
see the discussion in the applicable section below.
.
The
.CW PD
and
.CW DD
registers use the larger value if the vertical resolution of the output
device is too coarse for the smaller one;
usually,
this is the case only for output to terminals and emulators thereof.
.
.
.\" ------------------------
.NH 2
Fractional point sizes
.XS
	Fractional point sizes
.XE
.
.
.LP
AT&T
.I ms
supported only integer values for the type size and vertical spacing.
.
To overcome this restriction,
for the registers
.CW PS ,
.CW VS ,
.CW FPS ,
and
.CW FVS ,
.I "groff ms"
interprets values equal to or larger than\~1000 as decimal fractions
multiplied by\~1000.
.
For example,
.CW ".nr PS 10500" \[rq] \[lq]
sets the document's type size to 10.5\~points.
.
In
.I ms
documents that don't need to be portable to other implementations,
using a scaling indicator,
as in
.CW ".nr PS 10.5p" \[rq], \[lq]
is preferable.
.
.
.\" ------------------------
.bp
.NH 1
Document description macros
.XS
Document description macros
.XE
.
.
.LP
All but the simplest documents bear a title.\**
.
.FS
Distinguish a document title from \[lq]titles\[rq],
which are what
.I roff
systems call headers and footers collectively.
.FE
.
As their level of sophistication
(or complexity)
increases,
they tend to acquire dates of revision,
explicitly identified authors,
sponsoring institutions for authors,
and,
at the rarefied heights,
an abstract of their content.
.
Define these data by calling the macros below in the order shown;
.CW .DA
or
.CW .ND
can be called to set the document date
(or other identifier)
at any time before (a) the abstract,
if present,
or (b) its information is required in a header or footer.
.
Use of these macros is optional,
except that
.CW .TL
is mandatory if any of
.CW .RP ,
.CW .AU ,
.CW .AI ,
or
.CW .AB
is called,
and
.CW .AE
is mandatory if
.CW .AB
is called.
.
.
.TS H
box;
lb lb
lf(CR) lx.
Macro	Description
_
.TH
\&.RP \f[R][\f[]no\f[R]]	T{
Use the \[lq]report\[rq]
(AT&T: \[lq]released paper\[rq])
format for your document,
creating a separate cover page.
.
The default arrangement is to print most of the document description
(title,
author names and institutions,
and abstract,
but not the date)
at the top of page\~1.
.
If the optional
.CW no
argument is given,
.I ms
prints a cover page but does not repeat any of its information on
page\~1
(but see the
.CW DA
macro below regarding the date).
T}
_
\&.TL	T{
Specify the document title.
.
.I ms
collects text on input lines following a call to this macro into the
title until reaching an
.CW .AU ,
.CW .AB ,
or heading or paragraph macro call.
T}
_
\&.AU	T{
Specify an author's name.
.
.I ms
collects text on input lines following a call to this macro into the
author's name until reaching an
.CW .AI ,
.CW .AB ,
another
.CW .AU ,
or heading or paragraph macro call.
.
Call it repeatedly to specify multiple authors.
T}
_
\&.AI	T{
Specify the preceding author's institution.
.
An
.CW .AU
call is usefully followed by at most one
.CW .AI
call;
if there are more,
the last
.CW .AI
call controls.
.
.I ms
collects text on input lines following a call to this macro into the
author's institution until reaching an
.CW .AU ,
.CW .AB ,
or heading or paragraph macro call.
T}
_
\&.DA \f[R][\f[I]x\f[] .\|.\|.\&]	T{
Print the current date,
or any
.I x , arguments\~
in the center footer,
and,
if
.CW .RP
is also called,
left-aligned after other document description information on the cover
page.
T}
_
\&.ND \f[R][\f[I]x\f[] .\|.\|.\&]	T{
Print the current date,
or any
.I x , arguments\~
if
.CW .RP
is also called,
left-aligned after other document description information on the cover
page.
.
This is the
.I "groff ms"
default.
T}
_
\&.AB \f[R][\f[]no\f[R]]	T{
Begin the abstract.
.
.I ms
collects text on input lines following a call to this macro into the
abstract until reaching an
.CW .AE
call.
.
By default,
.I ms
places the word \[lq]ABSTRACT\[rq] centered and in italics above the
text of the abstract.
.
The optional argument
.CW no
suppresses this heading.
T}
_
\&.AE	End the abstract.
.TE
.
.
.KS
.LP
An example document description,
using a cover page,
follows.
.
.
.\" Wrap lines in the code example below at 64 columns.
.TS
box center;
l.
T{
.nf
.CW
\&.RP
\&.TL
The Inevitability of Code Bloat in Commercial and Free Software
\&.AU
J.\[rs]& Random Luser
\&.AI
University of West Bumblefuzz
\&.AB
This report examines the long-term growth of the code bases in
two large,
popular software packages;
the free Emacs and the commercial Microsoft Word.
While differences appear in the type or order of features added,
due to the different methodologies used,
the results are the same in the end.
\&.PP
The free software approach is shown to be superior in that while
free software can become as bloated as commercial offerings,
free software tends to have fewer serious bugs and the added
features are more in line with user demand.
\&.AE
.R
\&.\|.\|.\|the rest of the paper\|.\|.\|.
.fi
T}
.TE
.KE
.
.
.\" ------------------------
.bp
.NH 1
Body text
.XS
Body text
.XE
.
.
.LP
A variety of macros,
registers,
and strings can be used to structure and style the body of your
document.
.
Examples include paragraphs,
headings,
footnotes,
and inclusions of material such as tables and figures.
.
.
.KS
.NH 2
Text settings
.XS
	Text settings
.XE
.
.
.LP
The
.CW FAM
string sets the font family for body text.
.
If this string is undefined at initialization,
it is set to
.CW T \[rq] \[lq]
(Times).
.
Setting
.CW \[rs]*[FAM]
before the first call of a sectioning,
paragraphing,
or (non-date) document description macro also applies it to headers,
footers,
and footnotes
(as well as the body text).
.
.
.PP
The hyphenation flags
(as used by the
.CW hy
request)
are set using the
.CW HY
register.
.KE
.
.
.KS
.NH 2
Paragraphs
.XS
	Paragraphs
.XE
.
.
.LP
Several paragraph types are available,
differing in how indentation
applies to them:
to left,
right,
or both margins;
to the first output line of the paragraph,
all output lines,
or all but the first.
.
All paragraphing macro calls cause the insertion of vertical space in
the amount stored in the
.CW PD
register,
except at page or column breaks.
.KE
.
.
.PP
The
.CW PORPHANS
register defines the minimum number of initial lines of any paragraph
that must be kept together to avoid orphaned lines at the bottom of a
page.
.
If a new paragraph is started close to the bottom of a page,
and there is insufficient space to accommodate
.CW \[rs]n[PORPHANS]
lines before an automatic page break,
then a page break is forced before the start of the paragraph.
.
This is a GNU extension.
.
.
.TS H
box;
lb lb
lf(CR) lx.
Macro	Description
_
.TH
\&.LP	Set a paragraph without any (additional) indentation.
_
\&.PP	T{
Set a paragraph with a first-line left indentation in the amount stored
in the
.CW PI
register.
T}
_
\&.IP \f[R][\f[I]marker\f[] [\f[I]width\f[]]]	T{
Set a paragraph with a left indentation.
.
The optional
.I marker
is not indented and is empty by default.
.
It has several applications;
see subsection \[lq]Lists\[rq] below.
.
.I width
overrides the default indentation amount stored in
.CW \[rs]n[PI] ;
its default unit is
.CW n \[rq]. \[lq]
.
Once specified,
.I width
applies to further
.CW .IP
calls until specified again or a heading or different paragraphing macro
is called.
T}
_
\&.QP	T{
Set a paragraph indented from both left and right margins by
.CW \[rs]n[QI] .
T}
_
T{
\&.QS
.br
\&.QE
T}	T{
Begin
.CW QS ) (
and end
.CW QE ) (
a region where each paragraph is indented from both margins by
.CW \[rs]n[QI] .
.
The text between
.CW .QS
and
.CW .QE
can be structured further by use of other paragraphing macros.
T}
_
\&.XP	T{
Set an \[lq]exdented\[rq] paragraph\[em]one with a left indentation of
.CW \[rs]n[PI]
on every line
.I except
the first
(also known as a hanging indent).
.
This is a Berkeley extension.
T}
.TE
.
.
.KS
.PP
The following example illustrates several different paragraph macros.
.
.
.TS
box center;
l.
T{
.nf
.CW
\&.NH 2
Cases used in the 2001 study
\&.LP
Two software releases were considered for this report.
\&.PP
The first is commercial software;
the second is free.
\&.IP \[rs][bu]
Microsoft Word for Windows,
starting with version 1.0 through the current version
(Word 2000).
\&.IP \[rs][bu]
GNU Emacs,
from its first appearance as a standalone editor through the
current version (v20).
See [Bloggs 2002] for details.
\&.QP
Franklin\[aq]s Law applied to software:
software expands to outgrow both RAM and disk space over time.
\&.SH
Bibliography
\&.XP
Bloggs, Joseph R.,
\&.I "Everyone\[aq]s a Critic" ,
Underground Press, March 2002.
A definitive work that answers all questions and criticisms
about the quality and usability of free software.
.R
.fi
T}
.TE
.KE
.
.
.NH 2
Headings
.XS
	Headings
.XE
.
.
.LP
Use headings to create a hierarchical structure for your document.
.
The
.I ms
macros print headings in
.B bold
using the same font family and,
by default,
point size as the body text.
.
Headings are available with and without automatic numbering.
.
Text lines immediately after heading macro calls are treated as part of
the heading,
rendered on the same output line in the same style.
.
.
.TS
box;
cb cb
lf(CR) lx .
Macro	Description
_
\&.NH \f[I]level\f[]	T{
Automatically numbered heading.
.
The
.I level
argument instructs
.I ms
to number headings in the form
.CW
.I a .\c
.I b .\c
.R
.I c .\|.\|.,
to any depth desired,
with the numbering of each level increasing automatically and being
reset to zero when a more significant level is increased.
.
\[lq]1\[rq]\~is the most significant or coarsest division of the
document.
.
Only nonzero values are output.
.
If you specify heading levels with a gap in an ascending sequence,
such as by
.CW ".NH\~1" \[rq] \[lq]
and then
.CW ".NH\~3" \[rq] \[lq]
as the next such call,
.I "groff ms"
emits a warning on the standard error stream.
T}
\&.NH S \f[I]heading-level-index\f[]\f[R] .\|.\|.\f[]	T{
Alternatively,
a first argument
.CW S "" of\~
can be given,
followed by integral arguments to number the levels of the heading
explicitly.
.
Further automatic numbering,
if used,
resumes using the specified heading level indices as their predecessors.
.
.\" Although undocumented in Tuthill's 4.2BSD ms.diffs paper...
This feature is a Berkeley extension.
T}
.TE
.
.
.PP
An example may be illustrative.
.
.
.TS
box center;
cb | cb
lf(CR) | lB.
Input	Result
_
T{
.nf
\&.NH 1
Animalia
\&.NH 2
Arthropoda
\&.NH 3
Crustacea
\&.NH 2
Chordata
\&.NH S 6 6 6
Daimonia
\&.NH 1
Plantae
.fi
T}	T{
.nf
1.  Animalia
.sp
1.1.  Arthropoda
.sp
1.1.1.  Crustacea
.sp
1.2.  Chordata
.sp
6.6.6.  Daimonia
.sp
7.  Plantae
.fi
T}
.TE
.
.
.PP
After invocation of
.CW .NH ,
the assigned number is made available in the strings
.CW SN\-DOT
(as it appears in a printed heading with default formatting,
followed by a terminating period)
and
.CW SN\-NO\-DOT
(with the terminating period omitted).
.
These are GNU extensions.
.
.
.PP
You can control the style used to print numbered headings by defining an
appropriate alias for the string
.CW SN\-STYLE .
.
By default,
.CW \[rs]*[SN\-STYLE]
is aliased to
.CW \[rs]*[SN\-DOT] .
.
If you prefer to omit the terminating period from numbers appearing in
numbered headings,
you may define the alias as follows.
.
.
.TS
box center;
lf(CR).
\&.als SN\-STYLE SN\-NO\-DOT
.TE
.
.
.LP
Any such change in numbering style becomes effective from the next use
of
.CW .NH
following redefinition of the alias for
.CW \[rs]*[SN\-STYLE] .
.
The formatted number of the current section is available in
.CW \[rs]*[SN]
(a feature first documented by Berkeley),
facilitating its inclusion in
.CW .XS /\c
.CW .XA /\c
.CW .XE
table of contents entries.
.
.
.TS
box;
cb cb
lf(CR) lx .
Macro	Description
_
\&.SH [\f[I]level\f[]]	T{
Unnumbered heading.
.
The optional
.I level
argument is a GNU extension indicating the heading level corresponding
to the
.I level
argument of
.CW .NH .
.
It matches the point size at which the heading is printed to that of a
numbered heading at the same level when the
.CW \[rs]n[GROWPS]
and
.CW \[rs]n[PSINCR]
heading size adjustment mechanism is in effect.
T}
.TE
.
.
.PP
The
.CW PSINCR
register defines an increment in point size to be applied to a heading
at a
.I level
more significant
(numerically less)
than the value specified in
.CW \[rs]n[GROWPS] .
.
The value of
.CW \[rs]n[PSINCR]
should be specified in points with the
.CW p
scaling indicator and may include a fractional component;
for example,
.
.
.TS
box center;
lf(CR).
\&.nr PSINCR 1.5p
.TE
.
.
.LP
sets a point size increment of 1.5 points.
.
.
.PP
The
.CW GROWPS
register defines the heading level at which the point size increment set
by
.CW \[rs]n[PSINCR]
becomes effective.
.
For each heading
.I level
below the value of
.CW \[rs]n[GROWPS] ,
the point size is increased by
.CW \[rs]n[PSINCR] .
.
Setting
.CW \[rs]n[GROWPS]
to a value less than\~2 disables the incremental heading size feature.
.
.
.PP
In other words,
if the
.CW GROWPS
register is greater than the
.I level
argument to a
.CW .NH
or
.CW .SH
call,
the point size of a heading produced by these macros increases by
.CW \[rs]n[PSINCR]
units over
.CW \[rs]n[PS]
multiplied by the difference of
.CW \[rs]n[GROWPS]
and
.I level .
.
.
For example,
the sequence
.
.TS
box center;
lf(CR).
\&.nr PS 10
\&.nr GROWPS 3
\&.nr PSINCR 1.5p
\&.NH 1
Carnivora
\&.NH 2
Felinae
\&.NH 3
Felis catus
\&.SH 2
Machairodontinae
.TE
.
.
.LP
will cause \[lq]1. Carnivora\[rq] to be printed in 13-point text,
followed by \[lq]1.1. Felinae\[rq] in 11.5-point text,
while \[lq]1.1.1. Felis catus\[rq] and all more deeply nested
heading levels will remain in the 10-point text specified by the
.CW PS
register.
.
\[lq]Machairodontinae\[rq] is printed at 11.5 points,
since it corresponds to heading level\~2.
.
.
.PP
The
.CW \[rs]n[HORPHANS]
register operates in conjunction with the
.CW NH
and
.CW SH
macros to inhibit the printing of orphaned headings at the bottom of a
page;
it specifies the minimum number of lines of the subsequent paragraph
that must be kept on the same page as the heading.
.
If insufficient space remains on the current page to accommodate the
heading and this number of lines of paragraph text,
a page break is forced before the heading is printed.
.
Any display macro or
.I tbl ,
.I pic ,
or
.I eqn
region between the heading and the subsequent paragraph suppresses this
grouping.
.
.
.\" The next table is huge and we need a lot of room for it, but we
.\" can't use a keep because it's a boxed repeated-heading table.  Flush
.\" the pending output line and demand half a page.
.br
.ne (\n[.p]u / 2u)
.NH 2
Highlighting
.XS
	Highlighting
.XE
.
.
.LP
The
.I ms
macros provide a variety of methods to highlight or emphasize text.
.
.
.TS H
box;
lb lb
lf(CR) lx.
Macro	Description
_
.TH
\&.B [txt [post [pre]]]	T{
Sets its first argument in
.B "bold type" .
.
If you specify a second argument,
.I groff
prints it in the previous font after the bold text,
with no intervening space
(this allows you to set punctuation after the highlighted text without
highlighting the punctuation).
.
Similarly,
it prints the third argument
(if any)
in the previous font
.B before
the first argument.
.
For example,
.
.
.sp \n[PD]u
.ti +3n
\&.B foo ) (
.
.
.sp \n[PD]u
prints
.B foo ). (
.
.
.sp \n[PD]u
If you give this macro no arguments,
.I groff
prints all text following in bold until the next highlighting,
paragraph,
or heading macro.
T}
_
\&.R [txt [post [pre]]]	T{
Sets its first argument in roman
(or regular)
type.
.
It operates similarly to the
.CW .B
macro otherwise.
T}
_
\&.I [txt [post [pre]]]	T{
Sets its first argument in
.I "italic type" .
.
It operates similarly to the
.CW .B
macro otherwise.
T}
_
\&.BI [txt [post [pre]]]	T{
Sets its first argument in
.BI "bold italic type" .
.
It operates similarly to the
.CW .B
macro otherwise.
.
This is a Version\~10 Research Unix extension.
.\" possibly V9, but definitely not Berkeley
T}
_
\&.CW [txt [post [pre]]]	T{
Sets its first argument in a
.CW constant-width
(monospaced) roman typeface.
.
It operates similarly to the
.CW .B
macro otherwise.
.
This is a Version\~10 Research Unix extension.
.\" possibly V9, but definitely not Berkeley
T}
_
\&.BX [txt]	T{
Prints
.I txt
and draws a
.BX box
around it.
.
On terminal devices,
reverse video is used instead
(see the implementation note below).
.
If you want the argument to contain space,
use non-breaking space escape sequences of appropriate width
.CW \[rs]\[ti] , (
.CW \[rs]\[ha] ,
.CW \[rs]| ,
.CW \[rs]0 ),
or
.CW \[rs]h .
T}
_
\&.UL [txt [post]]	T{
Prints its first argument with an
.UL underline .
.
If you specify a second argument,
.I groff
prints it in the previous font after the underlined text,
with no intervening space.
T}
_
\&.LG	T{
Prints all text following in
.LG
larger type
.NL
(2 points larger than the current point size)
until
the next font size,
highlighting,
paragraph,
or heading macro.
.
You can
.LG
specify this macro
.LG
multiple times
.NL
to enlarge the point size as needed.
T}
_
\&.SM	T{
Prints all text following in
.SM
smaller type
.NL
(2 points smaller than the current point size)
until
the next type size,
highlighting,
paragraph,
or heading macro.
.
You can
.SM
specify this macro
.SM
multiple times
.NL
to reduce the point size as needed.
T}
_
\&.NL	T{
Prints all text following in the normal point size
(that is,
the value of the
.CW PS
register).
T}
.TE
.
.
.PP
Rather than calling the
.CW CW
macro,
in
.I "groff ms"
you might prefer to change the font family to Courier\[em]a monospaced
typeface\[em]by setting
.CW \[rs]*[FAM]
to
.CW C \[rq]. \[lq]
.
You can then use all four style macros above,
returning to the default family (Times) with
.CW ".ds FAM T" \[rq]. \[lq]
.
Because
.CW \[rs]*[FAM]
takes effect at the next paragraph,
this document uses
.CW .CW
to \[lq]inline\[rq] a change to the font family,
marking syntactical elements of
.I ms
and
.I groff .
.
.
.PP
.I "groff ms"
also supports strings to begin and end super- and subscripting.
.
These are all GNU extensions.
.
.
.TS
box;
lb lb
lf(CR) lx.
String	Description
_
\[rs]*{	Begin superscripting.
\[rs]*}	End superscripting.
_
\[rs]*<	Begin subscripting.
\[rs]*>	End subscripting.
.TE
.
.
.nr PS -2
.nr VS -2
.LP
.B1
.hy 0
.I "Implementation note:"
In
.CW nroff
mode,
the
.CW BX
macro \[lq]boxes\[rq] its argument by bracketing it with
.I groff
extension escape sequences to set the foreground color to black and the
background to white and then reset them to their previous values;
the terminal output driver,
.I grotty (1),
converts these to ISO\~6429 color escape sequences,
which may be ignored or mishandled by some terminals,
or may be disabled by
.I grotty 's
.CW \-c
option.
.
Further,
if the terminal is set up to use these colors in those roles already,
.CW .BX
will cause no visible effect in the output.
.
Surmounting these challenges would require adding features to
.I grotty ,
for instance to provide a mechanism to request ISO\~6429's
\[lq]standout\[rq] mode \" That's "smso" and "rmso" in terminfo.
(often supported on monochrome terminals),
or to replace the presumed support of the terminal for ISO\~6429 escape
sequences with the use of a library that can query the capabilities of
the terminal and adapt the output sent to the device accordingly.
.
(Practically,
this likely means adding a dependency on
.CW libtinfo .)
.
Contact the
.I groff
development mailing list if you'd like to contribute.
.sp \n[PD]/2
.B2
.nr PS +2
.nr VS +2
.
.
.NH 2
Lists
.XS
	Lists
.XE
.
.
.LP
The
.I marker
argument to the
.CW IP
macro can be employed to present a variety of lists;
for instance,
you can use a bullet glyph
.CW \[rs][bu] ) (
for unordered lists,
a number
(or auto-incrementing register)
for numbered lists,
or a word or phrase for glossary-style or definition lists.
.
.
.TS H
box center;
cb cb
lf(CR) l .
Input	Result
_
.TH
T{
.nf
A bulleted list:
\&.IP \[rs][bu] 2n
lawyers
\&.IP \[rs][bu]
guns
\&.IP \[rs][bu]
money
.fi
T}	T{
A bulleted list:
.IP \[bu] 2
lawyers
.IP \[bu]
guns
.IP \[bu]
money
T}
_
T{
.nf
\&.nr step 1 1
A numbered list:
\&.IP \\n[step] 3n
lawyers
\&.IP \\n+[step]
guns
\&.IP \\n+[step]
money
.fi
T}	T{
.nr step 1 1
A numbered list:
.IP \n[step]. 3
lawyers
.IP \n+[step].
guns
.IP \n+[step].
money
T}
_
T{
.nf
A glossary-style list:
\&.IP lawyers 0.4i
Two or more attorneys.
\&.IP guns
Firearms,
preferably large-caliber.
\&.IP money
Gotta pay for those
lawyers and guns!
.fi
T}	T{
A glossary-style list:
.
.IP lawyers 0.4i
Two or more attorneys.
.IP guns
Firearms,
preferably large-caliber.
.IP money
Gotta pay for those lawyers and guns!
T}
.TE
.
.
.PP
In the last example above,
observe how the
.CW IP
macro places the definition on the same line as the term if it has
enough space.
.
If this is not what you want,
there are a few workarounds we will illustrate by modifying the example.
.
First,
you can use a
.CW br
request to force a break after printing the term or label.
.
Second,
you could apply the
.CW \[rs]p
escape sequence to force a break.
.
The space following the escape sequence is important;
if you omit it,
.I groff
prints the first word of the paragraph text on the same line as the term
or label
(if it fits)
.I then
breaks the line.
.
Finally,
you may append unbreakable horizontal space to the term or label with
the
.CW \[rs]h
escape sequence;
using the same amount as the indentation will ensure that it's too wide
for
.I groff
to treat it as \[lq]fitting\[rq] on the same line as the paragraph text.
.
.
.TS
box center;
cb | cb | cb
lf(CR) | lf(CR)  | lf(CR).
Approach #1	Approach #2	Approach #3
_
T{
.nf
\&.IP guns
\&.br
Firearms,
.fi
T}	T{
.nf
\&.IP guns
\[rs]p Firearms,
.fi
T}	T{
.nf
\&.IP guns\[rs]h\[aq]0.4i\[aq]
Firearms,
.fi
T}
_
.T&
cb s s
l s s.
Result
_
T{
A glossary-style list:
.
.IP lawyers 0.4i
Two or more attorneys.
.IP guns\h\[aq]0.4i\[aq] 0.4i
Firearms,
preferably large-caliber.
.IP money
Gotta pay for those lawyers and guns!
T}
.TE
.
.
.NH 2
Indented regions
.XS
	Indented regions
.XE
.
.
.LP
You may need to indent a region of text while still letting
.I groff
automatically break lines and fill the text.
.
.
.TS
box;
cb cb
lf(CR) lx .
Macro	Description
_
\&.RS	T{
Begin a region where headings,
paragraphs,
and displays are indented by
.CW \[rs]n[PI] .
T}
\&.RE	T{
End the most recent indented region.
T}
.TE
.
.
.PP
You can use indented regions to line up text under hanging and indented
paragraphs.
.
For example,
you may wish to nest lists.
.
.
.TS
box center;
cb cb
lf(CR)8 l .
Input	Result
_
T{
.nf
.CW
\&.IP \\[bu] 2
Lawyers:
\&.RS
\&.IP \\[bu]
Dewey,
\&.IP \\[bu]
Cheatham,
and
\&.IP \\[bu]
Howe.
\&.RE
\&.IP \\[bu]
Guns
.R
\&.\|.\|.
.fi
T}	T{
.IP \[bu] 2
Lawyers:
.RS
.IP \[bu]
Dewey,
.IP \[bu]
Cheatham,
and
.IP \[bu]
Howe.
.RE
.IP \[bu]
Guns
\&.\|.\|.
T}
.TE
.
.
.NH 2
Keeps, boxed keeps, and displays
.XS
	Keeps, boxed keeps, and displays
.XE
.
.
.LP
On occasion,
you may want to
.I keep
several lines of text,
or a region of a document,
together on a single page,
preventing an automatic page break within certain boundaries.
.
This can cause a page break to occur earlier than it normally would.
.
For example,
you may want to keep two paragraphs together,
or a paragraph that refers to a table,
list,
or figure adjacent to the item it discusses.
.
The
.I ms
macros provide the
.CW KS
and
.CW KE
macros for this purpose.
.
.
.PP
You can alternatively specify a
.I "floating keep" ;
if a keep cannot fit on the current page,
.I ms
holds its contents and allows material following the keep
(in the source document)
to fill the remainder of the current page.
.
When the page breaks,
whether by an explicit
.CW bp
request or by reaching the end of the page,
.I ms
puts the floating keep at the beginning of the next page.
.
This is useful for placing large graphics or tables that do not need to
appear exactly where they occur in the source document.
.
.
.TS
box;
cb cb
lf(CR) lx .
Macro	Description
_
\&.KS	Begin a keep.
\&.KF	Begin a floating keep.
_
\&.KE	End (floating) keep.
.TE
.
.
.PP
As an alternative to the keep mechanism,
the
.CW ne
request forces a page break if there is not at least the amount of
vertical space specified in its argument remaining on the page.
.
One application of
.CW ne
is to reserve space on the page for a figure or illustration to be
included later.
.
.
.PP
A keep can also be
.I boxed .
.
Text in a box is automatically placed in a diversion (keep).
.
.
.TS
box;
cb cb
lf(CR) lx .
Macro	Description
_
\&.B1	Begin a keep with a box drawn around it.
\&.B2	End boxed keep.
.TE
.
.
.LP
Box macros cause line breaks;
if you need to box a word or phrase within a line,
see the
.CW BX
macro in section \[lq]Highlighting\[rq] above.
.
Box lines are drawn as close as possible to the text they enclose so
that they are usable within paragraphs.
.
If you wish to box one or more paragraphs,
you may improve the appearance by calling
.CW .B1
after the first paragraphing macro,
and by adding a small amount of vertical space before calling
.CW .B2 .
.
.
.TS
box center;
lf(CR).
\&.LP
\&.B1
\&.I Warning:
Happy Fun Ball may suddenly accelerate to dangerous speeds.
\&.sp \[rs]n[PD]/2
\&.B2
.TE
.
.
.LP
If you want a box to float,
you will need to enclose the
.CW .B1
and
.CW .B2
calls within a pair of
.CW .KF
and
.CW .KE
calls.
.
.
.PP
.I Displays
turn off filling;
lines of verse or program code are shown with their lines broken as in
the source document without requiring
.CW br
requests between lines.
.
Displays can be kept on a single page or allowed to break across pages.
.
The
.CW DS
macro begins a kept display of the layout specified in its first
argument;
non-kept displays are begun with dedicated macros corresponding to their
layout.
.
.
.TS
box;
cb s | cb
cb cb | ^
lf(CR) lf(CR) | lx .
Display macro	Description
With keep	Without keep
_
\&.DS L	\&.LD	Begin left-aligned display.
\&.DS \f[R][\f[]I\f[R] [\,\f[I]indent\/\f[]]]	\
\&.ID \f[R][\,\f[I]indent\/\f[]]	T{
Begin display indented by
.I indent
if given,
.CW \[rs]n[DI]
otherwise.
T}
\&.DS B	\&.BD	T{
Begin block display
(left-aligned with longest line centered).
T}
\&.DS C	\&.CD	Begin centered display.
\&.DS R	\&.RD	T{
Begin right-aligned display.
This is a GNU extension.
T}
_
.T&
cf(CR) s | lx .
\&.DE	End any display.
.TE
.
.
.PP
The distance stored in
.CW \[rs]n[DD]
is inserted before and after each pair of display macros;
this is a Berkeley extension.
.
The
.CW \[rs]n[DI]
register is a GNU extension;
its value is an indentation applied to displays created with
.CW .DS
(with no argument),
.CW ".DS\~I" \[rq], \[lq]
and
.CW .ID ;
and indented equations set with
.CW .EQ .
.
Changes to either register take effect at the next display boundary.
.
.
.\" ----------------------------
.KS
.NH 2
Tables, figures, equations, and references
.XS
	Tables, figures, equations, and references
.XE
.LP
The
.I ms
package is often used with the
.I tbl ,
.I pic ,
.I eqn ,
and
.I refer
preprocessors.
.
The
.CW \[rs]n[DD]
distance is also applied to regions of the document preprocessed with
.I tbl ,
.I pic ,
and
.I eqn .
.
Mark text meant for preprocessors by enclosing it in pairs of tags as
follows,
with no space between the dot and the macro name.
.
.
.TS
box;
cb cb
lf(CR) lx .
Tag pair	Description
_
T{
\&.TS
.R
.CW H ] [
.CW
.br
\&.TE
T}	T{
Denote a table to be processed by the
.I tbl
preprocessor.
.
The optional
.CW H
argument to
.CW .TS
instructs
.I groff
to repeat table rows
(often column headings)
at the top of each new page the table spans,
if applicable;
calling the
.CW TH
macro marks the end of such rows.
T}
_
T{
\&.PS
.br
\&.PE
T}	T{
Denote a graphic to be processed by the
.I pic
preprocessor.
.
You can create
.I pic
input manually or by using a program such as
.I xfig (1).
T}
_
T{
\&.EQ
.R
.I align ] [
.CW
.br
\&.EN
T}	T{
Denote an equation to be processed by the
.I eqn
preprocessor.
.
The equation is center-aligned by default;
the optional
.I align
argument can be
.CW C ,
.CW L ,
or
.CW I
to center,
left-align,
or indent it by
.CW \[rs]n[DI] ,
respectively.
T}
_
T{
\&.[
.br
\&.]
T}	T{
Denote a reference to be processed by the
.I refer
preprocessor.
T}
.TE
.KE
.
.
.PP
When
.I refer
emits collected references
(as might be done on a \[lq]Works Cited\[rq] page),
it interpolates the string
.CW \[rs]*[REFERENCES]
as an unnumbered section heading
.CW .SH ). (
.
.
.KS
.NH 3
An example multi-page table
.XS
		An example multi-page table
.XE
.
.
.LP
The following is an example of how to set up a table that may print
across two or more pages.
.
.
.TS
box center;
l .
T{
.nf
.CW
\&.TS H
allbox expand;
cb | cb .
Part\[->]Description
_
\&.TH
\&.T&
l | l .
GH-1978\[->]Fribulating gonkulator
.R
\&.\|.\|.\|the rest of the table follows\|.\|.\|.
.CW
\&.TE
.R
.fi
T}
.TE
.
.
.PP
Attempting to place a multi-page table inside a keep can lead to
unpleasant results,
particularly if the
.I tbl
.CW allbox
option is used.
.KE
.
.
.KS
.NH 2
Footnotes
.XS
	Footnotes
.XE
.
.
.LP
.\" The following sentence is used below as an example as well.  Keep it
.\" in sync.
A footnote is typically anchored to a place in the text with a
.I marker ,
which is a small integer\**,
.FS
like this numeric footnote
.FE
a symbol\[dg],
.FS \[dg]
like this symbolic footnote
.FE
or arbitrary user-specified text.
.KE
.
.
.TS
box;
lb lb
lf(CR) lx.
String	Description
_
\[rs]**	T{
Place an automatically numbered footnote marker in the text.
.
Each time this string is interpolated,
the number it produces increments by one.
.
Automatic footnote numbers start at 1.
.
This is a Berkeley extension.
T}
.TE
.
.
.PP
Enclose the footnote text in
.CW FS
and
.CW FE
macro calls to set it at the nearest available \[lq]foot\[rq],
or bottom,
of a text column or page.
.
.
.TS
box;
cb cb
lfCR lx .
Macro	Description
_
\&.FS \f[R][\f[I]marker\f[]]	T{
Begin a footnote.
.
The
.CW FS\-MARK
hook
(see below)
is called with any supplied
.I marker
argument,
which is then also placed at the beginning of the footnote text.
.
If
.I marker
is omitted,
the next pending automatic footnote number enqueued by interpolation of
the
.CW *
string is used,
and if none exists,
nothing is prefixed.
.
T}
_
\&.FE	End footnote text.
.TE
.
.
.PP
You may not desire automatically numbered footnotes in spite of their
convenience.
.
You can indicate a footnote with a symbol or other text by specifying
its marker at the appropriate place
(for example,
by using
.CW \[rs][dg]
for the dagger glyph)
.I and
as an argument to the
.CW FS
macro.
.
Such manual marks should be repeated as arguments to
.CW .FS
or as part of the footnote text to disambiguate their correspondence.
.
You may wish to use
.CW \[rs]*{
and
.CW \[rs]*}
to superscript the marker at the anchor point,
in the footnote text,
or both.
.
.
.PP
.I "groff ms"
provides a hook macro,
.CW FS\-MARK ,
for user-determined operations to be performed when the
.CW FS
macro is called.
.
It is passed the same arguments as
.CW FS
itself.
.
An application of
.CW FS\-MARK
is anchor placement for a hyperlink reference,
so that a footnote can link back to its referential context.\**
.
.FS
\[lq]Portable Document Format Publishing with GNU Troff\[rq],
.I pdfmark.ms
in the
.I groff
distribution,
uses this technique.
.FE
.
By default,
this macro has an empty definition.
.
.CW FS\-MARK
is a GNU extension.
.
.
.PP
The following input was used to produce the first sentence in this
section.
.
.
.TS
box center;
lfCR.
A footnote is anchored to a place in the text with a
\&.I marker ,
which is a small integer\[rs]**,
\&.FS
like this numeric footnote
\&.FE
a symbol\[rs][dg],
\&.FS \[rs][dg]
like this symbolic footnote
\&.FE
or arbitrary user-specified text.
.TE
.
.
.PP
Footnotes can be safely used within keeps and displays,
but you should avoid using automatically numbered footnotes within
floating keeps.
.
You can place a second
.CW \[rs]**
interpolation between a
.CW \[rs]**
and its corresponding
.CW .FS
call as long as each
.CW .FS
call occurs
.I after
the corresponding
.CW \[rs]**
and the occurrences of
.CW .FS
are in the same order as the corresponding occurrences of
.CW \[rs]** .
.
.
.PP
Footnote text is formatted as paragraphs are,
using analogous parameters.
.
The registers
.CW FI ,
.CW FPD ,
.CW FPS ,
and
.CW FVS
correspond to
.CW PI ,
.CW PD ,
.CW PS ,
and
.CW VS ,
respectively.
.
.
.KS
.PP
The
.CW FF
register controls the formatting of automatically numbered footnotes,
and those for which
.CW .FS
is given a marker argument,
at the bottom of a column or page as follows.
.
.
.TS
box;
cb cb
lf(CR) lx .
\f[CB]FF\f[] value	Description
_
0	T{
Set an automatic number as a superscript
(on typesetter devices)
or surrounded by square brackets
(on terminals).
.
The footnote paragraph is indented if there is an
.CW .FS
argument or an automatic number.
.
This is the default.
T}
1	T{
Like
.CW 0 ,
but set the marker as regular text,
and follow an automatic number with a period.
T}
2	T{
Like
.CW 1 ,
but without indentation.
T}
3	T{
Like
.CW 1 ,
but set the footnote paragraph with the marker hanging.
T}
.TE
.KE
.
.
.PP
The default footnote line length is 11/12ths of the normal line length
for compatibility with the expectations of historical
.I ms
documents;
you may wish to set
.CW \[rs]*[FR]
to
.CW 1
to align with contemporary typesetting practices.
.
In the past,\**
.FS
Version\~7 Unix
.I ms ,
its descendants,
and GNU
.I ms
prior to
.I groff
version 1.23.0
.FE
an
.CW FL
register was used for the line length in footnotes;
however,
setting this register at document initialization time had no effect on
the footnote line length in multi-column arrangements.\**
.
.FS
You could reset it after each call to
.CW .1C ,
.CW .2C ,
or
.CW .MC .
.FE
.
.
.PP
.CW \[rs]*[FR]
should be used in preference to
.CW \[rs]n[FL]
in contemporary documents.
.
The footnote line length is effectively computed as
.I column-width "" \[lq]
.CW "\~*\~\[rs]*[FR]" \[rq].
.
If an absolute footnote line length is required,
recall that arithmetic expressions in
.I roff
languages are evaluated from left to right.
.
.
.TS
box center;
lf(CR).
\&.ds FR 0+3i \[rs]" Set footnote line length to 3 inches.
.TE
.
.
.LP \" continuing previous paragraph
Changes to the footnote length ratio
.CW \[rs]*[FR]
take effect with the next footnote written in single-column
arrangements,
but on the next page in multiple-column contexts.
.
.
.\" ------------------------
.NH 1
Page layout
.XS
Page layout
.XE
.LP
The default output from the
.I ms
macros provides a minimalist
page layout:
it prints a single column,
with the page number centered between hyphens at the top of each page.
.
It prints no footers.
.
.
.PP
You can change the layout by setting appropriate registers and strings.
.
.
.NH 2
Headers and footers
.XS
	Headers and footers
.XE
.
.
.LP
There are multiple ways to produce headers and footers.
.
One is to define the strings
.CW LH ,
.CW CH ,
and
.CW RH
to set the left,
center,
and right headers,
respectively;
and
.CW LF ,
.CW CF ,
and
.CW RF
to set the left,
center,
and right footers similarly.
.
This approach works best for documents that do not distinguish odd and
even pages.
.
.
.PP
Another method is to call macros with arguments that set headers or
footers for odd or even pages;
these variables produce four combinations,
so four macros are available.
.
They each take a delimiter separating the left,
center,
and right header or footer texts from each other.
.
You can replace the neutral apostrophes (\[aq]) with any character not
appearing in the header or footer text.
.
.
.TS
box;
lb lb
lf(CR) lx.
Macro	Description
_
\&.OH \[aq]\f[I]left\f[]\[aq]\f[I]center\f[]\[aq]\f[I]right\f[]\[aq]\
	Set the left, center, and right headers on odd-numbered pages.
\&.OF \[aq]\f[I]left\f[]\[aq]\f[I]center\f[]\[aq]\f[I]right\f[]\[aq]\
	Set the left, center, and right footers on odd-numbered pages.
\&.EH \[aq]\f[I]left\f[]\[aq]\f[I]center\f[]\[aq]\f[I]right\f[]\[aq]\
	Set the left, center, and right headers on even-numbered pages.
\&.EF \[aq]\f[I]left\f[]\[aq]\f[I]center\f[]\[aq]\f[I]right\f[]\[aq]\
	Set the left, center, and right footers on even-numbered pages.
.TE
.
.
.PP
By default,
.I ms
prints no header on any page numbered \[lq]1\[rq]
(regardless of its assigned format).
.
.
.TS
box;
lb lb
lf(CR) lx.
Macro	Description
_
\&.P1	T{
Print the header on page\~1.
.
To be effective,
this macro must be called before the header trap is sprung on any page
numbered \[lq]1\[rq];
in practice,
unless your page numbering is unusual,
this means that you should call it early,
before
.CW .TL
or any sectioning or paragraphing macro.
.
This is a Berkeley extension.
T}
.TE
.
.
.PP
For even greater flexibility,
.I ms
is designed to permit the redefinition of the macros that are called
when the
.I groff
traps that ordinarily cause the headers and footers to be output are
sprung.
.
.CW PT
(\[lq]page trap\[rq])
is called by
.I ms
when the header is to be written,
and
.CW BT
(\[lq]bottom trap\[rq])
when the footer is to be.
.
The
.I roff
trap that
.I ms
sets up to process the header also calls the
(normally undefined)
.CW HD
macro after
.CW .PT ;
you can define
.CW .HD
if you need additional processing after printing the header
(for example,
to draw a line below it).
.
The
.CW HD
hook is a Berkeley extension.
.
Any such macros you (re)define must implement any desired specialization
for odd-,
even-,
or first-numbered pages.
.
.
.\" ------------------------
.KS
.NH 2
Tab stops
.XS
	Tab stops
.XE
.
.
.LP
Use the
.CW ta
request to set tab stops as needed.
.
.
.TS
box;
lb lb
lf(CR) lx.
Macro	Description
_
\&.TA	T{
Reset the tab stops to the
.I ms
default
(every 5 ens).
.
Redefine this macro to create a different set of default tab stops.
T}
.TE
.KE
.
.
.\" ------------------------
.KS
.NH 2
Margins
.XS
	Margins
.XE
.
.
.LP
Control margins using registers.
.
These are summarized in the \[lq]Margins\[rq] section of the table in
section \[lq]Document control settings\[rq] above.
.
There is no explicit right margin setting;
the combination of page offset
.CW \[rs]n[PO]
and line length
.CW \[rs]n[LL]
provides the information necessary to derive the right margin.
.KE
.
.
.KS
.NH 2
Multiple columns
.XS
	Multiple columns
.XE
.
.
.LP
The
.I ms
macros can set text in as many columns as will reasonably fit on the
page.
.
The following macros are available.
.
All of them force a page break if a multi-column mode is already set.
.
However,
if the current mode is single-column,
starting a multi-column mode does
.I not
force a page break.
.
.
.TS
box;
cb cb
lf(CR) lx .
Macro	Description
_
\&.1C	Arrange page text in a single column (the default).
_
\&.2C	Arrange page text in two columns.
_
\&.MC \f[R][\f[I]column-width\f[] [\f[I]gutter-width\f[]]]	T{
Arrange page text in multiple columns.
.
If you specify no arguments,
it is equivalent to the
.CW 2C
macro.
.
Otherwise,
.I column-width
is the width of each column and
.I gutter-width
is the minimum distance between columns.
.
.CW \[rs]n[MINGW]
is the default minimum gutter width;
it is a GNU extension.
T}
.TE
.KE
.
.
.\" ------------------------
.NH 2
Creating a table of contents
.XS
	Creating a table of contents
.XE
.LP
Because
.I roff
formatters process their input in a single pass,
material on page 50,
for example,
cannot influence what appears on page\~1\[em]this poses a challenge for
a table of contents at its traditional location in front matter,
if you wish to avoid manually maintaining it.
.
.I ms
enables the collection of material to be presented in the table of
contents as it appears,
saving its page number along with it,
and then emitting the collected contents on demand toward the end of the
document.
.
The table of contents can then be resequenced to its desired location
as part of post-processing\[em]with a PDF page relocation tool,
or by physically rearranging the pages of a printed document,
depending on the output format and circumstances.
.
.
.PP
Define an entry to appear in the table of contents by bracketing its
text between calls to the
.CW XS
and
.CW XE
macros.
.
A typical application is to call them immediately after
.CW NH
or
.CW SH
and repeat the heading text within them.
.
The
.CW XA
macro,
used within
.CW .XS /\c
.CW .XE
pairs,
supplements an entry\[em]for instance,
when it requires multiple output lines,
whether because a heading is too long to fit or because style dictates
that page numbers not be repeated.
.
In a document with a multi-level sectioning structure,
you may wish to indent the text thus wrapped to correspond to its
sectioning depth;
this can be done in the entry text by prefixing it with tabs or
horizontally spacing escape sequences,
or by providing a second argument to the
.CW XA
macro.
.
.CW .XS
and
.CW .XA
automatically associate the page number where they are called with the
text following them,
but they accept arguments to override this behavior.
.
At the end of the document,
call
.CW TC
or
.CW PX
to emit the table of contents;
.CW .TC
resets the page number
.B i "" to\~
(Roman numeral one),
and then calls
.\" XXX ".BR PX ." here throws diagnostic with WRONG LINE NUMBER
.CW PX .
.
.
.PP
All of these macros are Berkeley extensions.
.
.TS
box;
cb cb
lf(CR) lx .
Macro	Description
_
\&.XS \f[R][\f[I]page-number\f[]]	T{
Begin,
supplement,
and end a table of contents entry.
.
Each entry is associated with
.I page-number
(otherwise the current page number);
a
.I page-number
of
.CW no
prevents a leader and page number from being emitted for that entry.
.
Use of
.CW .XA
within
.CW .XS /\c
.CW .XE
is optional;
it can be repeated.
.
If
.I indentation
is present,
a supplemental entry is indented by that amount;
ens are assumed if no unit is indicated.
.
Text on input lines between
.CW .XS
and
.CW .XE
is stored for later recall by
.CW .PX .
T}
\&.XA \f[R][\f[I]page-number\f[] [\f[I]indentation\f[]]]	\^
\&.XE	\^
_
\&.PX \f[R][\f[]no\f[R]]	T{
Switch to single-column layout.
.
Unless
.CW no
is specified,
center and interpolate
.CW \[rs]*[TOC]
in bold and two points larger than the body text.
.
Emit the table of contents entries.
T}
_
\&.TC \f[R][\f[]no\f[R]]	T{
Set the page number to\~1,
the page number format to lowercase Roman numerals,
and call
.CW PX
(with a
.CW no
argument,
if present).
T}
.TE
.
.
.PP
You can customize the style of the leader that bridges each table of
contents entry with its page number;
define the
.CW TC\-LEADER
special character by using the
.CW char
request.
.
A typical leader combines the dot glyph
.CW .\& \[rq] \[lq]
with a horizontal space escape sequence to spread the dots.
.
The width of the page number field is stored in the
.CW TC\-MARGIN
register.
.
.
.KS
.PP
Here's an example of typical
.I ms
table of contents preparation and
(a simulation of)
its result.
.
.ds DOT \h'1m'.\"
.TS
box center;
cb | cb
l | c.
Input	Result
_
T{
.nf
.CW
\&.NH 1
Introduction
\&.XS
Introduction
\&.XE
.R
\&.\|.\|.
.CW
\&.NH 2
Methodology
\&.XS
\[->]Methodology
\&.XA
\[->]\[->]Fassbinder\[aq]s Approach
\[->]\[->]Kahiu\[aq]s Approach
\&.XE
.R
\&.\|.\|.
.CW
\&.NH 1
Findings
\&.XS
Findings
\&.XE
.R
\&.\|.\|.
.CW
\&.TC
.fi
T}	T{
.sp 1v
.nf
.LG
.\" Manual centering--ugh!
.B "\h'2m'Table of Contents"
.NL
.sp 2v
.\" Use absolute motions to gets the dots aligned.
Introduction\h'|4.5m'\*[DOT]\*[DOT]\*[DOT]\*[DOT]\*[DOT]\*[DOT]\01
\h'1m'Methodology\h'|4.5m'\*[DOT]\*[DOT]\*[DOT]\*[DOT]\*[DOT]\*[DOT]\02
\h'2m'Fassbinder's Approach
\h'2m'Kahiu's Approach
\&.\|.\|.
.\" XXX: Why doesn't \h'|3.5m' achieve alignment?
Findings\h'|3.2m'\*[DOT]\*[DOT]\*[DOT]\*[DOT]\*[DOT]\*[DOT]\*[DOT]\08
T}
.TE
.rm DOT
.KE
.
.
.PP
Provins's
.I "Groff and Friends HOWTO"
includes a
.I sed
script that automatically inserts
.CW .XS
and
.CW .XE
entries after each heading in a document.
.
Altering the
.CW NH
macro to automatically build the table of contents is perhaps initially
more difficult,
but could save a great deal of time in the long run if you use
.I ms
regularly.
.
.
.\" ------------------------
.NH 1
Differences from AT&T
.BI ms
.XS
Differences from AT&T
.I ms
.XE
.LP
The
.I "groff ms"
macros are a complete re-implementation,
using no original AT&T code.
.
Since they take advantage of the extended features in
.I groff ,
they cannot be used with AT&T
.I troff .
.
.I "groff ms"
supports several features described above as Berkeley and Version 10
Research Unix extensions,
and adds several of its own.
.
.
.PP
The internals of
.I "groff ms"
differ from the internals of AT&T
.I ms .
.
Documents that depend upon implementation details of AT&T
.I ms
may not format properly with
.I "groff ms" .
.
Such details include macros whose function was not documented in the
AT&T
.I ms
manual [Lesk 1978].
.\" TODO: Use refer(1).
.\" XXX: We support RT anyway; maybe we should stop?
.
.
.PP
.I "groff ms"
does not work in GNU
.I troff 's \" GNU
AT&T compatibility mode.
.
If loaded when that mode is enabled,
it aborts processing with a diagnostic message.
.
.
.PP
.I "groff ms"
uses the same header and footer defaults in both
.CW nroff
and
.CW troff
modes
as AT&T
.I ms
does in
.CW troff
mode;
AT&T's default in
.CW nroff
mode is to put the date,
in U.S.\& traditional format
(e.g.,
\[lq]January 1, 2021\[rq]),
in the center footer
(the
.CW CF
string).
.
.
.PP
Macros that cause
.I "groff ms"
to internally reset its paragraph rendering parameters
(paragraphs,
headings,
and displays,
among others)
may change the indentation;
they do so not by incrementing or decrementing it,
but by setting it absolutely.
.
This can cause problems for documents that define additional macros of
their own that try to manipulate indentation.
.
The solution is to use,
not the
.CW in
request,
but
.CW .RS
and
.CW .RE .
.
.
.PP
Right-aligned displays are available.
.
The AT&T
.I ms
manual observes that \[lq]it is tempting to assume that
.CW ".DS R"
will right adjust lines,
but it doesn't work\[rq].
.
In
.I "groff ms" ,
it does.
.
.
.PP
.I "groff ms"
supports the
.CW PN
register,
but it is not necessary;
you can access the page number via the usual
.CW %
register and invoke the
.CW af
request to assign a different format to it if desired.\**
.FS
If you redefine the
.I ms
.CW PT
macro \" I wouldn't mention that, but Lesk 1978 encourages doing so. :-/
and desire special treatment of certain page numbers
(like
.CW 1 \[rq]), \[lq]
you may need to handle a non-Arabic page number format,
as
.I "groff ms" 's
.CW .PT
does;
see the macro package source.
.
.I "groff ms"
aliases the
.CW PN
register to
.CW % .
.FE
.
.
.PP
The AT&T
.I ms
manual documents registers
.CW CW
and
.CW GW
as setting the default column width and \[lq]intercolumn gap\[rq],
respectively,
and which applied when
.CW .MC
was called with fewer than two arguments.
.
.I "groff ms"
instead treats
.CW .MC
without arguments as synonymous with
.CW .2C ;
there is thus no occasion for a default column width register.
.
Further,
the
.CW MINGW
register
and the second argument to
.CW .MC
specify a
.I minimum
space between columns,
not the fixed gutter width of AT&T
.I ms .
.
.
.PP
The AT&T
.I ms
manual did not document the
.CW QI
register,
whereas Berkeley did;
.I "groff ms"
accordingly supports it.
.
.
.PP
The register
.CW GS
is set to\~1 by the
.I "groff ms"
macros,
but is not used by the AT&T
.I ms
package.
.
Documents that need to determine whether they are being formatted with
.I "groff ms"
or another implementation should test this register.
.
.
.\" ------------------------
.NH 2
AT&T
.BI ms
macros not appearing in
.BI "groff ms"
.XS
	AT&T
.I ms
macros not appearing in
.I "groff ms"
.XE
.LP
Macros missing from
.I "groff ms"
are cover page macros specific to
Bell Labs.
The macros known to be missing are:
.IP \&.TM 0.5i
Technical memorandum; a cover sheet style
.IP \&.IM
Internal memorandum; a cover sheet style
.IP \&.MR
Memo for record; a cover sheet style
.IP \&.MF
Memo for file; a cover sheet style
.IP \&.EG
Engineer's notes; a cover sheet style
.IP \&.TR
Computing Science Tech Report; a cover sheet style
.IP \&.OK
Other keywords
.IP \&.CS
Cover sheet information
.IP \&.MH
A cover sheet macro
.
.
.LP
Version\~10
.\" possibly V9
Research Unix supported a pair of
.CW P1
and
.CW P2
macros for setting code examples;
.I "groff ms"
does not.
.
.
.NH 2
.BI "groff ms"
macros not appearing in
AT&T
.BI ms
.XS
	\c
.I "groff ms"
macros not appearing in
AT&T
.I ms
.XE
.
.
.LP
The
.I "groff ms"
macros have some minor extensions,
not already discussed above,
compared to the AT&T
.I ms
macros.
.
.IP \&.AM 0.5i
Improved accent marks.
.
.
.IP \&.IX
Indexing term
(printed on standard error).
.
.
.\" ------------------------
.NH 2
Localization strings
.XS
	Localization strings
.XE
.
.
.LP
Redefine the following strings to adapt the
.I "groff ms"
macro package to languages other than English.
.
.
.TS
box center;
cb lb
lf(CR) lf(CR) .
String	Default
_
\[rs]*[REFERENCES]	References
\[rs]*[ABSTRACT]	\[rs]f[I]ABSTRACT\[rs]f[]
\[rs]*[TOC]	Table of Contents
\[rs]*[MONTH1]	January
\[rs]*[MONTH2]	February
\[rs]*[MONTH3]	March
\[rs]*[MONTH4]	April
\[rs]*[MONTH5]	May
\[rs]*[MONTH6]	June
\[rs]*[MONTH7]	July
\[rs]*[MONTH8]	August
\[rs]*[MONTH9]	September
\[rs]*[MONTH10]	October
\[rs]*[MONTH11]	November
\[rs]*[MONTH12]	December
.TE
.
.
.PP
The default for
.CW \[rs]*[ABSTRACT]
includes font style escape sequences to set the word in italics.
.
.
.\" ------------------------
.if t .bp
.NH 1
Further Reading
.XS
Further Reading
.XE
.
.
.IP \[bu]
\[lq]Typing Documents on the Unix System:
Using the \-ms Macros with Troff and Nroff\[rq];
M.\& E.\& Lesk;
November 13, 1978.
.
This document describes the
.I ms
supplied with AT&T Unix Version\~7.
.
.
.IP \[bu]
\[lq]A Revised Version of \-ms\[rq];
Bill Tuthill;
August 1983.
.
The 4.2BSD release featured several extensions to
.I ms ,
most of which are recreated in
.I "groff ms" .
.
(The exceptions are the
.CW TM
and
.CW CT
macros for setting a doctoral thesis in the format required by the
contemporaneous degree-granting authorities of the University of
California at Berkeley.)
.
.
.IP \[bu]
\[lq]Using PDF boxes with
.I groff
and the
.I ms
macros\[rq];
Deri James;
March 2021.
.
.CW BOXSTART
and
.CW BOXSTOP
macros are available via the
.I sboxes
extension package,
enabling colored,
bordered boxes when the
.CW pdf
output device is used.
.\" ------------------------
.TC
.
.
.\" Local Variables:
.\" fill-column: 72
.\" mode: nroff
.\" End:
.\" vim: set filetype=groff textwidth=72:
