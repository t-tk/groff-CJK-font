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
#include "hvunits.h"
#include "stringclass.h"
#include "mtsm.h"
#include "env.h"
#include "token.h"
#include "div.h"

const vunits V0; // zero in vertical units
const hunits H0; // zero in horizontal units

int hresolution = 1;
int vresolution = 1;
int units_per_inch;
int sizescale;

static bool is_valid_expression(units *v, int scaling_unit,
				bool is_parenthesized,
				bool is_mandatory = false);
static bool is_valid_expression_start();

bool get_vunits(vunits *res, unsigned char si)
{
  if (!is_valid_expression_start())
    return false;
  units x;
  if (is_valid_expression(&x, si, false /* is_parenthesized */)) {
    *res = vunits(x);
    return true;
  }
  else
    return false;
}

bool get_hunits(hunits *res, unsigned char si)
{
  if (!is_valid_expression_start())
    return false;
  units x;
  if (is_valid_expression(&x, si, false /* is_parenthesized */)) {
    *res = hunits(x);
    return true;
  }
  else
    return false;
}

// for \B

bool get_number_rigidly(units *res, unsigned char si)
{
  if (!is_valid_expression_start())
    return false;
  units x;
  if (is_valid_expression(&x, si, false /* is_parenthesized */,
			  true /* is_mandatory */)) {
    *res = x;
    return true;
  }
  else
    return false;
}

bool get_number(units *res, unsigned char si)
{
  if (!is_valid_expression_start())
    return false;
  units x;
  if (is_valid_expression(&x, si, false /* is_parenthesized */)) {
    *res = x;
    return true;
  }
  else
    return false;
}

bool get_integer(int *res)
{
  if (!is_valid_expression_start())
    return false;
  units x;
  if (is_valid_expression(&x, 0, false /* is_parenthesized */)) {
    *res = x;
    return true;
  }
  else
    return false;
}

enum incr_number_result { INVALID, ASSIGN, INCREMENT, DECREMENT };

static incr_number_result get_incr_number(units *res, unsigned char);

bool get_vunits(vunits *res, unsigned char si, vunits prev_value)
{
  units v;
  switch (get_incr_number(&v, si)) {
  case INVALID:
    return false;
  case ASSIGN:
    *res = v;
    break;
  case INCREMENT:
    *res = prev_value + v;
    break;
  case DECREMENT:
    *res = prev_value - v;
    break;
  default:
    assert(0 == "unhandled switch case returned by get_incr_number()");
  }
  return true;
}

bool get_hunits(hunits *res, unsigned char si, hunits prev_value)
{
  units v;
  switch (get_incr_number(&v, si)) {
  case INVALID:
    return false;
  case ASSIGN:
    *res = v;
    break;
  case INCREMENT:
    *res = prev_value + v;
    break;
  case DECREMENT:
    *res = prev_value - v;
    break;
  default:
    assert(0 == "unhandled switch case returned by get_incr_number()");
  }
  return true;
}

bool get_number(units *res, unsigned char si, units prev_value)
{
  units v;
  switch (get_incr_number(&v, si)) {
  case INVALID:
    return false;
  case ASSIGN:
    *res = v;
    break;
  case INCREMENT:
    *res = prev_value + v;
    break;
  case DECREMENT:
    *res = prev_value - v;
    break;
  default:
    assert(0 == "unhandled switch case returned by get_incr_number()");
  }
  return true;
}

bool get_integer(int *res, int prev_value)
{
  units v;
  switch (get_incr_number(&v, 0)) {
  case INVALID:
    return false;
  case ASSIGN:
    *res = v;
    break;
  case INCREMENT:
    *res = prev_value + int(v);
    break;
  case DECREMENT:
    *res = prev_value - int(v);
    break;
  default:
    assert(0 == "unhandled switch case returned by get_incr_number()");
  }
  return true;
}


static incr_number_result get_incr_number(units *res, unsigned char si)
{
  if (!is_valid_expression_start())
    return INVALID;
  incr_number_result result = ASSIGN;
  if (tok.ch() == '+') {
    tok.next();
    result = INCREMENT;
  }
  else if (tok.ch() == '-') {
    tok.next();
    result = DECREMENT;
  }
  if (is_valid_expression(res, si, false /* is_parenthesized */))
    return result;
  else
    return INVALID;
}

static bool is_valid_expression_start()
{
  while (tok.is_space())
    tok.next();
  if (tok.is_newline()) {
    warning(WARN_MISSING, "numeric expression missing");
    return false;
  }
  if (tok.is_tab()) {
    warning(WARN_TAB, "expected numeric expression, got %1",
	    tok.description());
    return false;
  }
  if (tok.is_right_brace()) {
    warning(WARN_RIGHT_BRACE, "expected numeric expression, got right"
	    "brace escape sequence");
    return false;
  }
  return true;
}

enum { OP_LEQ = 'L', OP_GEQ = 'G', OP_MAX = 'X', OP_MIN = 'N' };

#define SCALING_UNITS "icfPmnpuvMsz"

static bool is_valid_term(units *v, int scaling_unit,
			  bool is_parenthesized, bool is_mandatory);

static bool is_valid_expression(units *v, int scaling_unit,
				bool is_parenthesized,
				bool is_mandatory)
{
  int result = is_valid_term(v, scaling_unit, is_parenthesized,
			     is_mandatory);
  while (result) {
    if (is_parenthesized)
      tok.skip();
    int op = tok.ch();
    switch (op) {
    case '+':
    case '-':
    case '/':
    case '*':
    case '%':
    case ':':
    case '&':
      tok.next();
      break;
    case '>':
      tok.next();
      if (tok.ch() == '=') {
	tok.next();
	op = OP_GEQ;
      }
      else if (tok.ch() == '?') {
	tok.next();
	op = OP_MAX;
      }
      break;
    case '<':
      tok.next();
      if (tok.ch() == '=') {
	tok.next();
	op = OP_LEQ;
      }
      else if (tok.ch() == '?') {
	tok.next();
	op = OP_MIN;
      }
      break;
    case '=':
      tok.next();
      if (tok.ch() == '=')
	tok.next();
      break;
    default:
      return result;
    }
    units v2;
    if (!is_valid_term(&v2, scaling_unit, is_parenthesized,
		       is_mandatory))
      return false;
    bool had_overflow = false;
    switch (op) {
    case '<':
      *v = *v < v2;
      break;
    case '>':
      *v = *v > v2;
      break;
    case OP_LEQ:
      *v = *v <= v2;
      break;
    case OP_GEQ:
      *v = *v >= v2;
      break;
    case OP_MIN:
      if (*v > v2)
	*v = v2;
      break;
    case OP_MAX:
      if (*v < v2)
	*v = v2;
      break;
    case '=':
      *v = *v == v2;
      break;
    case '&':
      *v = *v > 0 && v2 > 0;
      break;
    case ':':
      *v = *v > 0 || v2 > 0;
      break;
    case '+':
      if (v2 < 0) {
	if (*v < INT_MIN - v2)
	  had_overflow = true;
      }
      else if (v2 > 0) {
	if (*v > INT_MAX - v2)
	  had_overflow = true;
      }
      if (had_overflow) {
	error("addition overflow");
	return false;
      }
      *v += v2;
      break;
    case '-':
      if (v2 < 0) {
	if (*v > INT_MAX + v2)
	  had_overflow = true;
      }
      else if (v2 > 0) {
	if (*v < INT_MIN + v2)
	  had_overflow = true;
      }
      if (had_overflow) {
	error("subtraction overflow");
	return false;
      }
      *v -= v2;
      break;
    case '*':
      if (v2 < 0) {
	if (*v > 0) {
	  if ((unsigned)*v > -(unsigned)INT_MIN / -(unsigned)v2)
	    had_overflow = true;
	}
	else if (-(unsigned)*v > INT_MAX / -(unsigned)v2)
	  had_overflow = true;
      }
      else if (v2 > 0) {
	if (*v > 0) {
	  if (*v > INT_MAX / v2)
	    had_overflow = true;
	}
	else if (-(unsigned)*v > -(unsigned)INT_MIN / v2)
	  had_overflow = true;
      }
      if (had_overflow) {
	error("multiplication overflow");
	return false;
      }
      *v *= v2;
      break;
    case '/':
      if (v2 == 0) {
	error("division by zero");
	return false;
      }
      *v /= v2;
      break;
    case '%':
      if (v2 == 0) {
	error("modulus by zero");
	return false;
      }
      *v %= v2;
      break;
    default:
      assert(0 == "unhandled switch case while processing operator");
    }
  }
  return result;
}

static bool is_valid_term(units *v, int scaling_unit,
			  bool is_parenthesized, bool is_mandatory)
{
  int negative = 0;
  for (;;)
    if (is_parenthesized && tok.is_space())
      tok.next();
    else if (tok.ch() == '+')
      tok.next();
    else if (tok.ch() == '-') {
      tok.next();
      negative = !negative;
    }
    else
      break;
  unsigned char c = tok.ch();
  switch (c) {
  case '|':
    // | is not restricted to the outermost level
    // tbl uses this
    tok.next();
    if (!is_valid_term(v, scaling_unit, is_parenthesized, is_mandatory))
      return false;
    int tem;
    tem = (scaling_unit == 'v'
	   ? curdiv->get_vertical_position().to_units()
	   : curenv->get_input_line_position().to_units());
    if (tem >= 0) {
      if (*v < INT_MIN + tem) {
	error("numeric overflow");
	return false;
      }
    }
    else {
      if (*v > INT_MAX + tem) {
	error("numeric overflow");
	return false;
      }
    }
    *v -= tem;
    if (negative) {
      if (*v == INT_MIN) {
	error("numeric overflow");
	return false;
      }
      *v = -*v;
    }
    return true;
  case '(':
    tok.next();
    c = tok.ch();
    if (c == ')') {
      if (is_mandatory)
	return false;
      warning(WARN_SYNTAX, "empty parentheses");
      tok.next();
      *v = 0;
      return true;
    }
    else if (c != 0 && strchr(SCALING_UNITS, c) != 0) {
      tok.next();
      if (tok.ch() == ';') {
	tok.next();
	scaling_unit = c;
      }
      else {
	error("expected ';' after scaling unit, got %1",
	      tok.description());
	return false;
      }
    }
    else if (c == ';') {
      scaling_unit = 0;
      tok.next();
    }
    if (!is_valid_expression(v, scaling_unit,
			     true /* is_parenthesized */, is_mandatory))
      return false;
    tok.skip();
    if (tok.ch() != ')') {
      if (is_mandatory)
	return false;
      warning(WARN_SYNTAX, "expected ')', got %1", tok.description());
    }
    else
      tok.next();
    if (negative) {
      if (*v == INT_MIN) {
	error("numeric overflow");
	return false;
      }
      *v = -*v;
    }
    return true;
  case '.':
    *v = 0;
    break;
  case '0':
  case '1':
  case '2':
  case '3':
  case '4':
  case '5':
  case '6':
  case '7':
  case '8':
  case '9':
    *v = 0;
    do {
      if (*v > INT_MAX/10) {
	error("numeric overflow");
	return false;
      }
      *v *= 10;
      if (*v > INT_MAX - (int(c) - '0')) {
	error("numeric overflow");
	return false;
      }
      *v += c - '0';
      tok.next();
      c = tok.ch();
    } while (csdigit(c));
    break;
  case '/':
  case '*':
  case '%':
  case ':':
  case '&':
  case '>':
  case '<':
  case '=':
    warning(WARN_SYNTAX, "empty left operand to '%1' operator", c);
    *v = 0;
    return is_mandatory ? false : true;
  default:
    warning(WARN_NUMBER, "expected numeric expression, got %1",
	    tok.description());
    return false;
  }
  int divisor = 1;
  if (tok.ch() == '.') {
    tok.next();
    for (;;) {
      c = tok.ch();
      if (!csdigit(c))
	break;
      // we may multiply the divisor by 254 later on
      if (divisor <= INT_MAX/2540 && *v <= (INT_MAX - 9)/10) {
	*v *= 10;
	*v += c - '0';
	divisor *= 10;
      }
      tok.next();
    }
  }
  int si = scaling_unit;
  int do_next = 0;
  if ((c = tok.ch()) != 0 && strchr(SCALING_UNITS, c) != 0) {
    switch (scaling_unit) {
    case 0:
      warning(WARN_SCALE, "scaling unit invalid in context");
      break;
    case 'z':
      if (c != 'u' && c != 'z') {
	warning(WARN_SCALE, "'%1' scaling unit invalid in context;"
		" convert to 'z' or 'u'", c);
	break;
      }
      si = c;
      break;
    case 'u':
      si = c;
      break;
    default:
      if (c == 'z') {
	warning(WARN_SCALE, "'z' scaling unit invalid in context");
	break;
      }
      si = c;
      break;
    }
    // Don't do tok.next() here because the next token might be \s,
    // which would affect the interpretation of m.
    do_next = 1;
  }
  switch (si) {
  case 'i':
    *v = scale(*v, units_per_inch, divisor);
    break;
  case 'c':
    *v = scale(*v, units_per_inch*100, divisor*254);
    break;
  case 0:
  case 'u':
    if (divisor != 1)
      *v /= divisor;
    break;
  case 'f':
    *v = scale(*v, 65536, divisor);
    break;
  case 'p':
    *v = scale(*v, units_per_inch, divisor*72);
    break;
  case 'P':
    *v = scale(*v, units_per_inch, divisor*6);
    break;
  case 'm':
    {
      // Convert to hunits so that with -Tascii 'm' behaves as in nroff.
      hunits em = curenv->get_size();
      *v = scale(*v, em.is_zero() ? hresolution : em.to_units(),
		 divisor);
    }
    break;
  case 'M':
    {
      hunits em = curenv->get_size();
      *v = scale(*v, em.is_zero() ? hresolution : em.to_units(),
		 (divisor * 100));
    }
    break;
  case 'n':
    {
      // Convert to hunits so that with -Tascii 'n' behaves as in nroff.
      hunits en = curenv->get_size() / 2;
      *v = scale(*v, en.is_zero() ? hresolution : en.to_units(),
		 divisor);
    }
    break;
  case 'v':
    *v = scale(*v, curenv->get_vertical_spacing().to_units(), divisor);
    break;
  case 's':
    while (divisor > INT_MAX/(sizescale*72)) {
      divisor /= 10;
      *v /= 10;
    }
    *v = scale(*v, units_per_inch, divisor*sizescale*72);
    break;
  case 'z':
    *v = scale(*v, sizescale, divisor);
    break;
  default:
    assert(0 == "unhandled switch case when processing scaling unit");
  }
  if (do_next)
    tok.next();
  if (negative) {
    if (*v == INT_MIN) {
      error("numeric overflow");
      return false;
    }
    *v = -*v;
  }
  return true;
}

units scale(units n, units x, units y)
{
  assert(x >= 0 && y > 0);
  if (x == 0)
    return 0;
  if (n >= 0) {
    if (n <= INT_MAX/x)
      return (n*x)/y;
  }
  else {
    if (-(unsigned)n <= -(unsigned)INT_MIN/x)
      return (n*x)/y;
  }
  double res = n*double(x)/double(y);
  if (res > INT_MAX) {
    error("numeric overflow");
    return INT_MAX;
  }
  else if (res < INT_MIN) {
    error("numeric overflow");
    return INT_MIN;
  }
  return int(res);
}

vunits::vunits(units x)
{
  // Don't depend on rounding direction when dividing negative integers.
  if (vresolution == 1)
    n = x;
  else
    n = (x < 0
	 ? -((-x + (vresolution / 2) - 1) / vresolution)
	 : (x + (vresolution / 2) - 1) / vresolution);
}

hunits::hunits(units x)
{
  // Don't depend on rounding direction when dividing negative integers.
  if (hresolution == 1)
    n = x;
  else
    n = (x < 0
	 ? -((-x + (hresolution / 2) - 1) / hresolution)
	 : (x + (hresolution / 2) - 1) / hresolution);
}

// Local Variables:
// fill-column: 72
// mode: C++
// End:
// vim: set cindent noexpandtab shiftwidth=2 textwidth=72:
