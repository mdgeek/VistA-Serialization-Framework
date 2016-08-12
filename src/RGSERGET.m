RGSERGET ;RI/CBMI/DKM - GET method support ;07-Aug-2016 04:32;DKM
 ;;1.0;SERIALIZATION FRAMEWORK;;14-March-2014;Build 280
 ;=================================================================
 ; Returns a serialized form of the requested object.
 ; SLCT may be:
 ;  - a single IEN (e.g., SLCT=123)
 ;  - a unique key on the source file (e.g., SLCT=@XYZ)
 ;  - an ordered array passed by ref whose values are IENs (e.g., SLCT(1)=123...)
 ;  - a global root whose subscript is an IEN (e.g., ^XYZ("B","ABC"))
 ;  - a reference to an iterator that returns IENs (e.g., $$NXT^XYZ)
 ; FLAGS may contain:
 ;  I - Add id attribute to resource
 ;  L - Processing an entry returned from a selector
 ;  M - Processing a multiple field (subfile)
 ;  P - Process search parameters
 ;  S - Selection of internal resources is allowed
 ;  X - Suppress execution of custom serializer
GET(RGSER,PATH,SLCT,PNAME,FLAGS) ;
 N RTN,TOP,IEN,IENS,FILE,SER,TP,XSER,XPRE,MAX,ID,SER,INTRNL,X,N0
 S:$E(PATH)="/" PATH=$E(PATH,2,9999)
 I '$L(PATH) D GETDSC(SLCT) Q
 S SER=$$GETGBL(PATH)
 Q:'$L(SER)
 S RGSER("CNT")=+$G(RGSER("CNT")),TOP='RGSER("CNT"),FLAGS=$G(FLAGS),PNAME=$G(PNAME),SLCT=$G(SLCT)
 S N0=$G(@SER@(0)),XSER=$G(^(10)),XPRE=$G(^(20)),XPOST=$G(^(21)),INTRNL=+$P(N0,U,2),FILE=+$P(N0,U,3),IENS="",TP=-1
 I $D(SLCT)=1,'$L(SLCT) D                                              ; No selector
 .I $D(RGNETREQ("PARAMS","_id",1)) D
 ..M SLCT=RGNETREQ("PARAMS","_id",1)
 ..K RGNETREQ("PARAMS","_id",1)
 I $$GETPARAM^RGNETWWW("_count")>0 D
 .S RGSER("MAX")=+RGNETREQ("PARAMS","_count",1,1)
 .K RGNETREQ("PARAMS","_count",1,1)
 I $$HASFLAG^RGSER("M") S IENS=SLCT,SLCT=$$ROOT^DILFD(FILE,SLCT,1),TP=2 Q:'$O(@SLCT@(0))
 E  I $E(SLCT)="@" S SLCT=$$FIND1^DIC(FILE,,"X",$E(SLCT,2,9999))
 E  I $E(SLCT)=U S TP=1
 E  I $E(SLCT,1,2)="$$" S SLCT=$$NEWITER(SLCT),TP=3
 E  I $D(SLCT)>9 S TP=0
 S MAX=$G(RGSER("MAX"),$S(TP:999999,1:1000))
 I '$D(RGSER("PREINIT")) D PREINIT^@RGSER("INTF") S RGSER("PREINIT")=$ESTACK
 I $L(XSER),'$$HASFLAG^RGSER("X") X XSER Q:$D(XSER)
 D BYIEN:TP=-1,BYSLCT:TP'=-1
 I '$$ISERROR^RGNETWWW,$ESTACK=RGSER("PREINIT") D PSTINIT^@RGSER("INTF")
 Q
 ; By selector
BYSLCT N LP,FL
 D PRELIST^@RGSER("INTF")
 F LP=0:0 Q:MAX'>RGSER("CNT")  S:TP=3 @("LP="_SLCT) S:TP'=3 LP=$S('TP:$O(SLCT(LP)),1:$O(@SLCT@(LP))) Q:'LP  D  Q:$$ISERROR^RGNETWWW
 .S IEN=$S(TP:LP,1:SLCT(LP)),FL=$S($$HASFLAG^RGSER("P"):"P",1:"")_$S(TP=2:"S",1:"L")
 .D GET(.RGSER,PATH,IEN_IENS,PNAME,FL)
 D PSTLIST^@RGSER("INTF")
 Q
 ; By IEN
BYIEN N LP,PROP,PARM,FLD,VALS
 I INTRNL,'$L(PNAME),'$$HASFLAG^RGSER("S") D OPEROUT^RGSEFHIR(3) Q
 D:$$HASFLAG^RGSER("P") PROCPARM
 Q:$$ISERROR^RGNETWWW
 I '$L(SLCT) D  Q:$L(SLCT)
 .S SLCT=$$GETSLCT
 .S:'$L(SLCT) SLCT=$$ROOT^DILFD(FILE,,1)
 .D:$L(SLCT) GET(.RGSER,PATH,SLCT,.PNAME,FLAGS)
 I '$L(SLCT) D OPEROUT^RGSEFHIR(4) Q
 M PROP=@SER@(30)
 S (ID,IEN)=SLCT
 I FILE!$L(XPRE)!$L(XPOST) D  Q:$$ISERROR^RGNETWWW  I '$$FILTER D:'$$HASFLAG^RGSER("L") OPEROUT^RGSEFHIR(6) Q
 .S IENS=IEN_","
 .D BLDFLDS(FILE,.PROP,.FLD),BLDFLDS(FILE,.PARM,.FLD)
 .I $L($G(FLD(0))) D
 ..N ERR
 ..X XPRE
 ..I FILE D
 ...D GETS^DIQ(FILE,IENS,FLD(0),"IEZ","VALS","ERR")
 ...I '$D(ERR) F LP=0:0 S LP=$O(FLD(LP)) Q:'LP  D
 ....N TMP,IENS2,FILE2,LP2
 ....S FILE2=FLD(LP,0),IENS2=VALS(FILE,IENS,LP,"I")_","
 ....Q:'IENS2
 ....D GETS^DIQ(FILE2,IENS2,FLD(LP),"IEZ","TMP","ERR")
 ....F LP2=0:0 S LP2=$O(TMP(FILE2,IENS2,LP2)) Q:'LP2  D
 .....M VALS(FILE,IENS,LP_"~"_LP2)=TMP(FILE2,IENS2,LP2)
 ..X XPOST
 ..I '$D(VALS),'$$ISERROR^RGNETWWW D OPEROUT^RGSEFHIR(1,$G(ERR("DIERR",1,"TEXT",1),$G(ERR,"Unknown error"))_" ("_FILE_":"_IEN_")")
 .I $D(PROP("B","@id")) D
 ..N X
 ..S X=+$O(PROP("B","@id",0)),X=$P($G(PROP(X,0)),U,2)
 ..S X=$S('$L(X):"",1:$G(VALS(FILE,IENS,X,"E")))
 ..S:$L(X) ID=X
 .S VALS(FILE,IENS,"@ien","I")=IEN
 .S VALS(FILE,IENS,"@ienx","I")=FILE_"-"_IEN
 .S VALS(FILE,IENS,"@id","I")=ID
 I '$L(PNAME),'$$HASFLAG^RGSER("S") S RGSER("CNT")=RGSER("CNT")+1
 D COMPOSE^@RGSER("INTF")
 Q
 ; Retrieval logic for custom source.
RETRIEVE(SRC,IEN,DLM) ;
 N X,Y
 S X=$G(@SRC@(IEN)),DLM=$G(DLM,U)
 F Y=1:1:$L(X,DLM) S (VALS(FILE,IENS,Y,"I"),VALS(FILE,IENS,Y,"E"))=$P(X,DLM,Y)
 Q
 ; Get resource type
GETRTYPE(PATH,PNAME) ;
 Q $P($S($L(PNAME):PNAME,1:$P(PATH,"/",$L(PATH,"/"))),"_")
 ; Get preferred global selector
GETSLCT() ;
 N LP,SQ,NM,X,PN
 S X=""
 F SQ=0:0 S SQ=$O(PARM("ASEQ",SQ)) Q:'SQ  D  Q:$L(X)
 .F LP=0:0 S LP=$O(PARM("ASEQ",SQ,LP)) Q:'LP  D  Q:$L(X)
 ..S PN=$P(PARM(LP,0),U)
 ..X $G(PARM(LP,20))
 Q X
 ; Process parameters
PROCPARM N LP
 S LP=""
 F  S LP=$O(RGNETREQ("PARAMS",LP)) D  Q:'$L(LP)
 .S PARM=$O(@SER@(40,"B",$S($L(LP):LP,1:"@selector"),0))
 .I 'PARM D:$L(LP) OPEROUT^RGSEFHIR(5,LP) S LP="" Q
 .M PARM(PARM)=@SER@(40,PARM)
 .S PARM("ASEQ",+$P(PARM(PARM,0),U,4),PARM)=""
 Q
 ; Process properties
PROCPROP N LP,SQ
 F SQ=0:0 S SQ=$O(PROP("ASEQ",SQ)) Q:'SQ  D
 .F LP=0:0 S LP=$O(PROP("ASEQ",SQ,LP)) Q:'LP  D
 ..N PN,FN,TP,VL,CTL
 ..D EXTRP(.PROP,LP)
 ..Q:TP="N"
 ..I TP="M" D PROPM Q
 ..I TP="T" D PROPT Q
 ..D:$L(TP) @("PROP"_TP)^@RGSER("INTF")
 Q
 ; Process a multiple field
PROPM D GET(.RGSER,CTL,","_IEN,PN,"M")
 Q
 ; Process a template property
PROPT D TEMPLATE(CTL)
 Q
 ; Extracts property values
EXTRP(SRC,LP) ;
 N X,Y,Z,P
 S X=SRC(LP,0),PN=$P(X,U),FN=$P(X,U,2),TP=$P(X,U,3),CTL=$G(SRC(LP,10))
 S PN(0)=$P(PN,"!",2,9999),PN=$P(PN,"!")
 F X=1:1:$L(FN,",") D
 .S Y=$P(FN,",",X)
 .I $L(Y) D
 ..S VALS(FILE,IENS,Y)=$L($G(VALS(FILE,IENS,Y,"I")))
 ..M:X=1 VL=VALS(FILE,IENS,Y)
 ..M:X>1 VL(X)=VALS(FILE,IENS,Y)
 Q
 ; Returns the global root for the specified resource.
 ;  PATH = Path of resource
 ;  TEST = If true, just testing for a match.
GETGBL(PATH,TEST) ;
 N SER,RES,N0
 S SER=$$GETSER(PATH),TEST=+$G(TEST)
 I SER<0 D:'TEST OPEROUT^RGSEFHIR($S(SER=-2:2,1:0)) Q ""
 I '$G(RGSER("SER")) D
 .S RGSER("SER")=SER,N0=^RGSER(998.1,SER,0)
 .S RGSER("SERNM")=$P(N0,U),RGSER("INTF")=$P(N0,U,3),RGSER("VER")=$P(N0,U,4)
 .D:'TEST SETCTYPE^RGNETWWW($P($P(N0,U,2),","))
 S RES=$$GETRES(PATH)
 I 'RES D:'TEST OPEROUT^RGSEFHIR(0) Q ""
 Q $NA(^RGSER(998.1,SER,10,RES))
 ; Lookup serializer for path and content type.
 ; Returns IEN of serializer, or
 ;   -1 if no match by name
 ;   -2 if no match by content type
 ;   -3 if no match to active serializer
GETSER(PATH) ;
 N SERNM,SER,SERX,MTYPE,ACCPT,FND,WT,MWT,IEN
 S SERNM=$P(PATH,"/"),SER=+$G(RGSER("SER"))
 Q:'$L(SERNM) -1
 Q:SER $S(SERNM="*":SER,SERNM=RGSER("SERNM"):SER,1:-3)
 S ACCPT=$G(RGSER("FORMAT")),(FND,MWT,SERX)=0
 F IEN=0:0 S IEN=$S(SER:SER,1:$O(^RGSER(998.1,"B",SERNM,IEN))) Q:'IEN  D  Q:MWT=1!SER
 .S MTYPE=$P(^RGSER(998.1,IEN,0),U,2),WT=$$ISCTYPE^RGNETWWW(MTYPE,ACCPT),FND=1
 .S:WT>MWT SERX=IEN,MWT=$S(WT>1:1,1:WT)
 Q $S(SERX:SERX,FND:-2,1:-1)
 ; Lookup resource for selected serializer
 ; Returns IEN of resource or 0 if not found
GETRES(PATH) ;
 N START,IEN,LEN,LP,RES,PTRN,D1,D2
 S (START,LP)=$P(PATH,"/",2),PATH=$P(PATH,"/",2,999),D1=RGSER("SER"),RES=0,LEN=$L(START)
 Q:'$L(START) 0
 F  D  Q:RES  S LP=$O(^RGSER(998.1,D1,10,"B",LP)) Q:$E(LP,1,LEN)'=START
 .F D2=0:0 S D2=$O(^RGSER(998.1,D1,10,"B",LP,D2)) Q:'D2  S PTRN=^(D2) D  Q:RES
 ..S:$S($L(PTRN):$$ISMATCH^RGSER(PATH,PTRN),1:LP=PATH) RES=D2
 Q RES
 ; Build the list of fields to retrieve from
 ; property or parameter list.
BLDFLDS(FILE,SRC,FLD) ;
 N PC,LP,FN,FN1,FN2,FNS
 F LP=0:0 S LP=$O(SRC(LP)) Q:'LP  D
 .S FNS=$P(SRC(LP,0),U,2)
 .F PC=1:1:$L(FNS,",") D
 ..S FN=$P(FNS,",",PC),FN1=$P(FN,"~"),FN2=$P(FN,"~",2)
 ..D:$L(FN2) BLDFLD($$PTRTGT(FILE,FN1),FN1,FN2,.FLD)
 ..D:$L(FN1) BLDFLD(FILE,0,FN1,.FLD)
 Q
BLDFLD(FILE,SB,FN,FLD) ;
 Q:$E(FN)["@"
 I FILE,FN'=+FN S FN=$$FLDNUM^DILFD(FILE,FN)
 S FLD(SB)=$G(FLD(SB)),FLD(SB,0)=FILE
 S:'$D(FLD(SB,FN)) FLD(SB)=FLD(SB)_$S($L(FLD(SB)):";",1:"")_FN,FLD(SB,FN)=1
 Q
 ; Get target file of pointer
 ; Note: GET1^DID does not work on all files, so go straight to DD.
PTRTGT(FILE,FLD) ;
 Q +$P($P($G(^DD(FILE,FLD,0)),U,2),"P",2)
 ; Search/filter logic.  Returns true if successful match.
FILTER() N LP,SQ,PR,MATCH
 S MATCH=1
 F SQ=0:0 Q:'MATCH  S SQ=$O(PARM("ASEQ",SQ)) Q:'SQ  D
 .F LP=0:0 Q:'MATCH  S LP=$O(PARM("ASEQ",SQ,LP)) Q:'LP  D
 ..N PN,PN1,PN2,FN,TP,VL,CTL
 ..D EXTRP(.PARM,LP)
 ..I PN="@selector" X CTL Q
 ..F PN1=0:0 Q:'MATCH  S PN1=$O(RGNETREQ("PARAMS",PN,PN1)) Q:'PN1  D
 ...S MATCH=1
 ...F PN2=0:0 S PN2=$O(RGNETREQ("PARAMS",PN,PN1,PN2)) Q:'PN2  D  Q:MATCH
 ....N PVAL
 ....M PVAL=RGNETREQ("PARAMS",PN,PN1,PN2)
 ....I '$D(PVAL("I")) D
 .....S PVAL("I")=1
 .....D:$L(TP) @("INIT"_TP)
 .....M RGNETREQ("PARAMS",PN,PN1,PN2)=PVAL
 ....X CTL
 ....D:$L(TP)&$D(PVAL) @("FILTER"_TP)
 Q MATCH
 ; Number
INITN D EXTOPR("<>m")
 Q
FILTERN I PVAL'=+PVAL S MATCH=0
 E  D DOCOMP("I")
 Q
 ; Date
INITD D EXTOPR("<>m")
 N DAT,TIM,TZ,X
 I PVAL?4N1"-"2N1"-"2N.E D
 .S TIM=$P(PVAL,"T",2,9999),DAT=$P(PVAL,"T"),DAT=$P(DAT,"-",2,3)_"-"_$P(DAT,"-")
 .S X=$S($E(TIM,$L(TIM))="Z":"Z",TIM["-":"-",TIM["+":"+",1:"")
 .S TZ=X_$P(TIM,X,2,9999),TIM=$P(TIM,X),PVAL=DAT
 .S:$L(TIM) PVAL=PVAL_"@"_TIM
 .I $L(TIM),$L(TZ) D
 ..S X=$$TZ^XLFDT,TZ=X-$TR(TZ,":"),TZ(0)=TZ\100,TZ(1)=TZ-(TZ(0)*100)
 D DT^DILF($S(PVAL["@":"TS",1:""),PVAL,.DAT)
 I DAT>0,$D(TZ)>1 D
 .S DAT=$$FMADD^XLFDT(DAT,0,TZ(0),TZ(1),0)
 S PVAL=DAT
 Q
FILTERD I '$D(VL(2)) D DOCOMP("I") Q
 D DOCOMPP("I")
 Q
 ; String
INITS D EXTOPR("me","s")
 S:PVAL("OPR")="s" PVAL=$$UP^XLFSTR(PVAL)
 Q
FILTERS D DOCOMP("E")
 Q
 ; Token
INITT D EXTOPR("mt")
 S:PVAL["|" PVAL(0)=$P(PVAL,"|"),PVAL=$P(PVAL,"|",2)
 S:PVAL("OPR")="t" PVAL=$$UP^XLFSTR(PVAL)
 Q
FILTERT D DOCOMP($S(PVAL("OPR")="t":"E",1:"I"))
 Q
 ; Reference
INITR D EXTOPR("m")
 Q
FILTERR D DOCOMP("I")
 Q
 ; Quantity
INITQ D EXTOPR("<>m~")
 Q
FILTERQ D FILTERN
 Q
DOCOMP(IE) ;
 D DOCOMPX($G(VL(IE)))
 Q
 ; Perform comparison against a period
DOCOMPP(IE) ;
 N START,END,OPR
 S START=$G(VL(IE)),END=$G(VL(2,IE)),OPR=PVAL("OPR"),MATCH=0
 I 'START,'END Q
 I 'START D DOCOMPX(END) Q
 I 'END D DOCOMPX(START) Q
 I OPR["=" S MATCH=PVAL'<START&(PVAL'>END) Q:MATCH
 I OPR["<" S MATCH=START<PVAL Q
 I OPR[">" S MATCH=END>PVAL Q
 Q
 ; Perform comparison against search value
DOCOMPX(VAL) ;
 N OPR
 S MATCH=0,OPR=PVAL("OPR")
 I OPR["m" S MATCH='$L(VAL)=(PVAL="true") Q
 I OPR["=" S MATCH=VAL=PVAL Q:MATCH
 I OPR["<" S MATCH=VAL<PVAL Q
 I OPR[">" S MATCH=VAL>PVAL Q
 I OPR["e" S MATCH=VAL=PVAL Q
 I OPR["~" D  Q
 .N X1,X2,Y
 .S Y=PVAL/10,X1=PVAL-Y,X2=PVAL+Y,MATCH=VAL'<X1&(X'>X2)
 I OPR["s" D  Q
 .S VAL=$$UP^XLFSTR($E(VAL,1,$L(PVAL))),MATCH=VAL=PVAL
 I OPR["t" D  Q
 .S MATCH=$$UP^XLFSTR(VAL)[PVAL
 Q
 ; Name comparison
OPRNAME(VAL,PC) ;
 N X,Y
 S VAL=$P(VAL,",",PC)
 F X=1:1:$L(VAL," ") D  Q:MATCH
 .S Y=$P(VAL," ",X)
 .D:$L(Y) DOCOMPX(Y)
 Q
 ; Extract optional operator from search parameter
EXTOPR(ALLOWED,DFLT) ;
 N X,OPR
 S OPR=$G(PVAL("OPR"))
 F X="<=",">=","<",">","~" I ALLOWED[$E(X),$E(PVAL,1,$L(X))=X D  Q
 .I '$L(OPR) S OPR=X,PVAL=$E(PVAL,$L(X)+1,9999)
 .E  D OPEROUT^RGSEFHIR(7,X,PVAL)
 S PVAL("OPR")=$S($L(OPR):OPR,1:$G(DFLT,"="))
 Q
 ; Creates a new instance of an iterator
 ; EP = entry point (tag or tag^routine)
 ; Note: entry point will be invoked immediately via a DO
 ; to permit initialization.
NEWITER(EP) ;
 S:$E(EP,1,2)="$$" EP=$E(EP,3,99)
 S EP=EP_"("_$QS($$TMPGBL^RGNETWWW,3)_")"
 D @EP
 Q "$$"_EP
 ; Iterator implementation for traversing a cross reference
XREFITER(CTX,ROOT,START,TST) ;
 S CTX=$$TMPGBL^RGNETWWW(CTX)
 I '$Q D  Q
 .S START=$$UP^XLFSTR(START)
 .S @CTX@("IEN")=0,^("ROOT")=ROOT,(^("START"),^("LAST"))=START,^("TST")=$G(TST,"I 1")
 N LAST,IEN
 S IEN=@CTX@("IEN"),START=^("START"),LAST=^("LAST"),TST=^("TST"),ROOT=^("ROOT")
 F  D  Q:IEN
 .S:$L(LAST) IEN=+$O(@ROOT@(LAST,IEN)),@CTX@("IEN")=IEN
 .Q:IEN
 .S LAST=$O(@ROOT@(LAST)),@CTX@("LAST")=LAST
 .I 0
 .X:$L(LAST) TST
 .S:'$T IEN=-1
 Q $S(IEN>0:IEN,1:0)
 ; Iterator implementation for traversing a name cross references
NAMEITER(CTX,ROOT) ;
 I '$Q D XREFITER(CTX,ROOT,$$GETPARAM^RGNETWWW("family"),"I $E($P(LAST,"",""),1,$L(START))=START") Q
 Q $$XREFITER(CTX)
 ; Return a cohort based on a xref
 ; PARAM = Name of search parameter
 ; GBL = Root of xref
 ; OFF = Offset to subscript containing IEN (defaults to 0)
COHORT(PARAM,GBL,OFF) ;
 N LP,TMP
 S OFF=+$G(OFF),LP=$O(RGNETREQ("PARAMS",PARAM,1,0)),TMP=$$TMPGBL^RGNETWWW
 I 'OFF,LP,'$O(RGNETREQ("PARAMS",PARAM,1,LP)) Q $$GBLROOT(RGNETREQ("PARAMS",PARAM,1,LP),GBL)
 F LP=0:0 S LP=$O(RGNETREQ("PARAMS",PARAM,1,LP)) Q:'LP  D COHORT2(RGNETREQ("PARAMS",PARAM,1,LP),GBL,OFF,TMP)
 Q TMP
 ; Return a cohort based on a xref
 ; IDX = Value of indexed entry
 ; GBL = Root of xref
 ; OFF = Offset to subscript containing IEN (defaults to 0)
COHORT2(IDX,GBL,OFF,TMP) ;
 S TMP=$$COHORT3($$GBLROOT(IDX,GBL),.OFF,.TMP)
 Q:$Q TMP
 Q
 ; Return a cohort from a global root
 ; GBL = Root of global
 ; OFF = Offset to subscript containing IEN (defaults to 0)
 ; Internal entry point
COHORT3(GBL,OFF,TMP) ;
 N X,L,S,I,QL
 S:'$D(TMP) TMP=$$TMPGBL^RGNETWWW
 S OFF=+$G(OFF),QL=$QL(GBL)+OFF+1
 I OFF D
 .S X=GBL,L=$QL(X),S=""
 .F  S X=$Q(@X) Q:'$L(X)  Q:$NA(@X,L)'=GBL  D
 ..S I=$QS(X,QL)
 ..I $L(I),I'=S S S=I,@TMP@(S)=""
 .E  M @TMP=@GBL
 Q:$Q TMP
 Q
 ; Returns global root for indexed entries.
 ; IDX = Index of entries
 ; GBL = Global root.  If contains "*", index value is placed there.
 ;       Otherwise, index value is placed at end.
GBLROOT(IDX,GBL) ;
 Q:GBL'["*" $NA(@GBL@(IDX))
 S GBL=$P(GBL,"*")_IDX_$P(GBL,"*",2,9999)
 Q $NA(@GBL)
 ; Process a compartment request
COMPRT(GBL,EXC,OFF) ;
 D:$L(SLCT) PARSEQS^RGNETWWW("_id="_SLCT)
 S:'$G(EXC) GBL=$NA(@GBL@($P(PATH,"/",3)))
 S:$G(OFF) GBL=$$COHORT3(GBL,OFF)
 D GET(.RGSER,$P(PATH,"/")_"/"_$P(PATH,"/",4),GBL,.PNAME,FLAGS)
 Q
 ; Process a compound id (#-#) selector
COMPID N ID1,ID2
 S ID1=$P(SLCT,"-"),ID2=$P(SLCT,"-",2,9999)
 I '$L(ID1)!'$L(ID2) D
 .D OPEROUT^RGSEFHIR(8,SLCT)
 E  D GET(.RGSER,PATH_"_"_ID1,ID2,.PNAME,"S")
 Q
 ; Retrieve description for end point
GETDSC(SERNM) ;
 N SER,LP
 S SER=$$GETSER(SERNM)
 I SER'>0 D OPEROUT^RGSEFHIR(0) Q
 D SETCTYPE^RGNETWWW("text/html")
 D ADDARY^RGSER($NA(^RGSER(998.1,SER,99)),"WR")
 Q
 ; Process a template
 ;   NAME = Template name
 ;   RESN = The resource name or ien (defaults to current resource)
 ; Template may contain replaceable fields using |xxx| format, where xxx may be:
 ;   A field reference in the format: name or name,[I, E or W]
 ;     where I indicates the internal value, E the external, and W for word processing.
 ;   An expression in the format: @expression or #expression
 ;     where @ causes the result to be escaped, # does not.
TEMPLATE(NAME,RESN) ;
 N TMPL,SERX,LP,LN,X,Y
 I $D(RESN)#2 D  Q:'$D(SERX)
 .S:RESN'=+RESN RESN=$O(^RGSER(998.1,RGSER("SER"),10,"B",RESN,0))
 .S:RESN SERX=$NA(^RGSER(998.1,RGSER("SER"),10,RESN))
 E  S SERX=SER
 S TMPL=$O(@SERX@(50,"B",NAME,0))
 D:TMPL TEMPL1($NA(@SERX@(50,TMPL,1)))
 Q
 ; Process template at specified array root
TEMPL1(ROOT) ;
 N LP
 F LP=0:0 S LP=$O(@ROOT@(LP)) Q:'LP  D TEMPL2(^(LP,0),0)
 Q
 ; Process a line from a template
TEMPL2(LN,ESC) ;
 N PAR,VAL,FLG,SB
 F  Q:LN'["|"  D
 .D TEMPL3($P(LN,"|"),ESC)
 .S PAR=$P(LN,"|",2),LN=$P(LN,"|",3,9999)
 .S FLG=$E(PAR)
 .I FLG="@"!(FLG="#") D
 ..S @("VAL="_$E(PAR,2,9999))
 ..D TEMPL2(VAL,FLG="@")
 .E  D
 ..S:FLG="\" PAR=$E(PAR,2,9999)
 ..S SB=$P(PAR,",",2),PAR=$P(PAR,",")
 ..D F(PAR,SB,ESC)
 D TEMPL3(LN,ESC)
 Q
 ; Output template text
TEMPL3(OUT,ESC) ;
 Q:'$L(OUT)
 S:ESC OUT=$$ESCAPE^RGSER(OUT)
 D ADD^RGNETWWW(OUT)
 Q
 ; Outputs a field value
F(FN,SB,ESC) ;
 N LP
 S:'$L($G(SB)) SB=$O(VALS(FILE,IENS,FN,""))
 Q:'$L(SB)
 S ESC=+$G(ESC,1)
 I "IE"[SB D TEMPL2($G(VALS(FILE,IENS,FN,SB)),ESC) Q
 Q:SB'="W"
 F LP=0:0 S LP=$O(VALS(FILE,IENS,PAR,LP)) Q:'LP  D
 .D TEMPL2(VALS(FILE,IENS,FN,LP,0),ESC)
 .D TEMPL3($C(13,10),1)
 Q:$Q ""
 Q
