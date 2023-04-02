#!/bin/sh
#
# Copyright (C) 2022 Free Software Foundation, Inc.
#
# This file is part of groff.
#
# groff is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your
# option) any later version.
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

# Regression-test Savnnah #63398.

input='.de M
.  nr N \\\\$1-1
.  if \\\\$1 .M \\\\nN
Sed ut perspiciatis, unde omnis iste natus error sit voluptatem
accusantium doloremque laudantium, totam rem aperiam eaque ipsa, quae ab
illo inventore veritatis et quasi architecto beatae vitae dicta sunt,
explicabo.\\\\*F
.  FS
footnote text
.  FE
..
.P
.M 16'

# .de M
# .  nr N \\$1-1
# .  if \\$1 .M \\nN
# Sed ut perspiciatis, unde omnis iste natus error sit voluptatem
# accusantium doloremque laudantium, totam rem aperiam eaque ipsa, quae ab
# illo inventore veritatis et quasi architecto beatae vitae dicta sunt,
# explicabo.\\*F
# .FS
# blather
# .FE
# Nemo enim ipsam voluptatem, quia voluptas sit, aspernatur
# aut odit aut fugit, sed quia consequuntur magni dolores eos, qui ratione
# voluptatem sequi nesciunt, neque porro quisquam est, qui dolorem ipsum,
# quia dolor sit amet consectetur adipiscivelit, sed quia non-numquam eius
# modi tempora incidunt, ut labore et dolore magnam aliquam quaerat
# voluptatem.  Ut enim ad minima veniam, quis nostrum exercitationem ullam
# corporis suscipitlaboriosam, nisi ut aliquid ex ea commodi consequatur?
# Quis autem vel eum iure reprehenderit, qui inea voluptate velit esse,
# quam nihil molestiae consequatur, vel illum, qui dolorem eum fugiat, quo
# voluptas nulla pariatur?  At vero eos et accusamus et iusto odio
# dignissimos ducimus, qui blanditiis praesentium voluptatum deleniti
# atque corrupti, quos dolores et quas molestias excepturi sint, obcaecati
# cupiditate non-provident, similique sunt in culpa, qui officia deserunt
# mollitia animi, id est laborum et dolorum fuga.  Et harum quidem rerum
# facilis est et expedita distinctio.  Nam libero tempore, cum soluta
# nobis est eligendi optio, cumque nihil impedit, quo minus id, quod
# maxime placeat, facere possimus, omnis voluptas assumenda est, omnis
# dolor repellendus.  Temporibus autem quibusdam et aut officiis debitis
# aut rerum necessitatibus saepe eveniet, ut et voluptates repudiandae
# sint et molestiae non-recusandae.  Itaque earum rerum hic tenetur a
# sapiente delectus, ut aut reiciendis voluptatibus maiores alias
# consequatur aut perferendis doloribus asperiores repellat.
# ..
# .P
# .M 4

output=$(echo "$input" | "$groff" -mm -mmse -Tps)

# vim:set ai et sw=4 ts=4 tw=72:
