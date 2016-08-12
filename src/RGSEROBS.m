RGSEROBS ;RI/CBMI/DKM - Return observations in intermediate format. ;01-Apr-2015 16:50;DKM
 ;;1.0;SERIALIZATION FRAMEWORK;;07-Feb-2015 08:51;Build 249
 ;=================================================================
OBS(DFN,ID,BEG,END,MAX) ;
 N RTN
 S RTN=$$TMPGBL^RGNETWWW,DFN=$G(DFN),ID=$G(ID),BEG=$G(BEG,1410101),END=$G(END,9999998)
 S MAX=$S($L(ID):1,1:$G(MAX,999999))
 D:'$$ISMAX EN^RGSERLAB(RTN,DFN,ID,BEG,END,MAX)
 D:'$$ISMAX EN^RGSERVIT(RTN,DFN,ID,BEG,END,MAX)
 S RGSER("RGSEROBS")=RTN
 Q RTN
 ; Retrieve data
RETRIEVE ; Merge into VALS
 S:'$D(RGSER("RGSEROBS")) RGSER("RGSEROBS")=$$OBS(,ID),IEN=1
 M VALS(0,IENS)=@RGSER("RGSEROBS")@(IEN)
 Q
 ; Return true if maximum observations returned
ISMAX() Q $O(@RTN@(""),-1)'<MAX
 ; Return vuid
VUID(IEN,FILE) ;
 Q $$GET1^DIQ(FILE,IEN_",",99.99)
 ; Ouput a file entry
FILE(NAME,IEN,FILE,FLD) ;
 D:IEN PUT(NAME,IEN,$$GET1^DIQ(FILE,+IEN,$G(FLD,.01)))
 Q
 ; Output facility
FACILITY(X) ;
 N P1,P2
 I $G(X) S P1=$$STA^XUAF4(X),P2=$P($$NS^XUAF4(X),U)
 E  S X=$$SITE^VASITE,P1=$P(X,U,2),P2=$P(X,U)
 D PUT("facility",P1,P2)
 Q
 ; Get array base
ARY(ARY) ;
 N X
 S X=$O(@ARY@(""),-1)+1
 Q $NA(@ARY@(X))
 ; Write to target array
PUT(NAME,INTERNAL,EXTERNAL) ;
 I $L($G(INTERNAL)) D
 .S @ARY@(NAME,"I")=INTERNAL
 .S @ARY@(NAME,"E")=$S($D(EXTERNAL)#2:EXTERNAL,1:INTERNAL)
 Q
 ; Output value (XML)
VALUEXML(VALUE,UNITS) ;
 Q:'$L($G(VALUE))
 I '$$ISNUM^RGUT(VALUE) D
 .D PUT^RGSEXML("valueString",VALUE)
 E  D
 .D NEWTAG^RGSEXML("valueQuantity")
 .D PUT^RGSEXML("value",VALUE)
 .I $L($G(UNITS)) D
 ..D PUT^RGSEXML("units",UNITS)
 ..D PUT^RGSEXML("code",UNITS)
 ..D PUT^RGSEXML("system","http://unitsofmeasure.org/")
 .D ENDTAG^RGSEXML("valueQuantity")
 Q
 ; Output value (JSON)
VALUEJSN(VALUE,UNITS) ;
 Q:'$L($G(VALUE))
 I '$$ISNUM^RGUT(VALUE) D
 .D PUT^RGSEJSON("valueString",VALUE)
 E  D
 .D NEWOBJ^RGSEJSON("valueQuantity")
 .D PUTRAW^RGSEJSON("value",VALUE)
 .I $L($G(UNITS)) D
 ..D PUT^RGSEJSON("units",UNITS)
 ..D PUT^RGSEJSON("code",UNITS)
 ..D PUT^RGSEJSON("system","http://unitsofmeasure.org/")
 .D ENDOBJ^RGSEJSON("valueQuantity")
 Q
 ; Return adusted reference range
REFRANGE(LOW,HIGH) ;
 S LOW=$G(VL("I")),HIGH=$G(VL(2,"I"))
 I $L(LOW),'$$ISNUM^RGUT(LOW) S LOW=""
 I $L(HIGH),'$$ISNUM^RGUT(HIGH) S HIGH=""
 Q $L(LOW)!$L(HIGH)
 ; Output reference range (XML)
RANGEXML(LOW,HIGH) ;
 Q:'$$REFRANGE(.LOW,.HIGH)
 D NEWTAG^RGSEXML(PN)
 D:$L(LOW) NEWTAG^RGSEXML("low"),PUT^RGSEXML("value",LOW),ENDTAG^RGSEXML("low")
 D:$L(HIGH) NEWTAG^RGSEXML("high"),PUT^RGSEXML("value",HIGH),ENDTAG^RGSEXML("high")
 D ENDTAG^RGSEXML(PN)
 Q
 ; Output reference range (JSON)
RANGEJSN(LOW,HIGH) ;
 Q:'$$REFRANGE(.LOW,.HIGH)
 D NEWARY^RGSEJSON(PN),NEWOBJ^RGSEJSON
 D:$L(LOW) NEWOBJ^RGSEJSON("low"),PUTAUTO^RGSEJSON("value",LOW),ENDOBJ^RGSEJSON("low")
 D:$L(HIGH) NEWOBJ^RGSEJSON("high"),PUTAUTO^RGSEJSON("value",HIGH),ENDOBJ^RGSEJSON("high")
 D ENDARY^RGSEJSON(PN)
 Q
 ; Output related observations (XML)
RELXML(RELATED) ;
 N LP
 F LP=1:1:$L(RELATED,",") D
 .D NEWTAG^RGSEXML("related")
 .D PUT^RGSEXML("type","has-component")
 .D PUT^RGSEXML("target:reference","Observation/"_$P(RELATED,",",LP))
 .D ENDTAG^RGSEXML("related")
 Q
 ; Output related observations (JSON)
RELJSN(RELATED) ;
 N LP
 D NEWARY^RGSEJSON("related")
 F LP=1:1:$L(RELATED,",") D
 .D NEWOBJ^RGSEJSON("related")
 .D PUT^RGSEJSON("type","has-component")
 .D NEWOBJ^RGSEJSON("target")
 .D PUT^RGSEJSON("reference","Observation/"_$P(RELATED,",",LP))
 .D ENDOBJ^RGSEJSON("related")
 D ENDARY^RGSEJSON("related")
 Q
