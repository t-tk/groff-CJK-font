/* Copyright (C) 1989-2020 Free Software Foundation, Inc.
     Written by James Clark (jjc@jclark.com)

This file is part of groff.

groff is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License, or
(at your option) any later version.

groff is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>. */

#include "lib.h"

#include <stdlib.h>
#include <errno.h>
#include "font.h"
#include "searchpath.h"
#include "device.h"
#include "defs.h"

const char *const FONT_ENV_VAR = "GROFF_FONT_PATH";

static search_path font_path(FONT_ENV_VAR, FONTPATH, 0, 0);

int font::res = 0;
int font::hor = 1;
int font::vert = 1;
int font::unitwidth = 0;
int font::paperwidth = 0;
int font::paperlength = 0;
const char *font::papersize = 0;
int font::biggestfont = 0;
int font::spare2 = 0;
int font::sizescale = 1;
bool font::has_tcommand = false;
bool font::pass_filenames = false;
bool font::use_unscaled_charwidths = false;
bool font::use_charnames_in_special = false;
bool font::is_unicode = false;
const char *font::image_generator = 0;
const char **font::font_name_table = 0;
int *font::sizes = 0;
const char *font::family = 0;
const char **font::style_table = 0;
FONT_COMMAND_HANDLER font::unknown_desc_command_handler = 0;

void font::command_line_font_dir(const char *dir)
{
  font_path.command_line_dir(dir);
}

FILE *font::open_file(const char *nm, char **pathp)
{
  FILE *fp = 0 /* nullptr */;
  // Do not traverse user-specified directories; Savannah #61424.
  if (0 /* nullptr */ == strchr(nm, '/')) {
    // Allocate enough for nm + device + 'dev' '/' '\0'.
    int expected_size = strlen(nm) + strlen(device) + 5;
    char *filename = new char[expected_size];
    const int actual_size = sprintf(filename, "dev%s/%s", device, nm);
    expected_size--; // sprintf() doesn't count the null terminator.
    if (actual_size == expected_size)
      fp = font_path.open_file(filename, pathp);
    delete[] filename;
  }
  return fp;
}

// Local Variables:
// fill-column: 72
// mode: C++
// End:
// vim: set cindent noexpandtab shiftwidth=2 textwidth=72:
