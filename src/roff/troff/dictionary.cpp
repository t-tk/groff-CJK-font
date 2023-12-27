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


#include "troff.h"
#include "dictionary.h"

// is 'p' a good size for a hash table

static bool is_good_size(unsigned int p)
{
  const unsigned int SMALL = 10;
  unsigned int i;
  for (i = 2; i <= (p / 2); i++)
    if (p % i == 0)
      return false;
  for (i = 0x100; i != 0; i <<= 8)
    if ((i % p) <= SMALL || (i % p) > (p - SMALL))
      return false;
  return true;
}

dictionary::dictionary(int n) : size(n), used(0), threshold(0.5), factor(1.5)
{
  table = new association[n];
}

// see Knuth, Sorting and Searching, p518, Algorithm L
// we can't use double-hashing because we want a remove function

void *dictionary::lookup(symbol s, void *v)
{
  int i;
  for (i = int(s.hash() % size);
       table[i].v != 0 /* nullptr */;
       i == 0 ? i = size - 1: --i)
    if (s == table[i].s) {
      if (v != 0 /* nullptr */) {
	void *temp = table[i].v;
	table[i].v = v;
	return temp;
      }
      else
	return table[i].v;
    }
  if (v == 0 /* nullptr */)
    return 0 /* nullptr */;
  ++used;
  table[i].v = v;
  table[i].s = s;
  if ((double)used/(double)size >= threshold || used + 1 >= size) {
    int old_size = size;
    size = int(size * factor);
    while (!is_good_size(size))
      ++size;
    association *old_table = table;
    table = new association[size];
    used = 0;
    for (i = 0; i < old_size; i++)
      if (old_table[i].v != 0 /* nullptr */)
	(void)lookup(old_table[i].s, old_table[i].v);
    delete[] old_table;
  }
  return 0 /* nullptr */;
}

void *dictionary::lookup(const char *p)
{
  symbol s(p, MUST_ALREADY_EXIST);
  if (s.is_null())
    return 0 /* nullptr */;
  else
    return lookup(s);
}

// see Knuth, Sorting and Searching, p527, Algorithm R

void *dictionary::remove(symbol s)
{
  // this relies on the fact that we are using linear probing
  int i;
  for (i = int(s.hash() % size);
       table[i].v != 0 /* nullptr */ && s != table[i].s;
       i == 0 ? i = size - 1: --i)
    ;
  void *p = table[i].v;
  while (table[i].v != 0 /* nullptr */) {
    table[i].v = 0 /* nullptr */;
    int j = i;
    int r;
    do {
      --i;
      if (i < 0)
	i = size - 1;
      if (table[i].v == 0 /* nullptr */)
	break;
      r = int(table[i].s.hash() % size);
    } while ((i <= r && r < j) || (r < j && j < i) || (j < i && i <= r));
    table[j] = table[i];
  }
  if (p != 0 /* nullptr */)
    --used;
  return p;
}

dictionary_iterator::dictionary_iterator(dictionary &d) : dict(&d), i(0)
{
}

bool dictionary_iterator::get(symbol *sp, void **vp)
{
  for (; i < dict->size; i++)
    if (dict->table[i].v) {
      *sp = dict->table[i].s;
      *vp = dict->table[i].v;
      i++;
      return true;
    }
  return false;
}

object_dictionary_iterator::object_dictionary_iterator(object_dictionary &od)
: di(od.d)
{
}

object::object() : refcount(0)
{
}

object::~object()
{
}

void object::add_reference()
{
  refcount += 1;
}

void object::remove_reference()
{
  if (--refcount == 0)
    delete this;
}

object_dictionary::object_dictionary(int n) : d(n)
{
}

object *object_dictionary::lookup(symbol nm)
{
  return (object *)d.lookup(nm);
}

void object_dictionary::define(symbol nm, object *obj)
{
  obj->add_reference();
  obj = (object *)d.lookup(nm, obj);
  if (obj)
    obj->remove_reference();
}

void object_dictionary::rename(symbol oldnm, symbol newnm)
{
  object *obj = (object *)d.remove(oldnm);
  if (obj) {
    obj = (object *)d.lookup(newnm, obj);
    if (obj)
      obj->remove_reference();
  }
}

void object_dictionary::remove(symbol nm)
{
  object *obj = (object *)d.remove(nm);
  if (obj)
    obj->remove_reference();
}

// Return non-zero if oldnm was defined.

bool object_dictionary::alias(symbol newnm, symbol oldnm)
{
  object *obj = (object *)d.lookup(oldnm);
  if (obj) {
    obj->add_reference();
    obj = (object *)d.lookup(newnm, obj);
    if (obj)
      obj->remove_reference();
    return true;
  }
  return false;
}

// Local Variables:
// fill-column: 72
// mode: C++
// End:
// vim: set cindent noexpandtab shiftwidth=2 textwidth=72:
