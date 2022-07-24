.\" Acronym (slightly smaller type)
.de Acr
\s-1\\$1\s0\\$2
..
.\" Paragraph symbol
.ie t .char \(pp \N'182'
.el .char \(pp para.
.\".RP
.nr LL 6.5i
.nr LT 6.5i
.nr PS 11
.nr VS 13
.nr PI 3.5n
.ND v0.1, April 2001
.EH '%''v0.1, April 2001'
.EF ''''
.OH 'Using \fIgroff\fP with the -ms macros''%'
.OF ''''
.TL
Using
.I groff
with the
.I -ms
Macro Package
.AU
Larry Kollar
.AI
kollar@alltel.net
.AB no
This document describes the
.Acr GNU
re-implementation of the popular
.I
groff -ms
.R
macro package.
.PP
The
.I -ms
macros are suitable for reports, letters, books,
user manuals, and so forth.
The package provides macros for cover pages, section headings,
paragraphs, lists, footnotes, pagination,
and a table of contents.
.PP
This document provides both tutorial and reference material.
It also discusses differences from the
.Acr AT&T
.I -ms
macros, both omissions and additions.
.AE
.\" ------------------------- End of cover page ------------------------- 
.NH 1
Introduction
.XS
Introduction
.XE
.LP
The original
.I -ms
macros were included with
.Acr AT&T
.I troff
as well as the
.I -man
macros.
While the
.I -man
package is intended for brief documents
that can be read on-line as well as printed, the
.I -ms
macros are suitable for longer documents that are meant to be
printed rather than read on-line.
.PP
The
.I -ms
macro package included with
.I -groff
is a complete, bottom-up re-implementation.
Several macros (specific to
.Acr AT&T
or Berkeley) are not included,
while several new commands are.
See
.I
Differences from
.Acr AT&T
-ms\c
.R
, later in this document, for more information.
.NH 2
Basic information
.XS
	Basic information
.XE
.LP
Most
.I "number registers"
have a default unit of measurement.
Specifying a unit explicitly does not cause any problems,
and can avoid problems in complex situations.
The following are typical units:
.TS
box;
cb cb
c a .
Unit	Description
_
i	inches
c	centimeters
p	points (1/72\[sd])
v	line height
n	width of a letter ``n'' in the current font
m	width of a letter ``M'' in the current font
P	pica (1/6\[sd])
.TE
.LP
You set number registers by using the
.CW .nr
request; for example:
.RS
.CW
\&.nr PS 12
.R
.RE
.\" ------------------------
.if t .bp
.NH 1
General structure of an
.I -ms
document
.XS
General structure of an
.I -ms
document
.XE
.LP
The
.I -ms
macro package expects a certain amount of structure,
but not as much as packages such as
.I -man
or
.I -mdoc .
.PP
The simplest documents can begin with a paragraph macro
(such as
.CW .LP
or
.CW .PP ),
and consist of text separated by paragraph macros
or even blank lines.
Longer documents have a structure as follows:
.IP "\fBDocument type\fP"
If you invoke the
.CW .RP
(report) macro on the first line of the document,
.I groff
prints the cover page information on its own page;
otherwise it prints the information on the
first page with your document text immediately following.
Other document formats found in
.Acr AT&T
.I troff
are specific to
.Acr AT&T
or Berkeley, and are not supported in
.I groff .
.IP "\fBFormat and layout\fP"
By setting number registers,
you can change your document's type (font and size),
margins, spacing, headers and footers, and footnotes.
See 
.I "Document control registers"
below for more details.
.IP "\fBCover page\fP"
A cover page consists of a title, the author's name and institution,
an abstract, and the date.\**
.FS
Actually, only the title is required.
.FE
See
.I "Cover page macros"
below for more details.
.IP "\fBBody\fP"
Following the cover page is your document.
You can use the
.I -ms
macros to write reports, letters, books, and so forth.
The package is designed for structured documents,
consisting of paragraphs interspersed with headings
and augmented by lists, footnotes, tables, and other
common constructs.
See
.I "Body text"
below for more details.
.IP "\fBTable of contents\fP"
Longer documents include a table of contents,
which you can invoke by placing the
.CW .TC
macro at the end of your document.\**
.FS
The
.I -ms
macros have minimal indexing facilities, consisting of the
.CW .IX
macro, which prints an entry on standard error.
.FE
Printing the table of contents at the end is necessary since
.I groff
is a single-pass text formatter,
thus it cannot determine the page number of each section
until that section has actually been set and printed.
Since
.I -ms
output was intended for hardcopy,
the standard procedure was to manually relocate the pages containing
the table of contents between the cover page and the
body text.
.\" ------------------------
.if t .bp
.NH 1
Document control settings
.XS
Document control settings
.XE
.LP
The following table lists document control registers and strings.
.
For the sake of consistency,
set registers related to margins at the beginning of your document,
or just after the
.CW .RP
macro.
.
You can set other registers later in your document,
but you should keep them together at the beginning
to make them easy to find and edit as necessary.
.TS H
box expand;
cb | cb cb cb cb
l | afCW l l lfCW .
Type	Parameter	Definition	Effective	Default
_
.TH
Margins	\[rs]n[PO]	Page offset (left margin)	next page	1i
\^	\[rs]n[LL]	Line length	next \(pp	6i
\^	\[rs]n[LT]	Header/footer (title) length	next \(pp	6i
\^	\[rs]n[HM]	Top (header) margin	next page	1i
\^	\[rs]n[FM]	Bottom (footer) margin	next page	1i
_
Text	\[rs]n[PS]	Point size	next \(pp	10p
\^	\[rs]n[VS]	Line spacing (leading)	next \(pp	12p
\^	\[rs]*[FAM]	Font family	next \(pp	12p
_
Paragraphs	\[rs]n[PI]	Initial indent	next \(pp	5n
\^	\[rs]n[PD]	Space between paragraphs	next \(pp	0.3v
\^	\[rs]n[QI]	Quoted paragraph indent	next \(pp	5n
_
Footnotes	\[rs]*[FR]	Footnote length ratio	next footnote	11/12
\^	\[rs]n[FI]	Footnote indent	next footnote	2n
\^	\[rs]n[FF]	Footnote format	next footnote	0
_
Other	\[rs]n[MINGW]	Minimum width between columns	next page	2n
.TE
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
to suit contemporary typesetting practices.
.
In the past,\**
.FS
in Version 7 Unix
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
setting this register had no effect on the footnote line length in
multi-column environments.
.
.
.\" ------------------------
.bp
.NH 1
Cover page macros
.XS
Cover page macros
.XE
.LP
Use the following macros to create a cover page for your document
in the order shown.
.TS H
box;
lb lb
lf(CR) lx.
Macro	Description
_
.TH
\&.RP [\fBno\fP]	T{
Specifies the report format for your document.
The report format creates a separate cover page.
The default action (no
.CW .RP
macro) is to print a subset of the
cover page on page 1 of your document.
.sp \n(PDu
If you use the optional
.B no
argument,
.I groff
prints a title page but
does not repeat any of the title page information
(title, author, abstract, etc.)
on page 1 of the document.
T}
_
\&.DA [\fIxxx\fP]	T{
(optional) Print the current date,
or the arguments to the macro if any,
on the title page (if specified)
and in the footers.
This is the default for
.I nroff .
T}
_
\&.ND xxx [\fIxxx\fP]	T{
(optional) Print the current date,
or the arguments to the macro if any,
on the title page (if specified)
but not in the footers.
This is the default for
.I troff .
T}
_
\&.TL	T{
Specifies the document title.
.I groff
collects text following the
.CW .TL
macro into the title, until reaching the author name or abstract.
T}
_
\&.AU	T{
Specifies the author's name, which appears on the
line (or lines) immediately following.
You can specify multiple authors as follows:
.DS I
.CW
\&.AU
John Doe
\&.AI
University of West Bumblefuzz
\&.AU
Martha Buck
\&.AI
Monolithic Corporation
.R
\&...
.DE
T}
_
\&.AI	T{
Specifies the author's institution.
You can specify multiple institutions in the same way
that you specify multiple authors.
T}
_
\&.AB [no]	T{
Begins the abstract.
The default is to print the word
.Acr ABSTRACT ,
centered and in italics, above the text of the abstract.
The option
.CW no
suppresses this heading.
T}
_
\&.AE	End the abstract.
.TE
.KS
.LP
The following is example mark-up for a title page.
.B1
.DS B
.CW
\&.RP
\&.TL
The Inevitability of Code Bloat
in Commercial and Free Software
\&.AU
J. Random Luser
\&.AI
University of West Bumblefuzz
\&.AB
This report examines the long-term growth
of the code bases in two large, popular software
packages; the free Emacs and the commercial
Microsoft Word.
While differences appear in the type or order
of features added, due to the different
methodologies used, the results are the same
in the end.
\&.PP
The free software approach is shown to be
superior in that while free software can
become as bloated as commercial offerings,
free software tends to have fewer serious
bugs and the added features are in line with
user demand.
\&.AE
.R
\&... the rest of the paper follows ...
.DE
.B2
.KE
.\" ------------------------
.bp
.NH 1
Body text
.XS
Body text
.XE
.LP
This section describes macros 
used to mark up the body of your document.
Examples include paragraphs, sections, and
other groups.
.NH 2
Paragraphs
.XS
	Paragraphs
.XE
.LP
Use the
.CW .PP
macro to create indented paragraphs
(like the next paragraph),
and the
.CW .LP
macro to create paragraphs with no initial indent (like this one).
.PP
The
.CW .QP
macro indents its text at both left and right margins.
The effect is identical to the
.Acr HTML
.CW <BLOCKQUOTE>
element.
The next paragraph or heading
returns margins to normal.
.KS
.PP
The following markup uses all three paragraph macros.
.B1
.DS B
.CW
\&.NH 2
Cases used in the study
\&.LP
The following software and versions were
considered for this report.
\&.PP
For commercial software, we chose
\&.B "Microsoft Word for Windows" ,
starting with version 1.0 through the
current version (Word 2000).
\&.PP
For free software, we chose
\&.B Emacs ,
from its first appearance as a standalone
editor through the current version (v20).
\&.QP
Franklin's Law applied to software:
software expands to outgrow both
RAM and disk space over time.
.R
.DE
.B2
.KE
.NH 2
Headings
.XS
	Headings
.XE
.LP
Use headings to create a hierarchical structure
for your document.
The
.I -ms
macros print headings in
.B bold ,
using the same font family and point size as the body text.
.KS
.PP
The following table describes the heading macros:
.TS
box expand;
cb cb
afCWw(0.75i) lw(5i) .
Macro	Description
_
\&.NH \fIxx\fP	T{
Numbered heading.
The argument
.I xx
is either a numeric argument to indicate the
level of the heading, or
.I "S xx xx" "..."
to set the heading level explicitly.
The section headings in this document use the
.CW .NH
macro to show the level of each section.

If you specify heading levels out of sequence,
such as invoking
.CW ".NH\ 3"
after
.CW ".NH\ 1" ,
.I groff
prints a warning on standard error.
T}
_
\&.SH	Unnumbered subheading.
.TE
.KE
.KS
.NH 2
Highlighting
.XS
	Highlighting
.XE
.LP
The
.I -ms
macros provide a variety of methods to highlight
or emphasize text:
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
If you specify a second argument,
.I groff
prints it in the previous font after
the bold text, with no intervening space
(this allows you to set punctuation after
the highlighted text without highlighting
the punctuation).
Similarly, it prints the third argument (if any)
in the previous font
.B before
the first argument.
For example,
.sp \n(PDu
.ti +3n
\&.B foo ) (
.sp \n(PDu
prints
.B foo ). (
.sp \n(PDu
If you give this macro no arguments,
.I groff
prints all text following in bold until
the next highlighting, paragraph, or heading macro.
T}
_
\&.R [txt [post [pre]]]	T{
Sets its first argument in
roman (or regular) type.
It operates similarly to the
.CW .B
macro otherwise.
T}
_
\&.I [txt [post [pre]]]	T{
Sets its first argument in
.I "italic type" .
It operates similarly to the
.CW .B
macro otherwise.
T}
_
\&.CW [txt [post [pre]]]	T{
Sets its first argument in a
.CW "constant width face" .
It operates similarly to the
.CW .B
macro otherwise.
T}
_
\&.BI [txt [post [pre]]]	T{
Sets its first argument in
.BI "bold italic type" .
It operates similarly to the
.CW .B
macro otherwise.
T}
_
\&.BX [txt]	T{
Prints its argument and draws a
.BX box
around it.
If you want to box a string that contains spaces,
use a digit-width space (\\0).
T}
_
\&.UL [txt [post]]	T{
Prints its first argument with an
.UL underline .
If you specify a second argument,
.I groff
prints it in the previous font after
the underlined text, with no intervening space.
T}
_
\&.LG	T{
Prints all text following in
.LG
larger type
.NL
(2 points larger than the current point size)
until
the next font size, highlighting, paragraph, or heading macro.
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
the next type size, highlighting, paragraph, or heading macro.
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
Prints all text following in
the normal point size
(that is, the value of the
.CW PS
register).
T}
.TE
.KE
.NH 2
Lists
.XS
	Lists
.XE
.LP
The
.CW .IP
macro handles duties for all lists.
Its syntax is as follows:
.PP
.CW .IP
.I marker "" [
.I width ]] [
.LP
The
.I marker
is usually a bullet character
.CW \\\\(bu ) (
for unordered lists,
a number (or auto-incrementing number register) for numbered lists,
or a word or phrase for indented (glossary-style) lists.
.PP
The
.I width
specifies the indent for the body of each list item.
Once specified, the indent remains the same for all
list items in the document until specified again.
.KS
.PP
The following are examples of each type of list:
.TS H
box expand;
cb cb
afCW a .
Source	Result
_
.TH
T{
.nf
A bulleted list:
\&.IP \\(bu 2
lawyers
\&.IP \\(bu
guns
\&.IP \\(bu
money
.fi
T}	T{
A bulleted list:
.IP \(bu 2
lawyers
.IP \(bu
guns
.IP \(bu
money
T}
_
T{
.nf
\&.nr step 1 1
A numbered list:
\&.IP \\n[step] 3
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
.LP
Note the use of the auto-incrementing number
.br
register in this example.
T}
_
T{
.nf
A glossary-style list:
\&.IP lawyers 0.4i
Two or more attorneys.
\&.IP guns
Firearms, preferably
large-caliber.
\&.IP money
Gotta pay for those
lawyers and guns!
.fi
T}	T{
A glossary-style list:
.IP lawyers 0.4i
Two or more attorneys.
.IP guns
Firearms, preferably large-caliber.
.IP money
Gotta pay for those lawyers and guns!
T}
.TE
.KE
.PP
In the last example, note how the
.CW .IP
macro places the definition on the same line as the term
if it has enough space.
This may or may not be the effect you want.
The following example shows two possible workarounds:
.TS
box expand;
cb cb
afCW l .
Code	Result
_
T{
.nf
A glossary-style list:
\&.IP lawyers 0.4i
Two or more attorneys.
\&.IP guns
\&.br
Firearms, preferably
large-caliber.
\&.IP money
Gotta pay for those
lawyers and guns!
.fi
T}	T{
A glossary-style list:
.IP lawyers 0.4i
Two or more attorneys.
.IP guns
.br
Firearms, preferably large-caliber.
.IP money
Gotta pay for those lawyers and guns!
T}
_
T{
.nf
A glossary-style list:
\&.IP lawyers 0.4i
Two or more attorneys.
\&.IP guns\[rs]h\[aq]0.4i\[aq]
Firearms, preferably
large-caliber.
\&.IP money
Gotta pay for those
lawyers and guns!
.fi
T}	T{
A glossary-style list:
.IP lawyers 0.4i
Two or more attorneys.
.IP guns\h'0.4i'
Firearms, preferably large-caliber.
.IP money
Gotta pay for those lawyers and guns!
T}
.TE
.PP
The first example uses the
.CW .br
request to force a break after printing the term or label.
The second example uses the
.CW \\\\p
escape to do the same thing.
Note the space following the escape; this is important.
If you omit the space,
.I groff
prints the first word on the same line as the term or label (if it fits)
.B then
breaks the line.
.PP
To set nested lists, use the
.CW .RS
and 
.CW .RE
macros.
These macros begin and end a section indented to line
up with the body of an
.CW .IP
macro.
For example:
.TS
box center;
a a .
T{
.nf
.CW
\&.IP \\(bu 2
Lawyers:
\&.RS
\&.IP \\(bu
Dewey,
\&.IP \\(bu
Cheatham,
\&.IP \\(bu
and Howe.
\&.RE
\&.IP \\(bu
Guns
.R
\&...
.fi
T}	T{
.IP \(bu 2
Lawyers:
.RS
.IP \(bu
Dewey,
.IP \(bu
Cheatham,
.IP \(bu
and Howe.
.RE
.IP \(bu
Guns
\&...
T}
.TE
.NH 2
Displays and keeps
.XS
	Displays and keeps
.XE
.LP
Use displays to show text-based examples or figures
(such as code listings).
This document shows
.I groff
code examples inside displays, for example.
.PP
Displays turn off filling, so lines of code can be
displayed as-is without inserting
.CW .br
requests in between each line.
Displays can be 
.I kept
on a single page, or allowed to break across pages.
The following table shows the display types available.
.TS
box expand;
cb s | cb 
cb cb | ^
afCW afCW | a .
Display macro	Description
With keep	No keep
_
\&.DS L	\&.LD	Left-justified display.
\&.DS I [\fIindent\fP]	\&.ID	T{
Indented display (default is the DI register).
T}
\&.DS B	\&.BD	T{
Block-centered display (left-justified, longest line centered).
T}
\&.DS C	\&.CD	Centers all lines in the display.
\&.DS R	\&.RD	Right-justifies all lines in the display.
.TE
.LP
Use the
.CW .DE
macro to end any display type.
.PP
On occasion, you may want to
.I keep
other text together on a page.
For example, you may want to keep two paragraphs together, or
a paragraph that refers to a table (or list, or other item)
immediately following.
The
.I -ms
macros provide the
.CW .KS
and
.CW .KE
macros for this purpose.
The
.CW .KS
macro begins a block of text to be kept on a single page,
and the
.CW .KE
macro ends the block.
.PP
You can specify a
.I "floating keep" ;
if the keep cannot fit on the current page,
.I groff
holds the contents of the keep and allows text following
the keep (in the source file) to fill in the remainder of
the current page.
When the page breaks,
whether by an explicit
.CW .bp
request or by reaching the end of the page,
.I groff
prints the floating keep at the top of the new page.
This is useful for printing large graphics or tables
that do not need to appear exactly where specified.
Use the
.CW .KF
and
.CW .KE
macros to specify a floating keep.
.PP
You can also use the
.CW .ne
request to force a page break if there is
not enough vertical space remaining on the page.
.\" ----------------------------
.KS
.NH 2
Tables, figures, equations, and references
.XS
	Tables, figures, equations, and references
.XE
.LP
The
.I -ms
macros support the standard
.I groff
preprocessors:
.I tbl ,
.I pic ,
.I eqn ,
and
.I refer .
You mark text meant for preprocessors by enclosing it
in pairs of tags as follows:
.TS
box expand;
cb cb
afCWw(1.25i) aw(4.75i) .
Tag Pair	Description
_
T{
\&.TS [H]
.br
\&.TE
T}	T{
Denotes a table, to be processed by the
.I tbl
preprocessor.
The optional
.B H
argument to
.CW .TS
instructs
.I groff
to create a running header with the information
up to the
.CW .TH
macro.
.I Groff
prints the header at the beginning of the table;
if the table runs onto another page,
.I groff
prints the header on the next page as well.
T}
_
T{
\&.PS
.br
\&.PE
T}	T{
Denotes a graphic, to be processed by the
.I pic
preprocessor.
You can create a
.I pic
file by hand, using the
.Acr AT&T
.I pic
manual available on the Web as a reference,
or by using a graphics program such as
.I xfig .
T}
_
T{
\&.EQ
.I align ] [
.br
\&.EN
T}	T{
Denotes an equation, to be processed by the
.I eqn
preprocessor.
The optional
.I align
argument can be
.B C ,
.B L ,
or
.B I
to center (the default), left-justify, or indent
the equation.
T}
_
T{
\&.[
.br
\&.]
T}	T{
Denotes a reference, to be processed by the
.I refer
preprocessor.
The
.Acr GNU
.I refer (1)
manpage provides a comprehensive reference
to the preprocessor and the format of the
bibliographic database.
T}
.TE
.KE
.KS
.NH 3
An example multi-page table
.XS
		An example multi-page table
.XE
.LP
The following is an example of how to set up a
table that may print across two or more pages.
.B1
.DS I
.CW
\&.TS H
allbox expand;
cb | cb .
Text      \&...of heading...
_
\&.TH
\&.T&
l | l .
.R
\&... the rest of the table follows...
.CW
\&.TE
.R
.DE
.B2
.KE
.NH 2
Footnotes
.XS
	Footnotes
.XE
.LP
The
.I -ms
macro package has a flexible footnote system.
You can specify a numbered footnote\**
.FS
This is a numbered footnote.
.FE
by using the
.CW \\\\**
escape, followed by the text of the footnote
enclosed by
.CW .FS
and
.CW .FE
macros.
.PP
You can specify symbolic footnotes\(dg
.FS
\(dgThis is a symbolic footnote.
.FE
by placing the character (such as
.CW \\\\(dg
for the dagger character used here),
followed by the symbol and the text of the footnote
enclosed by
.CW .FS
and
.CW .FE
macros.
.KS
.PP
You can control how
.I groff
prints footnote numbers by changing the value of the
.CW FF
register as follows:
.TS
box;
cb cb
aw(0.75i) lw(5.25i) .
Value	Description
_
0	T{
Prints the footnote number as a superscript; indents the footnote (default).
T}
1	T{
Prints the number followed by a period (like 1.)
and indents the footnote.
T}
2	Like 1, without an indent.
3	T{
Like 1, but prints the footnote number as a hanging paragraph.
T}
.TE
.KE
.\" ------------------------
.NH 1
Page layout
.XS
Page layout
.XE
.LP
The default output from the
.I -ms
macros provides a minimalist
page layout:
it prints a single column, with
the page number centered at the top of each page.
It prints no footers.
.PP
You can change the layout by setting
the proper number registers and strings.
.NH 2
Headers and footers
.XS
	Headers and footers
.XE
.LP
There are two ways to define headers and footers:
.IP \(bu 2
Set the strings
.CW LH ,
.CW CH ,
and
.CW RH ,
to set the left, center, and right headers; and
.CW LF ,
.CW CF ,
and
.CW RF
to set the left, center, and right footers.
This works best for documents that do not distinguish
between odd and even pages.
.IP \(bu
Use the
.CW .OH
and
.CW .EH
macros to define headers for the odd and even pages; and
.CW .OF
and
.CW .EF
macros to define footers for the odd and even pages.
This is more flexible than defining the individual strings.
The syntax for these macros is as follows:
.DS I
.CW
\&.OH '\fIleft\fP'\fIcenter\fP'\fIright\fP'
.R
.DE
.LP
You can replace the quote (') marks with any character not
appearing in the header or footer text.
.\" ------------------------
.KS
.NH 2
Margins
.XS
	Margins
.XE
.LP
You control margins using a set of number registers.
The following table lists the register names and defaults:
.TS
box expand;
cb cb cb cb
afCW l l a .
Register	Definition	Effective	Default
_
PO	Page offset (left margin)	next page	1i
LL	Line length	next \(pp	6i
LT	Header/footer (title) length	next \(pp	6i
HM	Top (header) margin	next page	1i
FM	Bottom (footer) margin	next page	1i
.TE
.KE
.PP
Note that there is no right margin setting.
The combination of page offset and line length
provide the information necessary to
derive the right margin.
.KS
.NH 2
Multiple columns
.XS
	Multiple columns
.XE
.LP
The
.I -ms
macros can set text in as many columns as will reasonably
fit on the page.
The following macros are available.
All of them force a page break if a multi-column mode is already set.
However, if the current mode is single-column, starting a multi-column
mode does
.B not
force a page break.
.TS
box expand;
cb cb
lfCWw(2i) lw(4i).
Macro	Description
_
\&.1C	Single-column mode.
_
\&.2C	Two-column mode.
_
\&.MC [\fIwidth\fP [\fIgutter\fP]]	T{
Multi-column mode.
If you specify no arguments, it is equivalent to the
.CW .2C
macro.
Otherwise,
.I width
is the width of each column and
.I gutter
is the space between columns.
The
.CW MINGW
number register is the default gutter width.
T}
.TE
.KE
.NH 2
Creating a table of contents
.XS
	Creating a table of contents
.XE
.LP
The facilities in the
.I -ms
macro package for creating a table of contents
are semi-automated at best.
Assuming that you want the table of contents to
consist of the document's headings, you need to
repeat those headings wrapped in
.CW .XS
and
.CW .XE
macros.
.PP
In addition, the
.CW .XS
macro does not know to indent a heading based on
its level.
The easiest way to work around this is to add tabs
to the table of contents string.
The following is an example:
.B1
.DS I
.CW
\&.NH 1
Introduction
\&.XS
Introduction
\&.XE
.R
\&...
.CW
\&.NH 2
Methodology
\&.XS
	Methodology
\&.XE
.R
\&...
.DE
.B2
.LP
The
.I "Groff and Friends HOWTO"
includes a
.I sed
script that automatically inserts
.CW .XS
and
.CW .XE
entries after each heading in a document.
.PP
Altering the
.CW .NH
macro to automatically build the table of contents
is perhaps initially more difficult, but would save
a great deal of time in the long run if you use
.I -ms
regularly.
.\" ------------------------
.NH 1
Differences from AT&T
.I -ms
.XS
Differences from AT&T
.I -ms
.XE
.LP
This section lists the (minor) differences between the
.I "groff -ms"
macros and
.Acr AT&T
.I "troff -ms"
macros.
.NH 2
.I troff
macros not appearing in
.I groff
.XS
	\fItroff\fP
macros not appearing in
.I groff
.XE
.LP
Macros missing from
.I "groff -ms"
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
.NH 2
.I groff
macros not appearing in
AT&T
.I troff
.XS
	\fIgroff\fP
macros not appearing in
AT&T
.I troff
.XE
.LP
The
.I "groff -ms"
macros have a few minor extensions compared to the
.Acr AT&T
.I "troff -ms"
macros.
.IP \&.AM 0.5i
Improved accent marks.
.IP "\&.DS I"
Indented display.
The default behavior of
.Acr AT&T
.I "troff -ms"
was to indent; the
.I groff
default prints displays flush left with the body text.
.IP \&.CW
Print text in
.CW "constant width"
(Courier) font.
.IP \&.IX
Indexing term (printed on standard error).
.PP
The
.CW MINGW
number register specifies a minimum space between columns
(for multi-column output); this takes the place of the
.CW GW
register that was documented but apparently not implemented in
.Acr AT&T
.I troff .
Several new string registers are available as well.
You can change these to handle (for example) the local language.
.IP REFERENCES 0.5i
Contains the string printed at the beginning of the
references (bibliography) page.
.IP ABSTRACT
Contains the string printed at the beginning of the abstract.
.IP TOC
.br
Contains the string printed at the beginning of the table of contents.
.\" ------------------------
.if t .bp
.NH 1
Acknowledgements
.XS
Acknowledgements
.XE
.LP
Two documents provided essential reference material:
.IP \(bu
The
.I "Groff and Friends HOWTO" ,
.R
by Dean Allen Provins.
.IP \(bu
.I "Using the -ms Macros with Troff and Nroff" ,
.R
the original
.Acr AT&T
document by M. E. Lesk.
.LP
Without these documents close at hand,
writing this document would have been a
much more difficult task.
.\" ------------------------
.\" Toc here at end...
.\" We need to fix the headers...
.TC
.
.
.\" Local Variables:
.\" fill-column: 72
.\" mode: nroff
.\" End:
.\" vim: set filetype=groff textwidth=72:
