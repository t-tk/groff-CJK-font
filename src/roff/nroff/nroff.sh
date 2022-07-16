#! /bin/sh
# Emulate nroff with groff.
#
# Copyright (C) 1992-2020 Free Software Foundation, Inc.
#
# Written by James Clark.

# This file is part of 'groff'.

# 'groff' is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License (GPL) as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# 'groff' is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

prog="$0"

# Default device.

# Check the GROFF_TYPESETTER environment variable.
Tenv=$GROFF_TYPESETTER

# Try the 'locale charmap' command first because it is most reliable.
# On systems where it doesn't exist, look at the environment variables.
case "`exec 2>/dev/null ; locale charmap`" in
  UTF-8)
    Tloc=utf8 ;;
  ISO-8859-1 | ISO-8859-15)
    Tloc=latin1 ;;
  IBM-1047)
    Tloc=cp1047 ;;
  *)
    case "${LC_ALL-${LC_CTYPE-${LANG}}}" in
      *.UTF-8)
        Tloc=utf8 ;;
      iso_8859_1 | *.ISO-8859-1 | *.ISO8859-1 | \
      iso_8859_15 | *.ISO-8859-15 | *.ISO8859-15)
        Tloc=latin1 ;;
      *.IBM-1047)
        Tloc=cp1047 ;;
      *)
        case "$LESSCHARSET" in
          utf-8)
            Tloc=utf8 ;;
          latin1)
            Tloc=latin1 ;;
          cp1047)
            Tloc=cp1047 ;;
          *)
            Tloc=ascii ;;
        esac ;;
    esac ;;
esac

Topt=
opts=
dry_run=
for i
do
  case $1 in
    -c)
      opts="$opts -P-c" ;;
    -h)
      opts="$opts -P-h" ;;
    -[eq] | -s*)
      # ignore these options
      ;;
    -[dmMnoPrTwW])
      echo "$prog: option '$1' requires an argument" >&2
      exit 1 ;;
    -[CEipStU] | -[dMmrnoPwW]*)
      opts="$opts $1" ;;
    -T*)
      Topt=$1 ;;
    -u*)
      # -u is for Solaris compatibility and not otherwise documented.
      #
      # Solaris 2.2 through at least Solaris 9 'man' invokes
      # 'nroff -u0 ... | col -x'.  Ignore the -u0, since 'less' and
      # 'more' can use the emboldening info.  But disable SGR, since
      # Solaris 'col' mishandles it.
      opts="$opts -P-c" ;;
    -V)
      dry_run=yes ;;
    -v | --version)
      echo "GNU nroff (groff) version @VERSION@"
      opts="$opts $1" ;;
    --help)
      cat <<EOF
usage: nroff [-cCEhipStUV] [-dCS] [-mNAME] [-MDIR] [-nNUM] [-oLIST]
             [-Popt ...] [-rCN] [-Tname] [-wNAME] [-WNAME] [FILE ...]
EOF
      exit 0 ;;
    --)
      shift
      break ;;
    -)
      break ;;
    -*)
      echo "$prog: invalid option '$1'; see '$prog --help'" >&2
      exit 1 ;;
    *)
      break ;;
  esac
  shift
done

if test "x$Topt" != x
then
  T=$Topt
else
  if test "x$Tenv" != x
  then
    T=-T$Tenv
  fi
fi

case $T in
  -Tascii | -Tlatin1 | -Tutf8 | -Tcp1047)
    ;;
  *)
    # ignore other devices and use locale fallback
    T=-T$Tloc ;;
esac

# Load nroff-style character definitions too.
opts="-mtty-char$opts"

# Set up the 'GROFF_BIN_PATH' variable to be exported in the current
# 'GROFF_RUNTIME' environment.
@GROFF_BIN_PATH_SETUP@
export GROFF_BIN_PATH

# Let the test cases redirect us.
groff=${GROFF_TEST_GROFF:-groff}

# Note 1: It would be nice to apply the DRY ("Don't Repeat Yourself")
# principle here and store the entire command string to be executed into
# a variable, and then either display it or execute it.  For example:
#
#   cmd="PATH=... groff ... $@"
#   ...
#   printf "%s\n" "$cmd"
#   ...
#   eval $cmd
#
# Unfortunately, the shell is a nightmarish hellscape of quoting issues.
# Naïve attempts to solve the problem fail when arguments to nroff
# contain embedded whitespace or shell metacharacters.  The solution
# below works with those, but there is insufficient quoting in -V (dry
# run) mode, such that you can't cut-and-paste the output of 'nroff -V'
# if you pass it a filename like foo"bar (with the embedded quotation
# mark) and expect it to run without further quoting.
#
# If POSIX adopts Bash's ${var@Q} or an equivalent, this issue can be
# revisited.
#
# Note 2: The construction '${1+"@$"}' is not for compatibility with old
# or buggy shells, but to preserve the absence of arguments.  We don't
# want 'nroff' to become 'groff ... ""' if $# equals zero.
if [ -n "$dry_run" ]
then
  echo PATH="$GROFF_RUNTIME$PATH" $groff $T $opts ${1+"$@"}
else
  PATH="$GROFF_RUNTIME$PATH" $groff $T $opts ${1+"$@"}
fi

# eof
