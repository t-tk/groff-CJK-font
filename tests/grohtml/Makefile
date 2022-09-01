export
GROFF_BIN_PATH := ../..
GROFF_FONT_PATH := ../../font
GROFF_TMAC_PATH := ../../tmac

SRCS  = dankeCJK.1 dankeCJK1.1 dankeCJK2.1 dankeJK0.1 dankeJK1.1 humanCJK0.1
SRCS += ningen0.1 ningen1.1 ningen2.1 ningen3.1 ningen4.1
SRCS += vita0.1 vita1.1 vita2.1 vita3.1 ame.1
SRCS += kingdom0.1 leftKO.1 lucky.1
HTML  = $(SRCS:.1=.html)

.SUFFIXES: .html

html: $(HTML)
grout: dankeCJK.grout dankeJK0.grout dankeJK1.grout


dankeCJK.html: ../dankeCJK.1
	groff -K utf8 -T html -P-U ../dankeCJK.1 > ./dankeCJK.html

dankeCJK_ascii.html: ../dankeCJK.1
	groff -K utf8 -T html ../dankeCJK.1 > ./dankeCJK_ascii.html

dankeCJK.grout: ../dankeCJK.1
	groff -K utf8 -T html -Z ../dankeCJK.1 > ./dankeCJK.grout

dankeCJK1.html: ../dankeCJK1.1
	groff -K utf8 -T html -P-U ../dankeCJK1.1 > ./dankeCJK1.html

dankeCJK1_ascii.html: ../dankeCJK1.1
	groff -K utf8 -T html ../dankeCJK1.1 > ./dankeCJK1_ascii.html

dankeCJK2.html: ../dankeCJK2.1
	groff -K utf8 -T html -P-U ../dankeCJK2.1 > ./dankeCJK2.html

dankeJK0.html: ../dankeJK0.1
	groff -K utf8 -T html -P-U ../dankeJK0.1 > ./dankeJK0.html

dankeJK0.grout: ../dankeJK0.1
	groff -K utf8 -T html -Z ../dankeJK0.1 > ./dankeJK0.grout

dankeJK1.html: ../dankeJK1.1
	groff -K utf8 -T html -P-U ../dankeJK1.1 > ./dankeJK1.html

dankeJK1.grout: ../dankeJK1.1
	groff -K utf8 -T html -Z ../dankeJK1.1 > ./dankeJK1.grout

humanCJK0.html: ../humanCJK0.1
	groff -K utf8 -T html -P-U ../humanCJK0.1 > ./humanCJK0.html

ningen0.html: ../ningen0.1
	groff -K utf8 -T html -P-U ../ningen0.1 > ./ningen0.html

ningen1.html: ../ningen1.1
	groff -K utf8 -T html -P-U ../ningen1.1 > ./ningen1.html

ningen2.html: ../ningen2.1
	groff -K utf8 -T html -P-U ../ningen2.1 > ./ningen2.html

ningen3.html: ../ningen3.1
	groff -K utf8 -T html -P-U ../ningen3.1 > ./ningen3.html

ningen4.html: ../ningen4.1
	groff -K utf8 -T html -P-U ../ningen4.1 > ./ningen4.html

vita0.html: ../vita0.1
	groff -K utf8 -T html -P-U ../vita0.1 > ./vita0.html

vita1.html: ../vita1.1
	groff -K utf8 -T html -P-U ../vita1.1 > ./vita1.html

vita2.html: ../vita2.1
	groff -K utf8 -T html -P-U ../vita2.1 > ./vita2.html

vita3.html: ../vita3.1
	groff -K utf8 -T html -P-U ../vita3.1 > ./vita3.html

ame.html: ../ame.1
	groff -K utf8 -T html -P-U ../ame.1 > ./ame.html

kingdom0.html: ../kingdom0.1
	groff -K utf8 -T html -P-U ../kingdom0.1 > ./kingdom0.html

leftKO.html: ../leftKO.1
	groff -K utf8 -T html -P-U ../leftKO.1 > ./leftKO.html

lucky.html: ../lucky.1
	groff -K utf8 -T html -P-U ../lucky.1 > ./lucky.html


