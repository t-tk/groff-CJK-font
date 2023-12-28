/* Copyright (C) 1989-2023 Free Software Foundation, Inc.
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

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <assert.h>

#include "eqn.h"
#include "pbox.h"

const char *current_roman_font;

char *gifont = 0 /* nullptr */;
char *grfont = 0 /* nullptr */;
char *gbfont = 0 /* nullptr */;
int gsize = 0;

int script_size_reduction = -1;	// negative means reduce by a percentage

int positive_space = -1;
int negative_space = -1;

int minimum_size = 5;

static int fat_offset = 4;
static int over_hang = 0;
static int accent_width = 31;
static int delimiter_factor = 900;
static int delimiter_shortfall = 50;

static int null_delimiter_space = 12;
static int script_space = 5;
static int thin_space = 17;
static int half_space = 17;
static int medium_space = 22;
static int thick_space = 28;
static int full_space = 28;

static int num1 = 70;
static int num2 = 40;
// we don't use num3, because we don't have \atop
static int denom1 = 70;
static int denom2 = 36;
static int axis_height = 26;	// in 100ths of an em
static int sup1 = 42;
static int sup2 = 37;
static int sup3 = 28;
static int default_rule_thickness = 4;
static int sub1 = 20;
static int sub2 = 23;
static int sup_drop = 38;
static int sub_drop = 5;
static int x_height = 45;
static int big_op_spacing1 = 11;
static int big_op_spacing2 = 17;
static int big_op_spacing3 = 20;
static int big_op_spacing4 = 60;
static int big_op_spacing5 = 10;

// These are for piles and matrices.

static int baseline_sep = 140;		// = num1 + denom1
static int shift_down = 26;		// = axis_height
static int column_sep = 100;		// = em space
static int matrix_side_sep = 17;	// = thin space

static int body_height = 85;
static int body_depth = 35;

static int nroff = 0;		// should we grok ndefine or tdefine?

struct param {
  const char *name;
  int *ptr;
} default_param_table[] = {
  { "fat_offset", &fat_offset },
  { "over_hang", &over_hang },
  { "accent_width", &accent_width },
  { "delimiter_factor", &delimiter_factor },
  { "delimiter_shortfall", &delimiter_shortfall },
  { "null_delimiter_space", &null_delimiter_space },
  { "script_space", &script_space },
  { "thin_space", &thin_space },
  { "medium_space", &medium_space },
  { "thick_space", &thick_space },
  { "half_space", &half_space },
  { "full_space", &full_space },
  { "num1", &num1 },
  { "num2", &num2 },
  { "denom1", &denom1 },
  { "denom2", &denom2 },
  { "axis_height", &axis_height },
  { "sup1", &sup1 },
  { "sup2", &sup2 },
  { "sup3", &sup3 },
  { "default_rule_thickness", &default_rule_thickness },
  { "sub1", &sub1 },
  { "sub2", &sub2 },
  { "sup_drop", &sup_drop },
  { "sub_drop", &sub_drop },
  { "x_height", &x_height },
  { "big_op_spacing1", &big_op_spacing1 },
  { "big_op_spacing2", &big_op_spacing2 },
  { "big_op_spacing3", &big_op_spacing3 },
  { "big_op_spacing4", &big_op_spacing4 },
  { "big_op_spacing5", &big_op_spacing5 },
  { "minimum_size", &minimum_size },
  { "baseline_sep", &baseline_sep },
  { "shift_down", &shift_down },
  { "column_sep", &column_sep },
  { "matrix_side_sep", &matrix_side_sep },
  { "draw_lines", &draw_flag },
  { "body_height", &body_height },
  { "body_depth", &body_depth },
  { "nroff", &nroff },
};

struct param *param_table = 0 /* nullptr */;

// Use the size of default_param_table to iterate through both it and
// param_table, because the former is known constant to the compiler.

void set_param(const char *name, int value)
{
  for (size_t i = 0; i <= array_length(default_param_table); i++)
    if (strcmp(param_table[i].name, name) == 0) {
      *(param_table[i].ptr) = value;
      return;
    }
  error("'set' primitive does not recognize parameter name '%1'", name);
}

void reset_param(const char *name)
{
  for (size_t i = 0; i < array_length(default_param_table); i++)
    if (strcmp(param_table[i].name, name) == 0) {
      *param_table[i].ptr = *(default_param_table[i].ptr);
      return;
    }
  error("'reset' primitive does not recognize parameter name '%1'",
	name);
}

int get_param(const char *name)
{
  for (size_t i = 0; i < array_length(default_param_table); i++)
    if (strcmp(param_table[i].name, name) == 0)
      return *(param_table[i].ptr);
  assert(0 == "attempted to access parameter not in table");
  fatal("internal error: unrecognized parameter name '%1'", name);
}

void init_param_table()
{
  param_table = new param[array_length(default_param_table)];
  for (size_t i = 0; i < array_length(default_param_table); i++) {
    param_table[i].name = default_param_table[i].name;
    param_table[i].ptr = new int(*(default_param_table[i].ptr));
  }
}

void free_param_table()
{
  if (param_table != 0 /* nullptr */) {
    for (size_t i = 0; i < array_length(default_param_table); i++)
      delete param_table[i].ptr;
    delete[] param_table;
    param_table = 0 /* nullptr */;
  }
}

int script_style(int style)
{
  return style > SCRIPT_STYLE ? style - 2 : style;
}

int cramped_style(int style)
{
  return (style & 1) ? style - 1 : style;
}

void set_space(int n)
{
  if (n < 0)
    negative_space = -n;
  else
    positive_space = n;
}

// Return 0 if the specified size is bad.
// The caller is responsible for giving the error message.

int set_gsize(const char *s)
{
  const char *p = (*s == '+' || *s == '-') ? s + 1 : s;
  char *end;
  long n = strtol(p, &end, 10);
  if (n <= 0 || *end != '\0' || n > INT_MAX)
    return 0;
  if (p > s) {
    if (!gsize)
      gsize = 10;
    if (*s == '+') {
      if (gsize > INT_MAX - n)
	return 0;
      gsize += int(n);
    }
    else {
      if (gsize - n <= 0)
	return 0;
      gsize -= int(n);
    }
  }
  else
    gsize = int(n);
  return 1;
}

void set_script_reduction(int n)
{
  script_size_reduction = n;
}

const char *get_gifont()
{
  return gifont ? gifont : "I";
}

const char *get_grfont()
{
  return grfont ? grfont : "R";
}

const char *get_gbfont()
{
  return gbfont ? gbfont : "B";
}

void set_gifont(const char *s)
{
  delete[] gifont;
  gifont = strsave(s);
}

void set_grfont(const char *s)
{
  delete[] grfont;
  grfont = strsave(s);
}

void set_gbfont(const char *s)
{
  delete[] gbfont;
  gbfont = strsave(s);
}

// this must be precisely 2 characters in length
#define COMPATIBLE_REG "0C"

void start_string()
{
  if (output_format == troff) {
    printf(".nr " COMPATIBLE_REG " \\n(.C\n");
    printf(".cp 0\n");
    printf(".ds " LINE_STRING "\n");
  }
}

void output_string()
{
  if (output_format == troff)
    printf("\\*(" LINE_STRING "\n");
  else if (output_format == mathml && !xhtml)
    putchar('\n');
}

void restore_compatibility()
{
  if (output_format == troff)
    printf(".cp \\n(" COMPATIBLE_REG "\n");
}

void do_text(const char *s)
{
  if (output_format == troff) {
    printf(".eo\n");
    printf(".as " LINE_STRING " \"%s\n", s);
    printf(".ec\n");
  }
  else if (output_format == mathml) {
    fputs(s, stdout);
    if (xhtml && strlen(s) > 0)
      printf("\n");
  }
}

void set_minimum_size(int n)
{
  minimum_size = n;
}

void set_script_size()
{
  if (minimum_size < 0)
    minimum_size = 0;
  if (script_size_reduction >= 0)
    printf(".ps \\n[.s]-%d>?%d\n", script_size_reduction, minimum_size);
  else
    printf(".ps (u;\\n[.ps]*7+5/10>?%dz)\n", minimum_size);
}

int box::next_uid = 0;

box::box() : spacing_type(ORDINARY_TYPE), uid(next_uid++)
{
}

box::~box()
{
}

void box::top_level()
{
  box *b = this;
  if (output_format == troff) {
    // debug_print();
    // putc('\n', stderr);
    printf(".nr " SAVED_FONT_REG " \\n[.f]\n");
    printf(".ft\n");
    printf(".nr " SAVED_PREV_FONT_REG " \\n[.f]\n");
    printf(".ft %s\n", get_gifont());
    printf(".nr " SAVED_SIZE_REG " \\n[.ps]\n");
    if (gsize > 0) {
      char buf[INT_DIGITS + 1];
      sprintf(buf, "%d", gsize);
      b = new size_box(strsave(buf), b);
    }
    current_roman_font = get_grfont();
    // This catches tabs used within \Z (which aren't allowed).
    b->diagnose_tab_stop_usage(0);
    int r = b->compute_metrics(DISPLAY_STYLE);
    printf(".ft \\n[" SAVED_PREV_FONT_REG "]\n");
    printf(".ft \\n[" SAVED_FONT_REG "]\n");
    printf(".nr " MARK_OR_LINEUP_FLAG_REG " %d\n", r);
    if (r == FOUND_MARK) {
      printf(".nr " SAVED_MARK_REG " \\n[" MARK_REG "]\n");
      printf(".nr " MARK_WIDTH_REG " 0\\n[" WIDTH_FORMAT "]\n", b->uid);
    }
    else if (r == FOUND_LINEUP)
      printf(".if r" SAVED_MARK_REG " .as1 " LINE_STRING " \\h'\\n["
	     SAVED_MARK_REG "]u-\\n[" MARK_REG "]u'\n");
    else
      assert(r == FOUND_NOTHING);
    // If we use \R directly, the space will prevent it working in a
    // macro argument; so we hide it in a string instead.
    printf(".ds " SAVE_FONT_STRING " "
	   "\\R'" SAVED_INLINE_FONT_REG " \\En[.f]'"
	   "\\fP"
	   "\\R'" SAVED_INLINE_PREV_FONT_REG " \\En[.f]'"
	   "\\R'" SAVED_INLINE_SIZE_REG " \\En[.ps]'"
	   "\\s0"
	   "\\R'" SAVED_INLINE_PREV_SIZE_REG " \\En[.ps]'"
	   "\n"
	   ".ds " RESTORE_FONT_STRING " "
	   "\\f[\\En[" SAVED_INLINE_PREV_FONT_REG "]]"
	   "\\f[\\En[" SAVED_INLINE_FONT_REG "]]"
	   "\\s'\\En[" SAVED_INLINE_PREV_SIZE_REG "]u'"
	   "\\s'\\En[" SAVED_INLINE_SIZE_REG "]u'"
	   "\n");
    printf(".as1 " LINE_STRING " \\&\\E*[" SAVE_FONT_STRING "]");
    printf("\\f[%s]", get_gifont());
    printf("\\s'\\En[" SAVED_SIZE_REG "]u'");
    current_roman_font = get_grfont();
    b->output();
    printf("\\E*[" RESTORE_FONT_STRING "]\n");
    if (r == FOUND_LINEUP)
      printf(".if r" SAVED_MARK_REG " .as1 " LINE_STRING " \\h'\\n["
	     MARK_WIDTH_REG "]u-\\n[" SAVED_MARK_REG "]u-(\\n["
	     WIDTH_FORMAT "]u-\\n[" MARK_REG "]u)'\n",
	     b->uid);
    b->extra_space();
    if (!inline_flag)
      printf(".ne \\n[" HEIGHT_FORMAT "]u-%dM>?0+(\\n["
	     DEPTH_FORMAT "]u-%dM>?0)\n",
	     b->uid, body_height, b->uid, body_depth);
  }
  else if (output_format == mathml) {
    if (xhtml)
      printf(".MATHML ");
    printf("<math>");
    b->output();
    printf("</math>");
  }
  delete b;
  next_uid = 0;
}

// gpic defines this register so as to make geqn not produce '\x's
#define EQN_NO_EXTRA_SPACE_REG "0x"

void box::extra_space()
{
  printf(".if !r" EQN_NO_EXTRA_SPACE_REG " "
	 ".nr " EQN_NO_EXTRA_SPACE_REG " 0\n");
  if (positive_space >= 0 || negative_space >= 0) {
    if (positive_space > 0)
      printf(".if !\\n[" EQN_NO_EXTRA_SPACE_REG "] "
	     ".as1 " LINE_STRING " \\x'-%dM'\n", positive_space);
    if (negative_space > 0)
      printf(".if !\\n[" EQN_NO_EXTRA_SPACE_REG "] "
	     ".as1 " LINE_STRING " \\x'%dM'\n", negative_space);
    positive_space = negative_space = -1;
  }
  else {
    printf(".if !\\n[" EQN_NO_EXTRA_SPACE_REG "] "
	   ".if \\n[" HEIGHT_FORMAT "]>%dM .as1 " LINE_STRING
	   " \\x'-(\\n[" HEIGHT_FORMAT
	   "]u-%dM)'\n",
	   uid, body_height, uid, body_height);
    printf(".if !\\n[" EQN_NO_EXTRA_SPACE_REG "] "
	   ".if \\n[" DEPTH_FORMAT "]>%dM .as1 " LINE_STRING
	   " \\x'\\n[" DEPTH_FORMAT
	   "]u-%dM'\n",
	   uid, body_depth, uid, body_depth);
  }
}

int box::compute_metrics(int)
{
  printf(".nr " WIDTH_FORMAT " 0\n", uid);
  printf(".nr " HEIGHT_FORMAT " 0\n", uid);
  printf(".nr " DEPTH_FORMAT " 0\n", uid);
  return FOUND_NOTHING;
}

void box::compute_subscript_kern()
{
  printf(".nr " SUB_KERN_FORMAT " 0\n", uid);
}

void box::compute_skew()
{
  printf(".nr " SKEW_FORMAT " 0\n", uid);
}

void box::output()
{
}

void box::diagnose_tab_stop_usage(int)
{
}

int box::is_char()
{
  return 0;
}

int box::left_is_italic()
{
  return 0;
}

int box::right_is_italic()
{
  return 0;
}

void box::hint(unsigned)
{
}

void box::handle_char_type(int, int)
{
}


box_list::box_list(box *pp)
{
  p = new box*[10];
  for (int i = 0; i < 10; i++)
    p[i] = 0;
  maxlen = 10;
  len = 1;
  p[0] = pp;
}

void box_list::append(box *pp)
{
  if (len + 1 > maxlen) {
    box **oldp = p;
    maxlen *= 2;
    p = new box*[maxlen];
    memcpy(p, oldp, sizeof(box*)*len);
    delete[] oldp;
  }
  p[len++] = pp;
}

box_list::~box_list()
{
  for (int i = 0; i < len; i++)
    delete p[i];
  delete[] p;
}

void box_list::list_diagnose_tab_stop_usage(int level)
{
  for (int i = 0; i < len; i++)
    p[i]->diagnose_tab_stop_usage(level);
}


pointer_box::pointer_box(box *pp) : p(pp)
{
  spacing_type = p->spacing_type;
}

pointer_box::~pointer_box()
{
  delete p;
}

int pointer_box::compute_metrics(int style)
{
  int r = p->compute_metrics(style);
  printf(".nr " WIDTH_FORMAT " 0\\n[" WIDTH_FORMAT "]\n", uid, p->uid);
  printf(".nr " HEIGHT_FORMAT " \\n[" HEIGHT_FORMAT "]\n", uid, p->uid);
  printf(".nr " DEPTH_FORMAT " \\n[" DEPTH_FORMAT "]\n", uid, p->uid);
  return r;
}

void pointer_box::compute_subscript_kern()
{
  p->compute_subscript_kern();
  printf(".nr " SUB_KERN_FORMAT " \\n[" SUB_KERN_FORMAT "]\n", uid,
	 p->uid);
}

void pointer_box::compute_skew()
{
  p->compute_skew();
  printf(".nr " SKEW_FORMAT " 0\\n[" SKEW_FORMAT "]\n",
	 uid, p->uid);
}

void pointer_box::diagnose_tab_stop_usage(int level)
{
  p->diagnose_tab_stop_usage(level);
}

int simple_box::compute_metrics(int)
{
  printf(".nr " WIDTH_FORMAT " 0\\w" DELIMITER_CHAR, uid);
  output();
  printf(DELIMITER_CHAR "\n");
  printf(".nr " HEIGHT_FORMAT " 0>?\\n[rst]\n", uid);
  printf(".nr " DEPTH_FORMAT " 0-\\n[rsb]>?0\n", uid);
  printf(".nr " SUB_KERN_FORMAT " 0-\\n[ssc]>?0\n", uid);
  printf(".nr " SKEW_FORMAT " 0\\n[skw]\n", uid);
  return FOUND_NOTHING;
}

void simple_box::compute_subscript_kern()
{
  // do nothing, we already computed it in do_metrics
}

void simple_box::compute_skew()
{
  // do nothing, we already computed it in do_metrics
}

int box::is_simple()
{
  return 0;
}

int simple_box::is_simple()
{
  return 1;
}

quoted_text_box::quoted_text_box(char *s) : text(s)
{
}

quoted_text_box::~quoted_text_box()
{
  free(text);
}

void quoted_text_box::output()
{
  if (text) {
    if (output_format == troff)
      fputs(text, stdout);
    else if (output_format == mathml) {
      fputs("<mtext>", stdout);
      fputs(text, stdout);
      fputs("</mtext>", stdout);
    }
  }
}

tab_box::tab_box() : disabled(false)
{
}

// We treat a tab_box as having width 0 for width computations.

void tab_box::output()
{
  if (!disabled)
    printf("\\t");
}

void tab_box::diagnose_tab_stop_usage(int level)
{
  if (level > 0) {
    error("tabs allowed only at outermost lexical level");
    disabled = true;
  }
}

half_space_box::half_space_box()
{
  spacing_type = SUPPRESS_TYPE;
}

void half_space_box::output()
{
  if (output_format == troff)
    printf("\\h'%dM'", half_space);
  else if (output_format == mathml)
    printf("<mtext>&ThinSpace;</mtext>");
  else
    assert("unimplemented output format");
}

full_space_box::full_space_box()
{
  spacing_type = SUPPRESS_TYPE;
}

void full_space_box::output()
{
  if (output_format == troff)
    printf("\\h'%dM'", full_space);
  else if (output_format == mathml)
    printf("<mtext>&ThickSpace;</mtext>");
  else
    assert("unimplemented output format");
}

thick_space_box::thick_space_box()
{
  spacing_type = SUPPRESS_TYPE;
}

void thick_space_box::output()
{
  if (output_format == troff)
    printf("\\h'%dM'", thick_space);
  else if (output_format == mathml)
    printf("<mtext>&ThickSpace;</mtext>");
  else
    assert("unimplemented output format");
}

thin_space_box::thin_space_box()
{
  spacing_type = SUPPRESS_TYPE;
}

void thin_space_box::output()
{
  if (output_format == troff)
    printf("\\h'%dM'", thin_space);
  else if (output_format == mathml)
    printf("<mtext>&ThinSpace;</mtext>");
  else
    assert("unimplemented output format");
}

void box_list::list_debug_print(const char *sep)
{
  p[0]->debug_print();
  for (int i = 1; i < len; i++) {
    fprintf(stderr, "%s", sep);
    p[i]->debug_print();
  }
}

void quoted_text_box::debug_print()
{
  fprintf(stderr, "\"%s\"", (text ? text : ""));
}

void half_space_box::debug_print()
{
  fprintf(stderr, "^");
}

void full_space_box::debug_print()
{
  fprintf(stderr, "~");
}

void thick_space_box::debug_print()
{
  fprintf(stderr, "~");
}

void thin_space_box::debug_print()
{
  fprintf(stderr, "^");
}

void tab_box::debug_print()
{
  fprintf(stderr, "<tab>");
}

// Local Variables:
// fill-column: 72
// mode: C++
// End:
// vim: set cindent noexpandtab shiftwidth=2 textwidth=72:
