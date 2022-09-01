export
GROFF_BIN_PATH := ../..
GROFF_FONT_PATH := ../../font
GROFF_TMAC_PATH := ../../tmac

SRCS  = dankeCJK.1 dankeCJK1.1 dankeCJK2.1 dankeJK0.1 dankeJK1.1 humanCJK0.1
SRCS += ningen0.1 ningen1.1 ningen2.1 ningen3.1 ningen4.1
SRCS += vita0.1 vita1.1 vita2.1 vita3.1 ame.1
SRCS += kingdom0.1 leftKO.1 lucky.1
TTY  = $(SRCS:.1=.tty)

.SUFFIXES: .tty

tty: $(TTY)
grout: dankeCJK.grout dankeJK0.grout dankeJK1.grout


dankeCJK.tty: ../dankeCJK.1
	groff -K utf8 -T utf8 ../dankeCJK.1 > ./dankeCJK.tty

dankeCJK.grout: ../dankeCJK.1
	groff -K utf8 -T utf8 -Z ../dankeCJK.1 > ./dankeCJK.grout

dankeCJK1.tty: ../dankeCJK1.1
	groff -K utf8 -T utf8 ../dankeCJK1.1 > ./dankeCJK1.tty

dankeCJK2.tty: ../dankeCJK2.1
	groff -K utf8 -T utf8 ../dankeCJK2.1 > ./dankeCJK2.tty

dankeJK0.tty: ../dankeJK0.1
	groff -K utf8 -T utf8 ../dankeJK0.1 > ./dankeJK0.tty

dankeJK0.grout: ../dankeJK0.1
	groff -K utf8 -T utf8 -Z ../dankeJK0.1 > ./dankeJK0.grout

dankeJK1.tty: ../dankeJK1.1
	groff -K utf8 -T utf8 ../dankeJK1.1 > ./dankeJK1.tty

dankeJK1.grout: ../dankeJK1.1
	groff -K utf8 -T utf8 -Z ../dankeJK1.1 > ./dankeJK1.grout

humanCJK0.tty: ../humanCJK0.1
	groff -K utf8 -T utf8 ../humanCJK0.1 > ./humanCJK0.tty

ningen0.tty: ../ningen0.1
	groff -K utf8 -T utf8 ../ningen0.1 > ./ningen0.tty

ningen1.tty: ../ningen1.1
	groff -K utf8 -T utf8 ../ningen1.1 > ./ningen1.tty

ningen2.tty: ../ningen2.1
	groff -K utf8 -T utf8 ../ningen2.1 > ./ningen2.tty

ningen3.tty: ../ningen3.1
	groff -K utf8 -T utf8 ../ningen3.1 > ./ningen3.tty

ningen4.tty: ../ningen4.1
	groff -K utf8 -T utf8 ../ningen4.1 > ./ningen4.tty

vita0.tty: ../vita0.1
	groff -K utf8 -T utf8 ../vita0.1 > ./vita0.tty

vita1.tty: ../vita1.1
	groff -K utf8 -T utf8 ../vita1.1 > ./vita1.tty

vita2.tty: ../vita2.1
	groff -K utf8 -T utf8 ../vita2.1 > ./vita2.tty

vita3.tty: ../vita3.1
	groff -K utf8 -T utf8 ../vita3.1 > ./vita3.tty

ame.tty: ../ame.1
	groff -K utf8 -T utf8 ../ame.1 > ./ame.tty

kingdom0.tty: ../kingdom0.1
	groff -K utf8 -T utf8 ../kingdom0.1 > ./kingdom0.tty

leftKO.tty: ../leftKO.1
	groff -K utf8 -T utf8 ../leftKO.1 > ./leftKO.tty

lucky.tty: ../lucky.1
	groff -K utf8 -T utf8 ../lucky.1 > ./lucky.tty


