RGSEFHIX ;RI/CBMI/DKM - XML FHIR Support ;08-Aug-2016 08:13;DKM
 ;;1.0;SERIALIZATION FRAMEWORK;;07-Feb-2015 08:51
 ;=================================================================
 ; Implements Serializer interface
 ; Serializer.PREINIT - Preinitialization
PREINIT D PREINIT^RGSEXML
 S RGSER("FHIR.VERSION")=$P(PATH,"/")
 D:$$ISBROWSR^RGNETWWW SETCTYPE^RGNETWWW("text/xml")
 Q
 ; Serializer.PSTINIT - Postinitialization
PSTINIT D PSTINIT^RGSEXML
 Q
 ; Serializer.PRELIST - List preprocessing
PRELIST I TOP,'$$INBUNDLE D NEWBNDL("Search results for resource type "_PATH)
 Q
 ; Serializer.PSTLIST - List postprocessing
PSTLIST I TOP,$$INBUNDLE,'$$ISERROR^RGNETWWW D ENDBNDL
 Q
 ; Serializer.COMPOSE - Compose an entry
COMPOSE N ENTRY,TAG,ATR,DSTU1
 S DSTU1=RGSER("FHIR.VERSION")="DSTU1"
 S TAG=$$GETRTYPE^RGSERGET(PATH,PNAME)
 S ENTRY='$L($G(PNAME))&$$INBUNDLE&'$$HASFLAG^RGSER("S")
 D:ENTRY NEWENTRY(TAG,ID)
 S:'$L(PNAME) ATR(0,"xmlns")="http://hl7.org/fhir"
 S:$$HASFLAG^RGSER("I") ATR(1,"id")=ID
 D PROP2ATR^RGSEFHIR(.PROP,.ATR)
 S:$E(TAG)="@" TAG=""
 D NEWTAG(TAG,.ATR):$L(TAG),PROCPROP^RGSERGET,ENDTAG(TAG):$L(TAG)
 D:ENTRY ENDENTRY
 Q
 ; Serializer.FMTDATE - Serialize a date
FMTDATE(DT) ;
 Q $$FMTDATE^RGSEXML(.DT)
 ; Serializer.ESCMAP - Location of escape map
ESCMAP() Q $$ESCMAP^RGSEXML
 ; Serializer.PROPF - Free text property
PROPF G PROPF^RGSEXML
 ; Serializer.PROPB - Boolean property
PROPB G PROPB^RGSEXML
 ; Serializer.PROPD - Date property
PROPD G PROPD^RGSEXML
 ; Serializer.PROPR - Raw value property
PROPR G PROPR^RGSEXML
 ; Serializer.PROPW - Word processing property
PROPW G PROPW^RGSEXML
 ; Serializer.PROPC - Custom property
PROPC X CTL
 Q
 ; Serializer.PROPO - Object property
PROPO G PROPO^RGSEXML
 ; Serializer.PROPI - Inline property
PROPI G PROPI^RGSEXML
 ; Serializer.PROPS - Static property
PROPS G PROPS^RGSEXML
 ; Create a new bundle.
NEWBNDL(TITLE,ID,LINK) ;
 N ATR
 I RGSER("FHIR.VERSION")="DSTU1" D
 .D:'$$ISBROWSR^RGNETWWW SETCTYPE^RGNETWWW("application/atom+xml")
 .S:'$D(ID) ID="urn:uuid:"_$$UUID^RGUT
 .S ATR("xmlns")="http://www.w3.org/2005/Atom"
 .D NEWTAG("feed",.ATR)
 .D NEWTAG("title",$G(TITLE,"Query Results"),1)
 .D NEWTAG("id",ID,1)
 .S:$D(LINK)#2 ATR(1,"rel")="self",ATR(2,"href")=LINK
 .D:$D(ATR) NEWTAG("link",.ATR,1)
 .S ATR(1,"rel")="fhir-base",ATR(2,"href")=$$HOSTURL^RGNETWWW("*")
 .D NEWTAG("link",.ATR,1)
 .D NEWTAG("updated",$$FMTDATE,1)
 .D NEWTAG("author"),NEWTAG("name",$P($G(^DIC(4,+$G(DUZ(2)),0),"Unknown"),U),1),ENDTAG("author")
 .S ATR=0,ATR("xmlns")="http://a9.com/-/spec/opensearch/1.1/"
 .D NEWTAG("totalResults",.ATR,1)
 .S RGSER("FHIR.BUNDLE")=RGNETRSP("LAST")-1
 E  D
 .S:'$D(ID) ID=$$UUID^RGUT
 .S ATR("xmlns")="http://hl7.org/fhir"
 .D NEWTAG("Bundle",.ATR)
 .D PUT("id",ID)
 .D NEWTAG("meta"),PUT("versionId",1),PUT("lastUpdated",$$FMTDATE),ENDTAG("meta")
 .D PUT("type","searchset")
 .D PUT("base",$$HOSTURL^RGNETWWW("*"))
 .D PUT("total",0)
 .S RGSER("FHIR.BUNDLE")=RGNETRSP("LAST")
 .D:$D(LINK)#2 NEWTAG("link"),PUT("relation","self"),PUT("url",LINK),ENDTAG("link")
 S RGSER("FHIR.COUNT")=0
 Q
 ; Close current bundle.
ENDBNDL N POS
 S POS=$$INBUNDLE
 Q:'POS
 I RGSER("FHIR.VERSION")="DSTU1" D
 .D ENDTAG("feed")
 .D REPLACE^RGNETWWW(POS,RGSER("FHIR.COUNT"))
 E  D
 .D ENDTAG("Bundle")
 .D REPLACE^RGNETWWW(POS,"<total value="""_RGSER("FHIR.COUNT")_"""/>")
 K RGSER("FHIR.BUNDLE"),RGSER("FHIR.COUNT")
 Q
 ; Returns true if in a bundle.
INBUNDLE() Q $G(RGSER("FHIR.BUNDLE"))
 ; Creates a new bundle entry.
NEWENTRY(RTYP,IEN) ;
 N ATR
 S:IEN'["/" IEN=RTYP_"/"_IEN
 D NEWTAG("entry")
 I RGSER("FHIR.VERSION")="DSTU1" D
 .D NEWTAG("id",IEN,1)
 .D NEWTAG("updated",$$FMTDATE,1)
 .S ATR("type")="text/xml"
 .D NEWTAG("content",.ATR)
 E  D
 .;D PUT("status","match")
 .D NEWTAG("resource")
 S RGSER("FHIR.COUNT")=RGSER("FHIR.COUNT")+1
 Q
 ; Closes current bundle entry.
ENDENTRY() ;
 D ENDTAG("entry")
 Q
 ; Put a name/value pair to output buffer
PUT(NM,VL) ;
 D PUT^RGSEXML(.NM,.VL) Q
 ; Put a date value to output buffer
PUTDT(NM,DT) ;
 D PUTDT^RGSEXML(.NM,.DT) Q
 ; Write the text section
 ; TXT = Scalar value (will be escaped) or
 ;       array (will not be escaped)
TEXT(TXT) ;
 N ATR,LP
 S ATR("xmlns")="http://www.w3.org/1999/xhtml"
 D NEWTAG("text"),PUT("status","generated"),NEWTAG("div",.ATR)
 I $D(TXT)=1 D
 .D ADD^RGNETWWW($$ESCAPE^RGSER(TXT))
 E  D
 .S LP=""
 .F  S LP=$O(TXT(LP)) Q:'$L(LP)  D ADD^RGNETWWW(TXT(LP))
 D ENDTAG("text")
 Q
 ;Add opening tag (with optional attributes)
 ; TAG = tag name
 ; ATR = optional array of attributes and/or content
 ; CLS = if true, tag is self-closing
NEWTAG(TAG,ATR,CLS) ;
 D NEWTAG^RGSEXML(.TAG,.ATR,.CLS) Q
 ; Write closing tag
 ;  TAG = If specified, write closing tags up to and including
 ;    this one.  Otherwise, just write last pending closing tag.
 ;  Returns true if there are more pending tag closures.
ENDTAG(TAG) ;
 D ENDTAG^RGSEXML(.TAG) Q
 ; Reformats a variable pointer for use as a resource id.
VP2ID(VP) ;
 Q $$VP2ID^RGSEFHIR(.VP)
 ; Identifier
IDENT(SYSTEM,VALUE,TYPE,USE) ;
 Q:'$L(VALUE)
 D NEWTAG("identifier")
 D PUT("use",.USE)
 I DSTU1 D
 .D PUT("label",.TYPE)
 E  D:$D(TYPE)
 .D PARSIDTP^RGSEFHIR(.TYPE),CODING("type",TYPE(2),TYPE(0),TYPE(1))
 D PUT("system",$$SYSTEM^RGSER(.SYSTEM))
 D PUT("value",VALUE)
 D ENDTAG("identifier")
 Q
 ; Reference
REF(TAG,RES,VL,PFX) ;
 D REF2(TAG,RES,VL("I"),VL("E"),.PFX)
 Q
 ; Reference
REF2(TAG,RES,VLI,VLE,PFX) ;
 I $L(VLI)!$L(VLE) D
 .D NEWTAG(TAG)
 .D:$L(VLI) PUT("reference",RES_"/"_$G(PFX)_VLI)
 .D:$L(VLE) PUT("display",VLE)
 .D ENDTAG(TAG)
 Q
 ; Codeable concept
CODING(TAG,SYSTEM,CODE,DISPLAY) ;
 I '$L($G(CODE)),'$L($G(DISPLAY)) Q
 D:$D(TAG) NEWTAG(TAG)
 D NEWTAG("coding")
 D PUT("system",$$SYSTEM^RGSER(.SYSTEM))
 D PUT("code",.CODE)
 D PUT("display",.DISPLAY)
 D ENDTAG("coding")
 D:$D(TAG) ENDTAG(TAG)
 Q
 ; Contact
CONTACT(TAG,SYSTEM,VALUE,USE,START,END) ;
 Q:'$L(VALUE)
 D NEWTAG(TAG)
 D PUT("system",$$SYSTEM^RGSER(.SYSTEM))
 D PUT("use",.USE)
 D PUT("value",VALUE)
 D PERIOD(.START,.END)
 D ENDTAG(TAG)
 Q
 ; Telecom
TELECOM D:VL CONTACT(PN,$P(PN(0),":"),VL("E"),$P(PN(0),":",2))
 Q
 ; Period
PERIOD(START,END) ;
 I $G(START)!$G(END) D
 .D NEWTAG("period")
 .D:$G(START) PUTDT("start",START)
 .D:$G(END) PUTDT("end",END)
 .D ENDTAG("period")
 Q
NAME(NAME,USE) ;
 N X
 D NEWTAG("name")
 D PUT("use",$G(USE,"usual"))
 D PUT("text",$S($E(NAME)=",":$E(NAME,2,99),1:NAME))
 S X=$P(NAME,","),NAME=$P(NAME,",",2,99)
 D PUT("family",X)
 F X=1:1:$L(NAME," ") D PUT("given",$P(NAME," ",X))
 D ENDTAG("name")
 Q
