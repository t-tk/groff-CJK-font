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


// There is no distinction between a name with no value and a name with
// a 0 (nullptr) value.  Null names are not permitted; they are ignored.

struct association {
  symbol s;
  void *v;
  association() : v(0 /* nullptr */) {}
};

class dictionary;

class dictionary_iterator {
  dictionary *dict;
  int i;
public:
  dictionary_iterator(dictionary &);
  bool get(symbol *, void **);
};

class dictionary {
  int size;
  int used;
  double threshold;
  double factor;
  association *table;
  void rehash(int);
public:
  dictionary(int);
  void *lookup(symbol s, void *v = 0 /* nullptr */);
  void *lookup(const char *);
  void *remove(symbol);
  friend class dictionary_iterator;
};

class object {
  int refcount;
 public:
  object();
  virtual ~object();
  void add_reference();
  void remove_reference();
};

class object_dictionary;

class object_dictionary_iterator {
  dictionary_iterator di;
public:
  object_dictionary_iterator(object_dictionary &);
  bool get(symbol *, object **);
};

class object_dictionary {
  dictionary d;
public:
  object_dictionary(int);
  object *lookup(symbol);
  void define(symbol, object *);
  void rename(symbol, symbol);
  void remove(symbol);
  bool alias(symbol, symbol);
  friend class object_dictionary_iterator;
};


inline bool object_dictionary_iterator::get(symbol *sp, object **op)
{
  return di.get(sp, (void **)op);
}

// Local Variables:
// fill-column: 72
// mode: C++
// End:
// vim: set cindent noexpandtab shiftwidth=2 textwidth=72:
