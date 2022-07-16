#!/bin/sh

export UPDATE_COPYRIGHT_USE_INTERVALS=2
find arch contrib font man tmac src \
     ! -name .gitignore \
     -type f | xargs ./gnulib/build-aux/update-copyright -

extra_files="
acinclude.m4
bootstrap.conf
configure.ac
gendef.sh
mdate.pl
test-groff.in
BUG-REPORT
Changelog
FOR-RELEASE
INSTALL.REPO
INSTALL.extra
LICENSES
MANIFEST
MORE.STUFF
Makefile.am
NEWS
PROBLEMS
PROJECTS
README
README.MinGW
TODO
doc/automake.mom
doc/doc.am
doc/groff.texi
doc/meref.me
doc/pic.ms
m4/groff.m4
m4/localcharset.m4
"
for k in $extra_files; do
    ./gnulib/build-aux/update-copyright $k
done
