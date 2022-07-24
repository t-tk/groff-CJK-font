# Autoconf configuration file for groff.
# Copyright (C) 1989-2020 Free Software Foundation, Inc.
#
# This file is part of groff.
#
# groff is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# groff is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Process this file with autoconf to produce a configure script.

AC_INIT([GNU Troff],
        m4_esyscmd([build-aux/git-version-gen --prefix "" .tarball-version]),
        http://savannah.gnu.org/bugs/?group=groff,
        [groff])

AC_PREREQ([2.64])

# SHORT_VERSION contains only the number of REVISION before the first '.',
# e.g. if REVISION is '3.real.434-5aafd' then SHORT_VERSION is 'x.yy.3',
# where x and yy are MAJOR_VERSION and MINOR_VERSION, respectively.
AC_SUBST([SHORT_VERSION],
	m4_bregexp(AC_PACKAGE_VERSION,[^\(\w+\.\w+\.\w+\).*$],[\1]))

# Directories where the helper scripts should be found. This must be consistent
# with the variable build_aux in bootstrap.conf
AC_CONFIG_AUX_DIR([build-aux])

AC_CONFIG_HEADERS([src/include/config.h:src/include/config.hin])
AC_CONFIG_SRCDIR([src/roff/groff/groff.cpp])

AC_USE_SYSTEM_EXTENSIONS

AM_INIT_AUTOMAKE([subdir-objects])

AM_SILENT_RULES([yes])

# checks for programs
AC_PROG_CC
AC_PROG_CXX
gl_EARLY
gl_INIT
GROFF_CXX_CHECK
GROFF_EBCDIC
GROFF_OS390
GROFF_CMD_FILES
GROFF_X11
GROFF_APPRESDIR_OPTION
GROFF_APPRESDIR_DEFAULT
GROFF_LIBPROGRAMDIR_DEFAULT
GROFF_GLILYPONDDIR_DEFAULT
GROFF_GPINYINDIR_DEFAULT
GROFF_PERL
GROFF_PRINT
# GROFF_REFER
GROFF_REFERDIR_DEFAULT
AC_PROG_EGREP
GROFF_PROG_YACC
GROFF_DOC_CHECK
GROFF_MAKEINFO
GROFF_TEXI2DVI
AC_PROG_RANLIB
GROFF_INSTALL_SH
GROFF_INSTALL_INFO
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MKDIR_P
GROFF_PROG_XPMTOPPM
PKG_PROG_PKG_CONFIG
GROFF_UCHARDET
GROFF_PDFTOOLS

# use a dummy substitution if no csh hack is necessary to avoid errors
# with non-GNU sed programs
GROFF_CSH_HACK([SH_SCRIPT_SED_CMD='1s/.*/:/'], [SH_SCRIPT_SED_CMD='1s/a/a/'])
AC_SUBST([SH_SCRIPT_SED_CMD])

# checks for headers
AC_CHECK_HEADERS([stddef.h stdlib.h unistd.h dirent.h limits.h sys/dir.h \
                  string.h strings.h math.h sys/time.h direct.h process.h])
GROFF_ISC_SYSV3
GROFF_POSIX

# checks for header stuff
GROFF_SRAND
GROFF_NEED_DECLARATION([gettimeofday])
GROFF_NEED_DECLARATION([popen])
GROFF_NEED_DECLARATION([pclose])
GROFF_NEED_DECLARATION([putenv])
GROFF_NEED_DECLARATION([rand])
GROFF_NEED_DECLARATION([srand])
GROFF_NEED_DECLARATION([strcasecmp])
GROFF_NEED_DECLARATION([strncasecmp])
GROFF_NEED_DECLARATION([vfprintf])
GROFF_SYS_NERR
GROFF_SYS_ERRLIST
GROFF_OSFCN_H
GROFF_LIMITS_H
GROFF_INTTYPES_H

# checks for typedefs
GROFF_UNSIGNED_LONG_LONG
GROFF_UINTMAX_T
GROFF_TIME_T
GROFF_TYPE_SIGNAL
GROFF_STRUCT_EXCEPTION

# check endianness
AC_C_BIGENDIAN

# checks for libraries
GROFF_LIBC
GROFF_LIBM

AC_LANG_PUSH([C++])
AM_ICONV
AC_LANG_POP([C++])

# we need LIBEXT
AC_SUBST([LIBEXT],[$acl_libext])

# checks for functions
AC_FUNC_MMAP
saved_libs="$LIBS"
LIBS="$LIBS $LIBC $LIBM"
AC_REPLACE_FUNCS([fmod getcwd putenv strcasecmp \
                  strerror strncasecmp strtol])
LIBS="$saved_libs"
AC_CHECK_FUNCS([gettimeofday isatty kill rename setlocale strsep])
GROFF_MKSTEMP
AC_CHECK_DECLS([strsignal, getc_unlocked])
AC_CHECK_DECLS([sys_siglist, getc_unlocked])
AM_LANGINFO_CODESET

# checks for compiler characteristics
GROFF_ARRAY_DELETE
GROFF_TRADITIONAL_CPP

# checks for operating system services
GROFF_WCOREFLAG

# URW fonts extra dir
GROFF_URW_FONTS_PATH

# other random stuff
GROFF_BROKEN_SPOOLER_FLAGS
GROFF_PAGE
GROFF_G
GROFF_TMAC
GROFF_WITH_COMPATIBILITY_WRAPPERS
GROFF_TARGET_PATH_SEPARATOR
GROFF_HTML_PROGRAMS
GROFF_PDFDOC_PROGRAMS
GROFF_PNMTOPS_NOSETPAGE
GROFF_MAKE_RM
GROFF_DIFF_D
GROFF_HAVE_TEST_EF_OPTION
GROFF_BASH
GROFF_GHOSTSCRIPT_VERSION_CHECK
gl_GLIBC21
gl_LOCALCHARSET

# checks for presence of URW fonts (requires ghostscript, which is
# checked in GROFF_HTML_PROGRAMS
GROFF_URW_FONTS

AM_CONDITIONAL([BUILD_WINSCRIPTS], [test -n "$make_winscripts"])

# If X11 is not available, don't build:
# font/devX75 
# font/devX75-12
# font/devX100
# font/devX100-12
# src/devices/xditview 
# src/utils/xtotroff
# src/libs/libxutil
AM_CONDITIONAL([WITHOUT_X11], [test "x$groff_no_x" = "xyes"])

# make builtin variable RM
AM_CONDITIONAL([MAKE_DONT_HAVE_RM], [test "x$groff_is_rm_defined" = "xno"])

# Some programs have a "g" prefix if an existing groff installation is detected
AM_CONDITIONAL([USEPROGRAMPREFIX], [test x$g = xg])

AM_CONDITIONAL([BUILD_INFODOC], [test -n "$make_infodoc"])
AM_CONDITIONAL([BUILD_HTML], [test -n "$make_htmldoc"])
AM_CONDITIONAL([BUILD_HTMLEXAMPLES], [test -n "$make_htmlexamples"])
AM_CONDITIONAL([BUILD_PDFDOC], [test -n "$make_pdfdoc"])
AM_CONDITIONAL([BUILD_PDFEXAMPLES], [test -n "$make_pdfexamples"])
AM_CONDITIONAL([BUILD_OTHERDOC], [test -n "$make_otherdoc"])
AM_CONDITIONAL([BUILD_EXAMPLES], [test -n "$make_examples"])
AM_CONDITIONAL([INSTALL_SHIPPED_HTML], [test -n "$make_install_shipped_htmldoc"])
AM_CONDITIONAL([HAVE_PDFTOOLS], [test "x$groff_have_pdftools" = "xyes" ])
AM_CONDITIONAL([HAVE_TEXI2DVI], [test "x$groff_have_texi2dvi" = "xyes" ])

AC_CONFIG_FILES([Makefile])
AC_CONFIG_FILES([test-groff], [chmod +x test-groff])
AC_OUTPUT

echo "
${PACKAGE_NAME} version ${PACKAGE_VERSION}
----------------------------------------------------------------------
 Prefix                          : ${prefix}
 Compiler                        : ${CC} ${CFLAGS} ${CPPFLAGS}"
if test "x$groff_no_x" = "xyes"; then
echo "\
 X11 support                     : no"
else
echo "\
 X11 support                     : yes
 X11 resources dir               : $appresdir"
fi
if test "x$doc" = x; then
echo "\
 Doc build                       : no"
else
echo "\
 Doc build                       : ${doc} "
fi
echo "\
 URW fonts for pdf               : $groff_have_urw_fonts
 Use uchardet library for preconv: $groff_have_uchardet
 pdftools for distcheck          : $groff_have_pdftools"
echo "\
----------------------------------------------------------------------"

GROFF_APPRESDIR_CHECK
GROFF_URW_FONTS_CHECK
GROFF_UCHARDET_CHECK
GROFF_GHOSTSCRIPT_VERSION_NOTICE
