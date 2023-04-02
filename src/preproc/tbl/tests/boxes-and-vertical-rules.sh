#!/bin/sh
#
# Copyright (C) 2023 Free Software Foundation, Inc.
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
    fail=YES
}

# Test behavior of unexpanded tables using boxes and/or vertical rules.

# Case 1: "naked" table

input='.ll 64n
.nf
1234567890123456789012345678901234567890123456789012345678901234
.fi
.TS
tab(@);
L L L L L.
abcdef@abcdef@abcdef@abcdef@abcdef
.TE
.pl \n(nlu'

echo "checking unboxed table without vertical rules" >&2
output=$(printf "%s\n" "$input" | "$groff" -t -Tascii)
echo "$output"
# 3 spaces between table entries
echo "$output" | sed -n '2p' \
    | grep -qx 'abcdef   abcdef   abcdef   abcdef   abcdef' || wail

# Case 2: left-hand vertical rule

input='.ll 64n
.nf
1234567890123456789012345678901234567890123456789012345678901234
.fi
.TS
tab(@);
| L L L L L.
abcdef@abcdef@abcdef@abcdef@abcdef
.TE
.pl \n(nlu'

echo "checking unboxed table with left-hand rule" >&2
output=$(printf "%s\n" "$input" | "$groff" -t -Tascii)
echo "$output"
# 3 spaces between table entries
echo "$output" | sed -n '3p' \
    | grep -qx '| abcdef   abcdef   abcdef   abcdef   abcdef' || wail

# Case 3: right-hand vertical rule

input='.ll 64n
.nf
1234567890123456789012345678901234567890123456789012345678901234
.fi
.TS
tab(@);
L L L L L |.
abcdef@abcdef@abcdef@abcdef@abcdef
.TE
.pl \n(nlu'

echo "checking unboxed table with right-hand rule" >&2
output=$(printf "%s\n" "$input" | "$groff" -t -Tascii)
echo "$output"
# 3 spaces between table entries
echo "$output" | sed -n '3p' \
    | grep -qx 'abcdef   abcdef   abcdef   abcdef   abcdef |' || wail

# Case 4: vertical rule on both ends

input='.ll 64n
.nf
1234567890123456789012345678901234567890123456789012345678901234
.fi
.TS
tab(@);
| L L L L L |.
abcdef@abcdef@abcdef@abcdef@abcdef
.TE
.pl \n(nlu'

echo "checking unboxed table with both rules" >&2
output=$(printf "%s\n" "$input" | "$groff" -t -Tascii)
echo "$output"
# 3 spaces between table entries
echo "$output" | sed -n '3p' \
    | grep -qx '| abcdef   abcdef   abcdef   abcdef   abcdef |' || wail

# Case 5: vertical rule on both ends and interior rule

input='.ll 64n
.nf
1234567890123456789012345678901234567890123456789012345678901234
.fi
.TS
tab(@);
| L L L | L L |.
abcdef@abcdef@abcdef@abcdef@abcdef
.TE
.pl \n(nlu'

echo "checking unboxed table with both edge and interior rules" >&2
output=$(printf "%s\n" "$input" | "$groff" -t -Tascii)
echo "$output"
# 3 spaces between table entries
echo "$output" | sed -n '3p' \
    | grep -qx '| abcdef   abcdef   abcdef | abcdef   abcdef |' || wail

# Case 6: boxed table

input='.ll 64n
.nf
1234567890123456789012345678901234567890123456789012345678901234
.fi
.TS
box tab(@);
L L L L L.
abcdef@abcdef@abcdef@abcdef@abcdef
.TE
.pl \n(nlu'

echo "checking boxed table without interior rules" >&2
output=$(printf "%s\n" "$input" | "$groff" -t -Tascii)
echo "$output"
# 3 spaces between table entries
echo "$output" | sed -n '3p' \
    | grep -qx '| abcdef   abcdef   abcdef   abcdef   abcdef |' || wail

# Case 7: boxed table with interior vertical rule

input='.ll 64n
.nf
1234567890123456789012345678901234567890123456789012345678901234
.fi
.TS
box tab(@);
L L L | L L.
abcdef@abcdef@abcdef@abcdef@abcdef
.TE
.pl \n(nlu'

echo "checking boxed table with interior rules" >&2
output=$(printf "%s\n" "$input" | "$groff" -t -Tascii)
echo "$output"
# 3 spaces between table entries
echo "$output" | sed -n '3p' \
    | grep -qx '| abcdef   abcdef   abcdef | abcdef   abcdef |' || wail

test -z "$fail"

# vim:set ai et sw=4 ts=4 tw=72:
