#!/usr/bin/perl -w
#
# BuildFoundries: Given a Foundry file, generate groff font description
# files and a "download" file so gropdf can embed fonts in PDF output.
#
# Copyright (C) 2011-2020 Free Software Foundation, Inc.
#      Written by Deri James <deri@chuzzlewit.myzen.co.uk>
#
# This file is part of groff.
#
# groff is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# groff is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use Getopt::Long;

my $pathsep='@PATH_SEPARATOR@';

my $check=0;
my $dirURW='';
my $beStrict=0;

GetOptions("check" => \$check, "dirURW=s" => \$dirURW,
	   "strict" => \$beStrict);

(my $progname = $0) =~s @.*/@@;
my $where=shift||'';
my @d=(split(':',shift||'../devps'));
my $devps=\@d;
chdir $where if $where ne '';
my (%flg,@downloadpreamble,%download);
my $GSpath=FindGSpath();
my $lct=0;
my $foundry='';	# the default foundry
my $notFoundFont=0;

if ($check)
{
    CheckFoundry("Foundry.in");
    exit $notFoundFont;
}
else
{
    LoadDownload("download"); # not required
    LoadFoundry("Foundry");
    WriteDownload();
}
exit 0;



sub LoadFoundry
{
    my $fn=shift;
    my $foundrypath;
    $notFoundFont=0;

    open(F,"<$fn") or Die("file '$fn' not found or not readable");

    while (<F>)
    {
	chomp;
	$lct++;
	s/\r$//;	# in case edited in windows

	s/\s*#.*?$//;	# remove comments

	next if $_ eq '';

	if (m/^[A-Za-z]=/)
	{
	    my (@f)=split('=');
	    $flg{$f[0]}=$f[1];
	    next;
	}

	my (@r)=split('\|');

	if (lc($r[0]) eq 'foundry')
	{
	    Warn("\nThe path(s) used for searching:\n".join(':',@{$foundrypath})."\n") if $notFoundFont;
	    $foundry=uc($r[1]);
	    $foundrypath=[];
	    push(@{$foundrypath},$dirURW) if $dirURW;
	    push(@{$foundrypath},(split(':',$r[2])),@{$devps});
	    foreach my $j (0..$#{$foundrypath})
	    {
		if (defined($foundrypath->[$j])
		    && $foundrypath->[$j]=~m'\s*\(gs\)')
		{
		    splice(@{$foundrypath},$j,1,@{$GSpath});
		}
	    }
	    $notFoundFont=0;
	}
	else
	{
	    # 0=groff font name
	    # 1=IsBase Y/N (one of PDFs 14 base fonts)
	    # 2=afmtodit flag
	    # 3=map file
	    # 4=encoding file
	    # 5=font file

	    my $gfont=($foundry eq '')?$r[0]:"$foundry-$r[0]";

	    if ($r[2] eq '')
	    {
		# Don't run afmtodit; just copy the groff font
		# description file for grops.
		my $gotf=1;
		my $gropsfnt=LocateFile($devps,$r[0],0);
		if ($gropsfnt ne '' and -r "$gropsfnt")
		{
		    my $psfont=UseGropsVersion($gropsfnt);
		    # To be embeddable in PDF, the font file name itself
		    # needs to be located and written to "download".
		    if (!PutDownload($psfont,
				     LocatePF($foundrypath,$r[5]),
					      uc($r[1])))
		    {
			if (uc($r[1]) ne 'Y')
			{
			    $gotf=0;
			    my $fns=join(', ',split('!',$r[5]));
			    Warn("groff font '$gfont' will not be"
				 . " available for PDF output; unable"
				 . " to locate font file(s): $fns");
			    $notFoundFont=1;
			    unlink $gfont;
			}
		    }
		    Notice("Copied grops font $gfont...") if $gotf;

		}
		else
		{
		    Warn("Can't read grops font '$r[0]' for Foundry '$foundry'");
		}
	    }
	    else
	    {
		# Use afmtodit to create a groff font description file.
		my $afmfile=LocateAF($foundrypath,$r[5]);
		if (!$afmfile) {
		    my $sub=\&Warn;
		    $sub=\&Die if ($beStrict);
		    &$sub("cannot locate AFM file for font '$gfont'");
		    next;
		}
		my $psfont=RunAfmtodit($gfont,$afmfile,$r[2],$r[3],$r[4]);

		if ($psfont)
		{
		    if (!PutDownload($psfont,LocatePF($foundrypath,$r[5]),uc($r[1])))
		    {
			unlink $gfont;	# Unable to find the postscript file for the font just created by afmtodit
		    }
		    else
		    {
			Notice("Generated $gfont...");
		    }
		}
		else
		{
		    Warn("Failed to create groff font '$gfont' by running afmtodit");
		    $notFoundFont=1;
		}
	    }
	}
    }

    close(F);
    Warn("\nThe path(s) used for searching:\n".join(':',@{$foundrypath})."\n") if $notFoundFont;
}

sub RunAfmtodit
{
    my $gfont=shift;
    my $afmfile=shift;
    my $flags=shift;
    my $map=shift||'';
    my $enc=shift||'';
    my $psfont='';

    $enc="-e 'enc/$enc'" if $enc;
    $map="'map/$map'" if $map;

    my $cmd='afmtodit -c -dDESC';

    foreach my $f (split('',$flags))
    {
	if (!exists($flg{$f}))
	{
	    Warn("Can't use undefined flag '$f' in calling afmtodit for groff font '$gfont'");
	    return('');
	}

	$cmd.=" $flg{$f}";
    }

    system("$cmd $enc '$afmfile' $map $gfont");

    if ($?)
    {
	unlink $gfont;
	return('');
    }

    if (open(GF,"<$gfont"))
    {
	my (@gf)=(<GF>);
	my @ps=grep(/^internalname /,@gf);
	if ($#ps == 0)	# Just 1 match
	{
	    (undef,$psfont)=split(' ',$ps[0],2);
	    chomp($psfont);
	}
	else
	{
	    Warn("Unexpected format for grops font '$gfont' for Foundry '$foundry' - ignoring");
	}

	close(GF);
    }

    return($psfont);
}

sub LocateAF
{
    my $path=shift;
    my $file=shift;

    return(LocateFile($path,$file,1));
}

sub LocatePF
{
    my $path=shift;
    my $file=shift;

    return(LocateFile($path,$file,0));
}

sub LocateFile
{
    my $path=shift;
    my $files=shift;
    my $tryafm=shift;
    return(substr($files,1)) if substr($files,0,1) eq '*';

    foreach my $p (@{$path})
    {
        next if !defined($p) or $p eq ';' or $p eq ':';
        $p=~s/^\s+//;
        $p=~s/\s+$//;

        next if $p=~m/^\%rom\%/;	# exclude %rom% paths (from (gs))

        foreach my $file (reverse(split('!',$files)))
        {
            if ($tryafm)
            {
                if (!($file=~s/\..+$/.afm/))
                {
                    # no extenaion
                    $file.='.afm';
                }
            }

            if ($file=~m'/')
            {
                # path given with file name so no need to search the paths

                if (-r $file)
                {
                    return($file);
                }

                if ($tryafm and $file=~s'type1/'afm/'i)
                {
                    if (-r "$file")
                    {
                        return($file);
                    }
                }

                return('');
            }

            if ($path eq '(tex)')
            {
                my $res=`kpsewhich $file`;
                return '' if $?;
                chomp($res);
                return($res);
            }

            if (-r "$p/$file")
            {
                return("$p/$file");
            }

            my $ap=$p;

            if ($tryafm and $ap=~s'type1/'afm/'i)
            {
                if (-r "$ap/$file")
                {
                    return("$ap/$file");
                }
            }
        }
    }

    return('');
}

sub FindGSpath
{
    my (@res)=`@GROFF_GHOSTSCRIPT_INTERPRETERS@ -h 2>/dev/null`;
    return '' if $?;
    my $buildpath=[];
    my $stg=1;

    foreach my $l (@res)
    {
	chomp($l);

	if ($stg==1 and $l=~m/^Search path:/)
	{
	    $stg=2;
	}
	elsif ($stg == 2)
	{
	    if (substr($l,0,1) ne ' ')
	    {
		$stg=3;
	    }
	    else
	    {
		$l=~s/^\s+//;
                $pathsep=';' if substr($l,-1) eq ';';
                push(@{$buildpath},(split("$pathsep",$l)));
	    }
	}
    }

    return($buildpath);
}

sub UseGropsVersion
{
    my $gfont=shift;
    my $psfont='';
    my (@gfa)=split('/',$gfont);
    my $gfontbase=pop(@gfa);

    if (open(GF,"<$gfont"))
    {
	my (@gf)=(<GF>);
	my @ps=grep(/^internalname /,@gf);
	if ($#ps == 0)	# Just 1 match
	{
	    (undef,$psfont)=split(' ',$ps[0],2);
	    chomp($psfont);
	}
	else
	{
	    Warn("Unexpected format for grops font '$gfont' for Foundry '$foundry' - ignoring");
	}

	close(GF);

	if ($psfont)
	{
	    if (open(GF,">$gfontbase"))
	    {
		local $"='';
		print GF "@gf";
		close(GF);
	    }
	    else
	    {
		$psfont='';
		Warn("Failed to create new font '$gfont' for Foundry '$foundry'");
	    }
	}
	else
	{
	    Warn("Failed to locate postscript internalname in grops font '$gfont' for Foundry '$foundry'");
	}

	close(GF);
    }
    else
    {
	Warn("Failed to open grops font '$gfont' for Foundry '$foundry'");
    }

    return($psfont);
}

sub PutDownload
{
    my $psfont=shift;
    my $pffile=shift;
    my $IsBase14=shift;
    my $key="$foundry $psfont";

    delete($download{$key}), return 0 if ($pffile eq '');

    $pffile='*'.$pffile if $IsBase14 eq 'Y'; # This signals to gropdf to only edmbed if -e given
    $download{$key}=$pffile;

    return 1;
}

sub LoadDownload
{
    my $fn=shift;

    return if !open(F,"<$fn");

    while (<F>)
    {
	chomp;
	s/\r$//;	# in case edited in windows

	if (substr($_,0,1) eq '#' or $_ eq '')
	{
	    # Preserve comments at top of download file

	    push(@downloadpreamble,$_);
	    next;
	}

	s/\s*#.*?$//;	# remove comments

	next if $_ eq '';

	my (@r)=split(/\t+/);
	my $key=$r[1];
	$key="$r[0] $r[1]";
	$download{$key}=$r[2];
    }

    close(F);
}

sub WriteDownload
{
    print join("\n",@downloadpreamble),"\n";

    foreach my $k (sort keys %download)
    {
	my ($f,$ps)=split(/ /,$k);
	print "$f\t$ps\t$download{$k}\n";
    }
}

sub Notice {
    my $msg=shift;
    Msg("notice: $msg");
}

sub Warn {
    my $msg=shift;
    Msg("warning: line $lct: $msg");
}

sub Die {
    my $msg=shift;
    Msg("error: $msg");
    exit 2;
}

sub Msg {
    my $msg=shift;
    print STDERR "$progname: $msg\n";
}

sub CheckFoundry
{
    my $fn=shift;
    my $foundrypath=[];
    $notFoundFont=0;

    open(F,"<$fn") or Die("file '$fn' not found or not readable");

    while (<F>)
    {
	chomp;
	s/\r$//;	# in case edited in windows

	s/\s*#.*?$//;	# remove comments

	next if $_ eq '';

	if (m/^[A-Za-z]=/)
	{
	    next;
	}

	my (@r)=split('\|');

	if (lc($r[0]) eq 'foundry')
	{
	    $foundry=uc($r[1]);
	    $foundrypath=[];
	    push(@{$foundrypath},$dirURW) if $dirURW;
	    push(@{$foundrypath},(split(':',$r[2])),$devps);
	    foreach my $j (0..$#{$foundrypath})
	    {
		if ($foundrypath->[$j]=~m'\s*\(gs\)')
		{
		    splice(@{$foundrypath},$j,1,@{$GSpath});
		}
	    }
	    $notFoundFont=0;
	}
	else
	{
	    # 0=groff font name
	    # 1=IsBase Y/N (one of PDFs 14 base fonts)
	    # 2=afmtodit flag
	    # 3=map file
	    # 4=encoding file
	    # 5=font file

	    my $gfont=($foundry eq '')?$r[0]:"$foundry-$r[0]";

	    if ($r[2] eq '')
	    {
		# Don't run afmtodit, just copy the grops font file

		my $gotf=1;
		my $gropsfnt=LocateFile([$devps],$r[0],0);

		if ($gropsfnt ne '' and -r "$gropsfnt")
		{

		}
		else
		{
                    $notFoundFont|=1;
		}
	    }
	    else
	    {
		# We need to run afmtodit to create this groff font
		$notFoundFont|=2 if !LocateAF($foundrypath,$r[5]);
		$notFoundFont|=1 if !LocatePF($foundrypath,$r[5]);
	    }
	}
    }

    close(F);
}

# Local Variables:
# fill-column: 72
# mode: CPerl
# End:
# vim: set cindent noexpandtab shiftwidth=4 softtabstop=4 textwidth=72:
