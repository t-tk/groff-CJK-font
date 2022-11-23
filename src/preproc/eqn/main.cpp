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

#include "eqn.h"
#include "stringclass.h"
#include "device.h"
#include "searchpath.h"
#include "macropath.h"
#include "htmlhint.h"
#include "pbox.h"
#include "ctype.h"
#include "lf.h"

#define STARTUP_FILE "eqnrc"

extern int yyparse();
extern "C" const char *Version_string;

static char *delim_search    (char *, int);
static int   inline_equation (FILE *, string &, string &);

char start_delim = '\0';
char end_delim = '\0';
int non_empty_flag;
int inline_flag;
int draw_flag = 0;
int one_size_reduction_flag = 0;
int compatible_flag = 0;
int no_newline_in_delim_flag = 0;
int html = 0;
int xhtml = 0;
eqnmode_t output_format;

static const char *input_char_description(int c)
{
  switch (c) {
  case '\001':
    return "a leader character";
  case '\n':
    return "a newline character";
  case '\b':
    return "a backspace character";
  case '\t':
    return "a tab character";
  case ' ':
    return "a space character";
  case '\177':
    return "a delete character";
  }
  size_t bufsz = sizeof "character code " + INT_DIGITS + 1;
  // repeat expression; no VLAs in ISO C++
  static char buf[sizeof "character code " + INT_DIGITS + 1];
  (void) memset(buf, 0, bufsz);
  if (csprint(c)) {
    buf[0] = '\'';
    buf[1] = c;
    buf[2] = '\'';
    return buf;
  }
  (void) sprintf(buf, "character code %d", c);
  return buf;
}

static bool read_line(FILE *fp, string *p)
{
  p->clear();
  int c = -1;
  while ((c = getc(fp)) != EOF) {
    if (!is_invalid_input_char(c))
      *p += char(c);
    else
      error("invalid input (%1)", input_char_description(c));
    if (c == '\n')
      break;
  }
  return (p->length() > 0);
}

void do_file(FILE *fp, const char *filename)
{
  string linebuf;
  string str;
  string fn(filename);
  fn += '\0';
  normalize_for_lf(fn);
  current_filename = fn.contents();
  if (output_format == troff)
    printf(".lf 1 %s\n", current_filename);
  current_lineno = 1;
  while (read_line(fp, &linebuf)) {
    if (linebuf.length() >= 4
	&& linebuf[0] == '.' && linebuf[1] == 'l' && linebuf[2] == 'f'
	&& (linebuf[3] == ' ' || linebuf[3] == '\n' || compatible_flag))
    {
      put_string(linebuf, stdout);
      linebuf += '\0';
      // In GNU roff, `lf` assigns the number of the _next_ line.
      if (interpret_lf_args(linebuf.contents() + 3))
	current_lineno--;
    }
    else if (linebuf.length() >= 4
	     && linebuf[0] == '.'
	     && linebuf[1] == 'E'
	     && linebuf[2] == 'Q'
	     && (linebuf[3] == ' ' || linebuf[3] == '\n'
		 || compatible_flag)) {
      put_string(linebuf, stdout);
      int start_lineno = current_lineno + 1;
      str.clear();
      for (;;) {
	if (!read_line(fp, &linebuf)) {
	  current_lineno = 0; // suppress report of line number
	  fatal("end of file before .EN");
	}
	if (linebuf.length() >= 3
	    && linebuf[0] == '.'
	    && linebuf[1] == 'E') {
	  if (linebuf[2] == 'N'
	      && (linebuf.length() == 3 || linebuf[3] == ' '
		  || linebuf[3] == '\n' || compatible_flag))
	    break;
	  else if (linebuf[2] == 'Q' && linebuf.length() > 3
		   && (linebuf[3] == ' ' || linebuf[3] == '\n'
		       || compatible_flag)) {
	    current_lineno++; // We just read another line.
	    fatal("equations cannot be nested (.EQ within .EQ)");
	  }
	}
	str += linebuf;
      }
      str += '\0';
      start_string();
      init_lex(str.contents(), current_filename, start_lineno);
      non_empty_flag = 0;
      inline_flag = 0;
      yyparse();
      restore_compatibility();
      if (non_empty_flag) {
	if (output_format == mathml)
	  putchar('\n');
        else {
	  current_lineno++;
	  printf(".lf %d\n", current_lineno);
	  output_string();
	}
      }
      if (output_format == troff) {
	current_lineno++;
	printf(".lf %d\n", current_lineno);
      }
      put_string(linebuf, stdout);
    }
    else if (start_delim != '\0' && linebuf.search(start_delim) >= 0
	     && inline_equation(fp, linebuf, str))
      ;
    else
      put_string(linebuf, stdout);
    current_lineno++;
  }
  current_filename = 0;
  current_lineno = 0;
}

// Handle an inline equation.  Return 1 if it was an inline equation,
// otherwise.
static int inline_equation(FILE *fp, string &linebuf, string &str)
{
  linebuf += '\0';
  char *ptr = &linebuf[0];
  char *start = delim_search(ptr, start_delim);
  if (!start) {
    // It wasn't a delimiter after all.
    linebuf.set_length(linebuf.length() - 1); // strip the '\0'
    return 0;
  }
  start_string();
  inline_flag = 1;
  for (;;) {
    if (no_newline_in_delim_flag && strchr(start + 1, end_delim) == 0) {
      error("unterminated inline equation; started with %1,"
	    " expecting %2", input_char_description(start_delim),
	    input_char_description(end_delim));
      char *nl = strchr(start + 1, '\n');
      if (nl != 0)
	*nl = '\0';
      do_text(ptr);
      break;
    }
    int start_lineno = current_lineno;
    *start = '\0';
    do_text(ptr);
    ptr = start + 1;
    str.clear();
    for (;;) {
      char *end = strchr(ptr, end_delim);
      if (end != 0) {
	*end = '\0';
	str += ptr;
	ptr = end + 1;
	break;
      }
      str += ptr;
      if (!read_line(fp, &linebuf))
	fatal("unterminated inline equation; started with %1,"
	      " expecting %2", input_char_description(start_delim),
	      input_char_description(end_delim));
      linebuf += '\0';
      ptr = &linebuf[0];
    }
    str += '\0';
    if (output_format == troff && html) {
      printf(".as1 %s ", LINE_STRING);
      html_begin_suppress();
      printf("\n");
    }
    init_lex(str.contents(), current_filename, start_lineno);
    yyparse();
    if (output_format == troff && html) {
      printf(".as1 %s ", LINE_STRING);
      html_end_suppress();
      printf("\n");
    }
    if (output_format == mathml)
      printf("\n");
    if (xhtml) {
      /* skip leading spaces */
      while ((*ptr != '\0') && (*ptr == ' '))
	ptr++;
    }
    start = delim_search(ptr, start_delim);
    if (start == 0) {
      char *nl = strchr(ptr, '\n');
      if (nl != 0)
	*nl = '\0';
      do_text(ptr);
      break;
    }
  }
  restore_compatibility();
  if (output_format == troff)
    printf(".lf %d\n", current_lineno);
  output_string();
  if (output_format == troff)
    printf(".lf %d\n", current_lineno + 1);
  return 1;
}

/* Search for delim.  Skip over number register and string names etc. */

static char *delim_search(char *ptr, int delim)
{
  while (*ptr) {
    if (*ptr == delim)
      return ptr;
    if (*ptr++ == '\\') {
      switch (*ptr) {
      case 'n':
      case '*':
      case 'f':
      case 'g':
      case 'k':
	switch (*++ptr) {
	case '\0':
	case '\\':
	  break;
	case '(':
	  if (*++ptr != '\\' && *ptr != '\0'
	      && *++ptr != '\\' && *ptr != '\0')
	      ptr++;
	  break;
	case '[':
	  while (*++ptr != '\0')
	    if (*ptr == ']') {
	      ptr++;
	      break;
	    }
	  break;
	default:
	  ptr++;
	  break;
	}
	break;
      case '\\':
      case '\0':
	break;
      default:
	ptr++;
	break;
      }
    }
  }
  return 0;
}

void usage(FILE *stream)
{
  fprintf(stream,
    "usage: %s [-CNrR] [-d xy] [-f font] [-m n] [-M dir] [-p n] [-s n]"
    " [-T name] [file ...]\n"
    "usage: %s {-v | --version}\n"
    "usage: %s --help\n",
    program_name, program_name, program_name);
}

int main(int argc, char **argv)
{
  program_name = argv[0];
  static char stderr_buf[BUFSIZ];
  setbuf(stderr, stderr_buf);
  int opt;
  int load_startup_file = 1;
  static const struct option long_options[] = {
    { "help", no_argument, 0, CHAR_MAX + 1 },
    { "version", no_argument, 0, 'v' },
    { NULL, 0, 0, 0 }
  };
  while ((opt = getopt_long(argc, argv, "CNrRd:f:m:M:p:s:T:v",
			    long_options, NULL))
	 != EOF)
    switch (opt) {
    case 'C':
      compatible_flag = 1;
      break;
    case 'R':			// don't load eqnrc
      load_startup_file = 0;
      break;
    case 'M':
      config_macro_path.command_line_dir(optarg);
      break;
    case 'v':
      printf("GNU eqn (groff) version %s\n", Version_string);
      exit(EXIT_SUCCESS);
      break;
    case 'd':
      if (optarg[0] == '\0' || optarg[1] == '\0')
	error("'-d' option requires a two-character argument");
      else if (is_invalid_input_char(optarg[0]))
	error("invalid delimiter (%1) in '-d' option argument",
	      input_char_description(optarg[0]));
      else if (is_invalid_input_char(optarg[1]))
	error("invalid delimiter (%1) in '-d' option argument",
	      input_char_description(optarg[1]));
      else {
	start_delim = optarg[0];
	end_delim = optarg[1];
      }
      break;
    case 'f':
      set_gfont(optarg);
      break;
    case 'T':
      device = optarg;
      if (strcmp(device, "ps:html") == 0) {
	device = "ps";
	html = 1;
      }
      else if (strcmp(device, "MathML") == 0) {
	output_format = mathml;
	load_startup_file = 0;
      }
      else if (strcmp(device, "mathml:xhtml") == 0) {
	device = "MathML";
	output_format = mathml;
	load_startup_file = 0;
	xhtml = 1;
      }
      break;
    case 's':
      if (set_gsize(optarg))
	warning("option '-s' is deprecated");
      else
	error("invalid size '%1' in '-s' option argument ", optarg);
      break;
    case 'p':
      {
	int n;
	if (sscanf(optarg, "%d", &n) == 1) {
	  warning("option '-p' is deprecated");
	  set_script_reduction(n);
	}
	else
	  error("invalid size '%1' in '-p' option argument ", optarg);
      }
      break;
    case 'm':
      {
	int n;
	if (sscanf(optarg, "%d", &n) == 1)
	  set_minimum_size(n);
	else
	  error("invalid size '%1' in '-n' option argument", optarg);
      }
      break;
    case 'r':
      one_size_reduction_flag = 1;
      break;
    case 'N':
      no_newline_in_delim_flag = 1;
      break;
    case CHAR_MAX + 1: // --help
      usage(stdout);
      exit(EXIT_SUCCESS);
      break;
    case '?':
      usage(stderr);
      exit(EXIT_FAILURE);
      break;
    default:
      assert(0 == "unhandled getopt_long return value");
    }
  init_table(device);
  init_char_table();
  printf(".do if !dEQ .ds EQ\n"
	 ".do if !dEN .ds EN\n");
  if (output_format == troff) {
    printf(".if !'\\*(.T'%s' "
	   ".if !'\\*(.T'html' "	// the html device uses '-Tps' to render
				  // equations as images
	   ".tm warning: %s should have been given a '-T\\*(.T' option\n",
	   device, program_name);
    printf(".if '\\*(.T'html' "
	   ".if !'%s'ps' "
	   ".tm warning: %s should have been given a '-Tps' option\n",
	   device, program_name);
    printf(".if '\\*(.T'html' "
	   ".if !'%s'ps' "
	   ".tm warning: (it is advisable to invoke groff via: groff -Thtml -e)\n",
	   device);
  }
  if (load_startup_file) {
    char *path;
    FILE *fp = config_macro_path.open_file(STARTUP_FILE, &path);
    if (fp) {
      do_file(fp, path);
      if (fclose(fp) < 0)
	fatal("unable to close '%1': %2", STARTUP_FILE,
	      strerror(errno));
      free(path);
    }
  }
  if (optind >= argc)
    do_file(stdin, "-");
  else
    for (int i = optind; i < argc; i++)
      if (strcmp(argv[i], "-") == 0)
	do_file(stdin, "-");
      else {
	errno = 0;
	FILE *fp = fopen(argv[i], "r");
	if (!fp)
	  fatal("unable to open '%1': %2", argv[i], strerror(errno));
	else {
	  do_file(fp, argv[i]);
	  if (fclose(fp) < 0)
	    fatal("unable to close '%1': %2", argv[i], strerror(errno));
	}
      }
  if (ferror(stdout))
    fatal("standard output stream is in an error state");
  if (fflush(stdout) < 0)
    fatal("unable to flush standard output stream: %1",
	  strerror(errno));
  exit(EXIT_SUCCESS);
}

// Local Variables:
// fill-column: 72
// mode: C++
// End:
// vim: set cindent noexpandtab shiftwidth=2 textwidth=72:
