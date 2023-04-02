#!/bin/sh
#
# Copyright (C) 2022 Free Software Foundation, Inc.
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

wail () {
    echo ...FAILED >&2
    fail=yes
}

# Ensure that italics in a section heading get remapped to bold italics
# (if the heading font is bold).

input='.Dd 2022-12-26
.Dt foo 1
.Os "groff test suite"
.Sh Name
.Nm foo
.Nd frobnicate a bar
.Sh Hacking Xr groff
Have fun!'

output=$(printf "%s\n" "$input" | "$groff" -mdoc -Tascii -Z)
echo "$output"

echo "$output" | sed -n '/tHacking/{n
/x font 4 BI/{n
/f4/{n
/h/{n
/tgroff/{n
/n/{n
/f1/p;}
}
}
}
}
}' | grep -Fqx f1

# vim:set ai et sw=4 ts=4 tw=72:
