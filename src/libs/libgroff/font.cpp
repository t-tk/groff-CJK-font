/* Copyright (C) 1989-2021 Free Software Foundation, Inc.
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

#include <ctype.h>
#include <assert.h>
#include <math.h>
#include <stdlib.h>
#include <wchar.h>
#include "errarg.h"
#include "error.h"
#include "cset.h"
#include "font.h"
#include "unicode.h"
#include "paper.h"

const char *const WS = " \t\n\r";

struct font_char_metric {
  char type;
  int code;
  int width;
  int height;
  int depth;
  int pre_math_space;
  int italic_correction;
  int subscript_correction;
  char *special_device_coding;
};

struct font_kern_list {
  glyph *glyph1;
  glyph *glyph2;
  int amount;
  font_kern_list *next;

  font_kern_list(glyph *, glyph *, int, font_kern_list * = 0);
};

struct font_widths_cache {
  font_widths_cache *next;
  int point_size;
  int *width;

  font_widths_cache(int, int, font_widths_cache * = 0);
  ~font_widths_cache();
};

/* text_file */

struct text_file {
  FILE *fp;
  char *path;
  int lineno;
  int linebufsize;
  bool recognize_comments;
  bool silent;
  char *buf;
  text_file(FILE *fp, char *p);
  ~text_file();
  bool next_line();
  void error(const char *format,
	     const errarg &arg1 = empty_errarg,
	     const errarg &arg2 = empty_errarg,
	     const errarg &arg3 = empty_errarg);
  void fatal(const char *format,
	     const errarg &arg1 = empty_errarg,
	     const errarg &arg2 = empty_errarg,
	     const errarg &arg3 = empty_errarg);
};

text_file::text_file(FILE *p, char *s) : fp(p), path(s), lineno(0),
  linebufsize(128), recognize_comments(true), silent(false), buf(0)
{
}

text_file::~text_file()
{
  delete[] buf;
  free(path);
  if (fp)
    fclose(fp);
}

bool text_file::next_line()
{
  if (fp == 0)
    return false;
  if (buf == 0)
    buf = new char[linebufsize];
  for (;;) {
    lineno++;
    int length = 0;
    for (;;) {
      int c = getc(fp);
      if (c == EOF)
	break;
      if (invalid_input_char(c))
	error("invalid input character code %1", int(c));
      else {
	if (length + 1 >= linebufsize) {
	  char *old_buf = buf;
	  buf = new char[linebufsize * 2];
	  memcpy(buf, old_buf, linebufsize);
	  delete[] old_buf;
	  linebufsize *= 2;
	}
	buf[length++] = c;
	if (c == '\n')
	  break;
      }
    }
    if (length == 0)
      break;
    buf[length] = '\0';
    char *ptr = buf;
    while (csspace(*ptr))
      ptr++;
    if (*ptr != 0 && (!recognize_comments || *ptr != '#'))
      return true;
  }
  return false;
}

void text_file::error(const char *format,
		      const errarg &arg1,
		      const errarg &arg2,
		      const errarg &arg3)
{
  if (!silent)
    error_with_file_and_line(path, lineno, format, arg1, arg2, arg3);
}

void text_file::fatal(const char *format,
		      const errarg &arg1,
		      const errarg &arg2,
		      const errarg &arg3)
{
  if (!silent)
    fatal_with_file_and_line(path, lineno, format, arg1, arg2, arg3);
}

int glyph_to_unicode(glyph *g)
{
  const char *nm = glyph_to_name(g);
  if (nm != 0) {
    // ASCII character?
    if (nm[0] == 'c' && nm[1] == 'h' && nm[2] == 'a' && nm[3] == 'r'
	&& (nm[4] >= '0' && nm[4] <= '9')) {
      int n = (nm[4] - '0');
      if (nm[5] == '\0')
	return n;
      if (n > 0 && (nm[5] >= '0' && nm[5] <= '9')) {
	n = 10*n + (nm[5] - '0');
	if (nm[6] == '\0')
	  return n;
	if (nm[6] >= '0' && nm[6] <= '9') {
	  n = 10*n + (nm[6] - '0');
	  if (nm[7] == '\0' && n < 128)
	    return n;
	}
      }
    }
    // Unicode character?
    if (check_unicode_name(nm)) {
      char *ignore;
      return (int)strtol(nm + 1, &ignore, 16);
    }
    // If 'nm' is a single letter 'x', the glyph name is '\x'.
    char buf[] = { '\\', '\0', '\0' };
    if (nm[1] == '\0') {
      buf[1] = nm[0];
      nm = buf;
    }
    // groff glyphs that map to Unicode?
    const char *unicode = glyph_name_to_unicode(nm);
    if (unicode != 0 && strchr(unicode, '_') == 0) {
      char *ignore;
      return (int)strtol(unicode, &ignore, 16);
    }
  }
  return -1;
}

/* font functions */

font::font(const char *s) : ligatures(0), kern_hash_table(0),
  space_width(0), special(false), internalname(0), slant(0.0), zoom(0),
  ch_index(0), nindices(0), ch(0), ch_used(0), ch_size(0),
  widths_cache(0)
{
  name = new char[strlen(s) + 1];
  strcpy(name, s);
}

font::~font()
{
  for (int i = 0; i < ch_used; i++)
    if (ch[i].special_device_coding)
      delete[] ch[i].special_device_coding;
  delete[] ch;
  delete[] ch_index;
  if (kern_hash_table) {
    for (int i = 0; i < KERN_HASH_TABLE_SIZE; i++) {
      font_kern_list *kerns = kern_hash_table[i];
      while (kerns) {
	font_kern_list *tem = kerns;
	kerns = kerns->next;
	delete tem;
      }
    }
    delete[] kern_hash_table;
  }
  delete[] name;
  delete[] internalname;
  while (widths_cache) {
    font_widths_cache *tem = widths_cache;
    widths_cache = widths_cache->next;
    delete tem;
  }
}

static int scale_round(int n, int x, int y)
{
  assert(x >= 0 && y > 0);
  int y2 = y/2;
  if (x == 0)
    return 0;
  if (n >= 0) {
    if (n <= (INT_MAX - y2) / x)
      return (n * x + y2) / y;
    return int(n * double(x) / double(y) + .5);
  }
  else {
    if (-(unsigned)n <= (-(unsigned)INT_MIN - y2) / x)
      return (n * x - y2) / y;
    return int(n * double(x) / double(y) - .5);
  }
}

static int scale_round(int n, int x, int y, int z)
{
  assert(x >= 0 && y > 0 && z > 0);
  if (x == 0)
    return 0;
  if (n >= 0)
    return int((n * double(x) / double(y)) * (double(z) / 1000.0) + .5);
  else
    return int((n * double(x) / double(y)) * (double(z) / 1000.0) - .5);
}

inline int font::scale(int w, int sz)
{
  if (zoom)
    return scale_round(w, sz, unitwidth, zoom);
  else
    return sz == unitwidth ? w : scale_round(w, sz, unitwidth);
}

// Returns whether scaling by arguments was successful.  Used for paper
// size conversions.
bool font::unit_scale(double *value, char unit)
{
  // Paper sizes are handled in inches.
  double divisor = 0;
  switch (unit) {
  case 'i':
    divisor = 1;
    break;
  case 'p':
    divisor = 72;
    break;
  case 'P':
    divisor = 6;
    break;
  case 'c':
    divisor = 2.54;
    break;
  default:
    assert(0 == "unit not in [cipP]");
    break;
  }
  if (divisor) {
    *value /= divisor;
    return true;
  }
  return false;
}

int font::get_skew(glyph *g, int point_size, int sl)
{
  int h = get_height(g, point_size);
  return int(h * tan((slant + sl) * PI / 180.0) + .5);
}

bool font::contains(glyph *g)
{
  int idx = glyph_to_index(g);
  assert(idx >= 0);
  // Explicitly enumerated glyph?
  if (idx < nindices && ch_index[idx] >= 0)
    return true;
  if (is_unicode) {
    // Unicode font
    // ASCII or Unicode character, or groff glyph name that maps to Unicode?
    if (glyph_to_unicode(g) >= 0)
      return true;
    // Numbered character?
    if (glyph_to_number(g) >= 0)
      return true;
  }
  return false;
}

bool font::is_special()
{
  return special;
}

font_widths_cache::font_widths_cache(int ps, int ch_size,
				     font_widths_cache *p)
: next(p), point_size(ps)
{
  width = new int[ch_size];
  for (int i = 0; i < ch_size; i++)
    width[i] = -1;
}

font_widths_cache::~font_widths_cache()
{
  delete[] width;
}

int font::get_width(glyph *g, int point_size)
{
  int idx = glyph_to_index(g);
  assert(idx >= 0);
  int real_size;
  if (zoom == 0) // 0 means "don't zoom"
    real_size = point_size;
  else
  {
    if (point_size <= (INT_MAX - 500) / zoom)
      real_size = (point_size * zoom + 500) / 1000;
    else
      real_size = int(point_size * double(zoom) / 1000.0 + .5);
  }
  if (idx < nindices && ch_index[idx] >= 0) {
    // Explicitly enumerated glyph
    int i = ch_index[idx];
    if (real_size == unitwidth || font::use_unscaled_charwidths)
      return ch[i].width;

    if (!widths_cache)
      widths_cache = new font_widths_cache(real_size, ch_size);
    else if (widths_cache->point_size != real_size) {
      font_widths_cache **p;
      for (p = &widths_cache; *p; p = &(*p)->next)
	if ((*p)->point_size == real_size)
	  break;
      if (*p) {
	font_widths_cache *tem = *p;
	*p = (*p)->next;
	tem->next = widths_cache;
	widths_cache = tem;
      }
      else
	widths_cache = new font_widths_cache(real_size, ch_size,
					     widths_cache);
    }
    int &w = widths_cache->width[i];
    if (w < 0)
      w = scale(ch[i].width, point_size);
    return w;
  }
  if (is_unicode) {
    // Unicode font
    int width = 24; // XXX: Add a request to override this.
    int w = wcwidth(get_code(g));
    if (w > 1)
      width *= w;
    if (real_size == unitwidth || font::use_unscaled_charwidths)
      return width;
    else
      return scale(width, point_size);
  }
  assert(0 == "glyph is not indexed and device lacks Unicode support");
  abort(); // -Wreturn-type
}

int font::get_height(glyph *g, int point_size)
{
  int idx = glyph_to_index(g);
  assert(idx >= 0);
  if (idx < nindices && ch_index[idx] >= 0) {
    // Explicitly enumerated glyph
    return scale(ch[ch_index[idx]].height, point_size);
  }
  if (is_unicode) {
    // Unicode font
    return 0;
  }
  assert(0 == "glyph is not indexed and device lacks Unicode support");
  abort(); // -Wreturn-type
}

int font::get_depth(glyph *g, int point_size)
{
  int idx = glyph_to_index(g);
  assert(idx >= 0);
  if (idx < nindices && ch_index[idx] >= 0) {
    // Explicitly enumerated glyph
    return scale(ch[ch_index[idx]].depth, point_size);
  }
  if (is_unicode) {
    // Unicode font
    return 0;
  }
  assert(0 == "glyph is not indexed and device lacks Unicode support");
  abort(); // -Wreturn-type
}

int font::get_italic_correction(glyph *g, int point_size)
{
  int idx = glyph_to_index(g);
  assert(idx >= 0);
  if (idx < nindices && ch_index[idx] >= 0) {
    // Explicitly enumerated glyph
    return scale(ch[ch_index[idx]].italic_correction, point_size);
  }
  if (is_unicode) {
    // Unicode font
    return 0;
  }
  assert(0 == "glyph is not indexed and device lacks Unicode support");
  abort(); // -Wreturn-type
}

int font::get_left_italic_correction(glyph *g, int point_size)
{
  int idx = glyph_to_index(g);
  assert(idx >= 0);
  if (idx < nindices && ch_index[idx] >= 0) {
    // Explicitly enumerated glyph
    return scale(ch[ch_index[idx]].pre_math_space, point_size);
  }
  if (is_unicode) {
    // Unicode font
    return 0;
  }
  assert(0 == "glyph is not indexed and device lacks Unicode support");
  abort(); // -Wreturn-type
}

int font::get_subscript_correction(glyph *g, int point_size)
{
  int idx = glyph_to_index(g);
  assert(idx >= 0);
  if (idx < nindices && ch_index[idx] >= 0) {
    // Explicitly enumerated glyph
    return scale(ch[ch_index[idx]].subscript_correction, point_size);
  }
  if (is_unicode) {
    // Unicode font
    return 0;
  }
  assert(0 == "glyph is not indexed and device lacks Unicode support");
  abort(); // -Wreturn-type
}

void font::set_zoom(int factor)
{
  assert(factor >= 0);
  if (factor == 1000)
    zoom = 0;
  else
    zoom = factor;
}

int font::get_zoom()
{
  return zoom;
}

int font::get_space_width(int point_size)
{
  return scale(space_width, point_size);
}

font_kern_list::font_kern_list(glyph *g1, glyph *g2, int n, font_kern_list *p)
: glyph1(g1), glyph2(g2), amount(n), next(p)
{
}

inline int font::hash_kern(glyph *g1, glyph *g2)
{
  int n = ((glyph_to_index(g1) << 10) + glyph_to_index(g2))
	  % KERN_HASH_TABLE_SIZE;
  return n < 0 ? -n : n;
}

void font::add_kern(glyph *g1, glyph *g2, int amount)
{
  if (!kern_hash_table) {
    kern_hash_table = new font_kern_list *[int(KERN_HASH_TABLE_SIZE)];
    for (int i = 0; i < KERN_HASH_TABLE_SIZE; i++)
      kern_hash_table[i] = 0;
  }
  font_kern_list **p = kern_hash_table + hash_kern(g1, g2);
  *p = new font_kern_list(g1, g2, amount, *p);
}

int font::get_kern(glyph *g1, glyph *g2, int point_size)
{
  if (kern_hash_table) {
    for (font_kern_list *p = kern_hash_table[hash_kern(g1, g2)]; p;
	 p = p->next)
      if (g1 == p->glyph1 && g2 == p->glyph2)
	return scale(p->amount, point_size);
  }
  return 0;
}

bool font::has_ligature(int mask)
{
  return (bool) (mask & ligatures);
}

int font::get_character_type(glyph *g)
{
  int idx = glyph_to_index(g);
  assert(idx >= 0);
  if (idx < nindices && ch_index[idx] >= 0) {
    // Explicitly enumerated glyph
    return ch[ch_index[idx]].type;
  }
  if (is_unicode) {
    // Unicode font
    return 0;
  }
  assert(0 == "glyph is not indexed and device lacks Unicode support");
  abort(); // -Wreturn-type
}

int font::get_code(glyph *g)
{
  int idx = glyph_to_index(g);
  assert(idx >= 0);
  if (idx < nindices && ch_index[idx] >= 0) {
    // Explicitly enumerated glyph
    return ch[ch_index[idx]].code;
  }
  if (is_unicode) {
    // Unicode font
    // ASCII or Unicode character, or groff glyph name that maps to Unicode?
    int uni = glyph_to_unicode(g);
    if (uni >= 0)
      return uni;
    // Numbered character?
    int n = glyph_to_number(g);
    if (n >= 0)
      return n;
  }
  // The caller must check 'contains(g)' before calling get_code(g).
  assert(0 == "glyph is not indexed and device lacks Unicode support");
  abort(); // -Wreturn-type
}

const char *font::get_name()
{
  return name;
}

const char *font::get_internal_name()
{
  return internalname;
}

const char *font::get_special_device_encoding(glyph *g)
{
  int idx = glyph_to_index(g);
  assert(idx >= 0);
  if (idx < nindices && ch_index[idx] >= 0) {
    // Explicitly enumerated glyph
    return ch[ch_index[idx]].special_device_coding;
  }
  if (is_unicode) {
    // Unicode font
    return 0;
  }
  assert(0 == "glyph is not indexed and device lacks Unicode support");
  abort(); // -Wreturn-type
}

const char *font::get_image_generator()
{
  return image_generator;
}

void font::alloc_ch_index(int idx)
{
  if (nindices == 0) {
    nindices = 128;
    if (idx >= nindices)
      nindices = idx + 10;
    ch_index = new int[nindices];
    for (int i = 0; i < nindices; i++)
      ch_index[i] = -1;
  }
  else {
    int old_nindices = nindices;
    nindices *= 2;
    if (idx >= nindices)
      nindices = idx + 10;
    int *old_ch_index = ch_index;
    ch_index = new int[nindices];
    memcpy(ch_index, old_ch_index, sizeof(int) * old_nindices);
    for (int i = old_nindices; i < nindices; i++)
      ch_index[i] = -1;
    delete[] old_ch_index;
  }
}

void font::extend_ch()
{
  if (ch == 0)
    ch = new font_char_metric[ch_size = 16];
  else {
    int old_ch_size = ch_size;
    ch_size *= 2;
    font_char_metric *old_ch = ch;
    ch = new font_char_metric[ch_size];
    memcpy(ch, old_ch, old_ch_size * sizeof(font_char_metric));
    delete[] old_ch;
  }
}

void font::compact()
{
  int i;
  for (i = nindices - 1; i >= 0; i--)
    if (ch_index[i] >= 0)
      break;
  i++;
  if (i < nindices) {
    int *old_ch_index = ch_index;
    ch_index = new int[i];
    memcpy(ch_index, old_ch_index, i*sizeof(int));
    delete[] old_ch_index;
    nindices = i;
  }
  if (ch_used < ch_size) {
    font_char_metric *old_ch = ch;
    ch = new font_char_metric[ch_used];
    memcpy(ch, old_ch, ch_used*sizeof(font_char_metric));
    delete[] old_ch;
    ch_size = ch_used;
  }
}

void font::add_entry(glyph *g, const font_char_metric &metric)
{
  int idx = glyph_to_index(g);
  assert(idx >= 0);
  if (idx >= nindices)
    alloc_ch_index(idx);
  assert(idx < nindices);
  if (ch_used + 1 >= ch_size)
    extend_ch();
  assert(ch_used + 1 < ch_size);
  ch_index[idx] = ch_used;
  ch[ch_used++] = metric;
}

void font::copy_entry(glyph *new_glyph, glyph *old_glyph)
{
  int new_index = glyph_to_index(new_glyph);
  int old_index = glyph_to_index(old_glyph);
  assert(new_index >= 0 && old_index >= 0 && old_index < nindices);
  if (new_index >= nindices)
    alloc_ch_index(new_index);
  ch_index[new_index] = ch_index[old_index];
}

font *font::load_font(const char *s, bool load_header_only)
{
  font *f = new font(s);
  if (!f->load(load_header_only)) {
    delete f;
    return 0;
  }
  return f;
}

static char *trim_arg(char *p)
{
  if (0 == p)
    return 0;
  while (csspace(*p))
    p++;
  char *q = strchr(p, '\0');
  while (q > p && csspace(q[-1]))
    q--;
  *q = '\0';
  return p;
}

bool font::scan_papersize(const char *p, const char **size,
			  double *length, double *width)
{
  double l, w;
  char lu[2], wu[2];
  const char *pp = p;
  bool attempt_file_open = true;
  char line[255];
again:
  if (csdigit(*pp)) {
    if (sscanf(pp, "%lf%1[ipPc],%lf%1[ipPc]", &l, lu, &w, wu) == 4
	&& l > 0 && w > 0
	&& unit_scale(&l, lu[0]) && unit_scale(&w, wu[0])) {
      if (length)
	*length = l;
      if (width)
	*width = w;
      if (size)
	*size = "custom";
      return true;
    }
  }
  else {
    int i;
    for (i = 0; i < NUM_PAPERSIZES; i++)
      if (strcasecmp(papersizes[i].name, pp) == 0) {
	if (length)
	  *length = papersizes[i].length;
	if (width)
	  *width = papersizes[i].width;
	if (size)
	  *size = papersizes[i].name;
	return true;
      }
    if (attempt_file_open) {
      FILE *fp = fopen(p, "r");
      if (fp != 0) {
	if (fgets(line, 254, fp)) {
	  // Don't recurse on file names.
	  attempt_file_open = false;
	  char *linep = strchr(line, '\0');
	  // skip final newline, if any
	  if (*(--linep) == '\n')
	    *linep = '\0';
	  pp = line;
	}
	fclose(fp);
	goto again;
      }
    }
  }
  return false;
}

bool font::load(bool load_header_only)
{
  FILE *fp;
  char *path;
  if ((fp = open_file(name, &path)) == 0)
    return false;
  text_file t(fp, path);
  t.silent = load_header_only;
  char *p = 0;
  bool saw_name_directive = false;
  while (t.next_line()) {
    p = strtok(t.buf, WS);
    if (strcmp(p, "name") == 0) {
      p = strtok(0, WS);
      if (0 == p) {
	t.error("'name' directive requires an argument");
	return false;
      }
      if (strcmp(p, name) != 0) {
	t.error("font description file name '%1' does not match 'name'"
		" argument '%2'", name, p);
	return false;
      }
      saw_name_directive = true;
    }
    else if (strcmp(p, "spacewidth") == 0) {
      p = strtok(0, WS);
      int n;
      if (0 == p) {
	t.error("missing argument to 'spacewidth' directive");
	return false;
      }
      if (sscanf(p, "%d", &n) != 1) {
	t.error("invalid argument '%1' to 'spacewidth' directive", p);
	return false;
      }
      if (n <= 0) {
	t.error("'spacewidth' argument '%1' out of range", n);
	return false;
      }
      space_width = n;
    }
    else if (strcmp(p, "slant") == 0) {
      p = strtok(0, WS);
      double n;
      if (0 == p) {
	t.error("missing argument to 'slant' directive");
	return false;
      }
      if (sscanf(p, "%lf", &n) != 1) {
	t.error("invalid argument '%1' to 'slant' directive", p);
	return false;
      }
      if (n >= 90.0 || n <= -90.0) {
	t.error("'slant' directive argument '%1' out of range", n);
	return false;
      }
      slant = n;
    }
    else if (strcmp(p, "ligatures") == 0) {
      for (;;) {
	p = strtok(0, WS);
	if (0 == p || strcmp(p, "0") == 0)
	  break;
	if (strcmp(p, "ff") == 0)
	  ligatures |= LIG_ff;
	else if (strcmp(p, "fi") == 0)
	  ligatures |= LIG_fi;
	else if (strcmp(p, "fl") == 0)
	  ligatures |= LIG_fl;
	else if (strcmp(p, "ffi") == 0)
	  ligatures |= LIG_ffi;
	else if (strcmp(p, "ffl") == 0)
	  ligatures |= LIG_ffl;
	else {
	  t.error("unrecognized ligature '%1'", p);
	  return false;
	}
      }
    }
    else if (strcmp(p, "internalname") == 0) {
      p = strtok(0, WS);
      if (0 == p) {
	t.error("missing argument to 'internalname' directive");
	return false;
      }
      internalname = new char[strlen(p) + 1];
      strcpy(internalname, p);
    }
    else if (strcmp(p, "special") == 0) {
      special = true;
    }
    else if (strcmp(p, "kernpairs") != 0 && strcmp(p, "charset") != 0) {
      char *directive = p;
      p = strtok(0, "\n");
      handle_unknown_font_command(directive, trim_arg(p), t.path,
				  t.lineno);
    }
    else
      break;
  }
  bool saw_charset_directive = false;
  char *directive = p;
  t.recognize_comments = false;
  while (directive) {
    if (strcmp(directive, "kernpairs") == 0) {
      if (load_header_only)
	return true;
      for (;;) {
	if (!t.next_line()) {
	  directive = 0;
	  break;
	}
	char *c1 = strtok(t.buf, WS);
	if (0 == c1)
	  continue;
	char *c2 = strtok(0, WS);
	if (0 == c2) {
	  directive = c1;
	  break;
	}
	p = strtok(0, WS);
	if (0 == p) {
	  t.error("missing kern amount for kerning pair '%1 %2'", c1,
		  c2);
	  return false;
	}
	int n;
	if (sscanf(p, "%d", &n) != 1) {
	  t.error("invalid kern amount '%1' for kerning pair '%2 %3'",
		  p, c1, c2);
	  return false;
	}
	glyph *g1 = name_to_glyph(c1);
	glyph *g2 = name_to_glyph(c2);
	add_kern(g1, g2, n);
      }
    }
    else if (strcmp(directive, "charset") == 0) {
      if (load_header_only)
	return true;
      saw_charset_directive = true;
      glyph *last_glyph = 0;
      for (;;) {
	if (!t.next_line()) {
	  directive = 0;
	  break;
	}
	char *nm = strtok(t.buf, WS);
	assert(nm != 0);
	p = strtok(0, WS);
	if (0 == p) {
	  directive = nm;
	  break;
	}
	if (p[0] == '"') {
	  if (last_glyph == 0) {
	    t.error("the first entry ('%1') in 'charset' subsection"
		    " cannot be an alias", nm);
	    return false;
	  }
	  if (strcmp(nm, "---") == 0) {
	    t.error("an unnamed character ('---') cannot be an alias");
	    return false;
	  }
	  glyph *g = name_to_glyph(nm);
	  copy_entry(g, last_glyph);
	}
	else {
	  font_char_metric metric;
	  metric.height = 0;
	  metric.depth = 0;
	  metric.pre_math_space = 0;
	  metric.italic_correction = 0;
	  metric.subscript_correction = 0;
	  int nparms = sscanf(p, "%d,%d,%d,%d,%d,%d",
			      &metric.width, &metric.height,
			      &metric.depth,
			      &metric.italic_correction,
			      &metric.pre_math_space,
			      &metric.subscript_correction);
	  if (nparms < 1) {
	    t.error("missing or invalid width for glyph '%1'", nm);
	    return false;
	  }
	  p = strtok(0, WS);
	  if (0 == p) {
	    t.error("missing character type for '%1'", nm);
	    return false;
	  }
	  int type;
	  if (sscanf(p, "%d", &type) != 1) {
	    t.error("invalid character type for '%1'", nm);
	    return false;
	  }
	  if (type < 0 || type > 255) {
	    t.error("character type '%1' out of range for '%2'", type,
		    nm);
	    return false;
	  }
	  metric.type = type;
	  p = strtok(0, WS);
	  if (0 == p) {
	    t.error("missing code for '%1'", nm);
	    return false;
	  }
	  char *ptr;
	  metric.code = (int)strtol(p, &ptr, 0);
	  if (metric.code == 0 && ptr == p) {
	    t.error("invalid code '%1' for character '%2'", p, nm);
	    return false;
	  }
	  if (is_unicode) {
	    int w = wcwidth(metric.code);
	    if (w > 1)
	      metric.width *= w;
	  }
	  p = strtok(0, WS);
	  if ((0 == p) || (strcmp(p, "--") == 0)) {
	    metric.special_device_coding = 0;
	  }
	  else {
	    char *nam = new char[strlen(p) + 1];
	    strcpy(nam, p);
	    metric.special_device_coding = nam;
	  }
	  if (strcmp(nm, "---") == 0) {
	    last_glyph = number_to_glyph(metric.code);
	    add_entry(last_glyph, metric);
	  }
	  else {
	    last_glyph = name_to_glyph(nm);
	    add_entry(last_glyph, metric);
	    copy_entry(number_to_glyph(metric.code), last_glyph);
	  }
	}
      }
      if (0 == last_glyph) {
	t.error("no glyphs defined in font description");
	return false;
      }
    }
    else {
      t.error("unrecognized font description directive '%1' (missing"
	      " 'kernpairs' or 'charset'?)", directive);
      return false;
    }
  }
  compact();
  t.lineno = 0;
  if (!saw_name_directive) {
    t.error("font description 'name' directive missing");
    return false;
  }
  if (!is_unicode && !saw_charset_directive) {
    t.error("font description 'charset' subsection missing");
    return false;
  }
  if (space_width == 0) {
    t.error("font description 'spacewidth' directive missing");
    // _Don't_ return false; compute a typical one for Western glyphs.
    if (zoom)
      space_width = scale_round(unitwidth, res, 72 * 3 * sizescale,
				zoom);
    else
      space_width = scale_round(unitwidth, res, 72 * 3 * sizescale);
  }
  return true;
}

static struct {
  const char *numeric_directive;
  int *ptr;
} table[] = {
  { "res", &font::res },
  { "hor", &font::hor },
  { "vert", &font::vert },
  { "unitwidth", &font::unitwidth },
  { "paperwidth", &font::paperwidth },
  { "paperlength", &font::paperlength },
  { "spare1", &font::biggestfont },
  { "biggestfont", &font::biggestfont },
  { "spare2", &font::spare2 },
  { "sizescale", &font::sizescale },
  };

bool font::load_desc()
{
  int nfonts = 0;
  FILE *fp;
  char *path;
  if ((fp = open_file("DESC", &path)) == 0)
    return false;
  text_file t(fp, path);
  while (t.next_line()) {
    char *p = strtok(t.buf, WS);
    assert(p != 0);
    bool numeric_directive_found = false;
    unsigned int idx;
    for (idx = 0; !numeric_directive_found
		  && idx < sizeof(table) / sizeof(table[0]); idx++)
      if (strcmp(table[idx].numeric_directive, p) == 0)
	numeric_directive_found = true;
    if (numeric_directive_found) {
      char *q = strtok(0, WS);
      if (0 == q) {
	t.error("missing value for directive '%1'", p);
	return false;
      }
      int val;
      if (sscanf(q, "%d", &val) != 1) {
	t.error("'%1' directive given invalid number '%2'", p, q);
	return false;
      }
      if ((strcmp(p, "res") == 0
	   || strcmp(p, "hor") == 0
	   || strcmp(p, "vert") == 0
	   || strcmp(p, "unitwidth") == 0
	   || strcmp(p, "paperwidth") == 0
	   || strcmp(p, "paperlength") == 0
	   ||  strcmp(p, "sizescale") == 0)
	  && val < 1) {
	t.error("expected argument to '%1' directive to be a"
		" positive number, got '%2'", p, val);
	return false;
      }
      *(table[idx-1].ptr) = val;
    }
    else if (strcmp("family", p) == 0) {
      p = strtok(0, WS);
      if (0 == p) {
	t.error("'family' directive requires an argument");
	return false;
      }
      char *tem = new char[strlen(p)+1];
      strcpy(tem, p);
      family = tem;
    }
    else if (strcmp("fonts", p) == 0) {
      p = strtok(0, WS);
      if (0 == p) {
	t.error("'fonts' directive requires arguments");
	return false;
      }
      if (sscanf(p, "%d", &nfonts) != 1 || nfonts <= 0) {
	t.error("expected first argument to 'fonts' directive to be a"
		" non-negative number, got '%1'", p);
	return false;
      }
      font_name_table = (const char **)new char *[nfonts+1];
      for (int i = 0; i < nfonts; i++) {
	p = strtok(0, WS);
	while (0 == p) {
	  if (!t.next_line()) {
	    t.error("unexpected end of file while reading font list");
	    return false;
	  }
	  p = strtok(t.buf, WS);
	}
	char *temp = new char[strlen(p)+1];
	strcpy(temp, p);
	font_name_table[i] = temp;
      }
      p = strtok(0, WS);
      if (p != 0) {
	t.error("font count does not match declared number of fonts"
		" ('%1')", nfonts);
	return false;
      }
      font_name_table[nfonts] = 0;
    }
    else if (strcmp("papersize", p) == 0) {
      if (0 == res) {
	t.error("'res' directive must precede 'papersize' in device"
		" description file");
	return false;
      }
      p = strtok(0, WS);
      if (0 == p) {
	t.error("'papersize' directive requires an argument");
	return false;
      }
      bool found_paper = false;
      char *savedp = strdup(p);
      if (0 == savedp)
	t.fatal("memory allocation failure while processing 'papersize'"
		" directive");
      while (p) {
	double unscaled_paperwidth, unscaled_paperlength;
	if (scan_papersize(p, &papersize, &unscaled_paperlength,
			   &unscaled_paperwidth)) {
	  paperwidth = int(unscaled_paperwidth * res + 0.5);
	  paperlength = int(unscaled_paperlength * res + 0.5);
	  found_paper = true;
	  break;
	}
	p = strtok(0, WS);
      }
      assert(savedp != 0);
      if (!found_paper) {
	t.error("unable to determine a paper format from '%1'", savedp);
	free(savedp);
	return false;
      }
      free(savedp);
    }
    else if (strcmp("unscaled_charwidths", p) == 0)
      use_unscaled_charwidths = true;
    else if (strcmp("pass_filenames", p) == 0)
      pass_filenames = true;
    else if (strcmp("sizes", p) == 0) {
      int n = 16;
      sizes = new int[n];
      int i = 0;
      for (;;) {
	p = strtok(0, WS);
	while (0 == p) {
	  if (!t.next_line()) {
	    t.error("list of sizes must be terminated by '0'");
	    return false;
	  }
	  p = strtok(t.buf, WS);
	}
	int lower, upper;
	switch (sscanf(p, "%d-%d", &lower, &upper)) {
	case 1:
	  upper = lower;
	  // fall through
	case 2:
	  if (lower <= upper && lower >= 0)
	    break;
	  // fall through
	default:
	  t.error("invalid size range '%1'", p);
	  return false;
	}
	if (i + 2 > n) {
	  int *old_sizes = sizes;
	  sizes = new int[n*2];
	  memcpy(sizes, old_sizes, n*sizeof(int));
	  n *= 2;
	  delete[] old_sizes;
	}
	sizes[i++] = lower;
	if (lower == 0)
	  break;
	sizes[i++] = upper;
      }
      if (i == 1) {
	t.error("must have some sizes");
	return false;
      }
    }
    else if (strcmp("styles", p) == 0) {
      int style_table_size = 5;
      style_table = (const char **)new char *[style_table_size];
      int j;
      for (j = 0; j < style_table_size; j++)
	style_table[j] = 0;
      int i = 0;
      for (;;) {
	p = strtok(0, WS);
	if (0 == p)
	  break;
	// leave room for terminating 0
	if (i + 1 >= style_table_size) {
	  const char **old_style_table = style_table;
	  style_table_size *= 2;
	  style_table = (const char **)new char*[style_table_size];
	  for (j = 0; j < i; j++)
	    style_table[j] = old_style_table[j];
	  for (; j < style_table_size; j++)
	    style_table[j] = 0;
	  delete[] old_style_table;
	}
	char *tem = new char[strlen(p) + 1];
	strcpy(tem, p);
	style_table[i++] = tem;
      }
    }
    else if (strcmp("tcommand", p) == 0)
      has_tcommand = true;
    else if (strcmp("use_charnames_in_special", p) == 0)
      use_charnames_in_special = true;
    else if (strcmp("unicode", p) == 0)
      is_unicode = true;
    else if (strcmp("image_generator", p) == 0) {
      p = strtok(0, WS);
      if (0 == p) {
	t.error("'image_generator' directive requires an argument");
	return false;
      }
      image_generator = strsave(p);
    }
    else if (strcmp("charset", p) == 0)
      break;
    else if (unknown_desc_command_handler) {
      char *directive = p;
      p = strtok(0, "\n");
      (*unknown_desc_command_handler)(directive, trim_arg(p), t.path,
				      t.lineno);
    }
  }
  t.lineno = 0;
  if (res == 0) {
    t.error("device description file missing 'res' directive");
    return false;
  }
  if (unitwidth == 0) {
    t.error("device description file missing 'unitwidth' directive");
    return false;
  }
  if (font_name_table == 0) {
    t.error("device description file missing 'fonts' directive");
    return false;
  }
  if (sizes == 0) {
    t.error("device description file missing 'sizes' directive");
    return false;
  }
  return true;
}

void font::handle_unknown_font_command(const char *, const char *,
				       const char *, int)
{
}

FONT_COMMAND_HANDLER
font::set_unknown_desc_command_handler(FONT_COMMAND_HANDLER func)
{
  FONT_COMMAND_HANDLER prev = unknown_desc_command_handler;
  unknown_desc_command_handler = func;
  return prev;
}

// Local Variables:
// fill-column: 72
// mode: C++
// End:
// vim: set cindent noexpandtab shiftwidth=2 textwidth=72:
