
### Local Setting for GhostScript 9.50

/usr/share/ghostscript/9.50/Resource/Init/FAPIcidfmap

```

% Japanese
/ipaexm << /FileType /TrueType /CSI [(Japan1) 6] /Path (/usr/share/fonts/opentype/ipaexfont-mincho/ipaexm.ttf) /SubfontID 0 >> ;
/ipaexg << /FileType /TrueType /CSI [(Japan1) 6] /Path (/usr/share/fonts/opentype/ipaexfont-gothic/ipaexg.ttf) /SubfontID 0 >> ;

% Korean
/UnBatang             << /FileType /TrueType /CSI [(Korea1) 2] /Path (/usr/share/fonts/truetype/unfonts-core/UnBatang.ttf) >> ;
/UnDotum              << /FileType /TrueType /CSI [(Korea1) 2] /Path (/usr/share/fonts/truetype/unfonts-core/UnDotum.ttf)  >> ;

% Chinese
/AR-PL-KaitiM-GB      << /FileType /TrueType /CSI [(GB1) 5]  /Path (/usr/share/fonts/truetype/arphic-gkai00mp/gkai00mp.ttf) >> ;
/AR-PL-SungtiL-GB     << /FileType /TrueType /CSI [(GB1) 5]  /Path (/usr/share/fonts/truetype/arphic-gbsn00lp/gbsn00lp.ttf) >> ;
/AR-PL-KaitiM-Big5    << /FileType /TrueType /CSI [(CNS1) 5] /Path (/usr/share/fonts/truetype/arphic-bkai00mp/bkai00mp.ttf) >> ;
/AR-PL-Mingti2L-Big5  << /FileType /TrueType /CSI [(CNS1) 5] /Path (/usr/share/fonts/truetype/arphic-bsmi00lp/bsmi00lp.ttf) >> ;


% Japanese
/Ryumin-Light /ipaexm ;
/GothicBBB-Medium /ipaexg ;

% Korean
/HYSMyeongJo-Medium /UnBatang ;
/HYGoThic-Medium /UnDotum ;

% Chinese
/STHeiti-Regular /AR-PL-KaitiM-GB ;
/STSong-Light /AR-PL-SungtiL-GB ;
/MHei-Medium /AR-PL-KaitiM-Big5 ;
/MSung-Light /AR-PL-Mingti2L-Big5 ;

```

### CJK True Type Fonts

I used following fonts distributed by Ubuntu apt package manager.

* fonts-ipaexfont-gothic: Japanese OpenType font, IPAex Gothic Font
* fonts-ipaexfont-mincho: Japanese OpenType font, IPAex Mincho Font
* fonts-unfonts-core: Un series Korean TrueType fonts
* fonts-arphic-uming: "AR PL UMing" Chinese Unicode TrueType font collection Mingti style
* fonts-arphic-ukai: "AR PL UKai" Chinese Unicode TrueType font collection Kaiti style
