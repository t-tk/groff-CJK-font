export
GROFF_BIN_PATH := ..
GROFF_FONT_PATH := ../font
GROFF_TMAC_PATH := ../tmac

SRCS  = dankeCJK.1 dankeJK0.1 dankeJK1.1 humanCJK0.1
SRCS += ningen0.1 ningen1.1 ningen2.1 ningen3.1 ningen4.1
SRCS += vita0.1 vita1.1 vita2.1 vita3.1 ame.1
SRCS += kingdom0.1 leftKO.1 lucky.1
PS    = $(SRCS:.1=.ps)
PDF   = $(SRCS:.1=.pdf)

.SUFFIXES: .ps .pdf

pdf: $(PDF)

.ps.pdf:
	ps2pdf $^

dankeCJK.ps: dankeCJK.1
	groff -K utf8 -T ps ./dankeCJK.1 > ./dankeCJK.ps

dankeJK0.ps: dankeJK0.1
	groff -K utf8 -T ps ./dankeJK0.1 > ./dankeJK0.ps

dankeJK1.ps: dankeJK1.1
	groff -K utf8 -T ps ./dankeJK1.1 > ./dankeJK1.ps

humanCJK0.ps: humanCJK0.1
	groff -K utf8 -T ps -m ja ./humanCJK0.1 > ./humanCJK0.ps

ningen0.ps: ningen0.1
	groff -K utf8 -T ps -m ja ./ningen0.1 > ./ningen0.ps

ningen1.ps: ningen1.1
	groff -K utf8 -T ps -m ja ./ningen1.1 > ./ningen1.ps

ningen2.ps: ningen2.1
	groff -K utf8 -T ps -m ja ./ningen2.1 > ./ningen2.ps

ningen3.ps: ningen3.1
	groff -K utf8 -T ps -m ja ./ningen3.1 > ./ningen3.ps

ningen4.ps: ningen4.1
	groff -K utf8 -T ps -m ja ./ningen4.1 > ./ningen4.ps

vita0.ps: vita0.1
	groff -K utf8 -T ps -m ja ./vita0.1 > ./vita0.ps

vita1.ps: vita1.1
	groff -K utf8 -T ps -m ja ./vita1.1 > ./vita1.ps

vita2.ps: vita2.1
	groff -K utf8 -T ps -m ja ./vita2.1 > ./vita2.ps

vita3.ps: vita3.1
	groff -K utf8 -T ps -m ja ./vita3.1 > ./vita3.ps

ame.ps: ame.1
	groff -K utf8 -T ps -m ja ./ame.1 > ./ame.ps

kingdom0.ps: kingdom0.1
	groff -K utf8 -T ps -m zh ./kingdom0.1 > ./kingdom0.ps

leftKO.ps: leftKO.1
	groff -K utf8 -T ps ./leftKO.1 > ./leftKO.ps

lucky.ps: lucky.1
	groff -K utf8 -T ps ./lucky.1 > ./lucky.ps

