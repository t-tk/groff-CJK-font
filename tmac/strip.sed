/%beginstrip%/,$ {
  /%beginstrip%/c\
.\\" This is a generated file, created by 'tmac/strip.sed' in groff's\
.\\" source distribution from a file having '-u' appended to its name.
  s/^\.[	 ]*/./
  s/^\.\\".*/./
  s/^\\#.*/./
  s/\\".*/\\"/
  s/\\#.*/\\/
  /\.[ad]s/!s/[	 ]*\\"//
  /\.[ad]s/s/\([^	 ]*\)\\"/\1/
  /^\.$/d
}
