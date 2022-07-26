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

groff="${abs_top_builddir:-.}/test-groff"
fail=

# Confirm translation of a groff special character escape sequence to a
# basic Latin character when used in a device control escape sequence.
#
# $1 is the special character escape _without_ the leading backslash.
# $2 is the expected output character _shell-quoted as necessary_.
# $3 is a human-readable glyph description for the test log.
# $4 is the groff -T device name under test.
check_char () {
  sc=$1
  output=$2
  description=$3
  device=$4
  printf 'checking conversion of \%s to %s (%s) on device %s' \
    "$sc" "$output" "$description" "$device"
  if ! printf "\\X#\\%s %s#\n" "$sc" "$desc" | "$groff" -T$device -Z \
    | grep -Fqx 'x X '$output' '
  then
    printf '...failed'
    fail=yes
  fi
  printf '\n'
}

for device in utf8 html
do
  check_char - - "minus sign" $device
  check_char '[aq]' "'" "neutral apostrophe" $device
  check_char '[dq]' '"' "double quote" $device
  check_char '[ga]' '`' "grave accent" $device
  check_char '[ha]' ^ "caret/hat" $device
  check_char '[rs]' '\' "reverse solidus/backslash" $device
  check_char '[ti]' '~' "tilde" $device
done

test -z "$fail" || exit 1

# vim:set autoindent expandtab shiftwidth=2 tabstop=2 textwidth=72:
