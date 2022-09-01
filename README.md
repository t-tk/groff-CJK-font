groff-CJK-font
==============

groff unofficial patch to support CJK fonts

## About

This repository provides unofficial patch for groff (GNU troff)
in order to better support CJK (Chinese, Japanese, Korean) fonts.


## Contents

The original groff 1.22.4 sources by GNU are tagged as "groff-1.22.4".
The original groff 1.23.0.rc1 sources by GNU are tagged as "groff-1.23.0.rc1".
The current sources are patched ones.

### patches

#### patch for font definition
- src/include/font.h
- src/libs/libgroff/font.cpp

It supports font definition by a range of unicode code points.

#### patch for grops (backend for PostScript format)
- src/devices/grops/ps.cpp
- src/devices/grops/ps.h

It supports UTF16 encoding.

#### patch for post-grohtml (backend for HTML format)
- src/preproc/html/pre-html.cpp
- src/devices/grohtml/post-html.cpp
- src/libs/libgroff/font.cpp

It supports UTF8 encoding and CJK fonts.
Command line option `-U` is added to pre-grohtml and post-grohtml.

#### grodvi (backend for dvi format)
We not need to patch for grodvi to support CJK.
It outputs in upTeX dvi format.

#### grotty UTF8 outputs
We not need to patch for grotty to support CJK.


### font definition

#### CJK font definition for grops
- font/devps/CSS
- font/devps/CSH
- font/devps/CTS
- font/devps/CTH
- font/devps/JPM
- font/devps/JPG
- font/devps/KOM
- font/devps/KOG

#### CJK font definition for grohtml
- font/devhtml/CSS
- font/devhtml/CSH
- font/devhtml/CTS
- font/devhtml/CTH
- font/devhtml/JPM
- font/devhtml/JPG
- font/devhtml/KOM
- font/devhtml/KOG

#### CJK font definition for grodvi
- font/devdvi/CSS
- font/devdvi/CSH
- font/devdvi/CTS
- font/devdvi/CTH
- font/devdvi/JPM
- font/devdvi/JPG
- font/devdvi/KOM
- font/devdvi/KOG

#### CJK font definition for grotty UTF-8 outputs
- font/devutf8/CSS
- font/devutf8/CSH
- font/devutf8/CTS
- font/devutf8/CTH
- font/devutf8/JPM
- font/devutf8/JPG
- font/devutf8/KOM
- font/devutf8/KOG

### test samples
- src/roff/groff/tests/smoke-test_ps_device.sh
- src/roff/groff/tests/smoke-test_dvi_device.sh
- src/roff/groff/tests/smoke-test_html_device.sh
- tests/*
- tests/grodvi/*
- tests/grohtml/*
- tests/grotty/*


## License

GNU GPL Version 3.


## References

1. [GNU troff (groff) — a GNU project](https://www.gnu.org/software/groff/)
2. [groff 1.18.1 with MULTILINGUAL support](https://answers.launchpad.net/ubuntu/+source/groff/1.18.1.1-12)
3. [bug #62830: [grops] support CJK fonts encoded in UTF16](http://savannah.gnu.org/bugs/?62830)

