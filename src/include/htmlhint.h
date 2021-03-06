// -*- C++ -*-
/* Copyright (C) 2000-2020 Free Software Foundation, Inc.
     Written by Gaius Mulley <gaius@glam.ac.uk>

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

#ifndef HTMLINDICATE_H
#define HTMLINDICATE_H

/*
 *  html_begin_suppress - suppresses output for the html device
 *                        and resets the min/max registers for -Tps.
 *                        Only called for inline images (such as eqn).
 *
 */
extern void html_begin_suppress();

/*
 *  html_end_suppress - end the suppression of output.
 */
extern void html_end_suppress();

#endif
