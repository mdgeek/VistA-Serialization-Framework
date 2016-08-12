RGSEFHIJ ;RI/CBMI/DKM - JSON FHIR Support ;08-Aug-2016 08:13;DKM
 ;;1.0;SERIALIZATION FRAMEWORK;;07-Feb-2015 08:51
 ;=================================================================
 ; Implements Serializer interface
 ; Serializer.PREINIT - Preinitialization
PREINIT D PREINIT^RGSEJSON
 S RGSER("FHIR.VERSION")=$P(PATH,"/")
 D:$$ISBROWSR^RGNETWWW SETCTYPE^RGNETWWW("text/json")
 Q
 ; Serializer.PSTINIT - Postinitialization
PSTINIT D PSTINIT^RGSEJSON
 Q
 ; Serializer.PRELIST - List preprocessing
PRELIST I TOP,'$$INBUNDLE D NEWBNDL("Search results for resource type "_PATH) Q
 D NEWARY(PNAME)
 Q
 ; Serializer.PSTLIST - List postprocessing
PSTLIST I TOP,$$INBUNDLE,'$$ISERROR^RGNETWWW D ENDBNDL Q
 D ENDARY(PNAME)
 Q
 ; Serializer.COMPOSE - Compose an entry
COMPOSE N ENTRY,RTYPE,ATR,TAG,DSTU1
 S DSTU1=RGSER("FHIR.VERSION")="DSTU1"
 S RTYPE=$$GETRTYPE^RGSERGET(PATH,PNAME)
 S ENTRY='$L($G(PNAME))&$$INBUNDLE&'$$HASFLAG^RGSER("S")
 D:ENTRY NEWENTRY(RTYPE,ID)
 S:$$HASFLAG^RGSER("I") ATR(1,"id")=ID
 D PROP2ATR^RGSEFHIR(.PROP,.ATR)
 S:$L(PNAME) RTYPE=""
 S TAG=$S('ENTRY:PNAME,DSTU1:"content",1:"resource")
 D COMPOSEX^RGSEJSON(TAG,"resourceType",RTYPE,.ATR,1)
 D:ENTRY ENDENTRY
 Q
 ; Serializer.FMTDATE - Serialize a date
FMTDATE(DT) ;
 Q $$FMTDATE^RGSEXML(.DT)
 ; Serializer.ESCMAP - Location of escape map
ESCMAP() Q $$ESCMAP^RGSEJSON
 ; Serializer.PROPF - Free text property
PROPF G PROPF^RGSEJSON
 ; Serializer.PROPB - Boolean property
PROPB G PROPB^RGSEJSON
 ; Serializer.PROPD - Date property
PROPD G PROPD^RGSEJSON
 ; Serializer.PROPR - Raw value property
PROPR G PROPR^RGSEJSON
 ; Serializer.PROPW - Word processing property
PROPW G PROPW^RGSEJSON
 ; Serializer.PROPC - Custom property
PROPC X CTL
 Q
 ; Serializer.PROPO - Object property
PROPO G PROPO^RGSEJSON
 ; Serializer.PROPI - Inline property
PROPI G PROPI^RGSEJSON
 ; Serializer.PROPS - Static property
PROPS G PROPS^RGSEJSON
 ; Create a new bundle.
NEWBNDL(TITLE,ID,LINK) ;
 N OBJ
 D NEWOBJ("@Bundle")
 D PUT("resourceType","Bundle")
 I RGSER("FHIR.VERSION")="DSTU1" D
 .S:'$D(ID) ID="urn:uuid:"_$$UUID^RGUT
 .D PUT("id",ID)
 .D PUT("title",$G(TITLE,"Query Results"))
 .D PUTDT("updated",$$NOW^XLFDT)
 .D PUT("totalResults",0)
 .S RGSER("FHIR.BUNDLE")=RGNETRSP("LAST")
 .D NEWARY("link")
 .I $D(LINK)#2 D
 ..S OBJ(1,"rel")="self",OBJ(2,"href")=LINK
 ..D PUTOBJ^RGSEJSON(,.OBJ)
 .S OBJ(1,"rel")="fhir-base",OBJ(2,"href")=$$HOSTURL^RGNETWWW("*")
 .D PUTOBJ^RGSEJSON(,.OBJ)
 .D ENDARY("link")
 E  D
 .S:'$D(ID) ID=$$UUID^RGUT
 .D PUT("id",ID)
 .D NEWOBJ("meta"),PUT("versionId",1),PUT("lastUpdated",$$FMTDATE),ENDOBJ("meta")
 .D PUT("type","searchset")
 .D PUT("base",$$HOSTURL^RGNETWWW)
 .D PUT("total",0)
 .S RGSER("FHIR.BUNDLE")=RGNETRSP("LAST")
 .I $D(LINK)#2 D
 ..D NEWARY("link")
 ..S OBJ(1,"relation")="self",OBJ(2,"url")=LINK
 ..D PUTOBJ^RGSEJSON(,.OBJ)
 ..D ENDARY("link")
 D NEWARY("entry")
 S RGSER("FHIR.COUNT")=0
 Q
 ; Close current bundle.
ENDBNDL N POS
 S POS=$$INBUNDLE
 Q:'POS
 D ENDOBJ("@Bundle"),REPLACE^RGNETWWW(POS,$$SUBST^RGUT(@RGNETRSP@(POS),"0",RGSER("FHIR.COUNT")))
 K RGSER("FHIR.BUNDLE"),RGSER("FHIR.COUNT")
 Q
 ; Returns true if in a bundle.
INBUNDLE() Q $G(RGSER("FHIR.BUNDLE"))
 ; Creates a new bundle entry.
NEWENTRY(RTYP,IEN) ;
 D NEWOBJ("@entry")
 I RGSER("FHIR.VERSION")="DSTU1" D
 .S:IEN'["/" IEN=RTYP_"/"_IEN
 .D PUT("id",IEN)
 .D PUT("updated",$$FMTDATE)
 S RGSER("FHIR.COUNT")=RGSER("FHIR.COUNT")+1
 Q
 ; Closes current bundle entry.
ENDENTRY() ;
 D ENDOBJ("@entry")
 Q
NEWARY(NM) ;
 D NEWARY^RGSEJSON(.NM)
 Q
ENDARY(NM) ;
 D ENDARY^RGSEJSON(.NM)
 Q
NEWOBJ(NM) ;
 D NEWOBJ^RGSEJSON(.NM)
 Q
ENDOBJ(NM) ;
 D ENDOBJ^RGSEJSON(.NM)
 Q
 ; Put a name/value pair to output buffer
PUT(NM,VL) ;
 D PUT^RGSEJSON(.NM,.VL) Q
 ; Put an array to output buffer
PUTARY(NM,ARY,LT,CT) ;
 D PUTARY^RGSEJSON(.NM,.ARY,.LT,.CT)
 Q
 ; Put a date value to output buffer
PUTDT(NM,DT) ;
 D PUTDT^RGSEJSON(.NM,.DT) Q
 ; Write the text section
 ; TXT = Scalar value (will be escaped) or
 ;       array (will not be escaped)
TEXT(TXT) ;
 N ATR,LP
 D NEWOBJ("text"),PUT("status","generated")
 I $D(TXT)=1 D
 .D PUT("div",TXT)
 E  D PUTARY("div",.TXT,,1)
 D ENDOBJ("text")
 Q
 ; Reformats a variable pointer for use as a resource id.
VP2ID(VP) ;
 Q $$VP2ID^RGSEFHIR(.VP)
 ; Identifier
IDENT(SYSTEM,VALUE,TYPE,USE) ;
 Q:'$L(VALUE)
 D NEWOBJ("identifier")
 D PUT("use",.USE)
 I DSTU1 D
 .D PUT("label",.TYPE)
 E  D:$D(TYPE)
 .D PARSIDTP^RGSEFHIR(.TYPE),CODING("type",TYPE(2),TYPE(0),TYPE(1))
 D PUT("system",$$SYSTEM^RGSER(.SYSTEM))
 D PUT("value",VALUE)
 D ENDOBJ("identifier")
 Q
 ; Reference
REF(TAG,RES,VL,PFX) ;
 D REF2(.TAG,RES,VL("I"),VL("E"),.PFX)
 Q
 ; Reference
REF2(TAG,RES,VLI,VLE,PFX) ;
 I $L(VLI)!$L(VLE) D
 .D:$D(TAG) NEWOBJ(TAG)
 .D:$L(VLI) PUT("reference",RES_"/"_$G(PFX)_VLI)
 .D:$L(VLE) PUT("display",VLE)
 .D:$D(TAG) ENDOBJ(TAG)
 Q
 ; Codeable concept
CODING(TAG,SYSTEM,CODE,DISPLAY) ;
 I '$L($G(CODE)),'$L($G(DISPLAY)) Q
 D:$L($G(TAG)) NEWOBJ(TAG),NEWARY("coding")
 D NEWOBJ("@coding")
 D PUT("system",$$SYSTEM^RGSER(.SYSTEM))
 D PUT("code",.CODE)
 D PUT("display",.DISPLAY)
 D ENDOBJ("@coding")
 D:$L($G(TAG)) ENDOBJ(TAG)
 Q
 ; Contact
CONTACT(SYSTEM,VALUE,USE,START,END) ;
 Q:'$L(VALUE)
 D NEWOBJ("@contact")
 D PUT("system",$$SYSTEM^RGSER(.SYSTEM))
 D PUT("use",.USE)
 D PUT("value",VALUE)
 D PERIOD(.START,.END)
 D ENDOBJ("@contact")
 Q
 ; Telecom
TELECOM D:VL CONTACT($P(PN(0),":"),VL("E"),$P(PN(0),":",2))
 Q
 ; Period
PERIOD(START,END) ;
 I $G(START)!$G(END) D
 .D NEWOBJ("period")
 .D:$G(START) PUTDT("start",START)
 .D:$G(END) PUTDT("end",END)
 .D ENDOBJ("period")
 Q
NAME(NAME,USE) ;
 N X
 D NEWOBJ("@name")
 D PUT("use",$G(USE,"usual"))
 D PUT("text",$S($E(NAME)=",":$E(NAME,2,99),1:NAME))
 S X(1)=$P(NAME,","),NAME=$P(NAME,",",2,99)
 D:$L(X(1)) PUTARY("family",.X)
 K X
 F X=1:1:$L(NAME," ") S X(X)=$P(NAME," ",X)
 D PUTARY("given",.X)
 D ENDOBJ("@name")
 Q
