groff-CJK-font
==============

groff unofficial patch to support CJK fonts

# About

This repository provides unofficial patch for groff (GNU troff)
in order to better support CJK (Chinese, Japanese, Korean) fonts.


# Contents

The original groff 1.22.4 sources by GNU are tagged as "groff-1.22.4".
The current sources are patched ones.

### patched sources for grops
- src/devices/grops/ps.cpp
- src/devices/grops/ps.h

It supports UTF16 encoding.

### patched sources for font definition
- src/include/font.h
- src/libs/libgroff/font.cpp

It supports font definition by a range of unicode code points.

### CJK font definition for grops

#### Chinese Simplified  简体中文
- font/devps/CSS
- font/devps/CSH

#### Chinese Traditional  繁體中文
- font/devps/CTS
- font/devps/CTH

#### Japanese  日本語
- font/devps/JPM
- font/devps/JPG

#### Korean  한국어
- font/devps/KOM
- font/devps/KOG

### others
- src/libs/libgroff/invalid.cpp

### test samples
- tests/*


# License

GNU GPL Version 3.


# References

1. [GNU troff (groff) — a GNU project](https://www.gnu.org/software/groff/)
2. [groff 1.18.1 with MULTILINGUAL support](https://answers.launchpad.net/ubuntu/+source/groff/1.18.1.1-12)

