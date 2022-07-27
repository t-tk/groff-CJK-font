// -*- C++ -*-
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
#define ENABLE_UCSRANGE
// A function of this type can be registered to define the semantics of
// arbitrary commands in a font DESC file.
typedef void (*FONT_COMMAND_HANDLER)(const char *,	// command
				     const char *,	// arg
				     const char *,	// file
				     int);		// lineno

// A glyph is represented by a font-independent 'glyph *' pointer.  The
// functions name_to_glyph and number_to_glyph return such a pointer.
//
// There are two types of glyphs:
//
//   - those with a name, and among these in particular:
//     'charNNN' denoting a single 'char' in the input character set,
//     'uXXXX' denoting a Unicode character,
//
//   - those with a number, referring to the font-dependent glyph with
//     the given number.

// The statically allocated information about a glyph.
//
// This is an abstract class; only its subclass 'charinfo' is
// instantiated.  'charinfo' exists in two versions: one in
// roff/troff/input.cpp for troff, and one in
// libs/libgroff/nametoindex.cpp for the preprocessors and the
// postprocessors.
struct glyph {
  int index;			// A font-independent integer value.
  int number;			// Glyph number or -1.
  friend class character_indexer;
};

#define UNDEFINED_GLYPH ((glyph *) 0)

// The next three functions exist in two versions: one in
// roff/troff/input.cpp for troff, and one in
// libs/libgroff/nametoindex.cpp for the preprocessors and the
// postprocessors.
extern glyph *name_to_glyph(const char *);	// Convert the glyph with
			// the given name (arg1) to a 'glyph' object.  This
			// has the same semantics as the groff escape sequence
			// \C'name'.  If such a 'glyph' object does not yet
			// exist, a new one is allocated.
extern glyph *number_to_glyph(int);	// Convert the font-dependent glyph
			// with the given number (in the font) to a 'glyph'
			// object.  This has the same semantics as the groff
			// escape sequence \N'number'.  If such a 'glyph'
			// object does not yet exist, a new one is allocated.
extern const char *glyph_to_name(glyph *);	// Convert the given
			// glyph back to its name.  Return null pointer
			// if the glyph doesn't have a name.
inline int glyph_to_number(glyph *);	// Convert the given glyph back to
			// its number.  Return -1 if it does not designate
			// a numbered character.
inline int glyph_to_index(glyph *);	// Return the unique index that is
			// associated with the given glyph. It is >= 0.
extern int glyph_to_unicode(glyph *);	// Convert the given glyph to its
			// Unicode codepoint.  Return -1 if it does not
			// designate a Unicode character.

inline int glyph_to_number(glyph *g)
{
  return g->number;
}

inline int glyph_to_index(glyph *g)
{
  return g->index;
}

// Types used in non-public members of 'class font'.
struct font_kern_list;
struct font_char_metric;
struct font_widths_cache;

// A 'class font' instance represents the relevant information of a font of
// the given device.  This includes the set of glyphs represented by the
// font, and metrics for each glyph.
class font {
public:
  enum {		// The valid argument values of 'has_ligature'.
    LIG_ff = 1,
    LIG_fi = 2,
    LIG_fl = 4,
    LIG_ffi = 8,
    LIG_ffl = 16
  };

  virtual ~font();	// Destructor.
  bool contains(glyph *);	// This font contains the given glyph.
  bool is_special();	// This font is searched for glyphs not defined
			// in the current font.  See section 'Special
			// Fonts' in the groff Texinfo manual.  Used by
			// make_glyph_node().
  int get_width(glyph *, int);	// A rectangle represents the shape of the
			// given glyph (arg1) at the given point size
			// (arg2).  Return the horizontal dimension of this
			// rectangle.
  int get_height(glyph *, int);	// A rectangle represents the shape of the
			// given glyph (arg1) at the given point size
			// (arg2).  Return the distance between the base
			// line and the top of this rectangle.
			// This is often also called the 'ascent' of the
			// glyph.  If the top is above the baseline, this
			// value is positive.
  int get_depth(glyph *, int);	// A rectangle represents the shape of the
			// given glyph (arg1) at the given point size
			// (arg2).  Return the distance between the base
			// line and the bottom of this rectangle.
			// This is often also called the 'descent' of the
			// glyph.  If the bottom is below the baseline,
			// this value is positive.
  int get_space_width(int);	// Return the normal width of a space at the
			// given point size.
  int get_character_type(glyph *);	// Return a bit mask describing the
			// shape of the given glyph.  Bit 0 is set if the
			// character has a descender.  Bit 1 is set if the
			// character has a tall glyph.  See groff manual,
			// description of \w and the 'ct' register.
  int get_kern(glyph *, glyph *, int);	// Return the kerning between the
			// given glyphs (arg1 and arg2), both at the given
			// point size (arg3).
  int get_skew(glyph *, int, int);	// A rectangle represents the shape
			// of the given glyph (arg1) at the given point size
			// (arg2).  For slanted fonts like Times-Italic, the
			// optical vertical axis is naturally slanted.  The
			// natural slant value (measured in degrees;
			// positive values mean aslant to the right) is
			// specified in the font's description file (see
			// member variable SLANT below).  In addition to
			// this, any font can be artificially slanted.  This
			// artificial slant value (arg3, measured in
			// degrees; positive values mean a slant to the
			// right) is specified with the \S escape.
			//
			// Return the skew value which is the horizontal
			// distance between the upper left corner of the
			// glyph box and the upper left corner of the glyph
			// box thought to be slanted by the sum of the
			// natural and artificial slant.  It basically means
			// how much an accent must be shifted horizontally
			// to put it on the optical axis of the glyph.
  bool has_ligature(int);	// This font has the given ligature type
			// (one of LIG_ff, LIG_fi, ...).
  int get_italic_correction(glyph *, int);	// If the given glyph (arg1)
			// at the given point size (arg2) is followed by an
			// unslanted glyph, some horizontal white space may
			// need to be inserted in between.  See the groff
			// manual, description of \/.  Return the amount
			// (width) of this white space.
  int get_left_italic_correction(glyph *, int);	// If the given glyph (arg1)
			// at the given point size (arg2) is preceded by an
			// unslanted roman glyph, some horizontal white
			// space may need to be inserted in between.  See
			// the groff manual, description of \,.  Return the
			// amount (width) of this white space.
  int get_subscript_correction(glyph *, int);	// If the given glyph (arg1)
			// at the given point size (arg2)is followed by a
			// subscript glyph, the horizontal position may need
			// to be advanced by some (possibly negative)
			// amount.  See groff manual, description of \w and
			// the 'ssc' register.  Return this amount.
  void set_zoom(int);	// Set the font's zoom factor * 1000.  Must be a
  			// non-negative value.
  int get_zoom();	// Return the font's zoom factor * 1000.
  int get_code(glyph *);	// Return the code point in the physical
			// font of the given glyph.
  const char *get_special_device_encoding(glyph *);	// Return
			// special device-dependent information about
			// the given glyph.  Return null pointer if
			// there is no special information.
  const char *get_name();	// Return the name of this font.
  const char *get_internal_name();	// Return the 'internalname'
			// attribute of this font or null pointer if it
			// has none.
  const char *get_image_generator();	// Return the 'image_generator'
			// attribute of this font or null pointer if it
			// has none.
  static bool scan_papersize(const char *, const char **,
			     double *, double *); // Parse the
			// 'papersize' directive in the DESC file name
			// given in arg1.  Update arg2 with the name
			// of the paper format and arg3 and arg4 with
			// its length and width, respectively.  Return
			// whether paper size was successfully set.
  static font *load_font(const char *, bool = false); // Load the font
			// description file with the given name (arg1)
			// and return a pointer to a 'font' object.  If
			// arg2 is true, only the part of the font
			// description file before the 'charset' and
			// 'kernpairs' sections is loaded.  Return null
			// pointer in case of failure.
  static void command_line_font_dir(const char *);	// Prepend given
			// path (arg1) to the list of directories in which
			// to look up fonts.
  static FILE *open_file(const char *, char **);	// Open
			// a font file with the given name (arg1),
			// searching along the current font path.  If
			// arg2 points to a string pointer, set it to
			// the found file name (this depends on the
			// device also).  Return the opened file.  If
			// not found, arg2 is unchanged, and a null
			// pointer is returned.

  // Open the DESC file (depending on the device) and initialize some
  // static variables with info from there.
  static const char *load_desc();
  static FONT_COMMAND_HANDLER
    set_unknown_desc_command_handler(FONT_COMMAND_HANDLER);	// Register
			// a function which defines the semantics of
			// arbitrary commands in the font DESC file.
  // Now the variables from the DESC file, shared by all fonts.
  static int res;	// The 'res' attribute given in the DESC file.
  static int hor;	// The 'hor' attribute given in the DESC file.
  static int vert;	// The 'vert' attribute given in the DESC file.
  static int unitwidth;	// The 'unitwidth' attribute given in the DESC file.
  static int paperwidth;	// The 'paperwidth' attribute given in the
			// DESC file, or derived from the 'papersize'
			// attribute given in the DESC file.
  static int paperlength;	// The 'paperlength' attribute given in the
			// DESC file, or derived from the 'papersize'
			// attribute given in the DESC file.
  static const char *papersize;
  static int biggestfont;	// The 'biggestfont' attribute given in the
			// DESC file.
  static int spare2;
  static int sizescale;	// The 'sizescale' attribute given in the DESC file.
  static bool has_tcommand;	// DESC file has 'tcommand' directive.
  static bool use_unscaled_charwidths;	// DESC file has
			// 'unscaled_charwidths' directive.
  static bool pass_filenames;	// DESC file has 'pass_filenames'
			// directive.
  static bool use_charnames_in_special;	// DESC file has
			// 'use_charnames_in_special' directive.
  static bool is_unicode; // DESC file has the 'unicode' directive.
  static const char *image_generator;	// The 'image_generator' attribute
			// given in the DESC file.
  static const char **font_name_table;	// The 'fonts' attribute given
			// in the DESC file, as a null
			// pointer-terminated array of strings.
  static const char **style_table;	// The 'styles' attribute given
			// in the DESC file, as a null
			// pointer-terminated array of strings.
  static const char *family;	// The 'family' attribute given in the DESC
			// file.
  static int *sizes;	// The 'sizes' attribute given in the DESC file, as
			// an array of intervals of the form { lower1,
			// upper1, ... lowerN, upperN, 0 }.

private:
  unsigned ligatures;	// Bit mask of available ligatures.  Used by
			// has_ligature().
  font_kern_list **kern_hash_table;	// Hash table of kerning pairs.
			// Used by get_kern().
  int space_width;	// The normal width of a space.  Used by
			// get_space_width().
  bool special;		// See public is_special() above.
  char *name;		// The name of this font.  Used by get_name().
  char *internalname;	// The 'internalname' attribute of this font, or
			// a null pointer.  Used by get_internal_name().
  double slant;		// The natural slant angle (in degrees) of this font.
  int zoom;		// The font's magnification, multiplied by 1000.
			// Used by scale().  A zero value means 'no zoom'.
  int *ch_index;	// Conversion table from font-independent character
			// indices to indices for this particular font.
  int nindices;
  font_char_metric *ch;	// Metrics information for every character in this
			// font (if !is_unicode) or for just some characters
			// (if is_unicode).  The indices of this array are
			// font-specific, found as values in ch_index[].
#ifdef ENABLE_UCSRANGE
  // font metric for wchar
  font_char_metric *wch;
  // get font metric for wchar indexed by uc
  font_char_metric *get_font_wchar_metric(int uc);
#endif
  int ch_used;
  int ch_size;
  font_widths_cache *widths_cache;	// A cache of scaled character
			// widths.  Used by the get_width() function.

  static FONT_COMMAND_HANDLER unknown_desc_command_handler;	// A
			// function defining the semantics of arbitrary
			// commands in the DESC file.
  enum { KERN_HASH_TABLE_SIZE = 503 };	// Size of the hash table of kerning
			// pairs.

  // These methods add new characters to the ch_index[] and ch[] arrays.
  void add_entry(glyph *,			// glyph
		 const font_char_metric &);	// metric
  void copy_entry(glyph *,			// new_glyph
		  glyph *);			// old_glyph
  void alloc_ch_index(int);			// index
  void extend_ch();
  void compact();

  void add_kern(glyph *, glyph *, int);	// Add to the kerning table a
			// kerning amount (arg3) between two given glyphs
			// (arg1 and arg2).
  static int hash_kern(glyph *, glyph *);	// Return a hash code for
			// the pair of glyphs (arg1 and arg2).

  /* Returns w * pointsize / unitwidth, rounded to the nearest integer.  */
  int scale(int w, int pointsize);
  static bool unit_scale(double *, char); // Convert value in arg1 from
			// the given unit (arg2; possible values are
			// 'i', 'c', 'p', and 'P' as documented in the
			// info file of groff, section 'Measurements')
			// to inches.  Store result in arg1 and return
			// whether conversion was successful.
  virtual void handle_unknown_font_command(const char *,	// command
					   const char *,	// arg
					   const char *,	// file
					   int);		// lineno

protected:
  font(const char *);	// Initialize a font with the given name.

  // Load the font description file with the name in member variable
  // `name` into this object.  If arg1 is true, only the part of the
  // font description file before the 'charset' and 'kernpairs' sections
  // is loaded.  Return success/failure status of load.
  bool load(bool = false);
};

// Local Variables:
// fill-column: 72
// mode: C++
// End:
// vim: set cindent noexpandtab shiftwidth=2 textwidth=72:
