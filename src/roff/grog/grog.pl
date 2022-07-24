#! /usr/bin/env perl
# grog - guess options for groff command
# Inspired by doctype script in Kernighan & Pike, Unix Programming
# Environment, pp 306-8.

# Copyright (C) 1993-2020 Free Software Foundation, Inc.
# Written by James Clark.
# Rewritten with Perl by Bernd Warken <groff-bernd.warken-72@web.de>.
# The macros for identifying the devices were taken from Ralph
# Corderoy's 'grog.sh' of 2006.

# This file is part of 'grog', which is part of 'groff'.

# 'groff' is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.

# 'groff' is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see
# <http://www.gnu.org/licenses/gpl-2.0.html>.

########################################################################

require v5.6;

use warnings;
use strict;

# $Bin is the directory where this script is located
use FindBin;

my $before_make;	# script before run of 'make'
{
  my $at = '@';
  $before_make = 1 if '@VERSION@' eq "${at}VERSION${at}";
}


our %at_at;
my $grog_dir;

if ($before_make) { # before installation
  my $grog_source_dir = $FindBin::Bin;
  $at_at{'BINDIR'} = $grog_source_dir;
# $grog_dir = $grog_source_dir;
  $grog_dir = '.';
  my $top = $grog_source_dir . '/../../../';
  open FILE, '<', $top . 'VERSION' ||
    die 'grog: could not open file "VERSION"';
  my $version = <FILE>;
  chomp $version;
  close FILE;
  open FILE, '<', $top . 'REVISION' ||
    die 'grog: could not open file "REVISION"';
  my $revision = <FILE>;
  chomp $revision;
  $at_at{'GROFF_VERSION'} = $version . '.' . $revision;
} else { # after installation}
  $at_at{'GROFF_VERSION'} = '@VERSION@';
  $at_at{'BINDIR'} = '@BINDIR@';
  $grog_dir = '@grog_dir@';
} # before make

die 'grog: "' . $grog_dir . '" does not exist or is not a directory'
  unless -d $grog_dir;


#############
# import subs

unshift(@INC, $grog_dir);
require 'subs.pl';


##########
# run subs

&handle_args();
&handle_file_ext(); # see $tmac_ext for gotten value
&handle_whole_files();
&make_groff_device();
&make_groff_preproc();
&make_groff_tmac_man_ms() || &make_groff_tmac_others();
&make_groff_line_rest();


1;
# Local Variables:
# mode: CPerl
# End:
