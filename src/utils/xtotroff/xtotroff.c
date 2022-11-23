/* Copyright (C) 1992-2022 Free Software Foundation, Inc.
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

/*
 * xtotroff
 *
 * convert X font metrics into troff font metrics
 */

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#define __GETOPT_PREFIX groff_

#include <X11/Xlib.h>
#include <stdbool.h>
#include <stdio.h>
#include <ctype.h>
#include <errno.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <limits.h>

#include <getopt.h>

#include "XFontName.h"
#include "DviChar.h"

#define charWidth(fi,c) \
	  ((fi)->per_char[(c) - (fi)->min_char_or_byte2].width)
#define charHeight(fi,c) \
	  ((fi)->per_char[(c) - (fi)->min_char_or_byte2].ascent)
#define charDepth(fi,c) \
	  ((fi)->per_char[(c) - (fi)->min_char_or_byte2].descent)
#define charLBearing(fi,c) \
	  ((fi)->per_char[(c) - (fi)->min_char_or_byte2].lbearing)
#define charRBearing(fi,c) \
	  ((fi)->per_char[(c) - (fi)->min_char_or_byte2].rbearing)

extern const char *Version_string;
static char *program_name;

Display *dpy;
unsigned resolution = 75;
unsigned point_size = 10;
char *destdir = NULL;

static bool charExists(XFontStruct * fi, int c)
{
  XCharStruct *p;

  /* 'c' is always >= 0 */
  if ((unsigned int) c < fi->min_char_or_byte2
      || (unsigned int) c > fi->max_char_or_byte2)
    return false;
  p = fi->per_char + (c - fi->min_char_or_byte2);
  return p->lbearing != 0 || p->rbearing != 0 || p->width != 0
	 || p->ascent != 0 || p->descent != 0 || p->attributes != 0;
}

/* Canonicalize the font name by replacing scalable parts by *s. */

static bool CanonicalizeFontName(char *font_name, char *canon_font_name)
{
  unsigned int attributes;
  XFontName parsed;

  if (!XParseFontName(font_name, &parsed, &attributes)) {
    fprintf(stderr, "%s: not a standard font name: \"%s\"\n",
	    program_name, font_name);
    return false;
  }

  attributes &= ~(FontNamePixelSize | FontNameAverageWidth
		  | FontNamePointSize
		  | FontNameResolutionX | FontNameResolutionY);
  XFormatFontName(&parsed, attributes, canon_font_name);
  return true;
}

static bool
FontNamesAmbiguous(const char *font_name, char **names, int count)
{
  char name1[2048], name2[2048];
  int i;

  if (1 == count)
    return false;

  for (i = 0; i < count; i++) {
    if (!CanonicalizeFontName(names[i], 0 == i ? name1 : name2)) {
      fprintf(stderr, "%s: invalid font name: \"%s\"\n", program_name,
	      names[i]);
      return true;
    }
    if (i > 0 && strcmp(name1, name2) != 0) {
      fprintf(stderr, "%s: ambiguous font name: \"%s\"", program_name,
	      font_name);
      fprintf(stderr, " matches \"%s\"", names[0]);
      fprintf(stderr, " and \"%s\"", names[i]);
      return true;
    }
  }
  return false;
}

static void xtotroff_exit(int status)
{
  free(destdir);
  exit(status);
}

static bool MapFont(char *font_name, const char *troff_name)
{
  XFontStruct *fi;
  int count;
  char **names;
  FILE *out;
  unsigned int c;
  unsigned int attributes;
  XFontName parsed;
  int j, k;
  DviCharNameMap *char_map;
  /* 'encoding' needs to hold a CharSetRegistry (256), a CharSetEncoding
     (256) [both from XFontName.h], a dash, and a null terminator. */
  char encoding[256 * 2 + 1 + 1];
  char *s;
  int wid;
  char name_string[2048];

  if (!XParseFontName(font_name, &parsed, &attributes)) {
    fprintf(stderr, "%s: not a standard font name: \"%s\"\n",
	    program_name, font_name);
    return false;
  }

  attributes &= ~(FontNamePixelSize | FontNameAverageWidth);
  attributes |= FontNameResolutionX;
  attributes |= FontNameResolutionY;
  attributes |= FontNamePointSize;
  parsed.ResolutionX = resolution;
  parsed.ResolutionY = resolution;
  parsed.PointSize = point_size * 10;
  XFormatFontName(&parsed, attributes, name_string);

  names = XListFonts(dpy, name_string, 100000, &count);
  if (count < 1) {
    fprintf(stderr, "%s: invalid font name: \"%s\"\n", program_name,
	    font_name);
    return false;
  }

  if (FontNamesAmbiguous(font_name, names, count))
    return false;

  XParseFontName(names[0], &parsed, &attributes);
  size_t sz = sizeof encoding;
  snprintf(encoding, sz, "%s-%s", parsed.CharSetRegistry,
	  parsed.CharSetEncoding);
  for (s = encoding; *s; s++)
    if (isupper(*s))
      *s = tolower(*s);
  char_map = DviFindMap(encoding);
  if (!char_map) {
    fprintf(stderr, "%s: not a standard encoding: \"%s\"\n",
	    program_name, encoding);
    return false;
  }

  fi = XLoadQueryFont(dpy, names[0]);
  if (!fi) {
    fprintf(stderr, "%s: font does not exist: \"%s\"\n", program_name,
	    names[0]);
    return false;
  }

  printf("%s -> %s\n", names[0], troff_name);
  char *file_name = (char *)troff_name;
  size_t dirlen = strlen(destdir);

  if (dirlen > 0) {
    size_t baselen = strlen(troff_name);
    file_name = malloc(dirlen + baselen + 2 /* '/' and '\0' */);
    if (NULL == file_name) {
      fprintf(stderr, "%s: fatal error: unable to allocate memory\n",
	      program_name);
      xtotroff_exit(EXIT_FAILURE);
    }
    (void) strcpy(file_name, destdir);
    file_name[dirlen] = '/';
    (void) strcpy((file_name + dirlen + 1), troff_name);
  }

  {				/* Avoid race while opening file */
    int fd;
    (void) unlink(file_name);
    fd = open(file_name, O_WRONLY | O_CREAT | O_EXCL, 0600);
    out = fdopen(fd, "w");
  }

  if (NULL == out) {
    fprintf(stderr, "%s: unable to create '%s': %s\n", program_name,
	    file_name, strerror(errno));
    free(file_name);
    return false;
  }
  fprintf(out, "name %s\n", troff_name);
  if (!strcmp(char_map->encoding, "adobe-fontspecific"))
    fprintf(out, "special\n");
  if (charExists(fi, ' ')) {
    int w = charWidth(fi, ' ');
    if (w > 0)
      fprintf(out, "spacewidth %d\n", w);
  }
  fprintf(out, "charset\n");
  for (c = fi->min_char_or_byte2; c <= fi->max_char_or_byte2; c++) {
    const char *name = DviCharName(char_map, c, 0);
    if (charExists(fi, c)) {
      int param[5];

      wid = charWidth(fi, c);

      fprintf(out, "%s\t%d", name ? name : "---", wid);
      param[0] = charHeight(fi, c);
      param[1] = charDepth(fi, c);
      param[2] = 0;		/* charRBearing (fi, c) - wid */
      param[3] = 0;		/* charLBearing (fi, c) */
      param[4] = 0;		/* XXX */
      for (j = 0; j < 5; j++)
	if (param[j] < 0)
	  param[j] = 0;
      for (j = 4; j >= 0; j--)
	if (param[j] != 0)
	  break;
      for (k = 0; k <= j; k++)
	fprintf(out, ",%d", param[k]);
      fprintf(out, "\t0\t0%o\n", c);

      if (name) {
	for (k = 1; DviCharName(char_map, c, k); k++) {
	  fprintf(out, "%s\t\"\n", DviCharName(char_map, c, k));
	}
      }
    }
  }
  XUnloadFont(dpy, fi->fid);
  fclose(out);
  free(file_name);
  return true;
}

static void usage(FILE *stream)
{
  fprintf(stream,
	  "usage: %s [-d destination-directory] [-r resolution]"
	  " [-s type-size] font-map\n"
	  "usage: %s {-v | --version}\n"
	  "usage: %s --help\n",
	  program_name, program_name, program_name);
}

int main(int argc, char **argv)
{
  char troff_name[1024];
  char font_name[1024];
  char line[1024];
  char *a, *b, c;
  FILE *map;
  int opt;
  static const struct option long_options[] = {
    { "help", no_argument, 0, CHAR_MAX + 1 },
    { "version", no_argument, 0, 'v' },
    { NULL, 0, 0, 0 }
  };

  program_name = argv[0];

  while ((opt = getopt_long(argc, argv, "d:gr:s:v", long_options,
			    NULL)) != EOF) {
    switch (opt) {
    case 'd':
      destdir = strdup(optarg);
      break;
    case 'g':
      /* unused; just for compatibility */
      break;
    case 'r':
      sscanf(optarg, "%u", &resolution);
      break;
    case 's':
      sscanf(optarg, "%u", &point_size);
      break;
    case 'v':
      printf("GNU xtotroff (groff) version %s\n", Version_string);
      xtotroff_exit(EXIT_SUCCESS);
      break;
    case CHAR_MAX + 1: /* --help */
      usage(stdout);
      xtotroff_exit(EXIT_SUCCESS);
      break;
    case '?':
      usage(stderr);
      xtotroff_exit(EXIT_FAILURE);
      break;
    }
  }
  if (argc - optind != 1) {
    usage(stderr);
    xtotroff_exit(EXIT_FAILURE);
  }

  dpy = XOpenDisplay(0);
  if (!dpy) {
    fprintf(stderr, "%s: fatal error: can't connect to the X server;"
	    " make sure the DISPLAY environment variable is set"
	    " correctly\n", program_name);
    xtotroff_exit(EXIT_FAILURE);
  }

  map = fopen(argv[optind], "r");
  if (NULL == map) {
    fprintf(stderr, "%s: fatal error: unable to open map file '%s':"
	    " %s\n", program_name, argv[optind], strerror(errno));
    xtotroff_exit(EXIT_FAILURE);
  }

  while (fgets(line, sizeof(line), map)) {
    for (a = line, b = troff_name; *a; a++, b++) {
      c = (*b = *a);
      if (' ' == c || '\t' == c)
	break;
    }
    *b = '\0';
    while (*a && (' ' == *a || '\t' == *a))
      ++a;
    for (b = font_name; *a; a++, b++)
      if ((*b = *a) == '\n')
	break;
    *b = '\0';
    if (!MapFont(font_name, troff_name))
      xtotroff_exit(EXIT_FAILURE);
  }
  xtotroff_exit(EXIT_SUCCESS);
}

// Local Variables:
// fill-column: 72
// mode: C
// End:
// vim: set cindent noexpandtab shiftwidth=2 textwidth=72:
