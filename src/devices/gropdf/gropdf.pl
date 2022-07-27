#!@PERL@ -w
#
#	gropdf		: PDF post processor for groff
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
# groff is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

use strict;
use Getopt::Long qw(:config bundling);

use constant
{
    WIDTH		=> 0,
    CHRCODE		=> 1,
    PSNAME		=> 2,
    ASSIGNED		=> 3,
    USED		=> 4,
};

my $gotzlib=0;

my $rc = eval
{
  require Compress::Zlib;
  Compress::Zlib->import();
  1;
};

if($rc)
{
  $gotzlib=1;
}
else
{
    Msg(0,"Perl module Compress::Zlib not available - cannot compress this pdf");
}

my %cfg;

$cfg{GROFF_VERSION}='@VERSION@';
$cfg{GROFF_FONT_PATH}='@GROFF_FONT_DIR@';
$cfg{RT_SEP}='@RT_SEP@';
binmode(STDOUT);

my @obj;	# Array of PDF objects
my $objct=0;	# Count of Objects
my $fct=0;	# Output count
my %fnt;	# Used fonts
my $lct=0;	# Input Line Count
my $src_name='';
my %env;	# Current environment
my %fontlst;	# Fonts Loaded
my $rot=0;	# Portrait
my %desc;	# Contents of DESC
my %download;	# Contents of downlopad file
my $pages;	# Pointer to /Pages object
my $devnm='devpdf';
my $cpage;	# Pointer to current pages
my $cpageno=0;	# Object no of current page
my $cat;	# Pointer to catalogue
my $dests;	# Pointer to Dests
my @mediabox=(0,0,595,842);
my @defaultmb=(0,0,595,842);
my $stream='';	# Current Text/Graphics stream
my $cftsz=10;	# Current font sz
my $cft;	# Current Font
my $lwidth=1;	# current linewidth
my $linecap=1;
my $linejoin=1;
my $textcol='';	# Current groff text
my $fillcol='';	# Current groff fill
my $curfill='';	# Current PDF fill
my $strkcol='';
my $curstrk='';
my @lin=();	# Array holding current line of text
my @ahead=();	# Buffer used to hol the next line
my $mode='g';	# Graphic (g) or Text (t) mode;
my $xpos=0;	# Current X position
my $ypos=0;	# Current Y position
my $tmxpos=0;
my $kernadjust=0;
my $curkern=0;
my $widtbl;	# Pointer to width table for current font size
my $origwidtbl; # Pointer to width table
my $krntbl;	# Pointer to kern table
my $matrix="1 0 0 1";
my $whtsz;	# Current width of a space
my $poschg=0;	# V/H pending
my $fontchg=0;	# font change pending
my $tnum=2;	# flatness of B-Spline curve
my $tden=3;	# flatness of B-Spline curve
my $linewidth=40;
my $w_flg=0;
my $nomove=0;
my $pendmv=0;
my $gotT=0;
my $suppress=0;	# Suppress processing?
my %incfil;	# Included Files
my @outlev=([0,undef,0,0]);	# Structure pdfmark /OUT entries
my $curoutlev=\@outlev;
my $curoutlevno=0;	# Growth point for @curoutlev
my $Foundry='';
my $xrev=0;	# Reverse x direction of font
my $matrixchg=0;
my $wt=-1;
my $thislev=1;
my $mark=undef;
my $suspendmark=undef;
my $boxmax=0;



my $n_flg=1;
my $pginsert=-1;    # Growth point for kids array
my %pgnames;        # 'names' of pages for switchtopage
my @outlines=();    # State of Bookmark Outlines at end of each page
my $custompaper=0;  # Has there been an X papersize
my $textenccmap=''; # CMap for groff text.enc encoding
my @XOstream=();
my @PageAnnots={};
my $noslide=0;
my $transition={PAGE => {Type => '/Trans', S => '', D => 1, Dm => '/H', M => '/I', Di => 0, SS => 1.0, B => 0},
		BLOCK => {Type => '/Trans', S => '', D => 1, Dm => '/H', M => '/I', Di => 0, SS => 1.0, B => 0}};
my $firstpause=0;
my $present=0;
my @bgstack; 		# Stack of background boxes
my $bgbox='';		# Draw commands for boxes on this page

$noslide=1 if exists($ENV{GROPDF_NOSLIDE}) and $ENV{GROPDF_NOSLIDE};

my %ppsz=(	'ledger'=>[1224,792],
	'legal'=>[612,1008],
	'letter'=>[612,792],
	'a0'=>[2384,3370],
	'a1'=>[1684,2384],
	'a2'=>[1191,1684],
	'a3'=>[842,1191],
	'a4'=>[595,842],
	'a5'=>[420,595],
	'a6'=>[297,420],
	'a7'=>[210,297],
	'a8'=>[148,210],
	'a9'=>[105,148],
	'a10'=>[73,105],
	'isob0'=>[2835,4008],
	'isob1'=>[2004,2835],
	'isob2'=>[1417,2004],
	'isob3'=>[1001,1417],
	'isob4'=>[709,1001],
	'isob5'=>[499,709],
	'isob6'=>[354,499],
	'c0'=>[2599,3677],
	'c1'=>[1837,2599],
	'c2'=>[1298,1837],
	'c3'=>[918,1298],
	'c4'=>[649,918],
	'c5'=>[459,649],
	'c6'=>[323,459] );

my $ucmap=<<'EOF';
/CIDInit /ProcSet findresource begin
12 dict begin
begincmap
/CIDSystemInfo
<< /Registry (Adobe)
/Ordering (UCS)
/Supplement 0
>> def
/CMapName /Adobe-Identity-UCS def
/CMapType 2 def
1 begincodespacerange
<0000> <FFFF>
endcodespacerange
2 beginbfrange
<008b> <008f> [<00660066> <00660069> <0066006c> <006600660069> <00660066006C>]
<00ad> <00ad> <002d>
endbfrange
endcmap
CMapName currentdict /CMap defineresource pop
end
end
EOF

my $fd;
my $frot;
my $fpsz;
my $embedall=0;
my $debug=0;
my $version=0;
my $stats=0;
my $unicodemap;
my @idirs;

#Load_Config();

GetOptions("F=s" => \$fd, 'I=s' => \@idirs, 'l' => \$frot, 'p=s' => \$fpsz, 'd!' => \$debug, 'v' => \$version, 'version' => \$version, 'e' => \$embedall, 'y=s' => \$Foundry, 's' => \$stats, 'u:s' => \$unicodemap);

unshift(@idirs,'.');

if ($version)
{
    print "GNU gropdf (groff) version $cfg{GROFF_VERSION}\n";
    exit;
}

if (defined($unicodemap))
{
    if ($unicodemap eq '')
    {
	$ucmap='';
    }
    elsif (-r $unicodemap)
    {
	local $/;
	open(F,"<$unicodemap") or die "gropdf: Failed to open '$unicodemap'";
	($ucmap)=(<F>);
	close(F);
    }
    else
    {
	Msg(0,"Failed to find '$unicodemap' - ignoring");
    }
}

# Search for 'font directory': paths in -f opt, shell var GROFF_FONT_PATH, default paths

my $fontdir=$cfg{GROFF_FONT_PATH};
$fontdir=$ENV{GROFF_FONT_PATH}.$cfg{RT_SEP}.$fontdir if exists($ENV{GROFF_FONT_PATH});
$fontdir=$fd.$cfg{RT_SEP}.$fontdir if defined($fd);

$rot=90 if $frot;
$matrix="0 1 -1 0" if $frot;

LoadDownload();
LoadDesc();

my $unitwidth=$desc{unitwidth};
my $papersz=$desc{papersize};
$papersz=lc($fpsz) if $fpsz;

$env{FontHT}=0;
$env{FontSlant}=0;
MakeMatrix();

if (substr($papersz,0,1) eq '/' and -r $papersz)
{
    if (open(P,"<$papersz"))
    {
	while (<P>)
	{
	    chomp;
	    s/# .*//;
	    next if $_ eq '';
	    $papersz=$_;
	    last
	}

	close(P);
    }
}

if ($papersz=~m/([\d.]+)([cipP]),([\d.]+)([cipP])/)
{
    @defaultmb=@mediabox=(0,0,ToPoints($3,$4),ToPoints($1,$2));
}
elsif (exists($ppsz{$papersz}))
{
    @defaultmb=@mediabox=(0,0,$ppsz{$papersz}->[0],$ppsz{$papersz}->[1]);
}

my (@dt)=localtime($ENV{SOURCE_DATE_EPOCH} || time);
my $dt=PDFDate(\@dt);

my %info=('Creator' => "(groff version $cfg{GROFF_VERSION})",
				'Producer' => "(gropdf version $cfg{GROFF_VERSION})",
				'ModDate' => "($dt)",
				'CreationDate' => "($dt)");
map { $_="< ".$_."\0" } @ARGV;

while (<>)
{
    chomp;
    s/\r$//;
    $lct++;

    do 	# The ahead buffer behaves like 'ungetc'
    {{
	if (scalar(@ahead))
	{
	    $_=shift(@ahead);
	}


	my $cmd=substr($_,0,1);
	next if $cmd eq '#';	# just a comment
	my $lin=substr($_,1);

	while ($cmd eq 'w')
	{
	    $cmd=substr($lin,0,1);
	    $lin=substr($lin,1);
	    $w_flg=1 if $gotT;
	}

	$lin=~s/^\s+//;
#		$lin=~s/\s#.*?$//;	# remove comment
	$stream.="\% $_\n" if $debug;

	do_x($lin),next if ($cmd eq 'x');
	next if $suppress;
	do_p($lin),next if ($cmd eq 'p');
	do_f($lin),next if ($cmd eq 'f');
	do_s($lin),next if ($cmd eq 's');
	do_m($lin),next if ($cmd eq 'm');
	do_D($lin),next if ($cmd eq 'D');
	do_V($lin),next if ($cmd eq 'V');
	do_v($lin),next if ($cmd eq 'v');
	do_t($lin),next if ($cmd eq 't');
	do_u($lin),next if ($cmd eq 'u');
	do_C($lin),next if ($cmd eq 'C');
	do_c($lin),next if ($cmd eq 'c');
	do_N($lin),next if ($cmd eq 'N');
	do_h($lin),next if ($cmd eq 'h');
	do_H($lin),next if ($cmd eq 'H');
	do_n($lin),next if ($cmd eq 'n');

	my $tmp=scalar(@ahead);
    }} until scalar(@ahead) == 0;

}

exit 0 if $lct==0;

if ($cpageno > 0)
{
	my $trans='BLOCK';

	$trans='PAGE' if $firstpause;

	if (scalar(@XOstream))
	{
	    MakeXO() if $stream;
	    $stream=join("\n",@XOstream)."\n";
	}

	my %t=%{$transition->{$trans}};
	$cpage->{MediaBox}=\@mediabox if $custompaper;
	$cpage->{Trans}=FixTrans(\%t) if $t{S};

	if ($#PageAnnots >= 0)
	{
	    @{$cpage->{Annots}}=@PageAnnots;
	}

	if ($#bgstack > -1 or $bgbox)
	{
	    my $box="q 1 0 0 1 0 0 cm ";

	    foreach my $bg (@bgstack)
	    {
		# 0=$bgtype # 1=stroke 2=fill. 4=page
		# 1=$strkcol
		# 2=$fillcol
		# 3=(Left,Top,Right,bottom,LineWeight)
		# 4=Start ypos
		# 5=Endypos
		# 6=Line Weight

		my $pg=$bg->[3] || \@mediabox;

		$bg->[5]=$pg->[3];	# box is continueing to next page
		$box.=DrawBox($bg);
		$bg->[4]=$pg->[1];	# will continue from page top
	    }

	    $stream=$box.$bgbox."Q\n".$stream;
	    $bgbox='';
	}

    $boxmax=0;
	PutObj($cpageno);
	OutStream($cpageno+1);
}

$cat->{PageMode}='/FullScreen' if $present;

PutOutlines(\@outlev);

PutObj(1);

my $info=BuildObj(++$objct,\%info);

PutObj($objct);

foreach my $fontno (sort keys %fontlst)
{
    my $o=$fontlst{$fontno}->{FNT};

    foreach my $ch (@{$o->{NO}})
    {
	my $psname=$o->{NAM}->{$ch->[1]}->[PSNAME] || '/.notdef';
	my $wid=$o->{NAM}->{$ch->[1]}->[WIDTH] || 0;

	push(@{$o->{DIFF}},$psname);
	push(@{$o->{WIDTH}},$wid);
	last if $#{$o->{DIFF}} >= 255;
    }
    unshift(@{$o->{DIFF}},0);
    my $p=GetObj($fontlst{$fontno}->{OBJ});

    if (exists($p->{LastChar}) and $p->{LastChar} > 255)
    {
	$p->{LastChar} = 255;
	splice(@{$o->{DIFF}},256);
	splice(@{$o->{WIDTH}},256);
    }
}

foreach my $o (3..$objct)
{
    PutObj($o) if (!exists($obj[$o]->{XREF}));
}

#my $encrypt=BuildObj(++$objct,{'Filter' => '/Standard', 'V' => 1, 'R' => 2, 'P' => 252});
#PutObj($objct);
PutObj(2);

my $xrefct=$fct;

$objct+=1;
print "xref\n0 $objct\n0000000000 65535 f \n";

foreach my $xr (@obj)
{
    next if !defined($xr);
    printf("%010d 00000 n \n",$xr->{XREF});
}

print "trailer\n<<\n/Info $info\n/Root 1 0 R\n/Size $objct\n>>\nstartxref\n$fct\n\%\%EOF\n";
print "\% Pages=$pages->{Count}\n" if $stats;


sub MakeMatrix
{
    my $fontxrev=shift||0;
    my @mat=($frot)?(0,1,-1,0):(1,0,0,1);

    if (!$frot)
    {
	if ($env{FontHT} != 0)
	{
	    $mat[3]=sprintf('%.3f',$env{FontHT}/$cftsz);
	}

	if ($env{FontSlant} != 0)
	{
	    my $slant=$env{FontSlant};
	    $slant*=$env{FontHT}/$cftsz if $env{FontHT} != 0;
	    my $ang=rad($slant);

	    $mat[2]=sprintf('%.3f',sin($ang)/cos($ang));
	}

	if ($fontxrev)
	{
	    $mat[0]=-$mat[0];
	}
    }

    $matrix=join(' ',@mat);
    $matrixchg=1;
}

sub PutOutlines
{
    my $o=shift;
    my $outlines;

    if ($#{$o} > 0)
    {
	# We've got Outlines to deal with
	my $openct=$curoutlev->[0]->[2];

	while ($thislev-- > 1)
	{
	    my $nxtoutlev=$curoutlev->[0]->[1];
	    $nxtoutlev->[0]->[2]+=$openct if $curoutlev->[0]->[3]==1;
	    $openct=0 if $nxtoutlev->[0]->[3]==-1;
	    $curoutlev=$nxtoutlev;
	}

	$cat->{Outlines}=BuildObj(++$objct,{'Count' => abs($o->[0]->[0])+$o->[0]->[2]});
	$outlines=$obj[$objct]->{DATA};
    }
    else
    {
	return;
    }

    SetOutObj($o);

    $outlines->{First}=$o->[1]->[2];
    $outlines->{Last}=$o->[$#{$o}]->[2];

    LinkOutObj($o,$cat->{Outlines});
}

sub SetOutObj
{
    my $o=shift;

    for my $j (1..$#{$o})
    {
	my $ono=BuildObj(++$objct,$o->[$j]->[0]);
	$o->[$j]->[2]=$ono;

	SetOutObj($o->[$j]->[1]) if $#{$o->[$j]->[1]} > -1;
    }
}

sub LinkOutObj
{
    my $o=shift;
    my $parent=shift;

    for my $j (1..$#{$o})
    {
	my $op=GetObj($o->[$j]->[2]);

	$op->{Next}=$o->[$j+1]->[2] if ($j < $#{$o});
	$op->{Prev}=$o->[$j-1]->[2] if ($j > 1);
	$op->{Parent}=$parent;

	if ($#{$o->[$j]->[1]} > -1)
	{
	    $op->{Count}=$o->[$j]->[1]->[0]->[2]*$o->[$j]->[1]->[0]->[3];# if exists($op->{Count}) and $op->{Count} > 0;
	    $op->{First}=$o->[$j]->[1]->[1]->[2];
	    $op->{Last}=$o->[$j]->[1]->[$#{$o->[$j]->[1]}]->[2];
	    LinkOutObj($o->[$j]->[1],$o->[$j]->[2]);
	}
    }
}

sub GetObj
{
    my $ono=shift;
    ($ono)=split(' ',$ono);
    return($obj[$ono]->{DATA});
}



sub PDFDate
{
    my $dt=shift;
    return(sprintf("D:%04d%02d%02d%02d%02d%02d%+03d'00'",$dt->[5]+1900,$dt->[4]+1,$dt->[3],$dt->[2],$dt->[1],$dt->[0],( localtime time() + 3600*( 12 - (gmtime)[2] ) )[2] - 12));
}

sub ToPoints
{
    my $num=shift;
    my $unit=shift;

    if ($unit eq 'i')
    {
	return($num*72);
    }
    elsif ($unit eq 'c')
    {
	return int($num*72/2.54);
    }
    elsif ($unit eq 'm')	# millimetres
    {
	return int($num*72/25.4);
    }
    elsif ($unit eq 'p')
    {
	return($num);
    }
    elsif ($unit eq 'P')
    {
	return($num*6);
    }
    elsif ($unit eq 'z')
    {
	return($num/$unitwidth);
    }
    else
    {
	Msg(1,"Unknown scaling factor '$unit'");
    }
}

sub Load_Config
{
    open(CFG,"<gropdf_config") or die "Can't open config file: $!";

    while (<CFG>)
    {
	chomp;
	my ($key,$val)=split(/ ?= ?/);

	$cfg{$key}=$val;
    }

    close(CFG);
}

sub LoadDownload
{
    my $f;
    my $found=0;

    my (@dirs)=split($cfg{RT_SEP},$fontdir);

    foreach my $dir (@dirs)
    {
	$f=undef;
	OpenFile(\$f,$dir,"download");
	next if !defined($f);
	$found++;

	while (<$f>)
	{
	    chomp;
	    s/#.*$//;
	    next if $_ eq '';
	    my ($foundry,$name,$file)=split(/\t+/);
	    if (substr($file,0,1) eq '*')
	    {
		next if !$embedall;
		$file=substr($file,1);
	    }

	    $download{"$foundry $name"}=$file;
	}

	close($f);
    }

    Msg(1,"Failed to open 'download'") if !$found;
}

sub OpenFile
{
    my $f=shift;
    my $dirs=shift;
    my $fnm=shift;

    if (substr($fnm,0,1)  eq '/' or substr($fnm,1,1) eq ':') # dos
    {
	return if -r "$fnm" and open($$f,"<$fnm");
    }

    my (@dirs)=split($cfg{RT_SEP},$dirs);

    foreach my $dir (@dirs)
    {
	last if -r "$dir/$devnm/$fnm" and open($$f,"<$dir/$devnm/$fnm");
    }
}

sub LoadDesc
{
    my $f;

    OpenFile(\$f,$fontdir,"DESC");
    Msg(1,"Failed to open 'DESC'") if !defined($f);

    while (<$f>)
    {
	chomp;
	s/#.*$//;
	next if $_ eq '';
	my ($name,$prms)=split(' ',$_,2);
	$desc{lc($name)}=$prms;
    }

    close($f);
}

sub rad  { $_[0]*3.14159/180 }

my $InPicRotate=0;

sub do_x
{
    my $l=shift;
    my ($xcmd,@xprm)=split(' ',$l);
    $xcmd=substr($xcmd,0,1);

    if ($xcmd eq 'T')
    {
	Msg(0,"Expecting a pdf pipe (got $xprm[0])") if $xprm[0] ne substr($devnm,3);
    }
    elsif ($xcmd eq 'f')	# Register Font
    {
	$xprm[1]="${Foundry}-$xprm[1]" if $Foundry ne '';
	LoadFont($xprm[0],$xprm[1]);
    }
    elsif ($xcmd eq 'F')	# Source File (for errors)
    {
	$env{SourceFile}=$xprm[0];
    }
    elsif ($xcmd eq 'H')	# FontHT
    {
	$xprm[0]/=$unitwidth;
	$xprm[0]=0 if $xprm[0] == $cftsz;
	$env{FontHT}=$xprm[0];
	MakeMatrix();
    }
    elsif ($xcmd eq 'S')	# FontSlant
    {
	$env{FontSlant}=$xprm[0];
	MakeMatrix();
    }
    elsif ($xcmd eq 'i')	# Initialise
    {
	if ($objct == 0)
	{
	    $objct++;
	    @defaultmb=@mediabox;
	    BuildObj($objct,{'Pages' => BuildObj($objct+1,
				{'Kids' => [],
				'Count' => 0,
				'Type' => '/Pages',
				'Rotate' => $rot,
				'MediaBox' => \@defaultmb,
				'Resources' =>
				    {'Font' => {},
				    'ProcSet' => ['/PDF', '/Text', '/ImageB', '/ImageC', '/ImageI']}
				}
				),
		'Type' =>  '/Catalog'});

	    $cat=$obj[$objct]->{DATA};
	    $objct++;
	    $pages=$obj[2]->{DATA};
	    Put("%PDF-1.4\n\x25\xe2\xe3\xcf\xd3\n");
	}
    }
    elsif ($xcmd eq 'X')
    {
	# There could be extended args
	do
	{{
	    LoadAhead(1);
	    if (substr($ahead[0],0,1) eq '+')
	    {
		$l.="\n".substr($ahead[0],1);
		shift(@ahead);
	    }
	}} until $#ahead==0;

	($xcmd,@xprm)=split(' ',$l);
	$xcmd=substr($xcmd,0,1);

	if ($xprm[0]=~m/^(.+:)(.+)/)
	{
	    splice(@xprm,1,0,$2);
	    $xprm[0]=$1;
	}

	my $par=join(' ',@xprm[1..$#xprm]);

	if ($xprm[0] eq 'ps:')
	{
	    if ($xprm[1] eq 'invis')
	    {
		$suppress=1;
	    }
	    elsif ($xprm[1] eq 'endinvis')
	    {
		$suppress=0;
	    }
	    elsif ($par=~m/exec gsave currentpoint 2 copy translate (.+) rotate neg exch neg exch translate/)
	    {
		# This is added by gpic to rotate a single object

		my $theta=-rad($1);

		IsGraphic();
		my ($curangle,$hyp)=RtoP($xpos,GraphY($ypos));
		my ($x,$y)=PtoR($theta+$curangle,$hyp);
 		my ($tx, $ty) = ($xpos - $x, GraphY($ypos) - $y);
 		if ($frot) {
 		  ($tx, $ty) = ($tx *  sin($theta) + $ty * -cos($theta),
 				$tx * -cos($theta) + $ty * -sin($theta));
 		}
 		$stream.="q\n".sprintf("%.3f %.3f %.3f %.3f %.3f %.3f cm",cos($theta),sin($theta),-sin($theta),cos($theta),$tx,$ty)."\n";
		$InPicRotate=1;
	    }
	    elsif ($par=~m/exec grestore/ and $InPicRotate)
	    {
		IsGraphic();
		$stream.="Q\n";
		$InPicRotate=0;
	    }
	    elsif ($par=~m/exec (\d) setlinejoin/)
	    {
		IsGraphic();
		$linejoin=$1;
		$stream.="$linejoin j\n";
	    }
	    elsif ($par=~m/exec (\d) setlinecap/)
	    {
		IsGraphic();
		$linecap=$1;
		$stream.="$linecap J\n";
	    }
	    elsif ($par=~m/exec %%%%PAUSE/i and !$noslide)
	    {
		my $trans='BLOCK';

		if ($firstpause)
		{
		    $trans='PAGE';
		    $firstpause=0;
		}
		MakeXO();
		NewPage($trans);
		$present=1;
	    }
	    elsif ($par=~m/exec %%%%BEGINONCE/)
	    {
		if ($noslide)
		{
		    $suppress=1;
		}
		else
		{
		    my $trans='BLOCK';

		    if ($firstpause)
		    {
			$trans='PAGE';
			$firstpause=0;
		    }
		    MakeXO();
		    NewPage($trans);
		    $present=1;
		}
	    }
	    elsif ($par=~m/exec %%%%ENDONCE/)
	    {
		if ($noslide)
		{
		    $suppress=0;
		}
		else
		{
		    MakeXO();
		    NewPage('BLOCK');
		    $cat->{PageMode}='/FullScreen';
		    pop(@XOstream);
		}
	    }
	    elsif ($par=~m/\[(.+) pdfmark/)
	    {
		my $pdfmark=$1;
		$pdfmark=~s((\d{4,6}) u)(sprintf("%.1f",$1/$desc{sizescale}))eg;
		$pdfmark=~s(\\\[u00(..)\])(chr(hex($1)))eg;
                $pdfmark=~s/\\n/\n/g;

		if ($pdfmark=~m/(.+) \/DOCINFO\s*$/s)
		{
		    my @xwds=split(/ /,"<< $1 >>");
		    my $docinfo=ParsePDFValue(\@xwds);

		    foreach my $k (sort keys %{$docinfo})
		    {
			$info{$k}=$docinfo->{$k} if $k ne 'Producer';
		    }
		}
		elsif ($pdfmark=~m/(.+) \/DOCVIEW\s*$/)
		{
		    my @xwds=split(' ',"<< $1 >>");
		    my $docview=ParsePDFValue(\@xwds);

		    foreach my $k (sort keys %{$docview})
		    {
			$cat->{$k}=$docview->{$k} if !exists($cat->{$k});
		    }
		}
		elsif ($pdfmark=~m/(.+) \/DEST\s*$/)
		{
		    my @xwds=split(' ',"<< $1 >>");
		    my $dest=ParsePDFValue(\@xwds);
		    foreach my $v (@{$dest->{View}})
		    {
			$v=GraphY(abs($v)) if substr($v,0,1) eq '-';
		    }
		    unshift(@{$dest->{View}},"$cpageno 0 R");

		    if (!defined($dests))
		    {
			$cat->{Dests}=BuildObj(++$objct,{});
			$dests=$obj[$objct]->{DATA};
		    }

		    my $k=substr($dest->{Dest},1);
		    $dests->{$k}=$dest->{View};
		}
		elsif ($pdfmark=~m/(.+) \/ANN\s*$/)
		{
		    my $l=$1;
		    $l=~s/Color/C/;
		    $l=~s/Action/A/;
		    $l=~s/Title/T/;
		    $l=~s'/Subtype /URI'/S /URI';
		    my @xwds=split(' ',"<< $l >>");
		    my $annotno=BuildObj(++$objct,ParsePDFValue(\@xwds));
		    my $annot=$obj[$objct];
		    $annot->{DATA}->{Type}='/Annot';
		    FixRect($annot->{DATA}->{Rect}); # Y origin to ll
		    FixPDFColour($annot->{DATA});
		    push(@PageAnnots,$annotno);
		}
		elsif ($pdfmark=~m/(.+) \/OUT\s*$/)
		{
		    my $t=$1;
		    $t=~s/\\\) /\\\\\) /g;
		    $t=~s/\\e/\\\\/g;
		    $t=~m/(^.*\/Title \()(.*)(\).*)/;
		    my ($pre,$title,$post)=($1,$2,$3);
		    $title=~s/(?<!\\)\(/\\\(/g;
		    $title=~s/(?<!\\)\)/\\\)/g;
		    my @xwds=split(' ',"<< $pre$title$post >>");
		    my $out=ParsePDFValue(\@xwds);

		    my $this=[$out,[]];

		    if (exists($out->{Level}))
		    {
			my $lev=abs($out->{Level});
			my $levsgn=sgn($out->{Level});
			delete($out->{Level});

			if ($lev > $thislev)
			{
			    my $thisoutlev=$curoutlev->[$#{$curoutlev}]->[1];
			    $thisoutlev->[0]=[0,$curoutlev,0,$levsgn];
			    $curoutlev=$thisoutlev;
			    $curoutlevno=$#{$curoutlev};
			    $thislev++;
			}
			elsif ($lev < $thislev)
			{
			    my $openct=$curoutlev->[0]->[2];

			    while ($thislev > $lev)
			    {
				my $nxtoutlev=$curoutlev->[0]->[1];
				$nxtoutlev->[0]->[2]+=$openct if $curoutlev->[0]->[3]==1;
				$openct=0 if $nxtoutlev->[0]->[3]==-1;
				$curoutlev=$nxtoutlev;
				$thislev--;
			    }

    			    $curoutlevno=$#{$curoutlev};
			}

# 			push(@{$curoutlev},$this);
			splice(@{$curoutlev},++$curoutlevno,0,$this);
			$curoutlev->[0]->[2]++;
		    }
		    else
		    {
			# This code supports old pdfmark.tmac, unused by pdf.tmac
			while ($curoutlev->[0]->[0] == 0 and defined($curoutlev->[0]->[1]))
			{
			    $curoutlev=$curoutlev->[0]->[1];
			}

			$curoutlev->[0]->[0]--;
			$curoutlev->[0]->[2]++;
			push(@{$curoutlev},$this);


			if (exists($out->{Count}) and $out->{Count} != 0)
			{
			    push(@{$this->[1]},[abs($out->{Count}),$curoutlev,0,sgn($out->{Count})]);
			    $curoutlev=$this->[1];

			    if ($out->{Count} > 0)
			    {
				my $p=$curoutlev;

				while (defined($p))
				{
				    $p->[0]->[2]+=$out->{Count};
				    $p=$p->[0]->[1];
				}
			    }
			}
		    }
		}
	    }
	}
	elsif (lc($xprm[0]) eq 'pdf:')
	{
	    if (lc($xprm[1]) eq 'import')
	    {
		my $fil=$xprm[2];
		my $llx=$xprm[3];
		my $lly=$xprm[4];
		my $urx=$xprm[5];
		my $ury=$xprm[6];
		my $wid=GetPoints($xprm[7]);
		my $hgt=GetPoints($xprm[8])||-1;
		my $mat=[1,0,0,1,0,0];

		if (!exists($incfil{$fil}))
		{
		    if ($fil=~m/\.pdf$/)
		    {
			$incfil{$fil}=LoadPDF($fil,$mat,$wid,$hgt,"import");
		    }
		    elsif ($fil=~m/\.swf$/)
		    {
			my $xscale=$wid/($urx-$llx+1);
			my $yscale=($hgt<=0)?$xscale:($hgt/($ury-$lly+1));
			$hgt=($ury-$lly+1)*$yscale;

			if ($rot)
			{
			    $mat->[3]=$xscale;
			    $mat->[0]=$yscale;
			}
			else
			{
			    $mat->[0]=$xscale;
			    $mat->[3]=$yscale;
			}

			$incfil{$fil}=LoadSWF($fil,[$llx,$lly,$urx,$ury],$mat);
		    }
		    else
		    {
			Msg(0,"Unknown filetype '$fil'");
			return undef;
		    }
		}

		if (defined($incfil{$fil}))
		{
		    IsGraphic();
		    if ($fil=~m/\.pdf$/)
		    {
			my $bbox=$incfil{$fil}->[1];
			my $xscale=d3($wid/($bbox->[2]-$bbox->[0]+1));
			my $yscale=d3(($hgt<=0)?$xscale:($hgt/($bbox->[3]-$bbox->[1]+1)));
			$wid=($bbox->[2]-$bbox->[0])*$xscale;
			$hgt=($bbox->[3]-$bbox->[1])*$yscale;
			$ypos+=$hgt;
			$stream.="q $xscale 0 0 $yscale ".PutXY($xpos,$ypos)." cm";
			$stream.=" 0 1 -1 0 0 0 cm" if $rot;
			$stream.=" /$incfil{$fil}->[0] Do Q\n";
		    }
		    elsif ($fil=~m/\.swf$/)
		    {
			$stream.=PutXY($xpos,$ypos)." m /$incfil{$fil} Do\n";
		    }
		}
	    }
	    elsif (lc($xprm[1]) eq 'pdfpic')
	    {
		my $fil=$xprm[2];
		my $flag=uc($xprm[3]||'-L');
		my $wid=GetPoints($xprm[4])||-1;
		my $hgt=GetPoints($xprm[5]||-1);
		my $ll=GetPoints($xprm[6]||0);
		my $mat=[1,0,0,1,0,0];

		if (!exists($incfil{$fil}))
		{
		    $incfil{$fil}=LoadPDF($fil,$mat,$wid,$hgt,"pdfpic");
		}

		if (defined($incfil{$fil}))
		{
		    IsGraphic();
		    my $bbox=$incfil{$fil}->[1];
		    $wid=($bbox->[2]-$bbox->[0]) if $wid <= 0;
		    my $xscale=d3($wid/($bbox->[2]-$bbox->[0]));
		    my $yscale=d3(($hgt<=0)?$xscale:($hgt/($bbox->[3]-$bbox->[1])));
		    $xscale=($wid<=0)?$yscale:$xscale;
		    $xscale=$yscale if $yscale < $xscale;
		    $yscale=$xscale if $xscale < $yscale;
		    $wid=($bbox->[2]-$bbox->[0])*$xscale;
		    $hgt=($bbox->[3]-$bbox->[1])*$yscale;

		    if ($flag eq '-C' and $ll > $wid)
		    {
			$xpos+=int(($ll-$wid)/2);
		    }
		    elsif ($flag eq '-R' and $ll > $wid)
		    {
			$xpos+=$ll-$wid;
		    }

		    $ypos+=$hgt;
		    $stream.="q $xscale 0 0 $yscale ".PutXY($xpos,$ypos)." cm";
		    $stream.=" 0 1 -1 0 0 0 cm" if $rot;
		    $stream.=" /$incfil{$fil}->[0] Do Q\n";
		}
	    }
	    elsif (lc($xprm[1]) eq 'xrev')
	    {
		$xrev=!$xrev;
	    }
	    elsif (lc($xprm[1]) eq 'markstart')
	    {
		$mark={'rst' => ($xprm[2]+$xprm[4])/$unitwidth, 'rsb' => ($xprm[3]-$xprm[4])/$unitwidth, 'xpos' => $xpos-($xprm[4]/$unitwidth),
			    'ypos' => $ypos, 'lead' => $xprm[4]/$unitwidth, 'pdfmark' => join(' ',@xprm[5..$#xprm])};
	    }
	    elsif (lc($xprm[1]) eq 'markend')
	    {
		PutHotSpot($xpos) if defined($mark);
		$mark=undef;
	    }
	    elsif (lc($xprm[1]) eq 'marksuspend')
	    {
		$suspendmark=$mark;
		$mark=undef;
	    }
	    elsif (lc($xprm[1]) eq 'markrestart')
	    {
		$mark=$suspendmark;
		$suspendmark=undef;
	    }
	    elsif (lc($xprm[1]) eq 'pagename')
	    {
		if ($pginsert > -1)
		{
		    $pgnames{$xprm[2]}=$pages->{Kids}->[$pginsert];
		}
		else
		{
		    $pgnames{$xprm[2]}='top';
		}
	    }
	    elsif (lc($xprm[1]) eq 'switchtopage')
	    {
		my $ba=$xprm[2];
		my $want=$xprm[3];

		if ($pginsert > -1)
		{
		    if (!defined($want) or $want eq '')
		    {
			# no before/after
			$want=$ba;
			$ba='before';
		    }

		    if (!defined($ba) or $ba eq '' or $want eq 'bottom')
		    {
			$pginsert=$#{$pages->{Kids}};
		    }
		    elsif ($want eq 'top')
		    {
			$pginsert=-1;
		    }
		    else
		    {
			if (exists($pgnames{$want}))
			{
			    my $ref=$pgnames{$want};

			    if ($ref eq 'top')
			    {
				$pginsert=-1;
			    }
			    else
			    {
				FIND: while (1)
				{
				    foreach my $j (0..$#{$pages->{Kids}})
				    {
					if ($ref eq $pages->{Kids}->[$j])
					{
					    if ($ba eq 'before')
					    {
						$pginsert=$j-1;
						last FIND;
					    }
					    elsif ($ba eq 'after')
					    {
						$pginsert=$j;
						last FIND;
					    }
					    else
					    {
						Msg(0,"Parameter must be top|bottom|before|after not '$ba'");
						last FIND;
					    }
					}

				    }

				    Msg(0,"Can't find page ref '$ref'");
				    last FIND

				}
			    }
			}
			else
			{
			    Msg(0,"Can't find page named '$want'");
			}
		    }

		    if ($pginsert < 0)
		    {
			($curoutlev,$curoutlevno,$thislev)=(\@outlev,0,1);
		    }
		    else
		    {
			($curoutlev,$curoutlevno,$thislev)=(@{$outlines[$pginsert]});
		    }
		}
	    }
	    elsif (lc($xprm[1]) eq 'transition' and !$noslide)
	    {
		if (uc($xprm[2]) eq 'PAGE' or uc($xprm[2] eq 'SLIDE'))
		{
		    $transition->{PAGE}->{S}='/'.ucfirst($xprm[3]) if $xprm[3] and $xprm[3] ne '.';
		    $transition->{PAGE}->{D}=$xprm[4] if $xprm[4] and $xprm[4] ne '.';
		    $transition->{PAGE}->{Dm}='/'.$xprm[5] if $xprm[5] and $xprm[5] ne '.';
		    $transition->{PAGE}->{M}='/'.$xprm[6] if $xprm[6] and $xprm[6] ne '.';
		    $xprm[7]='/None' if $xprm[7] and uc($xprm[7]) eq 'NONE';
		    $transition->{PAGE}->{Di}=$xprm[7] if $xprm[7] and $xprm[7] ne '.';
		    $transition->{PAGE}->{SS}=$xprm[8] if $xprm[8] and $xprm[8] ne '.';
		    $transition->{PAGE}->{B}=$xprm[9] if $xprm[9] and $xprm[9] ne '.';
		}
		elsif (uc($xprm[2]) eq 'BLOCK')
		{
		    $transition->{BLOCK}->{S}='/'.ucfirst($xprm[3]) if $xprm[3] and $xprm[3] ne '.';
		    $transition->{BLOCK}->{D}=$xprm[4] if $xprm[4] and $xprm[4] ne '.';
		    $transition->{BLOCK}->{Dm}='/'.$xprm[5] if $xprm[5] and $xprm[5] ne '.';
		    $transition->{BLOCK}->{M}='/'.$xprm[6] if $xprm[6] and $xprm[6] ne '.';
		    $xprm[7]='/None' if $xprm[7] and uc($xprm[7]) eq 'NONE';
		    $transition->{BLOCK}->{Di}=$xprm[7] if $xprm[7] and $xprm[7] ne '.';
		    $transition->{BLOCK}->{SS}=$xprm[8] if $xprm[8] and $xprm[8] ne '.';
		    $transition->{BLOCK}->{B}=$xprm[9] if $xprm[9] and $xprm[9] ne '.';
		}

		$present=1;
	    }
	    elsif (lc($xprm[1]) eq 'background')
	    {
		splice(@xprm,0,2);
		my $type=shift(@xprm);
# 		print STDERR "ypos=$ypos\n";

		if (lc($type) eq 'off')
		{
		    my $sptr=$#bgstack;
		    if ($sptr > -1)
		    {
                        if ($sptr == 0 and $bgstack[0]->[0] & 4)
                        {
                            pop(@bgstack);
                        }
                        else
                        {
                            $bgstack[$sptr]->[5]=GraphY($ypos);
			$bgbox=DrawBox(pop(@bgstack)).$bgbox;
		    }
		}
		}
		elsif (lc($type) eq 'footnote')
		{
                    my $t=GetPoints($xprm[0]);
                    $boxmax=($t<0)?abs($t):GraphY($t);
                }
		else
		{
		    my $bgtype=0;

		    foreach (@xprm)
		    {
			$_=GetPoints($_);
		    }

		    $bgtype|=2 if $type=~m/box/i;
		    $bgtype|=1 if $type=~m/fill/i;
		    $bgtype|=4 if $type=~m/page/i;
		    $bgtype=5 if $bgtype==4;
		    my $bgwt=$xprm[4];
		    $bgwt=$xprm[0] if !defined($bgwt) and $#xprm == 0;
		    my (@bg)=(@xprm);
		    my $bg=\@bg;

		    if (!defined($bg[3]) or $bgtype & 4)
		    {
			$bg=undef;
		    }
		    else
		    {
			FixRect($bg);
		    }

		    if ($bgtype)
		    {
                        if ($bgtype & 4)
                        {
                            shift(@bgstack) if $#bgstack >= 0 and $bgstack[0]->[0] & 4;
                            unshift(@bgstack,[$bgtype,$strkcol,$fillcol,$bg,GraphY($ypos),GraphY($bg[3]||0),$bgwt || 0.4]);
                        }
                        else
                        {
			push(@bgstack,[$bgtype,$strkcol,$fillcol,$bg,GraphY($ypos),GraphY($bg[3]||0),$bgwt || 0.4]);
		    }
		}
	    }
	}
	}
	elsif (lc(substr($xprm[0],0,9)) eq 'papersize')
	{
	    my ($px,$py)=split(',',substr($xprm[0],10));
	    $px=GetPoints($px);
	    $py=GetPoints($py);
	    @mediabox=(0,0,$px,$py);
	    my @mb=@mediabox;
	    $matrixchg=1;
	    $custompaper=1;
	    $cpage->{MediaBox}=\@mb;
	}
    }
}

sub FixPDFColour
{
    my $o=shift;
    my $a=$o->{C};
    my @r=();
    my $c=$a->[0];

    if ($#{$a}==3)
    {
	if ($c > 1)
	{
	    foreach my $j (0..2)
	    {
		push(@r,sprintf("%1.3f",$a->[$j]/0xffff));
	    }

	    $o->{C}=\@r;
	}
    }
    elsif (substr($c,0,1) eq '#')
    {
	if (length($c) == 7)
	{
	    foreach my $j (0..2)
	    {
		push(@r,sprintf("%1.3f",hex(substr($c,$j*2+1,2))/0xff));
	    }

	    $o->{C}=\@r;
	}
	elsif (length($c) == 14)
	{
	    foreach my $j (0..2)
	    {
		push(@r,sprintf("%1.3f",hex(substr($c,$j*4+2,4))/0xffff));
	    }

	    $o->{C}=\@r;
	}
    }
}

sub PutHotSpot
{
    my $endx=shift;
    my $l=$mark->{pdfmark};
    $l=~s/Color/C/;
    $l=~s/Action/A/;
    $l=~s'/Subtype /URI'/S /URI';
    $l=~s(\\\[u00(..)\])(chr(hex($1)))eg;
    my @xwds=split(' ',"<< $l >>");
    my $annotno=BuildObj(++$objct,ParsePDFValue(\@xwds));
    my $annot=$obj[$objct];
    $annot->{DATA}->{Type}='/Annot';
    $annot->{DATA}->{Rect}=[$mark->{xpos},$mark->{ypos}-$mark->{rsb},$endx+$mark->{lead},$mark->{ypos}-$mark->{rst}];
    FixPDFColour($annot->{DATA});
    FixRect($annot->{DATA}->{Rect}); # Y origin to ll
    push(@PageAnnots,$annotno);
}

sub sgn
{
    return(1) if $_[0] > 0;
    return(-1) if $_[0] < 0;
    return(0);
}

sub FixRect
{
    my $rect=shift;

    return if !defined($rect);
    $rect->[1]=GraphY($rect->[1]);
    $rect->[3]=GraphY($rect->[3]);
}

sub GetPoints
{
    my $val=shift;

    $val=ToPoints($1,$2) if ($val and $val=~m/(-?[\d.]+)([cipnz])/);

    return $val;
}

# Although the PDF reference mentions XObject/Form as a way of incorporating an external PDF page into
# the current PDF, it seems not to work with any current PDF reader (although I am told (by Leonard Rosenthol,
# who helped author the PDF ISO standard) that Acroread 9 does support it, empiorical observation shows otherwise!!).
# So... do it the hard way - full PDF parser and merge required objects!!!

# sub BuildRef
# {
# 	my $fil=shift;
# 	my $bbox=shift;
# 	my $mat=shift;
# 	my $wid=($bbox->[2]-$bbox->[0])*$mat->[0];
# 	my $hgt=($bbox->[3]-$bbox->[1])*$mat->[3];
#
# 	if (!open(PDF,"<$fil"))
# 	{
# 		Msg(0,"Failed to open '$fil'");
# 		return(undef);
# 	}
#
# 	my (@f)=(<PDF>);
#
# 	close(PDF);
#
# 	$objct++;
# 	my $xonm="XO$objct";
#
# 	$pages->{'Resources'}->{'XObject'}->{$xonm}=BuildObj($objct,{'Type' => '/XObject',
# 								    'Subtype' => '/Form',
# 								    'BBox' => $bbox,
# 								    'Matrix' => $mat,
# 								    'Resources' => $pages->{'Resources'},
# 								    'Ref' => {'Page' => '1',
# 										'F' => BuildObj($objct+1,{'Type' => '/Filespec',
# 													  'F' => "($fil)",
# 													  'EF' => {'F' => BuildObj($objct+2,{'Type' => '/EmbeddedFile'})}
# 										})
# 								    }
# 								});
#
# 	$obj[$objct]->{STREAM}="q 1 0 0 1 0 0 cm
# q BT
# 1 0 0 1 0 0 Tm
# .5 g .5 G
# /F5 20 Tf
# (Proxy) Tj
# ET Q
# 0 0 m 72 0 l s
# Q\n";
#
# #	$obj[$objct]->{STREAM}=PutXY($xpos,$ypos)." m ".PutXY($xpos+$wid,$ypos)." l ".PutXY($xpos+$wid,$ypos+$hgt)." l ".PutXY($xpos,$ypos+$hgt)." l f\n";
# 	$obj[$objct+2]->{STREAM}=join('',@f);
# 	PutObj($objct);
# 	PutObj($objct+1);
# 	PutObj($objct+2);
# 	$objct+=2;
# 	return($xonm);
# }

sub LoadSWF
{
    my $fil=shift;
    my $bbox=shift;
    my $mat=shift;
    my $wid=($bbox->[2]-$bbox->[0])*$mat->[0];
    my $hgt=($bbox->[3]-$bbox->[1])*$mat->[3];
    my (@path)=split('/',$fil);
    my $node=pop(@path);

    if (!open(PDF,"<$fil"))
    {
	Msg(0,"Failed to open '$fil'");
	return(undef);
    }

    my (@f)=(<PDF>);

    close(PDF);

    $objct++;
    my $xonm="XO$objct";

    $pages->{'Resources'}->{'XObject'}->{$xonm}=BuildObj($objct,{'Type' => '/XObject', 'BBox' => $bbox, 'Matrix' => $mat, 'FormType' => 1, 'Subtype' => '/Form', 'Length' => 0, 'Type' => "/XObject"});
    $obj[$objct]->{STREAM}='';
    PutObj($objct);
    $objct++;
    my $asset=BuildObj($objct,{'EF' => {'F' => BuildObj($objct+1,{})},
		'F' => "($node)",
		'Type' => '/Filespec',
		'UF' => "($node)"});

    PutObj($objct);
    $objct++;
    $obj[$objct]->{STREAM}=join('',@f);
    PutObj($objct);
    $objct++;
    my $config=BuildObj($objct,{'Instances' => [BuildObj($objct+1,{'Params' => { 'Binding' => '/Background'}, 'Asset' => $asset})],
		    'Subtype' => '/Flash'});

    PutObj($objct);
    $objct++;
    PutObj($objct);
    $objct++;

    my ($x,$y)=split(' ',PutXY($xpos,$ypos));

    push(@{$cpage->{Annots}},BuildObj($objct,{'RichMediaContent' => {'Subtype' => '/Flash', 'Configurations' => [$config], 'Assets' => {'Names' => [ "($node)", $asset ] }},
			'P' => "$cpageno 0 R",
			'RichMediaSettings' => { 'Deactivation' => { 'Condition' => '/PI',
						'Type' => '/RichMediaDeactivation'},
				    'Activation' => { 	'Condition' => '/PV',
						'Type' => '/RichMediaActivation'}},
			'F' => 68,
			'Subtype' => '/RichMedia',
			'Type' => '/Annot',
			'Rect' => "[ $x $y ".($x+$wid)." ".($y+$hgt)." ]",
			'Border' => [0,0,0]}));

    PutObj($objct);

    return $xonm;
}

sub OpenInc
{
    my $fn=shift;
    my $fnm=$fn;
    my $F;

    if (substr($fnm,0,1)  eq '/' or substr($fnm,1,1) eq ':') # dos
    {
	if (-r $fnm and open($F,"<$fnm"))
	{
	    return($F,$fnm);
	}
    }
    else
    {
	foreach my $dir (@idirs)
	{
	    $fnm="$dir/$fn";

	    if (-r "$fnm" and open($F,"<$fnm"))
	    {
		return($F,$fnm);
	    }
	}
    }

    return(undef,$fn);
}

sub LoadPDF
{
    my $pdfnm=shift;
    my $mat=shift;
    my $wid=shift;
    my $hgt=shift;
    my $type=shift;
    my $pdf;
    my $pdftxt='';
    my $strmlen=0;
    my $curobj=-1;
    my $instream=0;
    my $cont;
    my $adj=0;
    my $keepsep=$/;

    my ($PD,$PDnm)=OpenInc($pdfnm);

    if (!defined($PD))
    {
	Msg(0,"Failed to open PDF '$pdfnm'");
	return undef;
    }

    my $hdr=<$PD>;

    $/="\r",$adj=1 if (length($hdr) > 10);

    while (<$PD>)
    {
	chomp;

	s/\n//;

	if (m/endstream(\s+.*)?$/)
	{
	    $instream=0;
	    $_="endstream";
	    $_.=$1 if defined($1)
	}

	next if $instream;

	if (m'/Length\s+(\d+)(\s+\d+\s+R)?')
	{
	    if (!defined($2))
	    {
		$strmlen=$1;
	    }
	    else
	    {
		$strmlen=0;
	    }
	}

	if (m'^(\d+) \d+ obj')
	{
	    $curobj=$1;
	    $pdf->[$curobj]->{OBJ}=undef;
	}

	if (m'stream\s*$' and ! m/^endstream/)
	{
	    if ($curobj > -1)
	    {
		$pdf->[$curobj]->{STREAMPOS}=[tell($PD)+$adj,$strmlen];
		seek($PD,$strmlen,1);
		$instream=1;
	    }
	    else
	    {
		Msg(0,"Parsing PDF '$pdfnm' failed");
		return undef;
	    }
	}

	s/%.*?$//;
	$pdftxt.=$_.' ';
    }

    close($PD);

    open(PD,"<$PDnm");
#	$pdftxt=~s/\]/ \]/g;
    my (@pdfwds)=split(' ',$pdftxt);
    my $wd;
    my $root;

    while ($wd=nextwd(\@pdfwds),length($wd))
    {
	if ($wd=~m/\d+/ and defined($pdfwds[1]) and $pdfwds[1]=~m/^obj(.*)/)
	{
	    $curobj=$wd;
	    shift(@pdfwds); shift(@pdfwds);
	    unshift(@pdfwds,$1) if defined($1) and length($1);
	    $pdf->[$curobj]->{OBJ}=ParsePDFObj(\@pdfwds);
            my $o=$pdf->[$curobj];

            if (ref($o->{OBJ}) eq 'HASH' and exists($o->{OBJ}->{Type}) and $o->{OBJ}->{Type} eq '/ObjStm')
            {
                LoadStream($o,$pdf);
                my $pos=$o->{OBJ}->{First};
                my $s=$o->{STREAM};
                my @o=split(' ',substr($s,0,$pos));
                substr($s,0,$pos)='';
                push(@o,-1,length($s));

                for (my $j=0; $j<=$#o-2; $j+=2)
                {
                    my @w=split(' ',substr($s,$o[$j+1],$o[$j+3]-$o[$j+1]));
                    $pdf->[$o[$j]]->{OBJ}=ParsePDFObj(\@w);
                }

                $pdf->[$curobj]=undef;
            }

            $root=$curobj if ref($pdf->[$curobj]->{OBJ}) eq 'HASH' and exists($pdf->[$curobj]->{OBJ}->{Type}) and $pdf->[$curobj]->{OBJ}->{Type} eq '/XRef';
	}
	elsif ($wd eq 'trailer' and !exists($pdf->[0]->{OBJ}))
	{
	    $pdf->[0]->{OBJ}=ParsePDFObj(\@pdfwds);
	}
	else
	{
#			print "Skip '$wd'\n";
	}
    }

    $pdf->[0]=$pdf->[$root] if !defined($pdf->[0]);
    my $catalog=${$pdf->[0]->{OBJ}->{Root}};
    my $page=FindPage(1,$pdf);
    my $xobj=++$objct;

    # Load the streamas

    foreach my $o (@{$pdf})
    {
	if (exists($o->{STREAMPOS}) and !exists($o->{STREAM}))
	{
            LoadStream($o,$pdf);
        }
    }

    close(PD);

    # Find BBox
    my $BBox;
    my $insmap={};

    foreach my $k (qw( ArtBox TrimBox BleedBox CropBox MediaBox ))
    {
	$BBox=FindKey($pdf,$page,$k);
	last if $BBox;
    }

    $BBox=[0,0,595,842] if !defined($BBox);

    $wid=($BBox->[2]-$BBox->[0]+1) if $wid==0;
    my $xscale=d3(abs($wid)/($BBox->[2]-$BBox->[0]+1));
    my $yscale=d3(($hgt<=0)?$xscale:(abs($hgt)/($BBox->[3]-$BBox->[1]+1)));
    $hgt=($BBox->[3]-$BBox->[1]+1)*$yscale;

    if ($type eq "import")
    {
	$mat->[0]=$xscale;
	$mat->[3]=$yscale;
    }

    # Find Resource

    my $res=FindKey($pdf,$page,'Resources');
    my $xonm="XO$xobj";

    # Map inserted objects to current PDF

    MapInsValue($pdf,$page,'',$insmap,$xobj,$pdf->[$page]->{OBJ});
#
#	Many PDFs include 'Resources' at the 'Page' level but if 'Resources' is held at a higher level (i.e 'Pages')
#	then we need to include its objects as well.
#
    MapInsValue($pdf,$page,'',$insmap,$xobj,$res) if !exists($pdf->[$page]->{OBJ}->{Resources});

    # Copy Resources

    my %incres=%{$res};

    $incres{ProcSet}=['/PDF', '/Text', '/ImageB', '/ImageC', '/ImageI'];

    ($mat->[4],$mat->[5])=split(' ',PutXY($xpos,$ypos));
    $pages->{'Resources'}->{'XObject'}->{$xonm}=BuildObj($xobj,{'Type' => '/XObject', 'BBox' => $BBox, 'Name' => "/$xonm", 'FormType' => 1, 'Subtype' => '/Form', 'Length' => 0, 'Type' => "/XObject", 'Resources' => \%incres});

    if ($BBox->[0] != 0 or $BBox->[1] != 0)
    {
        my (@matrix)=(1,0,0,1,-$BBox->[0],-$BBox->[1]);
        $obj[$xobj]->{DATA}->{Matrix}=\@matrix;
    }

    BuildStream($xobj,$pdf,$pdf->[$page]->{OBJ}->{Contents});

    $/=$keepsep;
    return([$xonm,$BBox] );
}

sub LoadStream
{
    my $o=shift;
    my $pdf=shift;
    my $l;

    $l=$o->{OBJ}->{Length} if exists($o->{OBJ}->{Length});

    $l=$pdf->[$$l]->{OBJ} if (defined($l) && ref($l) eq 'OBJREF');

    Msg(1,"Unable to determine length of stream \@$o->{STREAMPOS}->[0]") if !defined($l);

    sysseek(PD,$o->{STREAMPOS}->[0],0);
    Msg(0,'Failed to read all the stream') if $l != sysread(PD,$o->{STREAM},$l);

    if ($gotzlib and exists($o->{OBJ}->{'Filter'}) and $o->{OBJ}->{'Filter'} eq '/FlateDecode')
    {
        $o->{STREAM}=Compress::Zlib::uncompress($o->{STREAM});
        delete($o->{OBJ }->{'Filter'});
    }
}

sub BuildStream
{
    my $xobj=shift;
    my $pdf=shift;
    my $val=shift;
    my $strm='';
    my $objs;
    my $refval=ref($val);

    if ($refval eq 'OBJREF')
    {
	push(@{$objs}, $val);
    }
    elsif ($refval eq 'ARRAY')
    {
	$objs=$val;
    }
    else
    {
	Msg(0,"unexpected 'Contents'");
    }

    foreach my $o (@{$objs})
    {
	$strm.="\n" if $strm;
	$strm.=$pdf->[$$o]->{STREAM} if exists($pdf->[$$o]->{STREAM});
    }

    $obj[$xobj]->{STREAM}=$strm;
}


sub MapInsHash
{
    my $pdf=shift;
    my $o=shift;
    my $insmap=shift;
    my $parent=shift;
    my $val=shift;


    foreach my $k (sort keys(%{$val}))
    {
	MapInsValue($pdf,$o,$k,$insmap,$parent,$val->{$k}) if $k ne 'Contents';
    }
}

sub MapInsValue
{
    my $pdf=shift;
    my $o=shift;
    my $k=shift;
    my $insmap=shift;
    my $parent=shift;
    my $val=shift;
    my $refval=ref($val);

    if ($refval eq 'OBJREF')
    {
	if ($k ne 'Parent')
	{
	    if (!exists($insmap->{IMP}->{$$val}))
	    {
		$objct++;
		$insmap->{CUR}->{$objct}=$$val;
		$insmap->{IMP}->{$$val}=$objct;
		$obj[$objct]->{DATA}=$pdf->[$$val]->{OBJ};
		$obj[$objct]->{STREAM}=$pdf->[$$val]->{STREAM} if exists($pdf->[$$val]->{STREAM});
		MapInsValue($pdf,$$val,'',$insmap,$o,$pdf->[$$val]->{OBJ});
	    }

	    $$val=$insmap->{IMP}->{$$val};
	}
	else
	{
	    $$val=$parent;
	}
    }
    elsif ($refval eq 'ARRAY')
    {
	foreach my $v (@{$val})
	{
	    MapInsValue($pdf,$o,'',$insmap,$parent,$v)
	}
    }
    elsif ($refval eq 'HASH')
    {
	MapInsHash($pdf,$o,$insmap,$parent,$val);
    }

}

sub FindKey
{
    my $pdf=shift;
    my $page=shift;
    my $k=shift;

    if (exists($pdf->[$page]->{OBJ}->{$k}))
    {
	my $val=$pdf->[$page]->{OBJ}->{$k};
	$val=$pdf->[$$val]->{OBJ} if ref($val) eq 'OBJREF';
	return($val);
    }
    else
    {
	if (exists($pdf->[$page]->{OBJ}->{Parent}))
	{
	    return(FindKey($pdf,${$pdf->[$page]->{OBJ}->{Parent}},$k));
	}
    }

    return(undef);
}

sub FindPage
{
    my $wantpg=shift;
    my $pdf=shift;
    my $catalog=${$pdf->[0]->{OBJ}->{Root}};
    my $pages=${$pdf->[$catalog]->{OBJ}->{Pages}};

    return(NextPage($pdf,$pages,\$wantpg));
}

sub NextPage
{
    my $pdf=shift;
    my $pages=shift;
    my $wantpg=shift;
    my $ret;

    if ($pdf->[$pages]->{OBJ}->{Type} eq '/Pages')
    {
	foreach my $kid (@{$pdf->[$pages]->{OBJ}->{Kids}})
	{
	    $ret=NextPage($pdf,$$kid,$wantpg);
	    last if $$wantpg<=0;
	}
    }
    elsif ($pdf->[$pages]->{OBJ}->{Type} eq '/Page')
    {
	$$wantpg--;
	$ret=$pages;
    }

    return($ret);
}

sub nextwd
{
    my $pdfwds=shift;

    my $wd=shift(@{$pdfwds});

    return('') if !defined($wd);

    if ($wd=~m/^(.*?)(<<|>>|(?:(?<!\\)\[|\]))(.*)/)
    {
	if (defined($1) and length($1))
	{
	    unshift(@{$pdfwds},$3) if defined($3) and length($3);
	    unshift(@{$pdfwds},$2);
	    $wd=$1;
	}
	else
	{
	    unshift(@{$pdfwds},$3) if defined($3) and length($3);
	    $wd=$2;
	}
    }

    return($wd);
}

sub ParsePDFObj
{

    my $pdfwds=shift;
    my $rtn;
    my $wd;

    while ($wd=nextwd($pdfwds),length($wd))
    {
	if ($wd eq 'stream' or $wd eq 'endstream')
	{
	    next;
	}
	elsif ($wd eq 'endobj' or $wd eq 'startxref')
	{
	    last;
	}
	else
	{
	    unshift(@{$pdfwds},$wd);
	    $rtn=ParsePDFValue($pdfwds);
	}
    }

    return($rtn);
}

sub ParsePDFHash
{
    my $pdfwds=shift;
    my $rtn={};
    my $wd;

    while ($wd=nextwd($pdfwds),length($wd))
    {
	if ($wd eq '>>')
	{
	    last;
	}

	my (@w)=split('/',$wd,3);

	if ($w[0])
	{
	    Msg(0,"PDF Dict Key '$wd' does not start with '/'");
	    exit 1;
	}
	else
	{
	    unshift(@{$pdfwds},"/$w[2]") if $w[2];
	    $wd=$w[1];
	    (@w)=split('\(',$wd,2);
	    $wd=$w[0];
	    unshift(@{$pdfwds},"($w[1]") if defined($w[1]);
	    (@w)=split('\<',$wd,2);
	    $wd=$w[0];
	    unshift(@{$pdfwds},"<$w[1]") if defined($w[1]);

	    $rtn->{$wd}=ParsePDFValue($pdfwds);
	}
    }

    return($rtn);
}

sub ParsePDFValue
{
    my $pdfwds=shift;
    my $rtn;
    my $wd=nextwd($pdfwds);

    if ($wd=~m/^\d+$/ and $pdfwds->[0]=~m/^\d+$/ and $pdfwds->[1]=~m/^R(\]|\>|\/)?/)
    {
	shift(@{$pdfwds});
	if (defined($1) and length($1))
	{
	    $pdfwds->[0]=substr($pdfwds->[0],1);
	}
	else
	{
	    shift(@{$pdfwds});
	}
	return(bless(\$wd,'OBJREF'));
    }

    if ($wd eq '<<')
    {
	return(ParsePDFHash($pdfwds));
    }

    if ($wd eq '[')
    {
	return(ParsePDFArray($pdfwds));
    }

    if ($wd=~m/(.*?)(\(.*)$/)
    {
	if (defined($1) and length($1))
	{
	    unshift(@{$pdfwds},$2);
	    $wd=$1;
	}
	else
	{
	    return(ParsePDFString($wd,$pdfwds));
	}
    }

    if ($wd=~m/(.*?)(\<.*)$/)
    {
	if (defined($1) and length($1))
	{
	    unshift(@{$pdfwds},$2);
	    $wd=$1;
	}
	else
	{
	    return(ParsePDFHexString($wd,$pdfwds));
	}
    }

    if ($wd=~m/(.+?)(\/.*)$/)
    {
	if (defined($2) and length($2))
	{
	    unshift(@{$pdfwds},$2);
	    $wd=$1;
	}
    }

    return($wd);
}

sub ParsePDFString
{
    my $wd=shift;
    my $rtn='';
    my $pdfwds=shift;
    my $lev=0;

    while (length($wd))
    {
	$rtn.=' ' if length($rtn);

	while ($wd=~m/(?<!\\)\(/g) {$lev++;}
	while ($wd=~m/(?<!\\)\)/g) {$lev--;}


	if ($lev<=0 and $wd=~m/^(.*?\))([^)]+)$/)
	{
	    unshift(@{$pdfwds},$2) if defined($2) and length($2);
	    $wd=$1;
	}

	$rtn.=$wd;

	last if $lev <= 0;

	$wd=nextwd($pdfwds);
    }

    return($rtn);
}

sub ParsePDFHexString
{
    my $wd=shift;
    my $rtn='';
    my $pdfwds=shift;
    my $lev=0;

    if ($wd=~m/^(<.+?>)(.*)/)
    {
	unshift(@{$pdfwds},$2) if defined($2) and length($2);
	$rtn=$1;
    }

    return($rtn);
}

sub ParsePDFArray
{
    my $pdfwds=shift;
    my $rtn=[];
    my $wd;

    while (1)
    {
	$wd=ParsePDFValue($pdfwds);
	last if $wd eq ']' or length($wd)==0;
	push(@{$rtn},$wd);
    }

    return($rtn);
}

sub Msg
{
    my ($lev,$msg)=@_;

    print STDERR "$env{SourceFile}: " if exists($env{SourceFile});
    print STDERR "$msg\n";
    exit 1 if $lev;
}

sub PutXY
{
    my ($x,$y)=(@_);

    if ($frot)
    {
	return(d3($y)." ".d3($x));
    }
    else
    {
	$y=$mediabox[3]-$y;
	return(d3($x)." ".d3($y));
    }
}

sub GraphY
{
    my $y=shift;

    if ($frot)
    {
	return($y);
    }
    else
    {
	return($mediabox[3]-$y);
    }
}

sub Put
{
    my $msg=shift;

    print $msg;
    $fct+=length($msg);
}

sub PutObj
{
    my $ono=shift;
    my $msg="$ono 0 obj ";
    $obj[$ono]->{XREF}=$fct;
    if (exists($obj[$ono]->{STREAM}))
    {
	if ($gotzlib && !$debug && !exists($obj[$ono]->{DATA}->{'Filter'}))
	{
	    $obj[$ono]->{STREAM}=Compress::Zlib::compress($obj[$ono]->{STREAM});
	    $obj[$ono]->{DATA}->{'Filter'}='/FlateDecode';
	}

	$obj[$ono]->{DATA}->{'Length'}=length($obj[$ono]->{STREAM});
    }
    PutField(\$msg,$obj[$ono]->{DATA});
    PutStream(\$msg,$ono) if exists($obj[$ono]->{STREAM});
    Put($msg."endobj\n");
}

sub PutStream
{
    my $msg=shift;
    my $ono=shift;

    # We could 'flate' here
    $$msg.="stream\n$obj[$ono]->{STREAM}endstream\n";
}

sub PutField
{
    my $pmsg=shift;
    my $fld=shift;
    my $term=shift||"\n";
    my $typ=ref($fld);

    if ($typ eq '')
    {
	$$pmsg.="$fld$term";
    }
    elsif ($typ eq 'ARRAY')
    {
	$$pmsg.='[';
	foreach my $cell (@{$fld})
	{
	    PutField($pmsg,$cell,' ');
	}
	$$pmsg.="]$term";
    }
    elsif ($typ eq 'HASH')
    {
	$$pmsg.='<< ';
	foreach my $key (sort keys %{$fld})
	{
	    $$pmsg.="/$key ";
	    PutField($pmsg,$fld->{$key});
	}
	$$pmsg.=">>$term";
    }
    elsif ($typ eq 'OBJREF')
    {
	$$pmsg.="$$fld 0 R$term";
    }
}

sub BuildObj
{
    my $ono=shift;
    my $val=shift;

    $obj[$ono]->{DATA}=$val;

    return("$ono 0 R ");
}

sub LoadFont
{
    my $fontno=shift;
    my $fontnm=shift;
    my $ofontnm=$fontnm;

    return $fontlst{$fontno}->{OBJ} if (exists($fontlst{$fontno}));

    my $f;
    OpenFile(\$f,$fontdir,"$fontnm");

    if (!defined($f) and $Foundry)
    {
	# Try with no foundry
	$fontnm=~s/.*?-//;
	OpenFile(\$f,$fontdir,$fontnm);
    }

    Msg(1,"Failed to open font '$ofontnm'") if !defined($f);

    my $foundry='';
    $foundry=$1 if $fontnm=~m/^(.*?)-/;
    my $stg=1;
    my %fnt;
    my @fntbbox=(0,0,0,0);
    my $capheight=0;
    my $lastchr=0;
    my $lastnm;
    my $t1flags=0;
    my $fixwid=-1;
    my $ascent=0;
    my $charset='';

    while (<$f>)
    {
	chomp;

	s/^ +//;
	s/^#.*// if $stg == 1;
	next if $_ eq '';

	if ($stg == 1)
	{
	    my ($key,$val)=split(' ',$_,2);

	    $key=lc($key);
	    $stg=2,next if $key eq 'kernpairs';
	    $stg=3,next if lc($_) eq 'charset';

	    $fnt{$key}=$val
	}
	elsif ($stg == 2)
	{
	    $stg=3,next if lc($_) eq 'charset';

	    my ($ch1,$ch2,$k)=split;
# 	    $fnt{KERN}->{$ch1}->{$ch2}=$k;
	}
	else
	{
	    my (@r)=split;
	    my (@p)=split(',',$r[1]);

	    if ($r[1] eq '"')
	    {
		$fnt{NAM}->{$r[0]}=$fnt{NAM}->{$lastnm};
		next;
	    }

	    $r[0]='u0020' if $r[3] == 32;
	    $r[0]="u00".hex($r[3]) if $r[0] eq '---';
#	    next if $r[3] >255;
	    $fnt{NAM}->{$r[0]}=[$p[0],$r[3],'/'.$r[4],$r[3],0];
	    $fnt{NO}->[$r[3]]=[$r[0],$r[0]];
	    $lastnm=$r[0];
	    $lastchr=$r[3] if $r[3] > $lastchr;
	    $fixwid=$p[0] if $fixwid == -1;
	    $fixwid=-2 if $fixwid > 0 and $p[0] != $fixwid;

	    $fntbbox[1]=-$p[2] if defined($p[2]) and -$p[2] < $fntbbox[1];
	    $fntbbox[2]=$p[0] if $p[0] > $fntbbox[2];
	    $fntbbox[3]=$p[1] if defined($p[1]) and $p[1] > $fntbbox[3];
	    $ascent=$p[1] if defined($p[1]) and $p[1] > $ascent and $r[3] >= 32 and $r[3] < 128;
	    $charset.='/'.$r[4] if defined($r[4]);
	    $capheight=$p[1] if length($r[4]) == 1 and $r[4] ge 'A' and $r[4] le 'Z' and $p[1] > $capheight;
	}
    }

    close($f);

    foreach my $j (0..$lastchr)
    {
	$fnt{NO}->[$j]=['',''] if !defined($fnt{NO}->[$j]);
    }

    my $fno=0;
    my $slant=0;
    $fnt{DIFF}=[];
    $fnt{WIDTH}=[];
    $fnt{NAM}->{''}=[0,-1,'/.notdef',-1,0];
    $slant=-$fnt{'slant'} if exists($fnt{'slant'});
    $fnt{'spacewidth'}=700 if !exists($fnt{'spacewidth'});

    $t1flags|=2**0 if $fixwid > -1;
    $t1flags|=(exists($fnt{'special'}))?2**2:2**5;
    $t1flags|=2**6 if $slant != 0;
    my $fontkey="$foundry $fnt{internalname}";

    if (exists($download{$fontkey}))
    {
	# Not a Base Font
	my ($l1,$l2,$l3,$t1stream)=GetType1($download{$fontkey});
	Msg(0,"Incorrect font format for '$fontkey' ($l1)") if !defined($t1stream);
	$fno=++$objct;
	$fontlst{$fontno}->{OBJ}=BuildObj($objct,
			{'Type' => '/Font',
			'Subtype' => '/Type1',
			'BaseFont' => '/'.$fnt{internalname},
			'Widths' => $fnt{WIDTH},
			'FirstChar' => 0,
			'LastChar' => $lastchr,
			'Encoding' => BuildObj($objct+1,
				    {'Type' => '/Encoding',
				    'Differences' => $fnt{DIFF}
				    }
				    ),
			'FontDescriptor' => BuildObj($objct+2,
					{'Type' => '/FontDescriptor',
					'FontName' => '/'.$fnt{internalname},
					'Flags' => $t1flags,
					'FontBBox' => \@fntbbox,
					'ItalicAngle' => $slant,
					'Ascent' => $ascent,
					'Descent' => $fntbbox[1],
					'CapHeight' => $capheight,
					'StemV' => 0,
#					'CharSet' => "($charset)",
					'FontFile' => BuildObj($objct+3,
						    {'Length1' => $l1,
						    'Length2' => $l2,
						    'Length3' => $l3
						    }
						    )
					}
					)
			}
			);

	$objct+=3;
	$fontlst{$fontno}->{NM}='/F'.$fontno;
	$pages->{'Resources'}->{'Font'}->{'F'.$fontno}=$fontlst{$fontno}->{OBJ};
	$fontlst{$fontno}->{FNT}=\%fnt;
	$obj[$objct]->{STREAM}=$t1stream;

    }
    else
    {
	$fno=++$objct;
	$fontlst{$fontno}->{OBJ}=BuildObj($objct,
			{'Type' => '/Font',
			'Subtype' => '/Type1',
			'BaseFont' => '/'.$fnt{internalname},
			'Widths' => $fnt{WIDTH},
			'FirstChar' => 0,
			'LastChar' => $lastchr,
			'Encoding' => BuildObj($objct+1,
				    {'Type' => '/Encoding',
				    'Differences' => $fnt{DIFF}
				    }
				    ),
			'FontDescriptor' => BuildObj($objct+2,
					{'Type' => '/FontDescriptor',
					'FontName' => '/'.$fnt{internalname},
					'Flags' => $t1flags,
					'FontBBox' => \@fntbbox,
					'ItalicAngle' => $slant,
					'Ascent' => $ascent,
					'Descent' => $fntbbox[1],
					'CapHeight' => $capheight,
					'StemV' => 0,
					'CharSet' => "($charset)",
					}
					)
			}
			);

	$objct+=2;
	$fontlst{$fontno}->{NM}='/F'.$fontno;
	$pages->{'Resources'}->{'Font'}->{'F'.$fontno}=$fontlst{$fontno}->{OBJ};
	$fontlst{$fontno}->{FNT}=\%fnt;
    }

    if (defined($fnt{encoding}) and $fnt{encoding} eq 'text.enc' and $ucmap ne '')
    {
	if ($textenccmap eq '')
	{
	    $textenccmap = BuildObj($objct+1,{});
	    $objct++;
	    $obj[$objct]->{STREAM}=$ucmap;
	}
	$obj[$fno]->{DATA}->{'ToUnicode'}=$textenccmap;
    }

#     PutObj($fno);
#     PutObj($fno+1);
#     PutObj($fno+2) if defined($obj[$fno+2]);
#     PutObj($fno+3) if defined($obj[$fno+3]);
}

sub GetType1
{
    my $file=shift;
    my ($l1,$l2,$l3);		# Return lengths
    my ($head,$body,$tail);		# Font contents
    my $f;

    OpenFile(\$f,$fontdir,"$file");
    Msg(1,"Failed to open '$file'") if !defined($f);

    $head=GetChunk($f,1,"currentfile eexec");
    $body=GetChunk($f,2,"00000000") if !eof($f);
    $tail=GetChunk($f,3,"cleartomark") if !eof($f);

    $l1=length($head);
    $l2=length($body);
    $l3=length($tail);

    return($l1,$l2,$l3,"$head$body$tail");
}

sub GetChunk
{
    my $F=shift;
    my $segno=shift;
    my $ascterm=shift;
    my ($type,$hdr,$chunk,@msg);
    binmode($F);
    my $enc="ascii";

    while (1)
    {
	# There may be multiple chunks of the same type

	my $ct=read($F,$hdr,2);

	if ($ct==2)
	{
	    if (substr($hdr,0,1) eq "\x80")
	    {
		# binary chunk

		my $chunktype=ord(substr($hdr,1,1));
		$enc="binary";

		if (defined($type) and $type != $chunktype)
		{
		    seek($F,-2,1);
		    last;
		}

		$type=$chunktype;
		return if $chunktype == 3;

		$ct=read($F,$hdr,4);

		Msg(1,"Failed to read binary segment length"), return if $ct != 4;

		my $sl=unpack('V',$hdr);
		my $data;
		my $chk=read($F,$data,$sl);

		Msg(1 ,"Failed to read binary segment"), return if $chk != $sl;

		$chunk.=$data;
	    }
	    else
	    {
		# ascii chunk

		my $hex=0;
		seek($F,-2,1);
		my $ct=0;

		while (1)
		{
		    my $lin=<$F>;

		    last if !$lin;

		    $hex=1,$enc.=" hex" if $segno == 2 and !$ct and $lin=~m/^[A-F0-9a-f]{4,4}/;

		    if ($segno !=2 and $lin=~m/^(.*$ascterm\n?)(.*)/)
		    {
			$chunk.=$1;
			seek($F,-length($2)-1,1) if $2;
			last;
		    }
		    elsif ($segno == 2 and $lin=~m/^(.*?)($ascterm.*)/)
		    {
			$chunk.=$1;
			seek($F,-length($2)-1,1) if $2;
			last;
		    }

		    chomp($lin), $lin=pack('H*',$lin) if $hex;
		    $chunk.=$lin; $ct++;
		}

		last;
	    }
	}
	else
	{
	    push(@msg,"Failed to read 2 header bytes");
	}
    }

    return $chunk;
}

sub OutStream
{
    my $ono=shift;

    IsGraphic();
    $stream.="Q\n";
    $obj[$ono]->{STREAM}=$stream;
    $obj[$ono]->{DATA}->{Length}=length($stream);
    $stream='';
    PutObj($ono);
}

sub do_p
{
    my $trans='BLOCK';

    $trans='PAGE' if $firstpause;
    NewPage($trans);
    @XOstream=();
    @PageAnnots=();
    $firstpause=1;
}

sub FixTrans
{
    my $t=shift;
    my $style=$t->{S};

    if ($style)
    {
	delete($t->{Dm}) if $style ne '/Split' and $style ne '/Blinds';
	delete($t->{M})  if !($style eq '/Split' or $style eq '/Box' or $style eq '/Fly');
	delete($t->{Di}) if !($style eq '/Wipe' or $style eq '/Glitter' or $style eq '/Fly' or $style eq '/Cover' or $style eq '/Uncover' or $style eq '/Push') or ($style eq '/Fly' and $t->{Di} eq '/None' and $t->{SS} != 1);
	delete($t->{SS}) if !($style eq '/Fly');
	delete($t->{B})  if !($style eq '/Fly');
    }

    return($t);
}

sub NewPage
{
    my $trans=shift;
    # Start of pages

    if ($cpageno > 0)
    {
	if ($#XOstream>=0)
	{
	    MakeXO() if $stream;
	    $stream=join("\n",@XOstream,'');
	}

	my %t=%{$transition->{$trans}};
	$cpage->{MediaBox}=\@mediabox if $custompaper;
	$cpage->{Trans}=FixTrans(\%t) if $t{S};

	if ($#PageAnnots >= 0)
	{
	    @{$cpage->{Annots}}=@PageAnnots;
	}

	if ($#bgstack > -1 or $bgbox)
	{
	    my $box="q 1 0 0 1 0 0 cm ";

	    foreach my $bg (@bgstack)
	    {
		# 0=$bgtype # 1=stroke 2=fill. 4=page
		# 1=$strkcol
		# 2=$fillcol
		# 3=(Left,Top,Right,bottom,LineWeight)
		# 4=Start ypos
		# 5=Endypos
		# 6=Line Weight

		my $pg=$bg->[3] || \@defaultmb;

		$bg->[5]=$pg->[3];	# box is continueing to next page
		$box.=DrawBox($bg);
		$bg->[4]=$pg->[1];	# will continue from page top
	    }

	    $stream=$box.$bgbox."Q\n".$stream;
	    $bgbox='';
	    $boxmax=0;
	}

	PutObj($cpageno);
	OutStream($cpageno+1);
    }

    $cpageno=++$objct;

    my $thispg=BuildObj($objct,
		    {'Type' => '/Page',
		    'Group' => {'CS' => '/DeviceRGB', 'S' => '/Transparency'},
		    'Parent' => '2 0 R',
		    'Contents' => [ BuildObj($objct+1,
				{'Length' => 0}
				) ],
		    }
	);

    splice(@{$pages->{Kids}},++$pginsert,0,$thispg);
    splice(@outlines,$pginsert,0,[$curoutlev,$#{$curoutlev}+1,$thislev]);

    $objct+=1;
    $cpage=$obj[$cpageno]->{DATA};
    $pages->{'Count'}++;
    $stream="q 1 0 0 1 0 0 cm\n$linejoin J\n$linecap j\n0.4 w\n";
    $stream.=$strkcol."\n", $curstrk=$strkcol if $strkcol ne '';
    $mode='g';
    $curfill='';
#    @mediabox=@defaultmb;
}

sub DrawBox
{
    my $bg=shift;
    my $res='';
    my $pg=$bg->[3] || \@mediabox;
    $bg->[4]=$pg->[1], $bg->[5]=$pg->[3] if $bg->[0] & 4;
    my $bot=$bg->[5];
    $bot=$boxmax if $boxmax > $bot;
    my $wid=$pg->[2]-$pg->[0];
    my $dep=$bot-$bg->[4];

    $res="$bg->[1] $bg->[2] $bg->[6] w\n";
    $res.="$pg->[0] $bg->[4] $wid $dep re f " if $bg->[0] & 1;
    $res.="$pg->[0] $bg->[4] $wid $dep re s " if $bg->[0] & 2;
    return("$res\n");
}

sub MakeXO
{
    $stream.="%mode=$mode\n";
    IsGraphic();
    $stream.="Q\n";
    my $xobj=++$objct;
    my $xonm="XO$xobj";
    $pages->{'Resources'}->{'XObject'}->{$xonm}=BuildObj($xobj,{'Type' => '/XObject', 'BBox' => \@mediabox, 'Name' => "/$xonm", 'FormType' => 1, 'Subtype' => '/Form', 'Length' => 0, 'Type' => "/XObject"});
    $obj[$xobj]->{STREAM}=$stream;
    $stream='';
    push(@XOstream,"q") if $#XOstream==-1;
    push(@XOstream,"/$xonm Do");
}

sub do_f
{
    my $par=shift;
    my $fnt=$fontlst{$par}->{FNT};

#	IsText();
    $cft="$par";
    $fontchg=1;
#	$stream.="/F$cft $cftsz Tf\n" if $cftsz;
    $widtbl=CacheWid($par);
    $origwidtbl=[];

    foreach my $w (@{$fnt->{NO}})
    {
	push(@{$origwidtbl},$fnt->{NAM}->{$w->[1]}->[WIDTH]);
    }

#     $krntbl=$fnt->{KERN};
}

sub CacheWid
{
    my $par=shift;

    if (!defined($fontlst{$par}->{CACHE}->{$cftsz}))
    {
	$fontlst{$par}->{CACHE}->{$cftsz}=BuildCache($fontlst{$par}->{FNT});
    }

    return($fontlst{$par}->{CACHE}->{$cftsz});
}

sub BuildCache
{
    my $fnt=shift;
    my @cwid;
    $origwidtbl=[];

    foreach my $w (@{$fnt->{NO}})
    {
	my $wid=(defined($w) and defined($w->[1]))?$fnt->{NAM}->{$w->[1]}->[WIDTH]:0;
	push(@cwid,$wid*$cftsz);
	push(@{$origwidtbl},$wid);
    }

    return(\@cwid);
}

sub IsText
{
    if ($mode eq 'g')
    {
	$xpos+=$pendmv/$unitwidth;
	$stream.="q BT\n$matrix ".PutXY($xpos,$ypos)." Tm\n";
	$poschg=0;
	$fontchg=0;
	$pendmv=0;
	$matrixchg=0;
	$tmxpos=$xpos;
	$stream.=$textcol."\n", $curfill=$textcol if $textcol ne $curfill;
	if (defined($cft))
	{
	    $whtsz=$fontlst{$cft}->{FNT}->{spacewidth}*$cftsz;
	    $stream.="/F$cft $cftsz Tf\n";
	}
	$stream.="$curkern Tc\n";
    }

    if ($poschg or $matrixchg)
    {
	PutLine(0) if $matrixchg;
	$stream.="$matrix ".PutXY($xpos,$ypos)." Tm\n", $poschg=0;
	$tmxpos=$xpos;
	$matrixchg=0;
	$stream.="$curkern Tc\n";
    }

    if ($fontchg)
    {
	PutLine(0);
	$whtsz=$fontlst{$cft}->{FNT}->{spacewidth}*$cftsz;
	$stream.="/F$cft $cftsz Tf\n" if $cftsz and defined($cft);
	$fontchg=0;
    }

    $mode='t';
}

sub IsGraphic
{
    if ($mode eq 't')
    {
	PutLine();
	$stream.="ET Q\n";
	$xpos+=($pendmv-$nomove)/$unitwidth;
	$pendmv=0;
	$nomove=0;
	$stream.=$strkcol."\n", $curstrk=$strkcol if $strkcol ne $curstrk;
	$curfill=$fillcol;
    }
    $mode='g';
}

sub do_s
{
    my $par=shift;
    $par/=$unitwidth;

    if ($par != $cftsz and defined($cft))
    {
	PutLine();
	$cftsz=$par;
	Set_LWidth() if $lwidth < 1;
#		$stream.="/F$cft $cftsz Tf\n";
	$fontchg=1;
	$widtbl=CacheWid($cft);
    }
    else
    {
	$cftsz=$par;
	Set_LWidth() if $lwidth < 1;
    }
}

sub Set_LWidth
{
    IsGraphic();
    $stream.=((($desc{res}/(72*$desc{sizescale}))*$linewidth*$cftsz)/1000)." w\n";
    return;
}

sub do_m
{
    # Groff uses /m[] for text & graphic stroke, and /M[] (DF?) for graphic fill.
    # PDF uses G/RG/K for graphic stroke, and g/rg/k for text & graphic fill.
    #
    # This means that we must maintain g/rg/k state separately for text colour & graphic fill (this is
    # probably why 'gs' maintains seperate graphic states for text & graphics when distilling PS -> PDF).
    #
    # To facilitate this:-
    #
    #	$textcol	= current groff stroke colour
    #	$fillcol	= current groff fill colour
    #	$curfill	= current PDF fill colour

    my $par=shift;
    my $mcmd=substr($par,0,1);

    $par=substr($par,1);
    $par=~s/^ +//;

#	IsGraphic();

    $textcol=set_col($mcmd,$par,0);
    $strkcol=set_col($mcmd,$par,1);

    if ($mode eq 't')
    {
	PutLine();
	$stream.=$textcol."\n";
	$curfill=$textcol;
    }
    else
    {
	$stream.="$strkcol\n";
	$curstrk=$strkcol;
    }
}

sub set_col
{
    my $mcmd=shift;
    my $par=shift;
    my $upper=shift;
    my @oper=('g','k','rg');

    @oper=('G','K','RG') if $upper;

    if ($mcmd eq 'd')
    {
	# default colour
	return("0 $oper[0]");
    }

    my (@c)=split(' ',$par);

    if ($mcmd eq 'c')
    {
	# Text CMY
	return(d3($c[0]/65535).' '.d3($c[1]/65535).' '.d3($c[2]/65535)." 0 $oper[1]");
    }
    elsif ($mcmd eq 'k')
    {
	# Text CMYK
	return(d3($c[0]/65535).' '.d3($c[1]/65535).' '.d3($c[2]/65535).' '.d3($c[3]/65535)." $oper[1]");
    }
    elsif ($mcmd eq 'g')
    {
	# Text Grey
	return(d3($c[0]/65535)." $oper[0]");
    }
    elsif ($mcmd eq 'r')
    {
	# Text RGB0
	return(d3($c[0]/65535).' '.d3($c[1]/65535).' '.d3($c[2]/65535)." $oper[2]");
    }
}

sub do_D
{
    my $par=shift;
    my $Dcmd=substr($par,0,1);

    $par=substr($par,1);
    $xpos+=$pendmv/$unitwidth;
    $pendmv=0;

    IsGraphic();

    if ($Dcmd eq 'F')
    {
	my $mcmd=substr($par,0,1);

	$par=substr($par,1);
	$par=~s/^ +//;

	$fillcol=set_col($mcmd,$par,0);
	$stream.="$fillcol\n";
	$curfill=$fillcol;
    }
    elsif ($Dcmd eq 'f')
    {
	my $mcmd=substr($par,0,1);

	$par=substr($par,1);
	$par=~s/^ +//;
	($par)=split(' ',$par);

	if ($par >= 0 and $par <= 1000)
	{
	    $fillcol=set_col('g',int((1000-$par)*65535/1000),0);
	}
	else
	{
	    $fillcol=lc($textcol);
	}

	$stream.="$fillcol\n";
	$curfill=$fillcol;
    }
    elsif ($Dcmd eq '~')
    {
	# B-Spline
	my (@p)=split(' ',$par);
	my ($nxpos,$nypos);

	foreach my $p (@p) { $p/=$unitwidth; }
	$stream.=PutXY($xpos,$ypos)." m\n";
	$xpos+=($p[0]/2);
	$ypos+=($p[1]/2);
	$stream.=PutXY($xpos,$ypos)." l\n";

	for (my $i=0; $i < $#p-1; $i+=2)
	{
	    $nxpos=(($p[$i]*$tnum)/(2*$tden));
	    $nypos=(($p[$i+1]*$tnum)/(2*$tden));
	    $stream.=PutXY(($xpos+$nxpos),($ypos+$nypos))." ";
	    $nxpos=($p[$i]/2 + ($p[$i+2]*($tden-$tnum))/(2*$tden));
	    $nypos=($p[$i+1]/2 + ($p[$i+3]*($tden-$tnum))/(2*$tden));
	    $stream.=PutXY(($xpos+$nxpos),($ypos+$nypos))." ";
	    $nxpos=(($p[$i]-$p[$i]/2) + $p[$i+2]/2);
	    $nypos=(($p[$i+1]-$p[$i+1]/2) + $p[$i+3]/2);
	    $stream.=PutXY(($xpos+$nxpos),($ypos+$nypos))." c\n";
	    $xpos+=$nxpos;
	    $ypos+=$nypos;
	}

	$xpos+=($p[$#p-1]-$p[$#p-1]/2);
	$ypos+=($p[$#p]-$p[$#p]/2);
	$stream.=PutXY($xpos,$ypos)." l\nS\n";
	$poschg=1;
    }
    elsif ($Dcmd eq 'p' or $Dcmd eq 'P')
    {
	# Polygon
	my (@p)=split(' ',$par);
	my ($nxpos,$nypos);

	foreach my $p (@p) { $p/=$unitwidth; }
	$stream.=PutXY($xpos,$ypos)." m\n";

	for (my $i=0; $i < $#p; $i+=2)
	{
	    $xpos+=($p[$i]);
	    $ypos+=($p[$i+1]);
	    $stream.=PutXY($xpos,$ypos)." l\n";
	}

	if ($Dcmd eq 'p')
	{
	    $stream.="s\n";
	}
	else
	{
	    $stream.="f\n";
	}
	$poschg=1;
    }
    elsif ($Dcmd eq 'c')
    {
	# Stroke circle
	$par=substr($par,1);
	my (@p)=split(' ',$par);

	DrawCircle($p[0],$p[0]);
	$stream.="s\n";
	$poschg=1;
    }
    elsif ($Dcmd eq 'C')
    {
	# Fill circle
	$par=substr($par,1);
	my (@p)=split(' ',$par);

	DrawCircle($p[0],$p[0]);
	$stream.="f\n";
	$poschg=1;
    }
    elsif ($Dcmd eq 'e')
    {
	# Stroke ellipse
	$par=substr($par,1);
	my (@p)=split(' ',$par);

	DrawCircle($p[0],$p[1]);
	$stream.="s\n";
	$poschg=1;
    }
    elsif ($Dcmd eq 'E')
    {
	# Fill ellipse
	$par=substr($par,1);
	my (@p)=split(' ',$par);

	DrawCircle($p[0],$p[1]);
	$stream.="f\n";
	$poschg=1;
    }
    elsif ($Dcmd eq 'l')
    {
	# Line To
	$par=substr($par,1);
	my (@p)=split(' ',$par);

	foreach my $p (@p) { $p/=$unitwidth; }
	$stream.=PutXY($xpos,$ypos)." m\n";
	$xpos+=$p[0];
	$ypos+=$p[1];
	$stream.=PutXY($xpos,$ypos)." l\n";

	$stream.="S\n";
	$poschg=1;
    }
    elsif ($Dcmd eq 't')
    {
	# Line Thickness
	$par=substr($par,1);
	my (@p)=split(' ',$par);

	foreach my $p (@p) { $p/=$unitwidth; }
	#		$xpos+=$p[0]*100;		# WTF!!!
	#int lw = ((font::res/(72*font::sizescale))*linewidth*env->size)/1000;
	$p[0]=(($desc{res}/(72*$desc{sizescale}))*$linewidth*$cftsz)/1000 if $p[0] < 0;
	$lwidth=$p[0];
	$stream.="$p[0] w\n";
	$poschg=1;
	$xpos+=$lwidth;
    }
    elsif ($Dcmd eq 'a')
    {
	# Arc
	$par=substr($par,1);
	my (@p)=split(' ',$par);
	my $rad180=3.14159;
	my $rad360=$rad180*2;
	my $rad90=$rad180/2;

	foreach my $p (@p) { $p/=$unitwidth; }

	# Documentation is wrong. Groff does not use Dh1,Dv1 as centre of the circle!

	my $centre=adjust_arc_centre(\@p);

	# Using formula here : http://www.tinaja.com/glib/bezcirc2.pdf
	# First calculate angle between start and end point

	my ($startang,$r)=RtoP(-$centre->[0],$centre->[1]);
	my ($endang,$r2)=RtoP(($p[0]+$p[2])-$centre->[0],-($p[1]+$p[3]-$centre->[1]));
	$endang+=$rad360 if $endang < $startang;
	my $totang=($endang-$startang)/4;	# do it in 4 pieces

	# Now 1 piece

	my $x0=cos($totang/2);
	my $y0=sin($totang/2);
	my $x3=$x0;
	my $y3=-$y0;
	my $x1=(4-$x0)/3;
	my $y1=((1-$x0)*(3-$x0))/(3*$y0);
	my $x2=$x1;
	my $y2=-$y1;

	# Rotate to start position and draw 4 pieces

	foreach my $j (0..3)
	{
	    PlotArcSegment($totang/2+$startang+$j*$totang,$r,$xpos+$centre->[0],GraphY($ypos+$centre->[1]),$x0,$y0,$x1,$y1,$x2,$y2,$x3,$y3);
	}

	$xpos+=$p[0]+$p[2];
	$ypos+=$p[1]+$p[3];

	$poschg=1;
    }
}

sub deg
{
    return int($_[0]*180/3.14159);
}

sub adjust_arc_centre
{
    # Taken from geometry.cpp

    # We move the center along a line parallel to the line between
    # the specified start point and end point so that the center
    # is equidistant between the start and end point.
    # It can be proved (using Lagrange multipliers) that this will
    # give the point nearest to the specified center that is equidistant
    # between the start and end point.

    my $p=shift;
    my @c;
    my $x = $p->[0] + $p->[2];	# (x, y) is the end point
    my $y = $p->[1] + $p->[3];
    my $n = $x*$x + $y*$y;
    if ($n != 0)
    {
	$c[0]= $p->[0];
	$c[1] = $p->[1];
	my $k = .5 - ($c[0]*$x + $c[1]*$y)/$n;
	$c[0] += $k*$x;
	$c[1] += $k*$y;
	return(\@c);
    }
    else
    {
	return(undef);
    }
}


sub PlotArcSegment
{
    my ($ang,$r,$transx,$transy,$x0,$y0,$x1,$y1,$x2,$y2,$x3,$y3)=@_;
    my $cos=cos($ang);
    my $sin=sin($ang);
    my @mat=($cos,$sin,-$sin,$cos,0,0);
    my $lw=$lwidth/$r;

    $stream.="q $r 0 0 $r $transx $transy cm ".join(' ',@mat)." cm $lw w $x0 $y0 m $x1 $y1 $x2 $y2 $x3 $y3 c S Q\n";
}

sub DrawCircle
{
    my $hd=shift;
    my $vd=shift;
    my $hr=$hd/2/$unitwidth;
    my $vr=$vd/2/$unitwidth;
    my $kappa=0.5522847498;
    $hd/=$unitwidth;
    $vd/=$unitwidth;


    $stream.=PutXY(($xpos+$hd),$ypos)." m\n";
    $stream.=PutXY(($xpos+$hd),($ypos+$vr*$kappa))." ".PutXY(($xpos+$hr+$hr*$kappa),($ypos+$vr))." ".PutXY(($xpos+$hr),($ypos+$vr))." c\n";
    $stream.=PutXY(($xpos+$hr-$hr*$kappa),($ypos+$vr))." ".PutXY(($xpos),($ypos+$vr*$kappa))." ".PutXY(($xpos),($ypos))." c\n";
    $stream.=PutXY(($xpos),($ypos-$vr*$kappa))." ".PutXY(($xpos+$hr-$hr*$kappa),($ypos-$vr))." ".PutXY(($xpos+$hr),($ypos-$vr))." c\n";
    $stream.=PutXY(($xpos+$hr+$hr*$kappa),($ypos-$vr))." ".PutXY(($xpos+$hd),($ypos-$vr*$kappa))." ".PutXY(($xpos+$hd),($ypos))." c\n";
    $xpos+=$hd;

    $poschg=1;
}

sub FindCircle
{
    my ($x1,$y1,$x2,$y2,$x3,$y3)=@_;
    my ($Xo, $Yo);

    my $x=$x2+$x3;
    my $y=$y2+$y3;
    my $n=$x**2+$y**2;

    if ($n)
    {
	my $k=.5-($x2*$x + $y2*$y)/$n;
	return(sqrt($n),$x2+$k*$x,$y2+$k*$y);
    }
    else
    {
	return(-1);
    }

}

sub PtoR
{
    my ($theta,$r)=@_;

    return($r*cos($theta),$r*sin($theta));
}

sub RtoP
{
    my ($x,$y)=@_;

    return(atan2($y,$x),sqrt($x**2+$y**2));
}

sub PutLine
{

    my $f=shift;

    IsText() if !defined($f);

    return if (scalar(@lin) == 0) or (!defined($lin[0]->[0]) and $#lin == 0);

#	$stream.="% --- wht=$whtsz, pend=$pendmv, nomv=$nomove\n" if $debug;
    $pendmv-=$nomove;
    $lin[$#lin]->[1]=-$pendmv/$cftsz if ($pendmv != 0);

    foreach my $wd (@lin)
    {
	next if !defined($wd->[0]);
	$wd->[0]=~s/\\/\\\\/g;
	$wd->[0]=~s/\(/\\(/g;
	$wd->[0]=~s/\)/\\)/g;
	$wd->[0]=~s/!\|!\|/\\/g;
	$wd->[1]=d3($wd->[1]);
    }

    if (0)
    {
	if (scalar(@lin) == 1 and (!defined($lin[0]->[1]) or $lin[0]->[1] == 0))
	{
	    $stream.="($lin[0]->[0]) Tj\n";
	}
	else
	{
	    $stream.="[";

	    foreach my $wd (@lin)
	    {
		$stream.="($wd->[0]) " if defined($wd->[0]);
		$stream.="$wd->[1] " if defined($wd->[1]) and $wd->[1] != 0;
	    }

	    $stream.="] TJ\n";
	}
    }
    else
    {
	if (scalar(@lin) == 1 and (!defined($lin[0]->[1]) or $lin[0]->[1] == 0))
	{
	    $stream.="0 Tw ($lin[0]->[0]) Tj\n";
	}
	else
	{
	    if ($wt>=-1 or $#lin == 0 or $lin[0]->[1]>=0)
	    {
		$stream.="0 Tw [";

		foreach my $wd (@lin)
		{
		    $stream.="($wd->[0]) " if defined($wd->[0]);
		    $stream.="$wd->[1] " if defined($wd->[1]) and $wd->[1] != 0;
		}

		$stream.="] TJ\n";
	    }
	    else
	    {
    # 			$stream.="\%dg  0 Tw [";
    #
    # 			foreach my $wd (@lin)
    # 			{
    #  				$stream.="($wd->[0]) " if defined($wd->[0]);
    # 				$stream.="$wd->[1] " if defined($wd->[1]) and $wd->[1] != 0;
    # 			}
    #
    # 			$stream.="] TJ\n";
    #
    #				my $wt=$lin[0]->[1]||0;

    # 			while ($wt < -$whtsz/$cftsz)
    # 			{
    # 				$wt+=$whtsz/$cftsz;
    # 			}

		$stream.=sprintf( "%.3f Tw ",-($whtsz+$wt*$cftsz)/$unitwidth-$curkern );
		if (!defined($lin[0]->[0]) and defined($lin[0]->[1]))
		{
		    $stream.="[ $lin[0]->[1] (";
		    shift @lin;
		}
		else
		{
		    $stream.="[(";
		}

		foreach my $wd (@lin)
		{
		    my $wwt=$wd->[1]||0;

		    while ($wwt <= $wt+.1)
		    {
			$wwt-=$wt;
			$wd->[0].=' ';
		    }

		    if (abs($wwt) < .1 or $wwt == 0)
		    {
			$stream.="$wd->[0]" if defined($wd->[0]);
		    }
		    else
		    {
			$wwt=sprintf("%.3f",$wwt);
			$stream.="$wd->[0]) $wwt (" if defined($wd->[0]);
		    }
		}
		$stream.=")] TJ\n";
	    }
	}
    }

    @lin=();
    $xpos+=$pendmv/$unitwidth;
    $pendmv=0;
    $nomove=0;
    $wt=-1;
}

sub d3
{
    return(sprintf("%.3f",shift || 0));
}

sub  LoadAhead
{
    my $no=shift;

    foreach my $j (1..$no)
    {
	my $lin=<>;
	chomp($lin);
	$lin=~s/\r$//;
	$lct++;

	push(@ahead,$lin);
	$stream.="%% $lin\n" if $debug;
    }
}

sub do_V
{
    my $par=shift;

    if ($mode eq 't')
    {
	PutLine();
    }
    else
    {
	$xpos+=$pendmv/$unitwidth;
	$pendmv=0;
    }

    $ypos=$par/$unitwidth;

    LoadAhead(1);

    if (substr($ahead[0],0,1) eq 'H')
    {
	$xpos=substr($ahead[0],1)/$unitwidth;

	$nomove=$pendmv=0;
	@ahead=();

    }

    $poschg=1;
}

sub do_v
{
    my $par=shift;

    PutLine() if $mode eq 't';

    $ypos+=$par/$unitwidth;

    $poschg=1;
}

sub TextWid
{
    my $txt=shift;
    my $fnt=shift;
    my $w=0;
    my $ck=0;

    foreach my $c (split('',$txt))
    {
	my $cn=ord($c);
	$widtbl->[$cn]=$origwidtbl->[$cn]*$cftsz if !defined($widtbl->[$cn]);
	$w+=$widtbl->[$cn];
    }

    $ck=length($txt)*$curkern;

    return(($w/$unitwidth)+$ck);
}

sub do_t
{
    my $par=shift;
    my $fnt=$fontlst{$cft}->{FNT};

    if ($kernadjust != $curkern)
    {
	PutLine();
	$stream.="$kernadjust Tc\n";
	$curkern=$kernadjust;
    }

    my $par2=$par;
    $par2=~s/^!\|!\|(\d\d\d)/chr(oct($1))/e;

    foreach my $j (0..length($par2)-1)
    {
	my $cn=ord(substr($par2,$j,1));
	my $chnm=$fnt->{NAM}->{$fnt->{NO}->[$cn]->[1]};

	if ($chnm->[USED]==0)
	{
	    $chnm->[USED]=1;
	}
	elsif ($fnt->{NO}->[$cn]->[0] ne $fnt->{NO}->[$cn]->[1])
	{
	    # A glyph has already been remapped to this char, so find a spare

	    my $cn2=RemapChr($cn,$fnt,$fnt->{NO}->[$cn]->[0]);
	    $stream.="% MMM Remap $cn to $cn2\n" if $debug;

	    if ($cn2)
	    {
		substr($par2,$j,1)=chr($cn2);

		if ($par=~m/^!\|!\|(\d\d\d)/)
		{
		    substr($par,4,3)=sprintf("%03o",$cn2);
		}
		else
		{
		    substr($par,$j,1)=chr($cn2);
		}
	    }
	}
    }
    my $wid=TextWid($par2,$fnt);

    $par=reverse(split('',$par)) if $xrev and $par!~m/^!\|!\|(\d\d\d)/;

    if ($n_flg and defined($mark))
    {
	$mark->{ypos}=$ypos;
	$mark->{xpos}=$xpos;
    }

    $n_flg=0;
    IsText();

    $xpos+=$wid;
    $xpos+=($pendmv-$nomove)/$unitwidth;

    $stream.="% == '$par'=$wid 'xpos=$xpos\n" if $debug;

    # $pendmv = 'h' move since last 't'
    # $nomove = width of char(s) added by 'C', 'N' or 'c'
    # $w-flg  = 'w' seen since last t

    if ($fontchg)
    {
	PutLine();
	$whtsz=$fontlst{$cft}->{FNT}->{spacewidth}*$cftsz;
	$stream.="/F$cft $cftsz Tf\n", $fontchg=0 if $fontchg && defined($cft);
    }

    $gotT=1;

    $stream.="% --- wht=$whtsz, pend=$pendmv, nomv=$nomove\n" if $debug;

# 	if ($w_flg && $#lin > -1)
# 	{
# 		$lin[$#lin]->[0].=' ';
# 		$pendmv-=$whtsz;
# 		$dontglue=1 if $pendmv==0;
# 	}

    $wt=-$pendmv/$cftsz if $w_flg and $wt==-1;
    $pendmv-=$nomove;
    $nomove=0;
    $w_flg=0;

    if ($xrev)
    {
	PutLine(0) if $#lin > -1;
	MakeMatrix(1);
	$stream.="$matrix ".PutXY($xpos,$ypos)." Tm\n", $poschg=0;
	$stream.="$curkern Tc\n";
	$stream.="0 Tw ";
	$stream.="($par) Tj\n";
	MakeMatrix();
	$stream.="$matrix ".PutXY($xpos,$ypos)." Tm\n", $poschg=0;
	$matrixchg=0;
	$stream.="$curkern Tc\n";
	return;
    }

    if ($pendmv)
    {
	if ($#lin == -1)
	{
	    push(@lin,[undef,-$pendmv/$cftsz]);
	}
	else
	{
	    $lin[$#lin]->[1]=-$pendmv/$cftsz;
	}

	push(@lin,[$par,undef]);
#		$xpos+=$pendmv/$unitwidth;
	$pendmv=0
    }
    else
    {
	if ($#lin == -1)
	{
	    push(@lin,[$par,undef]);
	}
	else
	{
	    $lin[$#lin]->[0].=$par;
	}
    }
}

sub do_u
{
    my $par=shift;

    $par=m/([+-]?\d+) (.*)/;
    $kernadjust=$1/$unitwidth;
    do_t($2);
    $kernadjust=0;
}

sub do_h
{
    $pendmv+=shift;
}

sub do_H
{
    my $par=shift;

    if ($mode eq 't')
    {
	PutLine();
    }
    else
    {
	$xpos+=$pendmv/$unitwidth;
	$pendmv=0;
    }

    my $newx=$par/$unitwidth;
    $stream.=sprintf("%.3f",$newx-$tmxpos)." 0 Td\n" if $mode eq 't';
    $tmxpos=$xpos=$newx;
    $pendmv=$nomove=0;
}

sub do_C
{
    my $par=shift;

    my ($par2,$nm)=FindChar($par);

    do_t($par2);
    $nomove=$fontlst{$cft}->{FNT}->{NAM}->{$par}->[WIDTH]*$cftsz ;
}

sub FindChar
{
    my $chnm=shift;
    my $fnt=$fontlst{$cft}->{FNT};

    if (exists($fnt->{NAM}->{$chnm}))
    {
	my $ch=$fnt->{NAM}->{$chnm}->[ASSIGNED];
	$ch=RemapChr($ch,$fnt,$chnm) if ($ch > 255);
	$fnt->{NAM}->{$chnm}->[USED]=0 if $fnt->{NO}->[$ch]->[1] eq $chnm;

	return(($ch<32)?sprintf("!|!|%03o",$ch):chr($ch),$widtbl->[$ch]);
    }
    else
    {
	return(' ');
    }
}

sub RemapChr
{
    my $ch=shift;
    my $fnt=shift;
    my $chnm=shift;
    my $unused=0;

    foreach my $un (0..$#{$fnt->{NO}})
    {
	next if $un >= 139 and $un <= 144;
	$unused=$un,last if $fnt->{NO}->[$un]->[1] eq '';
    }

    if (!$unused)
    {
	foreach my $un (128..255)
	{
	    next if $un >= 139 and $un <= 144;
	    my $glyph=$fnt->{NO}->[$un]->[1];
	    $unused=$un,last if $fnt->{NAM}->{$glyph}->[USED] == 0;
	}
    }

    if ($unused && $unused <= 255)
    {
	my $glyph=$fnt->{NO}->[$unused]->[1];
	delete($fontlst{$cft}->{CACHE}->{$cftsz});
	$fnt->{NAM}->{$chnm}->[ASSIGNED]=$unused;
	$fnt->{NO}->[$unused]->[1]=$chnm;
	$widtbl=CacheWid($cft);

	$stream.="% AAA Assign $chnm ($ch) to $unused\n" if $debug;

	$ch=$unused;
	return($ch);
    }
    else
    {
	Msg(0,"Too many glyphs used in font '$cft'");
	return(32);
    }
}

sub do_c
{
    my $par=shift;

    push(@ahead,substr($par,1));
    $par=substr($par,0,1);
    my $ch=ord($par);
    do_N($ch);
}

sub do_N
{
    my $par=shift;
    my $fnt=$fontlst{$cft}->{FNT};

    if (!defined($fnt->{NO}->[$par]))
    {
	Msg(0,"No chr($par) in font $fnt->{internalname}");
	return;
    }

    my $chnm=$fnt->{NO}->[$par]->[0];
    do_C($chnm);
}

sub do_n
{
    $gotT=0;
    PutLine(0);
    $pendmv=$nomove=0;
    $n_flg=1;
    @lin=();
    PutHotSpot($xpos) if defined($mark);
}


1;
# Local Variables:
# mode: CPerl
# End:
