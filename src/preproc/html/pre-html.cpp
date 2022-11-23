/* Copyright (C) 2000-2021 Free Software Foundation, Inc.
 * Written by Gaius Mulley (gaius@glam.ac.uk).
 *
 * This file is part of groff.
 *
 * groff is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or (at
 * your option) any later version.
 *
 * groff is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with groff; see the file COPYING.  If not, write to the Free
 * Software Foundation, 51 Franklin St - Fifth Floor, Boston, MA
 * 02110-1301, USA.
 */

#define PREHTMLC

#include "lib.h"

#include <signal.h>
#include <ctype.h>
#include <stdlib.h>
#include <errno.h>

#include "assert.h"

#include "errarg.h"
#include "error.h"
#include "stringclass.h"
#include "posix.h"
#include "defs.h"
#include "searchpath.h"
#include "paper.h"
#include "device.h"
#include "font.h"

#include <errno.h>
#include <sys/types.h>
#ifdef HAVE_UNISTD_H
# include <unistd.h>
#endif

#ifdef _POSIX_VERSION
# include <sys/wait.h>
# define PID_T pid_t
#else /* not _POSIX_VERSION */
# define PID_T int
#endif /* not _POSIX_VERSION */

#include <stdarg.h>

#include "nonposix.h"

#if 0
# define DEBUGGING
#endif

/* Establish some definitions to facilitate discrimination between
   differing runtime environments. */

#undef MAY_FORK_CHILD_PROCESS
#undef MAY_SPAWN_ASYNCHRONOUS_CHILD

#if defined(__MSDOS__) || defined(_WIN32)

// Most MS-DOS and Win32 environments will be missing the 'fork'
// capability (some, like Cygwin, have it, but it is better avoided).

# define MAY_FORK_CHILD_PROCESS 0

// On these systems, we use 'spawn...', instead of 'fork' ... 'exec...'.
# include <process.h>	// for 'spawn...'
# include <fcntl.h>	// for attributes of pipes

# if defined(__CYGWIN__) || defined(_UWIN) || defined(_WIN32)

// These Win32 implementations allow parent and 'spawn...'ed child to
// multitask asynchronously.

#  define MAY_SPAWN_ASYNCHRONOUS_CHILD 1

# else

// Others may adopt MS-DOS behaviour where parent must sleep,
// from 'spawn...' until child terminates.

#  define MAY_SPAWN_ASYNCHRONOUS_CHILD 0

# endif /* not defined __CYGWIN__, _UWIN, or _WIN32 */

# if defined(DEBUGGING) && !defined(DEBUG_FILE_DIR)
/* When we are building a DEBUGGING version we need to tell pre-grohtml
   where to put intermediate files (the DEBUGGING version will preserve
   these on exit).

   On a Unix host, we might simply use '/tmp', but MS-DOS and Win32 will
   probably not have this on all disk drives, so default to using
   'c:/temp' instead.  (Note that user may choose to override this by
   supplying a definition such as

     -DDEBUG_FILE_DIR=d:/path/to/debug/files

   in the CPPFLAGS to 'make'.) */

#  define DEBUG_FILE_DIR c:/temp
# endif

#else /* not __MSDOS__ or _WIN32 */

// For non-Microsoft environments assume Unix conventions,
// so 'fork' is required and child processes are asynchronous.
# define MAY_FORK_CHILD_PROCESS 1
# define MAY_SPAWN_ASYNCHRONOUS_CHILD 1

# if defined(DEBUGGING) && !defined(DEBUG_FILE_DIR)
/* For a DEBUGGING version, on the Unix host, we can also usually rely
   on being able to use '/tmp' for temporary file storage.  (Note that,
   as in the __MSDOS__ or _WIN32 case above, the user may override this
   by defining

     -DDEBUG_FILE_DIR=/path/to/debug/files

   in the CPPFLAGS.) */

#  define DEBUG_FILE_DIR /tmp
# endif

#endif /* not __MSDOS__ or _WIN32 */

#ifdef DEBUGGING
// For a DEBUGGING version, we need some additional macros,
// to direct the captured debugging mode output to appropriately named
// files in the specified DEBUG_FILE_DIR.

# define DEBUG_TEXT(text) #text
# define DEBUG_NAME(text) DEBUG_TEXT(text)
# define DEBUG_FILE(name) DEBUG_NAME(DEBUG_FILE_DIR) "/" name
#endif

extern "C" const char *Version_string;

#include "pre-html.h"
#include "pushback.h"
#include "html-strings.h"

#define DEFAULT_LINE_LENGTH 7	// inches wide
#define DEFAULT_IMAGE_RES 100	// number of pixels per inch resolution
#define IMAGE_BORDER_PIXELS 0
#define INLINE_LEADER_CHAR '\\'

// Don't use colour names here!  Otherwise there is a dependency on
// a file called 'rgb.txt' which maps names to colours.
#define TRANSPARENT "-background rgb:f/f/f -transparent rgb:f/f/f"
#define MIN_ALPHA_BITS 0
#define MAX_ALPHA_BITS 4

#define PAGE_TEMPLATE_SHORT "pg"
#define PAGE_TEMPLATE_LONG "-page-"
#define PS_TEMPLATE_SHORT "ps"
#define PS_TEMPLATE_LONG "-ps-"
#define REGION_TEMPLATE_SHORT "rg"
#define REGION_TEMPLATE_LONG "-regions-"

typedef enum {
  CENTERED, LEFT, RIGHT, INLINE
} IMAGE_ALIGNMENT;

typedef enum {xhtml, html4} html_dialect;

static int postscriptRes = -1;		// PostScript resolution,
					// dots per inch
static int stdoutfd = 1;		// output file descriptor -
					// normally 1 but might move
					// -1 means closed
static char *psFileName = 0 /* nullptr */;	// PostScript file name
static char *psPageName = 0 /* nullptr */;	// name of file
						// containing current
						// PostScript page
static char *regionFileName = 0 /* nullptr */;	// name of file
						// containing all image
						// regions
static char *imagePageName = 0 /* nullptr */;	// name of bitmap image
						// file containing
						// current page
static const char *image_device = "pnmraw";
static int image_res = DEFAULT_IMAGE_RES;
static int vertical_offset = 0;
static char *image_template = 0 /* nullptr */;	// image file name
						// template
static char *macroset_template= 0 /* nullptr */;	// image file
							// name template
							// passed to
							// troff by -D
static int troff_arg = 0;		// troff arg index
static char *image_dir = 0 /* nullptr */;	// user-specified image
						// directory
static int textAlphaBits = MAX_ALPHA_BITS;
static int graphicAlphaBits = MAX_ALPHA_BITS;
static char *antiAlias = 0 /* nullptr */;	// anti-alias arguments
						// to be passed to gs
static bool want_progress_report = false;	// display page numbers
						// as they are processed
static int currentPageNo = -1;		// current image page number
#if defined(DEBUGGING)
static bool debugging = false;
static char *troffFileName = 0 /* nullptr */;	// pre-html output sent
						// to troff -Tps
static char *htmlFileName = 0 /* nullptr */;	// pre-html output sent
						// to troff -Thtml
#endif
static bool need_eqn = false;		// must we preprocess via eqn?

static char *linebuf = 0 /* nullptr */;	// for scanning devps/DESC
static int linebufsize = 0;
static const char *image_gen = 0 /* nullptr */;	// the 'gs' program

static const char devhtml_desc[] = "devhtml/DESC";
static const char devps_desc[] = "devps/DESC";

const char *const FONT_ENV_VAR = "GROFF_FONT_PATH";
static search_path font_path(FONT_ENV_VAR, FONTPATH, 0, 0);
static html_dialect dialect = html4;


/*
 *  Images are generated via PostScript, gs, and the pnm utilities.
 */
#define IMAGE_DEVICE "-Tps"


/*
 *  sys_fatal - Write a fatal error message.
 *              Taken from src/roff/groff/pipeline.c.
 */

void sys_fatal(const char *s)
{
  fatal("%1: %2", s, strerror(errno));
}

/*
 *  get_line - Copy a line (w/o newline) from a file to the
 *             global line buffer.
 */

int get_line(FILE *f)
{
  if (f == 0)
    return 0;
  if (linebuf == 0) {
    linebuf = new char[128];
    linebufsize = 128;
  }
  int i = 0;
  // skip leading whitespace
  for (;;) {
    int c = getc(f);
    if (c == EOF)
      return 0;
    if (c != ' ' && c != '\t') {
      ungetc(c, f);
      break;
    }
  }
  for (;;) {
    int c = getc(f);
    if (c == EOF)
      break;
    if (i + 1 >= linebufsize) {
      char *old_linebuf = linebuf;
      linebuf = new char[linebufsize * 2];
      memcpy(linebuf, old_linebuf, linebufsize);
      delete[] old_linebuf;
      linebufsize *= 2;
    }
    linebuf[i++] = c;
    if (c == '\n') {
      i--;
      break;
    }
  }
  linebuf[i] = '\0';
  return 1;
}

/*
 *  get_resolution - Return the PostScript device resolution.
 */

static unsigned int get_resolution(void)
{
  char *pathp;
  FILE *f;
  unsigned int res = 0;
  f = font_path.open_file(devps_desc, &pathp);
  if (0 == f)
    fatal("cannot open file '%1'", devps_desc);
  free(pathp);
  // XXX: We should break out of this loop if we hit a "charset" line.
  // "This line and everything following it in the file are ignored."
  // (groff_font(5))
  while (get_line(f))
    (void) sscanf(linebuf, "res %u", &res);
  fclose(f);
  return res;
}


/*
 *  get_image_generator - Return the declared program from the HTML
 *                        device description.
 */

static char *get_image_generator(void)
{
  char *pathp;
  FILE *f;
  char *generator = 0;
  const char keyword[] = "image_generator";
  const size_t keyword_len = strlen(keyword);
  f = font_path.open_file(devhtml_desc, &pathp);
  if (0 == f)
    fatal("cannot open file '%1'", devhtml_desc);
  free(pathp);
  // XXX: We should break out of this loop if we hit a "charset" line.
  // "This line and everything following it in the file are ignored."
  // (groff_font(5))
  while (get_line(f)) {
    char *cursor = linebuf;
    size_t limit = strlen(linebuf);
    char *end = linebuf + limit;
    if (0 == (strncmp(linebuf, keyword, keyword_len))) {
      cursor += keyword_len;
      // At least one space or tab is required.
      if(!(' ' == *cursor) || ('\t' == *cursor))
	continue;
      cursor++;
      while((cursor < end) && ((' ' == *cursor) || ('\t' == *cursor)))
	cursor++;
      if (cursor == end)
	continue;
      generator = cursor;
    }
  }
  fclose(f);
  return generator;
}

/*
 *  html_system - A wrapper for system().
 */

void html_system(const char *s, int redirect_stdout)
{
#if defined(DEBUGGING)
  if (debugging) {
    fprintf(stderr, "executing: ");
    fwrite(s, sizeof(char), strlen(s), stderr);
    fflush(stderr);
  }
#endif
  {
    int saved_stdout = dup(1);
    int fdnull = open(NULL_DEV, O_WRONLY|O_BINARY, 0666);
    if (redirect_stdout && saved_stdout > 1 && fdnull > 1)
      dup2(fdnull, 1);
    if (fdnull >= 0)
      close(fdnull);
    int status = system(s);
    if (redirect_stdout)
      dup2(saved_stdout, 1);
    if (status == -1)
      fprintf(stderr, "Calling '%s' failed\n", s);
    else if (status)
      fprintf(stderr, "Calling '%s' returned status %d\n", s, status);
    close(saved_stdout);
  }
}

/*
 *  make_string - Create a string via `malloc()`, place the variadic
 *                arguments as formatted by `fmt` into it, and return
 *                it.  Adapted from Linux man-pages' printf(3) example.
 *                We never return a null pointer, instead treating
 *                failure as invariably fatal.
 */

char *make_string(const char *fmt, ...)
{
  size_t size = 0;
  char *p = 0 /* nullptr */;
  va_list ap;
  va_start(ap, fmt);
  int n = vsnprintf(p, size, fmt, ap);
  va_end(ap);
  if (n < 0)
    sys_fatal("vsnprintf");
  size = static_cast<size_t>(n) + 1 /* '\0' */;
  p = static_cast<char *>(malloc(size));
  if (0 /* nullptr */ == p)
    sys_fatal("vsnprintf");
  va_start(ap, fmt);
  n = vsnprintf(p, size, fmt, ap);
  va_end(ap);
  if (n < 0)
    sys_fatal("vsnprintf");
  assert(p != 0 /* nullptr */);
  return p;
}

/*
 *  classes and methods for retaining ascii text
 */

struct char_block {
  enum { SIZE = 256 };
  char buffer[SIZE];
  int used;
  char_block *next;

  char_block();
};

char_block::char_block()
: used(0), next(0)
{
  for (int i = 0; i < SIZE; i++)
    buffer[i] = 0;
}

class char_buffer {
public:
  char_buffer();
  ~char_buffer();
  void read_file(FILE *fp);
  int do_html(int argc, char *argv[]);
  int do_image(int argc, char *argv[]);
  void emit_troff_output(int device_format_selector);
  void write_upto_newline(char_block **t, int *i, int is_html);
  bool can_see(char_block **t, int *i, const char *string);
  void skip_until_newline(char_block **t, int *i);
private:
  char_block *head;
  char_block *tail;
  int run_output_filter(int device_format_selector, int argc,
			char *argv[]);
};

char_buffer::char_buffer()
: head(0), tail(0)
{
}

char_buffer::~char_buffer()
{
  while (head != 0 /* nullptr */) {
    char_block *temp = head;
    head = head->next;
    delete temp;
  }
}

/*
 *  read_file - Read file `fp` into char_blocks.
 */

void char_buffer::read_file(FILE *fp)
{
  int n;
  while (!feof(fp)) {
    if (0 /* nullptr */ == tail) {
      tail = new char_block;
      head = tail;
    }
    else {
      if (tail->used == char_block::SIZE) {
	tail->next = new char_block;
	tail = tail->next;
      }
    }
    // We now have a tail ready for the next `SIZE` bytes of the file.
    n = fread(tail->buffer, sizeof(char), char_block::SIZE-tail->used,
	      fp);
    if ((n < 0) || ((0 == n) && !feof(fp)))
      sys_fatal("fread");
    tail->used += n * sizeof(char);
  }
}

/*
 *  writeNbytes - Write n bytes to stdout.
 */

static void writeNbytes(const char *s, int l)
{
  int n = 0;
  int r;

  while (n < l) {
    r = write(stdoutfd, s, l - n);
    if (r < 0)
      sys_fatal("write");
    n += r;
    s += r;
  }
}

/*
 *  writeString - Write a string to stdout.
 */

static void writeString(const char *s)
{
  writeNbytes(s, strlen(s));
}

/*
 *  makeFileName - Create the image filename template
 *                 and the macroset image template.
 */

static void makeFileName(void)
{
  if ((image_dir != 0 /* nullptr */)
      && (strchr(image_dir, '%') != 0 /* nullptr */))
    fatal("'%%' is prohibited within the image directory name");
  if ((image_template != 0 /* nullptr */)
      && (strchr(image_template, '%') != 0 /* nullptr */))
    fatal("'%%' is prohibited within the image template");
  if (0 /* nullptr */ == image_dir)
    image_dir = (char *)"";
  else if (strlen(image_dir) > 0
	   && image_dir[strlen(image_dir) - 1] != '/')
    image_dir = make_string("%s/", image_dir);
  if (0 /* nullptr */ == image_template)
    macroset_template = make_string("%sgrohtml-%d-", image_dir,
				     int(getpid()));
  else
    macroset_template = make_string("%s%s-", image_dir,
				     image_template);
  size_t mtlen = strlen(macroset_template);
  image_template = (char *)malloc(strlen("%d") + mtlen + 1);
  if (0 /* nullptr */ == image_template)
    sys_fatal("malloc");
  char *s = strcpy(image_template, macroset_template);
  s += mtlen;
  // Keep this format string synced with troff:suppress_node::tprint().
  strcpy(s, "%d");
}

/*
 *  setupAntiAlias - Set up the antialias string, used when we call gs.
 */

static void setupAntiAlias(void)
{
  if (textAlphaBits == 0 && graphicAlphaBits == 0)
    antiAlias = make_string(" ");
  else if (textAlphaBits == 0)
    antiAlias = make_string("-dGraphicsAlphaBits=%d ",
			    graphicAlphaBits);
  else if (graphicAlphaBits == 0)
    antiAlias = make_string("-dTextAlphaBits=%d ", textAlphaBits);
  else
    antiAlias = make_string("-dTextAlphaBits=%d"
			    " -dGraphicsAlphaBits=%d ", textAlphaBits,
			    graphicAlphaBits);
}

/*
 *  checkImageDir - Check whether the image directory is available.
 */

static void checkImageDir(void)
{
  if (image_dir != 0 /* nullptr */ && strcmp(image_dir, "") != 0)
    if (!(mkdir(image_dir, 0777) == 0 || errno == EEXIST))
      fatal("cannot create directory '%1': %2", image_dir,
	    strerror(errno));
}

/*
 *  write_end_image - End the image.  Write out the image extents if we
 *                    are using -Tps.
 */

static void write_end_image(int is_html)
{
  /*
   *  if we are producing html then these
   *    emit image name and enable output
   *  else
   *    we are producing images
   *    in which case these generate image
   *    boundaries
   */
  writeString("\\O[4]\\O[2]");
  if (is_html)
    writeString("\\O[1]");
  else
    writeString("\\O[0]");
}

/*
 *  write_start_image - Write troff code which will:
 *
 *                      (i)  disable html output for the following image
 *                      (ii) reset the max/min x/y registers during
 *                           Postscript Rendering.
 */

static void write_start_image(IMAGE_ALIGNMENT pos, int is_html)
{
  writeString("\\O[5");
  switch (pos) {
  case INLINE:
    writeString("i");
    break;
  case LEFT:
    writeString("l");
    break;
  case RIGHT:
    writeString("r");
    break;
  case CENTERED:
  default:
    writeString("c");
    break;
  }
  writeString(image_template);
  writeString(".png]");
  if (is_html)
    writeString("\\O[0]\\O[3]");
  else
    // reset min/max registers
    writeString("\\O[1]\\O[3]");
}

/*
 *  write_upto_newline - Write the contents of the buffer until a
 *                       newline is seen.  Check for
 *                       HTML_IMAGE_INLINE_BEGIN and
 *                       HTML_IMAGE_INLINE_END; process them if they are
 *                       present.
 */

void char_buffer::write_upto_newline(char_block **t, int *i,
				     int is_html)
{
  int j = *i;

  if (*t) {
    while (j < (*t)->used
	   && (*t)->buffer[j] != '\n'
	   && (*t)->buffer[j] != INLINE_LEADER_CHAR)
      j++;
    if (j < (*t)->used
	&& (*t)->buffer[j] == '\n')
      j++;
    writeNbytes((*t)->buffer + (*i), j - (*i));
    if (j < char_block::SIZE && (*t)->buffer[j] == INLINE_LEADER_CHAR) {
      if (can_see(t, &j, HTML_IMAGE_INLINE_BEGIN))
	write_start_image(INLINE, is_html);
      else if (can_see(t, &j, HTML_IMAGE_INLINE_END))
	write_end_image(is_html);
      else {
	if (j < (*t)->used) {
	  *i = j;
	  j++;
	  writeNbytes((*t)->buffer + (*i), j - (*i));
	}
      }
    }
    if (j == (*t)->used) {
      *i = 0;
      *t = (*t)->next;
      if (*t && (*t)->buffer[j - 1] != '\n')
	write_upto_newline(t, i, is_html);
    }
    else
      // newline was seen
      *i = j;
  }
}

/*
 *  can_see - Return true if we can see string in t->buffer[i] onwards.
 */

bool char_buffer::can_see(char_block **t, int *i, const char *str)
{
  int j = 0;
  int l = strlen(str);
  int k = *i;
  char_block *s = *t;

  while (s) {
    while (k < s->used && j < l && s->buffer[k] == str[j]) {
      j++;
      k++;
    }
    if (j == l) {
      *i = k;
      *t = s;
      return true;
    }
    else if (k < s->used && s->buffer[k] != str[j])
      return false;
    s = s->next;
    k = 0;
  }
  return false;
}

/*
 *  skip_until_newline - Skip all characters until a newline is seen.
 *                       The newline is not consumed.
 */

void char_buffer::skip_until_newline(char_block **t, int *i)
{
  int j = *i;

  if (*t) {
    while (j < (*t)->used && (*t)->buffer[j] != '\n')
      j++;
    if (j == (*t)->used) {
      *i = 0;
      *t = (*t)->next;
      skip_until_newline(t, i);
    }
    else
      // newline was seen
      *i = j;
  }
}

#define DEVICE_FORMAT(filter) (filter == HTML_OUTPUT_FILTER)
#define HTML_OUTPUT_FILTER     0
#define IMAGE_OUTPUT_FILTER    1
#define OUTPUT_STREAM(name)   creat((name), S_IWUSR | S_IRUSR)
#define PS_OUTPUT_STREAM      OUTPUT_STREAM(psFileName)
#define REGION_OUTPUT_STREAM  OUTPUT_STREAM(regionFileName)

/*
 *  emit_troff_output - Write formatted buffer content to the troff
 *                      post-processor data pipeline.
 */

void char_buffer::emit_troff_output(int device_format_selector)
{
  // Handle output for BOTH html and image device formats
  // if 'device_format_selector' is passed as
  //
  //   HTML_FORMAT(HTML_OUTPUT_FILTER)
  //     Buffer data is written to the output stream
  //     with template image names translated to actual image names.
  //
  //   HTML_FORMAT(IMAGE_OUTPUT_FILTER)
  //     Buffer data is written to the output stream
  //     with no translation, for image file creation in the
  //     post-processor.

  int idx = 0;
  char_block *element = head;

  while (element != 0 /* nullptr */)
    write_upto_newline(&element, &idx, device_format_selector);

#if 0
  if (close(stdoutfd) < 0)
    sys_fatal ("close");

  // now we grab fd=1 so that the next pipe cannot use fd=1
  if (stdoutfd == 1) {
    if (dup(2) != stdoutfd)
      sys_fatal ("dup failed to use fd=1");
  }
#endif /* 0 */
}

/*
 *  The image class remembers the position of all images in the
 *  PostScript file and assigns names for each image.
 */

struct imageItem {
  imageItem *next;
  int X1;
  int Y1;
  int X2;
  int Y2;
  char *imageName;
  int resolution;
  int maxx;
  int pageNo;

  imageItem(int x1, int y1, int x2, int y2,
	    int page, int res, int max_width, char *name);
  ~imageItem();
};

/*
 *  imageItem - Constructor.
 */

imageItem::imageItem(int x1, int y1, int x2, int y2,
		     int page, int res, int max_width, char *name)
{
  X1 = x1;
  Y1 = y1;
  X2 = x2;
  Y2 = y2;
  pageNo = page;
  resolution = res;
  maxx = max_width;
  imageName = name;
  next = 0 /* nullptr */;
}

/*
 *  imageItem - Destructor.
 */

imageItem::~imageItem()
{
  if (imageName)
    free(imageName);
}

/*
 *  imageList - A class containing a list of imageItems.
 */

class imageList {
private:
  imageItem *head;
  imageItem *tail;
  int count;
public:
  imageList();
  ~imageList();
  void add(int x1, int y1, int x2, int y2,
	   int page, int res, int maxx, char *name);
  void createImages(void);
  int createPage(int pageno);
  void createImage(imageItem *i);
  int getMaxX(int pageno);
};

/*
 *  imageList - Constructor.
 */

imageList::imageList()
: head(0), tail(0), count(0)
{
}

/*
 *  imageList - Destructor.
 */

imageList::~imageList()
{
  while (head != 0 /* nullptr */) {
    imageItem *i = head;
    head = head->next;
    delete i;
  }
}

/*
 *  createPage - Create image of page `pageno` from PostScript file.
 */

int imageList::createPage(int pageno)
{
  char *s;

  if (currentPageNo == pageno)
    return 0;

  if (currentPageNo >= 1) {
    /*
     *  We need to unlink the files which change each time a new page is
     *  processed.  The final unlink is done by xtmpfile when
     *  pre-grohtml exits.
     */
    unlink(imagePageName);
    unlink(psPageName);
  }

  if (want_progress_report) {
    fprintf(stderr, "[%d] ", pageno);
    fflush(stderr);
  }

#if defined(DEBUGGING)
  if (debugging)
    fprintf(stderr, "creating page %d\n", pageno);
#endif

  s = make_string("psselect -q -p%d %s %s\n",
		   pageno, psFileName, psPageName);
  html_system(s, 1);
  assert(strlen(image_gen) > 0);
  s = make_string("echo showpage | "
		  "%s%s -q -dBATCH -dSAFER "
		  "-dDEVICEHEIGHTPOINTS=792 "
		  "-dDEVICEWIDTHPOINTS=%d -dFIXEDMEDIA=true "
		  "-sDEVICE=%s -r%d %s "
		  "-sOutputFile=%s %s -\n",
		  image_gen,
		  EXE_EXT,
		  (getMaxX(pageno) * image_res) / postscriptRes,
		  image_device,
		  image_res,
		  antiAlias,
		  imagePageName,
		  psPageName);
  html_system(s, 1);
  free(s);
  currentPageNo = pageno;
  return 0;
}

/*
 *  min - Return the minimum of two numbers.
 */

int min(int x, int y)
{
  if (x < y)
    return x;
  else
    return y;
}

/*
 *  max - Return the maximum of two numbers.
 */

int max(int x, int y)
{
  if (x > y)
    return x;
  else
    return y;
}

/*
 *  getMaxX - Return the largest right-hand position for any image
 *            on `pageno`.
 */

int imageList::getMaxX(int pageno)
{
  imageItem *h = head;
  int x = postscriptRes * DEFAULT_LINE_LENGTH;

  while (h != 0 /* nullptr */) {
    if (h->pageNo == pageno)
      x = max(h->X2, x);
    h = h->next;
  }
  return x;
}

/*
 *  createImage - Generate a minimal PNG file from the set of page
 *                images.
 */

void imageList::createImage(imageItem *i)
{
  if (i->X1 != -1) {
    char *s;
    int x1 = max(min(i->X1, i->X2) * image_res / postscriptRes
		   - IMAGE_BORDER_PIXELS,
		 0);
    int y1 = max(image_res * vertical_offset / 72
		   + min(i->Y1, i->Y2) * image_res / postscriptRes
		   - IMAGE_BORDER_PIXELS,
		 0);
    int x2 = max(i->X1, i->X2) * image_res / postscriptRes
	     + IMAGE_BORDER_PIXELS;
    int y2 = image_res * vertical_offset / 72
	     + max(i->Y1, i->Y2) * image_res / postscriptRes
	     + 1 + IMAGE_BORDER_PIXELS;
    if (createPage(i->pageNo) == 0) {
      s = make_string("pnmcut%s %d %d %d %d < %s "
		      "| pnmcrop%s -quiet | pnmtopng%s -quiet %s"
		      "> %s\n",
		      EXE_EXT,
		      x1, y1, x2 - x1 + 1, y2 - y1 + 1,
		      imagePageName,
		      EXE_EXT,
		      EXE_EXT,
		      TRANSPARENT,
		      i->imageName);
      html_system(s, 0);
      free(s);
    }
    else {
      fprintf(stderr, "failed to generate image of page %d\n",
	      i->pageNo);
      fflush(stderr);
    }
#if defined(DEBUGGING)
  }
  else {
    if (debugging) {
      fprintf(stderr, "ignoring image as x1 coord is -1\n");
      fflush(stderr);
    }
#endif
  }
}

/*
 *  add - Add an image description to the imageList.
 */

void imageList::add(int x1, int y1, int x2, int y2,
		    int page, int res, int maxx, char *name)
{
  imageItem *i = new imageItem(x1, y1, x2, y2, page, res, maxx, name);

  if (0 /* nullptr */ == head) {
    head = i;
    tail = i;
  }
  else {
    tail->next = i;
    tail = i;
  }
}

/*
 *  createImages - For each image descriptor on the imageList,
 *                 create the actual image.
 */

void imageList::createImages(void)
{
  imageItem *h = head;

  while (h != 0 /* nullptr */) {
    createImage(h);
    h = h->next;
  }
}

static imageList listOfImages;	// list of images defined by region file

/*
 *  generateImages - Parse the region file and generate images from the
 *                   PostScript file.  The region file contains the
 *                   x1,y1--x2,y2 extents of each image.
 */

static void generateImages(char *region_file_name)
{
  pushBackBuffer *f=new pushBackBuffer(region_file_name);

  while (f->putPB(f->getPB()) != eof) {
    if (f->isString("grohtml-info:page")) {
      int page = f->readInt();
      int x1 = f->readInt();
      int y1 = f->readInt();
      int x2 = f->readInt();
      int y2 = f->readInt();
      int maxx = f->readInt();
      char *name = f->readString();
      int res = postscriptRes;
      listOfImages.add(x1, y1, x2, y2, page, res, maxx, name);
      while (f->putPB(f->getPB()) != '\n'
	     && f->putPB(f->getPB()) != eof)
	(void)f->getPB();
      if (f->putPB(f->getPB()) == '\n')
	(void)f->getPB();
    }
    else {
      /* Write any error messages out to the user. */
      fputc(f->getPB(), stderr);
    }
  }
  fflush(stderr);

  listOfImages.createImages();
  if (want_progress_report) {
    fprintf(stderr, "done\n");
    fflush(stderr);
  }
  delete f;
}

/*
 *  set_redirection - Redirect file descriptor `was` to file descriptor
 *                    `willbe`.
 */

static void set_redirection(int was, int willbe)
{
  // Nothing to do if 'was' and 'willbe' already have same handle.
  if (was != willbe) {
    // Otherwise attempt the specified redirection.
    if (dup2(willbe, was) < 0) {
      // Redirection failed, so issue diagnostic and bail out.
      fprintf(stderr, "failed to replace fd=%d with %d\n", was, willbe);
      if (willbe == STDOUT_FILENO)
	fprintf(stderr,
		"likely that stdout should be opened before %d\n", was);
      sys_fatal("dup2");
    }

    // When redirection has been successfully completed assume redundant
    // handle 'willbe' is no longer required, so close it.
    if (close(willbe) < 0)
      // Issue diagnostic if 'close' fails.
      sys_fatal("close");
  }
}

/*
 *  save_and_redirect - Duplicate file descriptor for `was` on file
 *                      descriptor `willbe`.
 */

static int save_and_redirect(int was, int willbe)
{
  if (was == willbe)
    // No redirection specified; silently bail out.
    return (was);

  // Proceeding with redirection so first save and verify our duplicate
  // handle for 'was'.
  int saved = dup(was);
  if (saved < 0) {
    fprintf(stderr, "unable to get duplicate handle for %d\n", was);
    sys_fatal("dup");
  }

  // Duplicate handle safely established so complete redirection.
  set_redirection(was, willbe);

  // Finally return the saved duplicate descriptor for the original
  // 'was' descriptor.
  return saved;
}

/*
 *  alterDeviceTo - If toImage is set
 *                     the argument list is altered to include
 *                     IMAGE_DEVICE; we invoke groff rather than troff.
 *                  Else
 *                     set -Thtml and groff.
 */

static void alterDeviceTo(int argc, char *argv[], int toImage)
{
  int i = 0;

  if (toImage) {
    while (i < argc) {
      if ((strcmp(argv[i], "-Thtml") == 0) ||
	  (strcmp(argv[i], "-Txhtml") == 0))
	argv[i] = (char *)IMAGE_DEVICE;
      i++;
    }
    argv[troff_arg] = (char *)"groff";	/* rather than troff */
  }
  else {
    while (i < argc) {
      if (strcmp(argv[i], IMAGE_DEVICE) == 0) {
	if (dialect == xhtml)
	  argv[i] = (char *)"-Txhtml";
	else
	  argv[i] = (char *)"-Thtml";
      }
      i++;
    }
    argv[troff_arg] = (char *)"groff";	/* use groff -Z */
  }
}

/*
 *  addArg - Append newarg onto the command list for groff.
 */

char **addArg(int argc, char *argv[], char *newarg)
{
  char **new_argv = (char **)malloc((argc + 2) * sizeof(char *));
  int i = 0;

  if (0 /* nullptr */ == new_argv)
    sys_fatal("malloc");

  if (argc > 0) {
    new_argv[i] = argv[i];
    i++;
  }
  new_argv[i] = newarg;
  while (i < argc) {
    new_argv[i + 1] = argv[i];
    i++;
  }
  argc++;
  new_argv[argc] = 0 /* nullptr */;
  return new_argv;
}

/*
 *  addRegDef - Append a defined register or string onto the command
 *              list for troff.
 */

char **addRegDef(int argc, char *argv[], const char *numReg)
{
  char **new_argv = (char **)malloc((argc + 2) * sizeof(char *));
  int i = 0;

  if (0 /* nullptr */ == new_argv)
    sys_fatal("malloc");

  while (i < argc) {
    new_argv[i] = argv[i];
    i++;
  }
  new_argv[argc] = strsave(numReg);
  argc++;
  new_argv[argc] = 0 /* nullptr */;
  return new_argv;
}

/*
 *  dump_args - Display the argument list.
 */

void dump_args(int argc, char *argv[])
{
  fprintf(stderr, "  %d arguments:", argc);
  for (int i = 0; i < argc; i++)
    fprintf(stderr, " %s", argv[i]);
  fprintf(stderr, "\n");
}

/*
 *  print_args - Print arguments as if issued on the command line.
 */

#if defined(DEBUGGING)

void print_args(int argc, char *argv[])
{
  if (debugging) {
    fprintf(stderr, "executing: ");
    for (int i = 0; i < argc; i++)
      fprintf(stderr, "%s ", argv[i]);
    fprintf(stderr, "\n");
  }
}

#else

void print_args(int, char **)
{
}

#endif

int char_buffer::run_output_filter(int filter, int argc, char **argv)
{
  int pipedes[2];
  PID_T child_pid;
  int wstatus;

  print_args(argc, argv);
  if (pipe(pipedes) < 0)
    sys_fatal("pipe");

#if MAY_FORK_CHILD_PROCESS
  // This is the Unix process model.  To invoke our post-processor,
  // we must 'fork' the current process.

  if ((child_pid = fork()) < 0)
    sys_fatal("fork");

  else if (child_pid == 0) {
    // This is the child process.  We redirect its input file descriptor
    // to read data emerging from our pipe.  There is no point in
    // saving, since we won't be able to restore later!

    set_redirection(STDIN_FILENO, pipedes[0]);

    // The parent process will be writing this data; release the child's
    // writeable handle on the pipe since we have no use for it.

    if (close(pipedes[1]) < 0)
      sys_fatal("close");

    // The IMAGE_OUTPUT_FILTER needs special output redirection...

    if (filter == IMAGE_OUTPUT_FILTER) {
      // ...with BOTH 'stdout' AND 'stderr' diverted to files, the
      // latter so that `generateImages()` can scrape "grohtml-info"
      // from it.

      set_redirection(STDOUT_FILENO, PS_OUTPUT_STREAM);
      set_redirection(STDERR_FILENO, REGION_OUTPUT_STREAM);
    }

    // Now we are ready to launch the output filter.

    execvp(argv[0], argv); // does not return unless it fails
    fatal("cannot execute '%1': %2", argv[0], strerror(errno));
  }

  else {
    // This is the parent process.  We write data to the filter pipeline
    // where the child will read it.  We have no need to read from the
    // input side ourselves, so close it.

    if (close(pipedes[0]) < 0)
      sys_fatal("close");

    // Now redirect the standard output file descriptor to the inlet end
    // of the pipe, and push the formatted data to the filter.

    pipedes[1] = save_and_redirect(STDOUT_FILENO, pipedes[1]);
    emit_troff_output(DEVICE_FORMAT(filter));

    // After emitting all the data we close our connection to the inlet
    // end of the pipe so the child process will detect end of data.

    set_redirection(STDOUT_FILENO, pipedes[1]);

    // Finally, we must wait for the child process to complete.

    if (WAIT(&wstatus, child_pid, _WAIT_CHILD) != child_pid)
      sys_fatal("wait");
  }

#elif MAY_SPAWN_ASYNCHRONOUS_CHILD

  // We do not have `fork` (or we prefer not to use it), but
  // asynchronous processes are allowed, passing data through pipes.
  // This should be okay for most Win32 systems and is preferred to
  // `fork` for starting child processes under Cygwin.

  // Before we start the post-processor we bind its inherited standard
  // input file descriptor to the readable end of our pipe, saving our
  // own standard input file descriptor in `pipedes[0]`.

  pipedes[0] = save_and_redirect(STDIN_FILENO, pipedes[0]);

  // For the Win32 model,
  // we need special provision for saving BOTH 'stdout' and 'stderr'.

  int saved_stdout = dup(STDOUT_FILENO);
  int saved_stderr = STDERR_FILENO;

  // The IMAGE_OUTPUT_FILTER needs special output redirection...

  if (filter == IMAGE_OUTPUT_FILTER) {
    // with BOTH 'stdout' AND 'stderr' diverted to files while saving a
    // duplicate handle for 'stderr'.

    set_redirection(STDOUT_FILENO, PS_OUTPUT_STREAM);
    saved_stderr = save_and_redirect(STDERR_FILENO,
				     REGION_OUTPUT_STREAM);
  }

  // Use an asynchronous spawn request to start the post-processor.

  if ((child_pid = spawnvp(_P_NOWAIT, argv[0], argv)) < 0) {
    fatal("cannot spawn %1: %2", argv[0], strerror(errno));
  }

  // Once the post-processor has been started we revert our 'stdin'
  // to its original saved source, which also closes the readable handle
  // for the pipe.

  set_redirection(STDIN_FILENO, pipedes[0]);

  // if we redirected 'stderr', for use by the image post-processor,
  // then we also need to reinstate its original assignment.

  if (filter == IMAGE_OUTPUT_FILTER)
    set_redirection(STDERR_FILENO, saved_stderr);

  // Now we redirect the standard output to the inlet end of the pipe,
  // and push out the appropiately formatted data to the filter.

  set_redirection(STDOUT_FILENO, pipedes[1]);
  emit_troff_output(DEVICE_FORMAT(filter));

  // After emitting all the data we close our connection to the inlet
  // end of the pipe so the child process will detect end of data.

  set_redirection(STDOUT_FILENO, saved_stdout);

  // And finally, we must wait for the child process to complete.

  if (WAIT(&wstatus, child_pid, _WAIT_CHILD) != child_pid)
    sys_fatal("wait");

#else /* can't do asynchronous pipes! */

  // TODO: code to support an MS-DOS style process model should go here
  fatal("output filtering not supported on this platform");

#endif /* MAY_FORK_CHILD_PROCESS or MAY_SPAWN_ASYNCHRONOUS_CHILD */

  return wstatus;
}

/*
 *  do_html - Set the troff number htmlflip and
 *            write out the buffer to troff -Thtml.
 */

int char_buffer::do_html(int argc, char *argv[])
{
  string s;

  alterDeviceTo(argc, argv, 0);
  argv += troff_arg;		// skip all arguments up to groff
  argc -= troff_arg;
  argv = addArg(argc, argv, (char *)"-Z");
  argc++;

  s = (char *)"-dwww-image-template=";
  s += macroset_template;	// Do not combine these statements,
				// otherwise they will not work.
  s += '\0';			// The trailing '\0' is ignored.
  argv = addRegDef(argc, argv, s.contents());
  argc++;

  if (dialect == xhtml) {
    argv = addRegDef(argc, argv, "-rxhtml=1");
    argc++;
    if (need_eqn) {
      argv = addRegDef(argc, argv, "-e");
      argc++;
    }
  }

#if defined(DEBUGGING)
# define HTML_DEBUG_STREAM  OUTPUT_STREAM(htmlFileName)
  // slight security risk: only enabled if defined(DEBUGGING)
  if (debugging) {
    int saved_stdout = save_and_redirect(STDOUT_FILENO,
					 HTML_DEBUG_STREAM);
    emit_troff_output(DEVICE_FORMAT(HTML_OUTPUT_FILTER));
    set_redirection(STDOUT_FILENO, saved_stdout);
  }
#endif

  return run_output_filter(HTML_OUTPUT_FILTER, argc, argv);
}

/*
 *  do_image - Write out the buffer to troff -Tps.
 */

int char_buffer::do_image(int argc, char *argv[])
{
  string s;

  alterDeviceTo(argc, argv, 1);
  argv += troff_arg;		// skip all arguments up to troff/groff
  argc -= troff_arg;
  argv = addRegDef(argc, argv, "-rps4html=1");
  argc++;

  s = "-dwww-image-template=";
  s += macroset_template;
  s += '\0';
  argv = addRegDef(argc, argv, s.contents());
  argc++;

  // Override local settings and produce a letter-size PostScript page
  // file.
  argv = addRegDef(argc, argv, "-P-pletter");
  argc++;

  if (dialect == xhtml) {
    if (need_eqn) {
      argv = addRegDef(argc, argv, "-rxhtml=1");
      argc++;
    }
    argv = addRegDef(argc, argv, "-e");
    argc++;
  }

#if defined(DEBUGGING)
# define IMAGE_DEBUG_STREAM  OUTPUT_STREAM(troffFileName)
  // slight security risk: only enabled if defined(DEBUGGING)
  if (debugging) {
    int saved_stdout = save_and_redirect(STDOUT_FILENO,
					 IMAGE_DEBUG_STREAM);
    emit_troff_output(DEVICE_FORMAT(IMAGE_OUTPUT_FILTER));
    set_redirection(STDOUT_FILENO, saved_stdout);
  }
#endif

  return run_output_filter(IMAGE_OUTPUT_FILTER, argc, argv);
}

static char_buffer inputFile;

/*
 *  usage - Emit usage message.
 */

static void usage(FILE *stream)
{
  fprintf(stream,
"usage: %s [-epV] [-a anti-aliasing-text-bits] [-D image-directory]"
" [-F font-directory] [-g anti-aliasing-graphics-bits] [-i resolution]"
" [-I image-stem] [-o image-vertical-offset] [-x html-dialect]"
" troff-command troff-argument ...\n"
"usage: %s {-v | --version}\n"
"usage: %s --help\n",
	 program_name, program_name, program_name);
  if (stdout == stream) {
    fputs(
"\n"
"Prepare a troff(1) document for HTML formatting.\n"
"\n"
"This program is not intended to be executed standalone; it is\n"
"normally part of a groff pipeline.  If your need to run it manually\n"
"(e.g., for debugging purposes), give the 'groff' program the\n"
"command-line option '-V' to inspect the arguments with which\n",
	  stream);
    fprintf(stream,
"'%s' is called.  See the grohtml(1) manual page.\n",
	  program_name);
    exit(EXIT_SUCCESS);
  }
}

/*
 *  scanArguments - Scan for all arguments including -P-i, -P-o, -P-D,
 *                  and -P-I.  Return the argument index of the first
 *                  non-option.
 */

static int scanArguments(int argc, char **argv)
{
  const char *cmdprefix = getenv("GROFF_COMMAND_PREFIX");
  if (!cmdprefix)
    cmdprefix = PROG_PREFIX;
  size_t pfxlen = strlen(cmdprefix);
  char *troff_name = new char[pfxlen + strlen("troff") + 1];
  char *s = strcpy(troff_name, cmdprefix);
  s += pfxlen;
  strcpy(s, "troff");
  int c, i;
  static const struct option long_options[] = {
    { "help", no_argument, 0, CHAR_MAX + 1 },
    { "version", no_argument, 0, 'v' },
    { 0 /* nullptr */, 0, 0, 0 }
  };
  while ((c = getopt_long(argc, argv,
	  "+a:bCdD:eF:g:Ghi:I:j:lno:prs:S:UvVx:y", long_options,
	  0 /* nullptr */))
	 != EOF)
    switch(c) {
    case 'a':
      textAlphaBits = min(max(MIN_ALPHA_BITS, atoi(optarg)),
			  MAX_ALPHA_BITS);
      if (textAlphaBits == 3)
	fatal("cannot use 3 bits of antialiasing information");
      break;
    case 'b':
      // handled by post-grohtml (set background color to white)
      break;
    case 'C':
      // handled by post-grohtml (don't write Creator HTML comment)
      break;
    case 'd':
#if defined(DEBUGGING)
      debugging = true;
#endif
      break;
    case 'D':
      image_dir = optarg;
      break;
    case 'e':
      need_eqn = true;
      break;
    case 'F':
      font_path.command_line_dir(optarg);
      break;
    case 'g':
      graphicAlphaBits = min(max(MIN_ALPHA_BITS, atoi(optarg)),
			     MAX_ALPHA_BITS);
      if (graphicAlphaBits == 3)
	fatal("cannot use 3 bits of antialiasing information");
      break;
    case 'G':
      // handled by post-grohtml (don't write CreationDate HTML comment)
      break;
    case 'h':
      // handled by post-grohtml (write headings with font size changes)
      break;
    case 'i':
      image_res = atoi(optarg);
      break;
    case 'I':
      image_template = optarg;
      break;
    case 'j':
      // handled by post-grohtml (set job name for multiple file output)
      break;
    case 'l':
      // handled by post-grohtml (no automatic section links)
      break;
    case 'n':
      // handled by post-grohtml (generate simple heading anchors)
      break;
    case 'o':
      vertical_offset = atoi(optarg);
      break;
    case 'p':
      want_progress_report = true;
      break;
    case 'r':
      // handled by post-grohtml (no header and footer lines)
      break;
    case 's':
      // handled by post-grohtml (use font size n as the HTML base size)
      break;
    case 'S':
      // handled by post-grohtml (set file split level)
      break;
    case 'U':
      // handled by post-grohtml (charset UTF-8)
      break;
    case 'v':
      printf("GNU pre-grohtml (groff) version %s\n", Version_string);
      exit(EXIT_SUCCESS);
    case 'V':
      // handled by post-grohtml (create validator button)
      break;
    case 'x':
      // html dialect
      if (strcmp(optarg, "x") == 0)
	dialect = xhtml;
      else if (strcmp(optarg, "4") == 0)
	dialect = html4;
      else
	warning("unsupported HTML dialect: '%1'", optarg);
      break;
    case 'y':
      // handled by post-grohtml (create groff signature)
      break;
    case CHAR_MAX + 1: // --help
      usage(stdout);
      break;
    case '?':
      usage(stderr);
      exit(EXIT_FAILURE);
      break;
    default:
      break;
    }

  i = optind;
  while (i < argc) {
    if (strcmp(argv[i], troff_name) == 0)
      troff_arg = i;
    else if (argv[i][0] != '-')
      return i;
    i++;
  }
  delete[] troff_name;

  return argc;
}

/*
 *  makeTempFiles - Name the temporary files.
 */

static void makeTempFiles(void)
{
#if defined(DEBUGGING)
  psFileName = DEBUG_FILE("prehtml-ps");
  regionFileName = DEBUG_FILE("prehtml-region");
  imagePageName = DEBUG_FILE("prehtml-page");
  psPageName = DEBUG_FILE("prehtml-psn");
  troffFileName = DEBUG_FILE("prehtml-troff");
  htmlFileName = DEBUG_FILE("prehtml-html");
#else /* not DEBUGGING */
  FILE *f;

  // psPageName contains a single page of PostScript.
  f = xtmpfile(&psPageName, PS_TEMPLATE_LONG, PS_TEMPLATE_SHORT, true);
  if (0 /* nullptr */ == f)
    sys_fatal("xtmpfile");
  fclose(f);

  // imagePageName contains a bitmap image of a single PostScript page.
  f = xtmpfile(&imagePageName, PAGE_TEMPLATE_LONG, PAGE_TEMPLATE_SHORT,
	       true);
  if (0 /* nullptr */ == f)
    sys_fatal("xtmpfile");
  fclose(f);

  // psFileName contains a PostScript file of the complete document.
  f = xtmpfile(&psFileName, PS_TEMPLATE_LONG, PS_TEMPLATE_SHORT, true);
  if (0 /* nullptr */ == f)
    sys_fatal("xtmpfile");
  fclose(f);

  // regionFileName contains a list of the images and their boxed
  // coordinates.
  f = xtmpfile(&regionFileName,
	       REGION_TEMPLATE_LONG, REGION_TEMPLATE_SHORT, true);
  if (0 /* nullptr */ == f)
    sys_fatal("xtmpfile");
  fclose(f);
#endif /* not DEBUGGING */
}

static bool do_file(const char *filename)
{
  FILE *fp;

  current_filename = filename;
  if (strcmp(filename, "-") == 0)
    fp = stdin;
  else {
    fp = fopen(filename, "r");
    if (0 /* nullptr*/ == fp) {
      error("unable to open '%1': %2", filename, strerror(errno));
      return false;
    }
  }
  inputFile.read_file(fp);
  if (fp != stdin)
    if (fclose(fp) != 0)
      sys_fatal("fclose");
  current_filename = 0 /* nullptr */;
  return true;
}

static void cleanup(void)
{
  free(const_cast<char *>(image_gen));
}

int main(int argc, char **argv)
{
#ifdef CAPTURE_MODE
  fprintf(stderr, "%s: invoked with %d arguments ...\n", argv[0], argc);
  for (int i = 0; i < argc; i++)
    fprintf(stderr, "%2d: %s\n", i, argv[i]);
  FILE *dump = fopen(DEBUG_FILE("pre-html-data"), "wb");
  if (dump != 0 /* nullptr */) {
    while((int ch = fgetc(stdin)) >= 0)
      fputc(ch, dump);
    fclose(dump);
  }
  exit(EXIT_FAILURE);
#endif /* CAPTURE_MODE */
  program_name = argv[0];
  if (atexit(&cleanup) != 0)
    sys_fatal("atexit");
  int operand_index = scanArguments(argc, argv);
  image_gen = strsave(get_image_generator());
  if (0 == image_gen)
    fatal("'image_generator' directive not found in file '%1'",
	  devhtml_desc);
  postscriptRes = get_resolution();
  if (postscriptRes < 1) // TODO: what's a more sane minimum value?
    fatal("'res' directive missing or invalid in file '%1'",
	  devps_desc);
  setupAntiAlias();
  checkImageDir();
  makeFileName();
  bool have_file_operand = false;
  while (operand_index < argc) {
    if (argv[operand_index][0] != '-') {
      if(!do_file(argv[operand_index]))
	exit(EXIT_FAILURE);
      have_file_operand = true;
    }
    operand_index++;
  }

  if (!have_file_operand)
    do_file("-");
  makeTempFiles();
  int wstatus = inputFile.do_image(argc, argv);
  if (wstatus == 0) {
    generateImages(regionFileName);
    wstatus = inputFile.do_html(argc, argv);
  }
  else
    if (WEXITSTATUS(wstatus) != 0)
      // XXX: This is a crappy suggestion.  See Savannah #62673.
      fatal("'%1' exited with status %2; re-run '%1' with a different"
	    " output driver to see diagnostic messages", argv[0],
	    WEXITSTATUS(wstatus));
  exit(EXIT_SUCCESS);
}

// Local Variables:
// fill-column: 72
// mode: C++
// End:
// vim: set cindent noexpandtab shiftwidth=2 textwidth=72:
