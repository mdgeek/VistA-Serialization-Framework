RGSEXML ;RI/CBMI/DKM - XML Support ;08-Apr-2015 17:02;DKM
 ;;1.0;SERIALIZATION FRAMEWORK;;14-March-2014;Build 1
 ;=================================================================
 ; Implements Serializer interface (abstract)
 ; Serializer.PREINIT - Preinitialization
PREINIT D ADD^RGNETWWW("<?xml version=""1.0"" encoding=""UTF-8""?>")
 Q
 ; Serializer.PSTINIT - Postinitialization
PSTINIT D ENDALL
 Q
 ; Serializer.PRELIST - List preprocessing
PRELIST Q
 ; Serializer.PSTLIST - List postprocessing
PSTLIST Q
 ; Serializer.COMPOSE - Compose an entry
COMPOSE Q
 ; Serializer.FMTDATE - Serialize a date
FMTDATE(DT) ;
 N X
 S:'$G(DT) DT=$$NOW^XLFDT
 S X=$$FMTDATE^RGUTDATF(DT,"YYYY-MM-dd"_$S(DT#1:"'T'HH:mm:ssXXXX",1:""))
 S:X["-00" X=$$SUBST^RGUT(X,"-00")
 Q X
 ; Serializer.ESCMAP - Location of escape map
ESCMAP() Q "ESCMAPX^RGSEXML"
ESCMAPX ;;Table of escape mappings
 ;;&;&amp;
 ;;";&quot;
 ;;';&apos;
 ;;<;&lt;
 ;;>;&gt;
 ;;
 ; Serializer.PROPF - Free text property
PROPF D PUT(PN,$G(VL("E")))
 Q
 ; Serializer.PROPB - Boolean property
PROPB D PUTBL(PN,$G(VL("I")))
 Q
 ; Serializer.PROPD - Date property
PROPD D PUTDT(PN,$G(VL("I")))
 Q
 ; Serializer.PROPR - Raw value property
PROPR D PUT(PN,$G(VL("I")))
 Q
 ; Serializer.PROPW - Word processing property
PROPW D PUT(PN,$$ARY2STR^RGSER(.VL,$$UNESCURL^RGNETWWW(CTL)))
 Q
 ; Serializer.PROPC - Custom property
PROPC X CTL
 Q
 ; Serializer.PROPO - Object property
PROPO D:$G(VL("I")) GET^RGSERGET(.RGSER,CTL,VL("I"),PN)
 Q
 ; Serializer.PROPI - Inline object property
PROPI D:$G(VL("I")) NEWTAG(PN),GET^RGSERGET(.RGSER,CTL,VL("I"),,"I"),ENDTAG(PN)
 Q
 ; Serializer.PROPS - Static property
PROPS D PUT(PN,$G(CTL))
 Q
 ; Put a name/value pair to output buffer
 ; If name is ":"-delimited, it is assumed to be a sequenced list of
 ; enclosing tags, the last one being the recipient of the value.
PUT(NM,VL) ;
 I $L($G(VL)) D
 .N ATR
 .S ATR("value")=VL
 .D NEWTAG(NM,.ATR,1)
 Q
 ; Put a date value to output buffer
PUTDT(NM,DT) ;
 D:DT PUT(NM,$$FMTDATE^RGSER(DT))
 Q
 ; Put a boolean value to output buffer
PUTBL(NM,BL) ;
 D PUT(NM,$S(BL:"true",1:"false"))
 Q
 ; Put a set value to output buffer
PUTST(NM,VL,ST) ;
 D PUT(NM,$$SET^RGUT(VL,ST))
 Q
 ; Put an array to output buffer
PUTAR(NM,AR) ;
 D NEWTAG(NM),ADDARY^RGSER(.AR),ENDTAG(NM)
 Q
 ;Add opening tag (with optional attributes)
 ; TAG = tag name (separate multiple names with ":")
 ; ATR = optional array of attributes and/or content
 ; CLS = if true, tag is self-closing
NEWTAG(TAG,ATR,CLS) ;
 N X,Y,A,CNT,TGC
 S CLS=+$G(CLS),CNT=$G(ATR),CLS(0)=$S(CLS&'$L(CNT):"/>",1:">"),TGC=0
 I TAG[":" D
 .S X=$L(TAG,":")
 .F TGC=1:1:X-1 D NEWTAG($P(TAG,":",TGC))
 .S TAG=$P(TAG,":",X)
 I $D(ATR)'>1 D
 .S X="<"_TAG_CLS(0)
 E  D
 .S X="<"_TAG
 .S ATR=""
 .F  S ATR=$O(ATR(ATR)) Q:'$L(ATR)  D
 ..S:$D(ATR(ATR))>1 Y=$O(ATR(ATR,"")),X=X_" "_Y_"="_$$QT(ATR(ATR,Y))
 ..S:$D(ATR(ATR))#10 X=X_" "_ATR_"="_$$QT(ATR(ATR))
 .S X=X_CLS(0)
 D ADD^RGNETWWW(X)
 I $L(CNT) D
 .D ADD^RGNETWWW($$ESCAPE^RGSER(CNT))
 .D:CLS ADD^RGNETWWW("</"_$P(TAG," ")_">")
 S Y=+$G(RGSER("T"))
 S:Y RGSER("T",Y,0)=RGSER("T",Y,0)+1
 S:'CLS Y=Y+1,RGSER("T")=Y,RGSER("T",Y)=TAG,RGSER("T",Y,0)=0
 I CLS F  Q:'TGC  D ENDTAG S TGC=TGC-1
 K ATR
 Q
 ; Write closing tag
 ;  TAG = If specified, write closing tags up to and including
 ;    this one.  Otherwise, just write last pending closing tag.
 ;  Returns true if there are more pending tag closures.
ENDTAG(TAG) ;
 N Y,T
 I $G(TAG)[":" D  Q
 .F Y=$L(TAG,":"):-1:1 Q:'$$ENDTAG($P(TAG,":",Y))
 S Y=+$G(RGSER("T"))
 F  Q:'Y  D  Q:TAG=T
 .S T=RGSER("T",Y)
 .D ADD^RGNETWWW("</"_T_">")
 .S Y=Y-1,RGSER("T")=Y
 .S:'$D(TAG) TAG=T
 Q:$Q Y
 Q
 ; Close all open tags
ENDALL F  Q:'$$ENDTAG
 Q
 ; Return # of siblings at specified tag level.
 ; LVL: 0 = Current level (default); >0 = Absolute; <0 = Relative to current
SIBS(LVL) ;
 N X
 S X=+$G(RGSER("T")),LVL=+$G(LVL),LVL=$S(LVL>X:X,LVL>0:LVL,1:X-LVL)
 Q +$G(RGSER("T",LVL,0))
 ; Enclose value in quotes (escape contents if necessary)
QT(X) Q """"_$$ESCAPE^RGSER(X)_""""
