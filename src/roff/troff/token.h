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


class charinfo;
struct node;
class vunits;

class token {
  symbol nm;
  node *nd;
  unsigned char c;
  int val;
  units dim;
  enum token_type {
    TOKEN_BACKSPACE,
    TOKEN_BEGIN_TRAP,
    TOKEN_CHAR,			// a normal printing character
    TOKEN_DUMMY,		// \&
    TOKEN_EMPTY,		// this is the initial value
    TOKEN_END_TRAP,
    TOKEN_ESCAPE,		// \e
    TOKEN_HYPHEN_INDICATOR,
    TOKEN_INTERRUPT,		// \c
    TOKEN_ITALIC_CORRECTION,	// \/
    TOKEN_LEADER,		// ^A
    TOKEN_LEFT_BRACE,
    TOKEN_MARK_INPUT,		// \k -- 'nm' is the name of the register
    TOKEN_NEWLINE,		// newline
    TOKEN_NODE,
    TOKEN_NUMBERED_CHAR,
    TOKEN_PAGE_EJECTOR,
    TOKEN_REQUEST,
    TOKEN_RIGHT_BRACE,
    TOKEN_SPACE,		// ' ' -- ordinary space
    TOKEN_SPECIAL,		// a special character -- \' \` \- \(xx \[xxx]
    TOKEN_SPREAD,		// \p -- break and spread output line
    TOKEN_STRETCHABLE_SPACE,	// \~
    TOKEN_UNSTRETCHABLE_SPACE,	// '\ '
    TOKEN_HORIZONTAL_SPACE,	// \|, \^, \0, \h
    TOKEN_TAB,			// tab
    TOKEN_TRANSPARENT,		// \!
    TOKEN_TRANSPARENT_DUMMY,	// \)
    TOKEN_ZERO_WIDTH_BREAK,	// \:
    TOKEN_EOF			// end of file
  } type;
public:
  token();
  ~token();
  token(const token &);
  void operator=(const token &);
  void next();
  void process();
  void skip();
  int nspaces();		// 1 if space, 0 otherwise
  bool is_eof();
  bool is_space();
  bool is_stretchable_space();
  bool is_unstretchable_space();
  bool is_horizontal_space();
  bool is_white_space();
  bool is_special();
  bool is_newline();
  bool is_tab();
  bool is_leader();
  bool is_backspace();
  bool is_usable_as_delimiter(bool = false);
  bool is_dummy();
  bool is_transparent_dummy();
  bool is_transparent();
  bool is_left_brace();
  bool is_right_brace();
  bool is_page_ejector();
  bool is_hyphen_indicator();
  bool is_zero_width_break();
  int operator==(const token &); // need this for delimiters, and for conditions
  int operator!=(const token &); // ditto
  unsigned char ch();
  charinfo *get_char(bool = false);
  int add_to_zero_width_node_list(node **);
  void make_space();
  void make_newline();
  const char *description();

  friend void process_input_stack();
  friend node *do_overstrike();
};

extern token tok;		// the current token

extern symbol get_name(bool = false);
extern symbol get_long_name(bool = false);
extern charinfo *get_optional_char();
extern char *read_string();
extern void check_missing_character();
extern void skip_line();
extern void handle_initial_title();

enum char_mode {
  CHAR_NORMAL,
  CHAR_FALLBACK,
  CHAR_FONT_SPECIAL,
  CHAR_SPECIAL
};

extern void do_define_character(char_mode, const char * = 0);

class hunits;
extern void read_title_parts(node **part, hunits *part_width);

extern bool get_number_rigidly(units *result, unsigned char si);

extern bool get_number(units *result, unsigned char si);
extern bool get_integer(int *result);

extern bool get_number(units *result, unsigned char si, units prev_value);
extern bool get_integer(int *result, int prev_value);

extern void interpolate_register(symbol, int);

const char *asciify(int c);

inline bool token::is_newline()
{
  return type == TOKEN_NEWLINE;
}

inline bool token::is_space()
{
  return type == TOKEN_SPACE;
}

inline bool token::is_stretchable_space()
{
  return type == TOKEN_STRETCHABLE_SPACE;
}

inline bool token::is_unstretchable_space()
{
  return type == TOKEN_UNSTRETCHABLE_SPACE;
}

inline bool token::is_horizontal_space()
{
  return type == TOKEN_HORIZONTAL_SPACE;
}

inline bool token::is_special()
{
  return type == TOKEN_SPECIAL;
}

inline int token::nspaces()
{
  return (int)(type == TOKEN_SPACE);
}

inline bool token::is_white_space()
{
  return type == TOKEN_SPACE || type == TOKEN_TAB;
}

inline bool token::is_transparent()
{
  return type == TOKEN_TRANSPARENT;
}

inline bool token::is_page_ejector()
{
  return type == TOKEN_PAGE_EJECTOR;
}

inline unsigned char token::ch()
{
  return type == TOKEN_CHAR ? c : 0;
}

inline bool token::is_eof()
{
  return type == TOKEN_EOF;
}

inline bool token::is_dummy()
{
  return type == TOKEN_DUMMY;
}

inline bool token::is_transparent_dummy()
{
  return type == TOKEN_TRANSPARENT_DUMMY;
}

inline bool token::is_left_brace()
{
  return type == TOKEN_LEFT_BRACE;
}

inline bool token::is_right_brace()
{
  return type == TOKEN_RIGHT_BRACE;
}

inline bool token::is_tab()
{
  return type == TOKEN_TAB;
}

inline bool token::is_leader()
{
  return type == TOKEN_LEADER;
}

inline bool token::is_backspace()
{
  return type == TOKEN_BACKSPACE;
}

inline bool token::is_hyphen_indicator()
{
  return type == TOKEN_HYPHEN_INDICATOR;
}

inline bool token::is_zero_width_break()
{
  return type == TOKEN_ZERO_WIDTH_BREAK;
}

bool has_arg();

// Local Variables:
// fill-column: 72
// mode: C++
// End:
// vim: set cindent noexpandtab shiftwidth=2 textwidth=72:
