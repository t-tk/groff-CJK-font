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

// A front end for groff.

#include "lib.h"

#include <stdlib.h>
#include <signal.h>
#include <errno.h>

#include "assert.h"
#include "errarg.h"
#include "error.h"
#include "stringclass.h"
#include "cset.h"
#include "font.h"
#include "device.h"
#include "pipeline.h"
#include "nonposix.h"
#include "relocate.h"
#include "defs.h"

#define GXDITVIEW "gxditview"

// troff will be passed an argument of -rXREG=1 if the -X option is
// specified
#define XREG ".X"

#ifdef NEED_DECLARATION_PUTENV
extern "C" {
  int putenv(const char *);
}
#endif /* NEED_DECLARATION_PUTENV */

// The number of commands must be in sync with MAX_COMMANDS in
// pipeline.h.

// grap, chem, and ideal must come before pic;
// tbl must come before eqn
const int PRECONV_INDEX = 0;
const int SOELIM_INDEX = PRECONV_INDEX + 1;
const int REFER_INDEX = SOELIM_INDEX + 1;
const int GRAP_INDEX = REFER_INDEX + 1;
const int CHEM_INDEX = GRAP_INDEX + 1;
const int IDEAL_INDEX = CHEM_INDEX + 1;
const int PIC_INDEX = IDEAL_INDEX + 1;
const int TBL_INDEX = PIC_INDEX + 1;
const int GRN_INDEX = TBL_INDEX + 1;
const int EQN_INDEX = GRN_INDEX + 1;
const int TROFF_INDEX = EQN_INDEX + 1;
const int POST_INDEX = TROFF_INDEX + 1;
const int SPOOL_INDEX = POST_INDEX + 1;

const int NCOMMANDS = SPOOL_INDEX + 1;

class possible_command {
  char *name;
  string args;
  char **argv;

  void build_argv();
public:
  possible_command();
  ~possible_command();
  void clear_name();
  void set_name(const char *);
  void set_name(const char *, const char *);
  const char *get_name();
  void append_arg(const char *, const char * = 0 /* nullptr */);
  void insert_arg(const char *);
  void insert_args(string s);
  void clear_args();
  char **get_argv();
  void print(int is_last, FILE *fp);
};

extern "C" const char *Version_string;

int lflag = 0;
char *spooler = 0 /* nullptr */;
char *postdriver = 0 /* nullptr */;
char *predriver = 0 /* nullptr */;
bool need_postdriver = true;
char *saved_path = 0 /* nullptr */;
char *groff_bin_path = 0 /* nullptr */;
char *groff_font_path = 0 /* nullptr */;

possible_command commands[NCOMMANDS];

int run_commands(int no_pipe);
void print_commands(FILE *);
void append_arg_to_string(const char *arg, string &str);
void handle_unknown_desc_command(const char *command, const char *arg,
				 const char *filename, int lineno);
const char *xbasename(const char *);

void usage(FILE *stream);
void help();

static char *xstrdup(const char *s) {
  if (0 /* nullptr */ == s)
    return const_cast<char *>(s);
  char *str = strdup(s);
  if (0 /* nullptr */ == str)
    fatal("unable to copy string: %1", strerror(errno));
  return str;
}

static void xputenv(const char *s) {
  if (putenv(const_cast<char *>(s)) != 0)
    fatal("unable to write to environment: %1", strerror(errno));
  return;
}

static void xexit(int status) {
  free(spooler);
  free(predriver);
  free(postdriver);
  free(saved_path);
  free(groff_bin_path);
  free(groff_font_path);
  exit(status);
}

int main(int argc, char **argv)
{
  program_name = argv[0];
  static char stderr_buf[BUFSIZ];
  setbuf(stderr, stderr_buf);
  assert(NCOMMANDS <= MAX_COMMANDS);
  string Pargs, Largs, Fargs;
  int Kflag = 0;
  int vflag = 0;
  int Vflag = 0;
  int zflag = 0;
  int iflag = 0;
  int Xflag = 0;
  int oflag = 0;
  int safer_flag = 1;
  int is_xhtml = 0;
  int eflag = 0;
  int need_pic = 0;
  int opt;
  const char *command_prefix = getenv("GROFF_COMMAND_PREFIX");
  const char *encoding = getenv("GROFF_ENCODING");
  if (!command_prefix)
    command_prefix = PROG_PREFIX;
  commands[TROFF_INDEX].set_name(command_prefix, "troff");
  static const struct option long_options[] = {
    { "help", no_argument, 0, 'h' },
    { "version", no_argument, 0, 'v' },
    { NULL, 0, 0, 0 }
  };
  while ((opt = getopt_long(
		  argc, argv,
		  "abcCd:D:eEf:F:gGhiI:jJkK:lL:m:M:"
		  "n:No:pP:r:RsStT:UvVw:W:XzZ",
		  long_options, NULL))
	 != EOF) {
    char buf[3];
    buf[0] = '-';
    buf[1] = opt;
    buf[2] = '\0';
    switch (opt) {
    case 'i':
      iflag = 1;
      break;
    case 'I':
      commands[GRN_INDEX].set_name(command_prefix, "grn");
      commands[GRN_INDEX].append_arg("-M", optarg);
      commands[SOELIM_INDEX].set_name(command_prefix, "soelim");
      commands[SOELIM_INDEX].append_arg(buf, optarg);
      // .psbb may need to search for files
      commands[TROFF_INDEX].append_arg(buf, optarg);
      // \X'ps:import' may need to search for files
      Pargs += buf;
      Pargs += optarg;
      Pargs += '\0';
      break;
    case 'D':
      commands[PRECONV_INDEX].set_name("preconv");
      commands[PRECONV_INDEX].append_arg("-D", optarg);
      break;
    case 'K':
      commands[PRECONV_INDEX].append_arg("-e", optarg);
      Kflag = 1;
      // fall through
    case 'k':
      commands[PRECONV_INDEX].set_name("preconv");
      break;
    case 't':
      commands[TBL_INDEX].set_name(command_prefix, "tbl");
      break;
    case 'J':
      // commands[IDEAL_INDEX].set_name(command_prefix, "gideal");
      // need_pic = 1;
      break;
    case 'j':
      commands[CHEM_INDEX].set_name(command_prefix, "chem");
      need_pic = 1;
      break;
    case 'p':
      commands[PIC_INDEX].set_name(command_prefix, "pic");
      break;
    case 'g':
      commands[GRN_INDEX].set_name(command_prefix, "grn");
      break;
    case 'G':
      commands[GRAP_INDEX].set_name(command_prefix, "grap");
      need_pic = 1;
      break;
    case 'e':
      eflag = 1;
      commands[EQN_INDEX].set_name(command_prefix, "eqn");
      break;
    case 's':
      commands[SOELIM_INDEX].set_name(command_prefix, "soelim");
      break;
    case 'R':
      commands[REFER_INDEX].set_name(command_prefix, "refer");
      break;
    case 'z':
    case 'a':
      commands[TROFF_INDEX].append_arg(buf);
      // fall through
    case 'Z':
      zflag++;
      need_postdriver = false;
      break;
    case 'l':
      lflag++;
      break;
    case 'V':
      Vflag++;
      break;
    case 'v':
      vflag = 1;
      printf("GNU groff version %s\n", Version_string);
      printf(
	"Copyright (C) 2022 Free Software Foundation, Inc.\n"
	"GNU groff comes with ABSOLUTELY NO WARRANTY.\n"
	"You may redistribute copies of groff and its subprograms\n"
	"under the terms of the GNU General Public License.\n"
	"For more information about these matters, see the file\n"
	"named COPYING.\n");
      printf("\ncalled subprograms:\n\n");
      fflush(stdout);
      // Pass -v to all possible subprograms
      commands[PRECONV_INDEX].append_arg(buf);
      commands[CHEM_INDEX].append_arg(buf);
      commands[IDEAL_INDEX].append_arg(buf);
      commands[POST_INDEX].append_arg(buf);
      // fall through
    case 'C':
      commands[SOELIM_INDEX].append_arg(buf);
      commands[REFER_INDEX].append_arg(buf);
      commands[PIC_INDEX].append_arg(buf);
      commands[GRAP_INDEX].append_arg(buf);
      commands[TBL_INDEX].append_arg(buf);
      commands[GRN_INDEX].append_arg(buf);
      commands[EQN_INDEX].append_arg(buf);
      commands[TROFF_INDEX].append_arg(buf);
      break;
    case 'N':
      commands[EQN_INDEX].append_arg(buf);
      break;
    case 'h':
      help();
      break;
    case 'E':
    case 'b':
      commands[TROFF_INDEX].append_arg(buf);
      break;
    case 'c':
      commands[TROFF_INDEX].append_arg(buf);
      break;
    case 'S':
      safer_flag = 1;
      break;
    case 'U':
      safer_flag = 0;
      break;
    case 'T':
      if (strcmp(optarg, "xhtml") == 0) {
	// force soelim to aid the html preprocessor
	commands[SOELIM_INDEX].set_name(command_prefix, "soelim");
	Pargs += "-x";
	Pargs += '\0';
	Pargs += 'x';
	Pargs += '\0';
	is_xhtml = 1;
	device = "html";
	break;
      }
      if (strcmp(optarg, "html") == 0)
	// force soelim to aid the html preprocessor
	commands[SOELIM_INDEX].set_name(command_prefix, "soelim");
      if (strcmp(optarg, "Xps") == 0) {
	warning("-TXps option is obsolete: use -X -Tps instead");
	device = "ps";
	Xflag++;
      }
      else
	device = optarg;
      break;
    case 'F':
      font::command_line_font_dir(optarg);
      if (Fargs.length() > 0) {
	Fargs += PATH_SEP_CHAR;
	Fargs += optarg;
      }
      else
	Fargs = optarg;
      break;
    case 'o':
      oflag = 1;
      // fall through
    case 'f':
    case 'm':
    case 'r':
    case 'd':
    case 'n':
    case 'w':
    case 'W':
      commands[TROFF_INDEX].append_arg(buf, optarg);
      break;
    case 'M':
      commands[EQN_INDEX].append_arg(buf, optarg);
      commands[GRAP_INDEX].append_arg(buf, optarg);
      commands[GRN_INDEX].append_arg(buf, optarg);
      commands[TROFF_INDEX].append_arg(buf, optarg);
      break;
    case 'P':
      Pargs += optarg;
      Pargs += '\0';
      break;
    case 'L':
      append_arg_to_string(optarg, Largs);
      break;
    case 'X':
      Xflag++;
      need_postdriver = false;
      break;
    case '?':
      usage(stderr);
      xexit(EXIT_FAILURE);
      break;
    default:
      assert(0 == "no case to handle option character");
      break;
    }
  }
  if (need_pic)
    commands[PIC_INDEX].set_name(command_prefix, "pic");
  if (encoding) {
    commands[PRECONV_INDEX].set_name("preconv");
    if (!Kflag && *encoding)
      commands[PRECONV_INDEX].append_arg("-e", encoding);
  }
  if (!safer_flag) {
    commands[TROFF_INDEX].insert_arg("-U");
    commands[PIC_INDEX].append_arg("-U");
  }
  font::set_unknown_desc_command_handler(handle_unknown_desc_command);
  const char *desc = font::load_desc();
  if (0 /* nullptr */ == desc)
    fatal("cannot load 'DESC' description file for device '%1'",
	  device);
  if (need_postdriver && (0 /* nullptr */ == postdriver))
    fatal_with_file_and_line(desc, 0, "device description file missing"
			     " 'postpro' directive");
  if (predriver && !zflag) {
    commands[TROFF_INDEX].insert_arg(commands[TROFF_INDEX].get_name());
    commands[TROFF_INDEX].set_name(predriver);
    // pass the device arguments to the predrivers as well
    commands[TROFF_INDEX].insert_args(Pargs);
    if (eflag && is_xhtml)
      commands[TROFF_INDEX].insert_arg("-e");
    if (vflag)
      commands[TROFF_INDEX].insert_arg("-v");
  }
  const char *real_driver = 0 /* nullptr */;
  if (Xflag) {
    real_driver = postdriver;
    postdriver = (char *)GXDITVIEW;
    commands[TROFF_INDEX].append_arg("-r" XREG "=", "1");
  }
  if (postdriver)
    commands[POST_INDEX].set_name(postdriver);
  int gxditview_flag = postdriver
		       && strcmp(xbasename(postdriver), GXDITVIEW) == 0;
  if (gxditview_flag && argc - optind == 1) {
    commands[POST_INDEX].append_arg("-title");
    commands[POST_INDEX].append_arg(argv[optind]);
    commands[POST_INDEX].append_arg("-xrm");
    commands[POST_INDEX].append_arg("*iconName:", argv[optind]);
    string filename_string("|");
    append_arg_to_string(argv[0], filename_string);
    append_arg_to_string("-Z", filename_string);
    for (int i = 1; i < argc; i++)
      append_arg_to_string(argv[i], filename_string);
    filename_string += '\0';
    commands[POST_INDEX].append_arg("-filename");
    commands[POST_INDEX].append_arg(filename_string.contents());
  }
  if (gxditview_flag && Xflag) {
    string print_string(real_driver);
    if (spooler) {
      print_string += " | ";
      print_string += spooler;
      print_string += Largs;
    }
    print_string += '\0';
    commands[POST_INDEX].append_arg("-printCommand");
    commands[POST_INDEX].append_arg(print_string.contents());
  }
  const char *p = Pargs.contents();
  const char *end = p + Pargs.length();
  while (p < end) {
    commands[POST_INDEX].append_arg(p);
    p = strchr(p, '\0') + 1;
  }
  if (gxditview_flag)
    commands[POST_INDEX].append_arg("-");
  if (lflag && !vflag && !Xflag && spooler) {
    commands[SPOOL_INDEX].set_name(BSHELL);
    commands[SPOOL_INDEX].append_arg(BSHELL_DASH_C);
    Largs += '\0';
    Largs = spooler + Largs;
    commands[SPOOL_INDEX].append_arg(Largs.contents());
  }
  if (zflag) {
    commands[POST_INDEX].set_name(0 /* nullptr */);
    commands[SPOOL_INDEX].set_name(0 /* nullptr */);
  }
  commands[TROFF_INDEX].append_arg("-T", device);
  if (strcmp(device, "html") == 0) {
    if (is_xhtml) {
      if (oflag)
	fatal("'-o' option is invalid with device 'xhtml'");
      if (zflag)
	commands[EQN_INDEX].append_arg("-Tmathml:xhtml");
      else if (eflag)
	commands[EQN_INDEX].clear_name();
    }
    else {
      if (oflag)
	fatal("'-o' option is invalid with device 'html'");
      // html renders equations as images via ps
      commands[EQN_INDEX].append_arg("-Tps:html");
    }
  }
  else
    commands[EQN_INDEX].append_arg("-T", device);

  commands[GRN_INDEX].append_arg("-T", device);

  int first_index;
  for (first_index = 0; first_index < TROFF_INDEX; first_index++)
    if (commands[first_index].get_name() != 0 /* nullptr */)
      break;
  if (optind < argc) {
    if (argv[optind][0] == '-' && argv[optind][1] != '\0')
      commands[first_index].append_arg("--");
    for (int i = optind; i < argc; i++)
      commands[first_index].append_arg(argv[i]);
    if (iflag)
      commands[first_index].append_arg("-");
  }
  if (Fargs.length() > 0) {
    string e = "GROFF_FONT_PATH";
    e += '=';
    e += Fargs;
    char *fontpath = getenv("GROFF_FONT_PATH");
    if (fontpath && *fontpath) {
      e += PATH_SEP_CHAR;
      e += fontpath;
    }
    e += '\0';
    groff_font_path = xstrdup(e.contents());
    xputenv(groff_font_path);
  }
  {
    // we save the original path in GROFF_PATH__ and put it into the
    // environment -- troff will pick it up later.
    char *path = getenv("PATH");
    string g = "GROFF_PATH__";
    g += '=';
    if (path && *path)
      g += path;
    g += '\0';
    saved_path = xstrdup(g.contents());
    xputenv(saved_path);
    char *binpath = getenv("GROFF_BIN_PATH");
    string f = "PATH";
    f += '=';
    if (binpath && *binpath)
      f += binpath;
    else {
      binpath = relocatep(BINPATH);
      f += binpath;
    }
    if (path && *path) {
      f += PATH_SEP_CHAR;
      f += path;
    }
    f += '\0';
    groff_bin_path = xstrdup(f.contents());
    xputenv(groff_bin_path);
  }
  if (Vflag)
    print_commands(Vflag == 1 ? stdout : stderr);
  if (Vflag == 1)
    xexit(EXIT_SUCCESS);
  xexit(run_commands(vflag));
}

const char *xbasename(const char *s)
{
  if (!s)
    return 0 /* nullptr */;
  // DIR_SEPS[] are possible directory separator characters; see
  // nonposix.h.  We want the rightmost separator of all possible ones.
  // Example: d:/foo\\bar.
  const char *p = strrchr(s, DIR_SEPS[0]), *p1;
  const char *sep = &DIR_SEPS[1];

  while (*sep)
    {
      p1 = strrchr(s, *sep);
      if (p1 && (!p || p1 > p))
	p = p1;
      sep++;
    }
  return p ? p + 1 : s;
}

void handle_unknown_desc_command(const char *command, const char *arg,
				 const char *filename, int lineno)
{
  current_filename = filename;
  current_lineno = lineno;
  if (strcmp(command, "print") == 0) {
    if (arg == 0 /* nullptr */)
      error("'print' directive requires an argument");
    else
      spooler = xstrdup(arg);
  }
  if (strcmp(command, "prepro") == 0) {
    if (arg == 0 /* nullptr */)
      error("'prepro' directive requires an argument");
    else {
      for (const char *p = arg; *p; p++)
	if (csspace(*p)) {
	  error("invalid 'prepro' directive argument '%1':"
		" program name required", arg);
	  return;
	}
      predriver = xstrdup(arg);
    }
  }
  if (strcmp(command, "postpro") == 0) {
    if (arg == 0 /* nullptr */)
      error("'postpro' directive requires an argument");
    else {
      for (const char *p = arg; *p; p++)
	if (csspace(*p)) {
	  error("invalid 'postpro' directive argument '%1':"
		" program name required", arg);
	  return;
	}
      postdriver = xstrdup(arg);
    }
  }
}

void print_commands(FILE *fp)
{
  int last;
  for (last = SPOOL_INDEX; last >= 0; last--)
    if (commands[last].get_name() != 0 /* nullptr */)
      break;
  for (int i = 0; i <= last; i++)
    if (commands[i].get_name() != 0 /* nullptr */)
      commands[i].print(i == last, fp);
}

// Run the commands. Return the code with which to exit.

int run_commands(int no_pipe)
{
  char **v[NCOMMANDS];
  int j = 0;
  for (int i = 0; i < NCOMMANDS; i++)
    if (commands[i].get_name() != 0 /* nullptr */)
      v[j++] = commands[i].get_argv();
  return run_pipeline(j, v, no_pipe);
}

possible_command::possible_command()
: name(0), argv(0)
{
}

possible_command::~possible_command()
{
  free(name);
  delete[] argv;
}

void possible_command::set_name(const char *s)
{
  free(name);
  name = xstrdup(s);
}

void possible_command::clear_name()
{
  delete[] name;
  delete[] argv;
  name = NULL;
  argv = NULL;
}

void possible_command::set_name(const char *s1, const char *s2)
{
  free(name);
  name = (char*)malloc(strlen(s1) + strlen(s2) + 1);
  strcpy(name, s1);
  strcat(name, s2);
}

const char *possible_command::get_name()
{
  return name;
}

void possible_command::clear_args()
{
  args.clear();
}

void possible_command::append_arg(const char *s, const char *t)
{
  args += s;
  if (t)
    args += t;
  args += '\0';
}

void possible_command::insert_arg(const char *s)
{
  string str(s);
  str += '\0';
  str += args;
  args = str;
}

void possible_command::insert_args(string s)
{
  const char *p = s.contents();
  const char *end = p + s.length();
  int l = 0;
  if (p >= end)
    return;
  // find the total number of arguments in our string
  do {
    l++;
    p = strchr(p, '\0') + 1;
  } while (p < end);
  // now insert each argument preserving the order
  for (int i = l - 1; i >= 0; i--) {
    p = s.contents();
    for (int j = 0; j < i; j++)
      p = strchr(p, '\0') + 1;
    insert_arg(p);
  }
}

void possible_command::build_argv()
{
  if (argv)
    return;
  // Count the number of arguments.
  int len = args.length();
  int argc = 1;
  char *p = 0 /* nullptr */;
  if (len > 0) {
    p = &args[0];
    for (int i = 0; i < len; i++)
      if (p[i] == '\0')
	argc++;
  }
  // Build an argument vector.
  argv = new char *[argc + 1];
  argv[0] = name;
  for (int i = 1; i < argc; i++) {
    argv[i] = p;
    p = strchr(p, '\0') + 1;
  }
  argv[argc] = 0 /* nullptr */;
}

void possible_command::print(int is_last, FILE *fp)
{
  build_argv();
  if (IS_BSHELL(argv[0])
      && argv[1] != 0 /* nullptr */
      && strcmp(argv[1], BSHELL_DASH_C) == 0
      && argv[2] != 0 /* nullptr */ && argv[3] == 0 /* nullptr */)
    fputs(argv[2], fp);
  else {
    fputs(argv[0], fp);
    string str;
    for (int i = 1; argv[i] != 0 /* nullptr */; i++) {
      str.clear();
      append_arg_to_string(argv[i], str);
      put_string(str, fp);
    }
  }
  if (is_last)
    putc('\n', fp);
  else
    fputs(" | ", fp);
}

void append_arg_to_string(const char *arg, string &str)
{
  str += ' ';
  int needs_quoting = 0;
  // Native Windows programs don't support '..' style of quoting, so
  // always behave as if ARG included the single quote character.
#if defined(_WIN32) && !defined(__CYGWIN__)
  int contains_single_quote = 1;
#else
  int contains_single_quote = 0;
#endif
  const char*p;
  for (p = arg; *p != '\0'; p++)
    switch (*p) {
    case ';':
    case '&':
    case '(':
    case ')':
    case '|':
    case '^':
    case '<':
    case '>':
    case '\n':
    case ' ':
    case '\t':
    case '\\':
    case '"':
    case '$':
    case '?':
    case '*':
      needs_quoting = 1;
      break;
    case '\'':
      contains_single_quote = 1;
      break;
    }
  if (contains_single_quote || arg[0] == '\0') {
    str += '"';
    for (p = arg; *p != '\0'; p++)
      switch (*p) {
#if !(defined(_WIN32) && !defined(__CYGWIN__))
      case '"':
      case '\\':
      case '$':
	str += '\\';
#else
      case '"':
      case '\\':
	if (*p == '"' || (*p == '\\' && p[1] == '"'))
	  str += '\\';
#endif
	// fall through
      default:
	str += *p;
	break;
      }
    str += '"';
  }
  else if (needs_quoting) {
    str += '\'';
    str += arg;
    str += '\'';
  }
  else
    str += arg;
}

char **possible_command::get_argv()
{
  build_argv();
  return argv;
}

void synopsis(FILE *stream)
{
  // Add `J` to the cluster if we ever get ideal(1) support.
  fprintf(stream,
"usage: %s [-abcCeEgGijklNpRsStUVXzZ] [-dCS] [-dNAME=STRING] [-Denc]"
" [-fFAM] [-Fdir] [-Idir] [-Kenc] [-Larg] [-mNAME] [-Mdir] [-nNUM]"
" [-oLIST] [-Parg] [-rCN] [-rREG=EXPR] [-Tdev] [-wNAME] [-Wname]"
" [file ...]\n"
"usage: %s {-h | --help | -v | --version}\n",
	  program_name, program_name);
}

void help()
{
  synopsis(stdout);
  fputs("\n"
"-a\tproduce approximate description of output\n"
"-b\treport backtraces with errors or warnings\n"
"-c\tstart with color output disabled\n"
"-C\tstart with AT&T troff compatibility mode enabled\n"
"-d ST\tstore text T to string S (one character)\n"
"-d STRING=TEXT\n\tstore TEXT to string STRING\n"
"-D ENC\tfall back to ENC as default input encoding; implies -k\n"
"-e\tpreprocess with eqn\n"
"-E\tsuppress error diagnostics; implies -Ww\n"
"-f FAM\tuse FAM as the default font family\n"
"-F DIR\tsearch DIR for device and font description files\n"
"-g\tpreprocess with grn\n"
"-G\tpreprocess with grap; implies -p\n"
"-h\toutput this usage message and exit\n"
"-i\tread standard input after all FILEs\n"
"-I DIR\tsearch DIR for input files; implies -s\n"
"-j\tpreprocess with chem; implies -p\n"
// "-J\tpreprocess with gideal\n"
"-k\tpreprocess with preconv\n"
"-K ENC\tuse ENC as input encoding; implies -k\n"
"-l\tsend postprocessed output to print spooler\n"
"-L ARG\tpass ARG to print spooler\n"
"-m NAME\tread macro file NAME.tmac\n"
"-M DIR\tsearch DIR for macro files\n"
"-N\tdon't allow newlines within eqn delimiters\n"
"-n NUM\tnumber first page NUM\n"
"-o LIST\toutput only page in LIST (\"1\"; \"2,4\"; \"3,7-11\")\n"
"-p\tpreprocess with pic\n"
"-P ARG\tpass ARG to the postprocessor\n"
"-r CN\tstore numeric expression N in register C (one character)\n"
"-r REG=EXPR\n\tstore numeric expression EXPR in register REG\n"
"-R\tpreprocess with refer\n"
"-s\tpreprocess with soelim\n"
"-S\tenable safer mode (default)\n"
"-t\tpreprocess with tbl\n"
"-T DEV\tprepare output for device DEV\n"
"-U\taccept unsafe input (disable safer mode)\n"
"-v\toutput version information and pass -v to commands to be run\n"
"-V\twrite commands to standard output instead of running them\n"
"-w NAME\tenable warning type NAME\n"
"-W NAME\tinhibit warning type NAME\n"
"-X\trun gxditview previewer instead of normal postprocessor\n"
"-z\tsuppress formatted output\n"
"-Z\tdo not run postprocessor\n"
"\n"
"See groff(1) for details.\n",
	stdout);
  exit(EXIT_SUCCESS);
}

void usage(FILE *stream)
{
  synopsis(stream);
}

extern "C" {

void c_error(const char *format, const char *arg1, const char *arg2,
	     const char *arg3)
{
  error(format, arg1, arg2, arg3);
}

void c_fatal(const char *format, const char *arg1, const char *arg2,
	     const char *arg3)
{
  fatal(format, arg1, arg2, arg3);
}

}

// Local Variables:
// fill-column: 72
// mode: C++
// End:
// vim: set cindent noexpandtab shiftwidth=2 textwidth=72:
