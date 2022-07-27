s/.*\\##.*/&\
&/
s/\\##//
t
s/\\" FOOTNOTE/@FOOTNOTE@/
s/\\/\\[rs]/g
s/-/\\&/g
s/'/\\[aq]/g
s/~/\\[ti]/g
s/^\./\\\&&/
/@FOOTNOTE@/a\
.FS\
This is a long footnote occupying multiple output lines.\
Its only purpose is to verify that the bottom of the box on this page\
has been adjusted upwards to accommodate it.\
.FE
s/@FOOTNOTE@/\\m[red]\\**\\m[]/
s/REPLACEME/(replaced by source of this document)/
