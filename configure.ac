# Autoconf configuration file for groff.
# Copyright (C) 1989-2023 Free Software Foundation, Inc.
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
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Process this file with autoconf to produce a configure script.

AC_INIT([GNU roff],
        m4_esyscmd([build-aux/git-version-gen --prefix "" .tarball-version]),
        http://savannah.gnu.org/bugs/?group=groff,
        [groff])

AC_PREREQ([2.64])

# SHORT_VERSION contains only the number of REVISION before the first
# '.'; e.g., if REVISION is '3.real.434-5aafd' then SHORT_VERSION is
# 'x.yy.3', where x and yy are MAJOR_VERSION and MINOR_VERSION,
# respectively.
AC_SUBST([SHORT_VERSION],
	m4_bregexp(AC_PACKAGE_VERSION,[^\(\w+\.\w+\.\w+\).*$],[\1]))

# Directories where the helper scripts should be found. This must be
# consistent with the variable build_aux in bootstrap.conf.
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
GROFF_APPDEFDIR_OPTION
GROFF_APPDEFDIR_DEFAULT
GROFF_LIBPROGRAMDIR_DEFAULT
GROFF_GLILYPONDDIR_DEFAULT
GROFF_GPINYINDIR_DEFAULT
GROFF_PERL
GROFF_PRINT
# GROFF_REFER
GROFF_REFERDIR_DEFAULT
AC_PROG_EGREP
GROFF_PROG_YACC
GROFF_PROG_M4
GROFF_PROG_MAKEINFO
GROFF_PROG_TEXI2DVI
GROFF_USE_TEX_CHECK
AC_PROG_RANLIB
GROFF_INSTALL_SH
GROFF_INSTALL_INFO
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MKDIR_P
GROFF_PROG_XPMTOPPM
PKG_PROG_PKG_CONFIG
GROFF_UCHARDET

# use a dummy substitution if no csh hack is necessary to avoid errors
# with non-GNU sed programs
GROFF_CSH_HACK([SH_SCRIPT_SED_CMD='1s/.*/:/'],
               [SH_SCRIPT_SED_CMD='1s/a/a/'])
AC_SUBST([SH_SCRIPT_SED_CMD])

# checks for headers
AC_CHECK_HEADERS([stdbool.h stddef.h stdlib.h unistd.h dirent.h \
                  limits.h sys/dir.h string.h strings.h math.h \
                  sys/time.h direct.h process.h])
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
AC_CHECK_FUNCS([gettimeofday isatty kill rename setlocale strdup \
                strsep])
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

# use groff's own malloc-based allocator for C++ new/delete operators
GROFF_USE_GROFF_ALLOCATOR

# other random stuff
GROFF_BROKEN_SPOOLER_FLAGS
GROFF_PAGE
GROFF_G
GROFF_TMAC
GROFF_WITH_COMPATIBILITY_WRAPPERS
GROFF_TARGET_PATH_SEPARATOR
GROFF_CHECK_GROHTML_PROGRAMS
GROFF_PDFROFF_DEPENDENCIES_CHECK
GROFF_GROPDF_DEPENDENCIES_CHECK
GROFF_PNMTOOLS_CAN_BE_QUIET
GROFF_PNMTOPS_NOSETPAGE
GROFF_MAKE_DEFINES_RM
GROFF_DIFF_D
GROFF_HAVE_TEST_EF_OPTION
GROFF_BASH
GROFF_GHOSTSCRIPT_VERSION_CHECK
gl_GLIBC21
gl_LOCALCHARSET

AM_CONDITIONAL([BUILD_WINSCRIPTS], [test -n "$make_winscripts"])

# If X11 is not available, don't build:
# font/devX75
# font/devX75-12
# font/devX100
# font/devX100-12
# src/devices/xditview
# src/utils/xtotroff
# src/libs/libxutil
AM_CONDITIONAL([WITHOUT_X11], [test "$groff_no_x" = yes])

AM_CONDITIONAL([MAKE_DEFINES_RM], [test "$groff_make_defines_rm" = yes])

# Some programs have a "g" prefix if an existing troff installation is
# detected.
AM_CONDITIONAL([USEPROGRAMPREFIX], [test "$g" = g])

AM_CONDITIONAL([USE_GROHTML], [test "$use_grohtml" = yes])
AM_CONDITIONAL([USE_PDFROFF], [test "$use_pdfroff" = yes])
AM_CONDITIONAL([USE_GROPDF], [test "$use_gropdf" = yes])
AM_CONDITIONAL([USE_GROFF_ALLOCATOR],
               [test "$groff_use_own_allocator" = yes])
AM_CONDITIONAL([HAVE_GHOSTSCRIPT], [test "$GHOSTSCRIPT" != no \
                && test "$GHOSTSCRIPT" != missing])
AM_CONDITIONAL([HAVE_URW_FONTS], [test "$groff_have_urw_fonts" = yes ])
AM_CONDITIONAL([HAVE_TEXI2DVI], [test "$groff_have_texi2dvi" = yes ])
AM_CONDITIONAL([USE_TEX], [test "$groff_use_tex" = yes ])

AC_CONFIG_FILES([Makefile])
AC_CONFIG_FILES([test-groff], [chmod +x test-groff])
AC_OUTPUT

echo "
$PACKAGE_NAME version $PACKAGE_VERSION
----------------------------------------------------------------------
 installation directory prefix    : $prefix"
if test -n "$g"
then
  echo "\
 command name prefix              : $g"
  if test -n "$tmac_wrap"
  then
  echo "\
 wrappers used for macro packages : $tmac_wrap"
  fi
fi
echo "\
 C++ compiler and options         : $CXX $CXXFLAGS $CPPFLAGS
 use libgroff's memory allocator  : $groff_use_own_allocator
 C compiler and options           : $CC $CFLAGS $CPPFLAGS
 Perl interpreter version         : $perl_version"
if test "$groff_no_x" = yes
then
  echo "\
 X11 support                      : disabled"
else
  echo "\
 X11 support                      : enabled
 X11 app defaults directory       : $appdefdir"
fi
echo "\
 default paper format             : $PAGE"
echo "\
 'groff -l' uses print spooler    : $groff_have_spooler
 use URW fonts for PDF output     : $groff_have_urw_fonts"
if test "$groff_have_urw_fonts" = yes
then
 echo "\
 URW fonts directory              : $urwfontsdir"
fi
echo "\
 preconv can use uchardet library : $groff_have_uchardet
 can build groff.dvi, groff.pdf   : $groff_use_tex
----------------------------------------------------------------------"

GROFF_APPDEFDIR_NOTICE
GROFF_AWK_NOTICE
GROFF_GHOSTSCRIPT_AVAILABILITY_NOTICE
GROFF_GHOSTSCRIPT_VERSION_NOTICE
GROFF_URW_FONTS_NOTICE
GROFF_UCHARDET_NOTICE
GROFF_GROHTML_PROGRAM_NOTICE
GROFF_PDFROFF_PROGRAM_NOTICE
GROFF_GROPDF_PROGRAM_NOTICE
