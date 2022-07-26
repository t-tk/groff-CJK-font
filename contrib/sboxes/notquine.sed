s/\\" FOOTNOTE/@FOOTNOTE@/
s/.*\\##.*/&\n&/
/\\##/{
  s/\\##//
  b}
s/\\/\\[rs]/g
s/-/\\&/g
s/'/\\[aq]/g
s/^\./\\\&&/
/@FOOTNOTE@/a\
.FS\
This is just a long footnote. Its purpose is only to check that the\
bottom of the box on this page has been adjusted because of the size\
of the footnote.\
.FE
s/@FOOTNOTE@/\\m[red]\\**\\m[]/
s/REPLACEME/(replaced by source of this document)/
