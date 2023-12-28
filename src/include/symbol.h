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

#include <stdint.h> // uintptr_t

#define DONT_STORE 1
#define MUST_ALREADY_EXIST 2

class symbol {
  static const char **table;
  static int table_used;
  static int table_size;
  static char *block;
  static size_t block_size;
  const char *s;
public:
  symbol(const char *p, int how = 0);
  symbol();
  uintptr_t hash() const;
  int operator ==(symbol) const;
  int operator !=(symbol) const;
  const char *contents() const;
  int is_null() const;
  int is_empty() const;
};


extern const symbol NULL_SYMBOL;
extern const symbol EMPTY_SYMBOL;

inline symbol::symbol() : s(0)
{
}

inline int symbol::operator==(symbol p) const
{
  return s == p.s;
}

inline int symbol::operator!=(symbol p) const
{
  return s != p.s;
}

inline uintptr_t symbol::hash() const
{
  return reinterpret_cast<uintptr_t>(s);
}

inline const char *symbol::contents() const
{
  return s;
}

inline int symbol::is_null() const
{
  return s == 0;
}

inline int symbol::is_empty() const
{
  return s != 0 && *s == 0;
}

symbol concat(symbol, symbol);

extern symbol default_symbol;

// Local Variables:
// fill-column: 72
// mode: C++
// End:
// vim: set cindent noexpandtab shiftwidth=2 textwidth=72:
