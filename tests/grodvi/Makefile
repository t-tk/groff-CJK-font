export
GROFF_BIN_PATH := ../..
GROFF_FONT_PATH := ../../font
GROFF_TMAC_PATH := ../../tmac

SRCS  = dankeCJK.1 dankeJK0.1 dankeJK1.1 humanCJK0.1
SRCS += ningen0.1 ningen1.1 ningen2.1 ningen3.1 ningen4.1
SRCS += vita0.1 vita1.1 vita2.1 vita3.1 ame.1
SRCS += kingdom0.1 leftKO.1 lucky.1 width1.1
DVI   = $(SRCS:.1=.dvi)
PS    = $(SRCS:.1=.ps)
PDF   = $(SRCS:.1=.pdf)
PNG   = $(SRCS:.1=.png)

.SUFFIXES: .dvi .ps .pdf .png

dvi: $(DVI)
ps: $(PS)
pdf: $(PDF)
png: $(PNG)

#.ps.pdf:
#	ps2pdf $^

.dvi.ps:
	dvips -u ryumin-ps.map -o $@ $^

.dvi.pdf:
	dvipdfmx -f cjk-tt-pdf.map -o $@ $^
#	dvipdfmx -f haranoaji-pdf.map -o $@ $^

.pdf.png:
	gs -dSAFER -sDEVICE=pnggray -r300 -o $@ $^

dankeCJK.dvi: ../dankeCJK.1
	groff -K utf8 -T dvi ../dankeCJK.1 > ./dankeCJK.dvi

dankeJK0.dvi: ../dankeJK0.1
	groff -K utf8 -T dvi ../dankeJK0.1 > ./dankeJK0.dvi

dankeJK1.dvi: ../dankeJK1.1
	groff -K utf8 -T dvi ../dankeJK1.1 > ./dankeJK1.dvi

humanCJK0.dvi: ../humanCJK0.1
	groff -K utf8 -T dvi -m ja ../humanCJK0.1 > ./humanCJK0.dvi

ningen0.dvi: ../ningen0.1
	groff -K utf8 -T dvi -m ja ../ningen0.1 > ./ningen0.dvi

ningen1.dvi: ../ningen1.1
	groff -K utf8 -T dvi -m ja ../ningen1.1 > ./ningen1.dvi

ningen2.dvi: ../ningen2.1
	groff -K utf8 -T dvi -m ja ../ningen2.1 > ./ningen2.dvi

ningen3.dvi: ../ningen3.1
	groff -K utf8 -T dvi -m ja ../ningen3.1 > ./ningen3.dvi

ningen4.dvi: ../ningen4.1
	groff -K utf8 -T dvi -m ja ../ningen4.1 > ./ningen4.dvi

vita0.dvi: ../vita0.1
	groff -K utf8 -T dvi -m ja ../vita0.1 > ./vita0.dvi

vita1.dvi: ../vita1.1
	groff -K utf8 -T dvi -m ja ../vita1.1 > ./vita1.dvi

vita2.dvi: ../vita2.1
	groff -K utf8 -T dvi -m ja ../vita2.1 > ./vita2.dvi

vita3.dvi: ../vita3.1
	groff -K utf8 -T dvi -m ja ../vita3.1 > ./vita3.dvi

ame.dvi: ../ame.1
	groff -K utf8 -T dvi -m ja ../ame.1 > ./ame.dvi

kingdom0.dvi: ../kingdom0.1
	groff -K utf8 -T dvi -m zh ../kingdom0.1 > ./kingdom0.dvi

leftKO.dvi: ../leftKO.1
	groff -K utf8 -T dvi ../leftKO.1 > ./leftKO.dvi

lucky.dvi: ../lucky.1
	groff -K utf8 -T dvi ../lucky.1 > ./lucky.dvi

width1.dvi: ../width1.1
	groff -K utf8 -T dvi ../width1.1 > ./width1.dvi


