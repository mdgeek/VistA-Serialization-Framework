RGSEJSON ;RI/CBMI/DKM - JSON Serialization Support ;21-Mar-2017 15:43;DKM
 ;;1.0;SERIALIZATION FRAMEWORK;;14-March-2014;Build 1
 ;=================================================================
 ; Implements Serializer interface
 ; Serializer.PREINIT - Preinitialization
PREINIT Q
 ; Serializer.PSTINIT - Postinitialization
PSTINIT Q
 ; Serializer.PRELIST - List preprocessing
PRELIST D NEWARY
 Q
 ; Serializer.PSTLIST - List postprocessing
PSTLIST D ENDARY
 Q
 ; Serializer.COMPOSE - Compose an entry
COMPOSE D COMPOSEX("@compose","@class",$$GETRTYPE^RGSERGET(PATH,PNAME))
 Q
COMPOSEX(OLABEL,RLABEL,RTYPE,ATR,RAW) ;
 D NEWOBJ(OLABEL)
 S:$E(RTYPE)="@" RTYPE=""
 D:$L(RTYPE) PUT(RLABEL,RTYPE)
 D PUTATR(.ATR,.RAW)
 D PROCPROP^RGSERGET
 D ENDOBJ(OLABEL)
 Q
 ; Serializer.FMTDATE - Serialize a date
FMTDATE(DT) ;
 Q $S($D(DT):DT,1:$$NOW^XLFDT)
 ; Serializer.ESCMAP - Location of escape map
ESCMAP() Q "ESCMAPX^RGSEJSON"
ESCMAPX ;;Table of escape mappings
 ;;\;\\
 ;;/;\/
 ;;";\"
 ;;#8;\b
 ;;#12;\f
 ;;#10;\n
 ;;#13;\r
 ;;#9;\t
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
PROPW K VL("E"),VL("I")
 D PUTARY(PN,.VL,$$UNESCURL^RGNETWWW(CTL),1)
 Q
 ; Serializer.PROPC - Custom property
PROPC X CTL
 Q
 ; Serializer.PROPO - Object property
PROPO D:$G(VL("I")) GET^RGSERGET(.RGSER,CTL,$G(VL("I")),PN)
 Q
 ; Serializer.PROPI - Inline property
PROPI D:$G(VL("I")) NEWARY(PN),GET^RGSERGET(.RGSER,CTL,VL("I"),,"S"),ENDARY(PN)
 Q
 ; Serializer.PROPS - Static property
PROPS D PUT(PN,$G(CTL))
 Q
 ; Format attribute name for output
NM(NM) Q $S($L($G(NM)):$$QT(NM)_":",1:"")
 ; Put a name/value pair to output buffer
 ; Value will be quoted
PUT(NM,VL) ;
 D:$L($G(VL)) PUTRAW(.NM,$$QT(.VL))
 Q
 ; Put a name/value pair to output buffer
 ; Value will be stored in raw form
PUTRAW(NM,VL) ;
 Q:'$L($G(VL))
 N LVLS
 S NM=$$PRSLVLS(.NM,.LVLS)
 D NEWLVLS(.LVLS)
 K:$$INARY NM
 S:$E(VL)="." VL="0"_VL
 D PUTELE($$NM(.NM)_VL),ENDLVLS(.LVLS)
 Q
 ; Put a name/value pair to output buffer
 ; Auto detect value type (or specify QT to force)
PUTAUTO(NM,VL,QT) ;
 S:$S($D(QT):QT,1:'$$ISNUM^RGUT(VL)) VL=$$QT(VL)
 D PUTRAW(NM,VL)
 Q
 ; Put an element in output buffer
PUTELE(X) ;
 N L,I
 S L=+$O(RGSER("L",""),-1),I=0
 S:L I=RGSER("L",L),RGSER("L",L)=I+1
 D ADD($S(I:",",1:"")_X)
 Q
 ; Put a date value to output buffer
PUTDT(NM,DT) ;
 D:DT PUT(NM,$$FMTDATE^RGSER(DT))
 Q
 ; Put a boolean value to output buffer
PUTBL(NM,BL) ;
 D PUTRAW(NM,$S(BL:"true",1:"false"))
 Q
 ; Put a set value to output buffer
PUTST(NM,VL,ST) ;
 D PUT(NM,$$SET^RGUT(VL,ST))
 Q
 ; Put an object to output buffer
PUTOBJ(NM,OBJ,RAW) ;
 N LP,LP1
 D NEWOBJ(.NM),PUTATR(.OBJ,.RAW),ENDOBJ(.NM)
 Q
 ; Put object attributes to output buffer
PUTATR(OBJ,RAW) ;
 N LP,LP1
 S LP=""
 F  S LP=$O(OBJ(LP)) Q:'$L(LP)  D
 .I $D(OBJ(LP))>1 D
 ..S LP1=""
 ..F  S LP1=$O(OBJ(LP,LP1)) Q:'$L(LP1)  D
 ...D PUTAUTO(LP1,OBJ(LP,LP1),.RAW)
 .E  D PUTAUTO(LP,OBJ(LP),.RAW)
 K OBJ
 Q
 ; Put an array to output buffer
 ;  NM  = Object/array name
 ; .ARY = Array passed by reference
 ;  LT  = Line terminator to append
 ;  CT  = Concatenate as single value
PUTARY(NM,ARY,LT,CT) ;
 N LP,LVLS,X
 S LP=$NA(ARY),LT=$G(LT),CT=$G(CT)
 S NM=$$PRSLVLS(.NM,.LVLS)
 D NEWLVLS(.LVLS)
 K:$$INARY NM
 I CT D
 .D PUTELE($$NM(.NM)_"""")
 E  D NEWARY(.NM)
 F  S LP=$Q(@LP) Q:'$L(LP)  D
 .S X=@LP_LT
 .D:'CT PUTELE($$QT(X))
 .D:CT ADD($$ESCAPE^RGSER(X))
 I CT D
 .D ADD("""")
 E  D ENDARY(.NM)
 D ENDLVLS(.LVLS)
 Q
 ; Start an array level
NEWARY(NM) ;
 D NEWLVL(.NM,0)
 Q
 ; End an array level
ENDARY(NM) ;
 D ENDLVL(.NM,0)
 Q
 ; Returns true if inside an array
INARY(NM) ;
 N LVL
 S LVL=$$GETLVL
 Q:'LVL 0
 Q:RGSER("L",LVL,0) 0
 Q $S('$D(NM):1,1:RGSER("L",LVL,1)=NM)
 ; Start an object level
NEWOBJ(NM) ;
 D NEWLVL(.NM,1)
 Q
 ; End an object level
ENDOBJ(NM) ;
 D ENDLVL(.NM,1)
 Q
 ; Start a new level
 ; TP: 0 = array; 1 = object
 ; The level stack is at RGSER("L"):
 ;   RGSER("L",LVL)   = # of elements at this level
 ;   RGSER("L",LVL,0) = 0 if array, 1 if object
 ;   RGSER("L",LVL,1) = Tag associated with level
 ;   RGSER("L",LVL,2) = Position of level in output stream
NEWLVL(NM,TP) ;
 N LVL,OUT,CNT,ARY
 S ARY=$$INARY,LVL=$$GETLVL,OUT=""
 I LVL S CNT=RGSER("L",LVL),OUT=$S(CNT:",",1:""),RGSER("L",LVL)=CNT+1
 S LVL=LVL+1,RGSER("L",LVL)=0,RGSER("L",LVL,0)=TP,RGSER("L",LVL,1)=$G(NM)
 I 'ARY,$L($G(NM)),$E(NM)'="@" S OUT=OUT_$$NM(NM)
 D ADD(OUT_$S(TP:"{",1:"["))
 S RGSER("L",LVL,2)=RGNETRSP("LAST")
 Q
 ; End a level
 ; If an empty level is ended, it is completely removed
 ; from the output stream.
ENDLVL(NM,TP) ;
 N LVL,OUT,MATCH
 F LVL=$$GETLVL:-1:1 D  Q:MATCH
 .I RGSER("L",LVL) D
 ..S OUT=$S(RGSER("L",LVL,0):"}",1:"]")
 ..D ADD(OUT)
 .E  D
 ..D REPLACE^RGNETWWW(RGSER("L",LVL,2),"")
 ..S:LVL>1 RGSER("L",LVL-1)=RGSER("L",LVL-1)-1
 .S MATCH=RGSER("L",LVL,0)=TP
 .S:MATCH MATCH=$G(NM)=RGSER("L",LVL,1)
 .K RGSER("L",LVL)
 Q
 ; Creates multiple levels as specified by the
 ; array returned by PRSLVLS.
NEWLVLS(LVLS) ;
 N LP
 F LP=1:1:LVLS-1 D NEWLVL(LVLS(LP,0),LVLS(LP,1))
 Q
 ; Ends multiple levels as specified by the
 ; array returned by PRSLVLS.
ENDLVLS(LVLS) ;
 N LP
 F LP=LVLS-1:-1:1 D ENDLVL(LVLS(LP,0),LVLS(LP,1))
 Q
 ; Parses a property name.  A property name can designate multiple levels by
 ; introducing a "." separator to indicate an object level or a ":" to indicate
 ; an array level.  For example, A:B.C, represents an attribute named "C" under
 ; an object named "B" under an array named "A".
 ;   NM   = The property name to parse
 ;  .LVLS = Array to receive parsed results
 ; Returns the attribute name (in the above example, "C").
PRSLVLS(NM,LVLS) ;
 N NM2,LN,POS,PC
 K LVLS
 S NM=$G(NM),NM2=$TR(NM,".",":"),LN=$L(NM2,":"),POS=0
 F LVLS=1:1:LN D
 .S PC=$P(NM2,":",LVLS),POS=POS+$L(PC)+1
 .S LVLS(LVLS,0)=PC,LVLS(LVLS,1)=$S(LVLS=LN:-1,1:$E(NM,POS)=".")
 Q:$Q PC
 Q
 ; Return current level
GETLVL() Q +$O(RGSER("L",""),-1)
 ; Enclose value in quotes (escape contents if necessary)
QT(X) Q """"_$$ESCAPE^RGSER($G(X))_""""
 ; Convenience method
ADD(X) D ADD^RGNETWWW(X)
 Q
