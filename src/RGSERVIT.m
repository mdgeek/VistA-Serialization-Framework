RGSERVIT ;RI/CBMI/DKM - Return vital observations. ;17-Apr-2015 12:44;DKM
 ;;1.0;SERIALIZATION FRAMEWORK;;07-Feb-2015 08:51;Build 249
 ;=================================================================
 ; Return vital measurements
EN(RESULTS,DFN,ID,BEG,END,MAX) ;
 N ARY,GMRVSTR,IEN,IDT,ANID,TYPE,QUAL,VALUE,PROC,RANGE,SEQ,X0,X,Y
 I $L($G(ID)) D
 .I $P(ID,"-")'="VT" S DFN=0 Q
 .S IEN=+$P(ID,"-",2),X0=$G(^GMR(120.5,IEN,0)),X=+$P(X0,U,2)
 .I $G(DFN),DFN'=X S DFN=0 Q
 .S DFN=X,MAX=9999,BEG=X0\1-.1,END=X0\1+.9
 .S GMRVSTR=$$GET1^DIQ(120.51,$P(X0,U,3),1)
 E  S GMRVSTR="BP;T;R;P;HT;WT;CVP;CG;PO2;PN"
 Q:'$G(DFN)
 S GMRVSTR(0)=BEG_U_END_U_MAX_"^1"
 K ^UTILITY($J,"GMRVD")
 D EN1^GMRVUT0,RANGES
 S IDT=0
 F  S IDT=$O(^UTILITY($J,"GMRVD",IDT)),TYPE="" Q:'IDT  D  Q:MAX'>0
 .F  S TYPE=$O(^UTILITY($J,"GMRVD",IDT,TYPE)),IEN=0 Q:TYPE=""  D  Q:MAX'>0
 ..S PROC=$$EP(TYPE)
 ..F  S IEN=$O(^UTILITY($J,"GMRVD",IDT,TYPE,IEN)) Q:'IEN  S X0=^(IEN) D  Q:MAX'>0
 ...S SEQ=0,VALUE=$P(X0,U,8),VALUE(0)=$P(X0,U,13),NAME=$$GET1^DIQ(120.5,IEN_",",.03)
 ...D @PROC
 K ^UTILITY($J,"GMRVD")
 Q
PROC(NAME,VALUE,UNITS,LOINC,HI,LO,RELATED) ;
 N ANID
 S SEQ=SEQ+1,ANID="VT-"_IEN_"-"_SEQ
 I '$L(VALUE),'$D(RELATED) Q
 I $L(ID) Q:ANID'=ID  S MAX=1
 S ARY=$$ARY^RGSEROBS(RESULTS),MAX=MAX-1,HI=+$G(HI),LO=+$G(LO),UNITS=$G(UNITS),LOINC=$G(LOINC)
 D PUT("id",ANID)
 D FILE^RGSEROBS("patient",DFN,2)
 D PUT("collected",9999999-IDT)
 D PUT("issued",$P(X0,U,4))                                            ;use last one
 D PUT("status","final")
 D PUT("reliability","ok")
 D:LOINC PUT("code",LOINC,NAME),PUT("code_system","http://loinc.org/")
 D:'LOINC PUT("code",$$VUID^RGSEROBS(+$P(X0,U,3),120.51),NAME),PUT("code_system",$$LOCALSYS^RGSER("vitals"))
 D PUT("value",VALUE)
 D PUT("units",UNITS)
 D PUT("low",RANGE(LO))
 D PUT("high",RANGE(HI))
 D FACILITY^RGSEROBS($P(X0,U,5))
 S QUAL=$P(X0,U,17)
 I $L(QUAL) F I=1:1:$L(QUAL,";") D
 .S X=$P(QUAL,";",I),Y=$$FIND1^DIC(120.52,,"QX",X)
 .D:Y PUT("qualifier."_I,$$VUID^RGSEROBS(Y,120.52),X)
 D:$D(RELATED) PUT("related",RELATED)
 Q
 ; Write to target array
PUT(NAME,INTERNAL,EXTERNAL) ;
 D PUT^RGSEROBS(.NAME,.INTERNAL,.EXTERNAL)
 Q
 ; Blood pressure
PROCBP D PROC("BLOOD PRESSURE","","","55284-4","","","VT-"_IEN_"-2,VT-"_IEN_"-3")
 D PROC("SYSTOLIC "_NAME,$P(VALUE,"/"),"mmHg","8480-6",5.7,5.71)
 D PROC("DIASTOLIC "_NAME,$P(VALUE,"/",2),"mmHg","8462-4",5.8,5.81)
 Q
 ; Temperature
PROCT D PROC(NAME,VALUE,"F","8310-5",5.1,5.2)
 D PROC(NAME,VALUE(0),"C","8310-5")
 Q
 ; Respiratory rate
PROCR D PROC(NAME,VALUE,"/min","9279-1",5.5,5.6)
 Q
 ; Pulse
PROCP D PROC(NAME,VALUE,"/min","8867-4",5.3,5.4)
 Q
 ; Height
PROCHT D PROC(NAME,VALUE,"in","8302-2")
 D PROC(NAME,VALUE(0),"cm","8302-2")
 Q
 ; Weight
PROCWT D PROC(NAME,VALUE,"lb","29463-7")
 D PROC(NAME,VALUE(0),"kg","29463-7")
 Q
 ; Central venous pressure
PROCCVP D PROC(NAME,VALUE,"cmH2O","8591-0",6.1,6.2)
 Q
 ; Circumference/girth
PROCCG D PROC(NAME,VALUE,"in","9844-2")
 D PROC(NAME,VALUE(0),"cm","9844-2")
 Q
 ; Pulse oximetry
PROCPO2 D PROC(NAME,VALUE,"%","59408-5",6.31,6.3)
 Q
 ; Pain
PROCPN D PROC(NAME,VALUE,,"57696-7")
 Q
 ; All other types
PROCOTH D PROC(NAME,VALUE)
 Q
 ; Return entry point for processing measurement
EP(TYPE) S TYPE="PROC"_TYPE
 Q $S($L($T(@TYPE)):TYPE,1:"PROCOTH")
 ; Load normal ranges
RANGES N VAL
 D GETS^DIQ(120.57,"1,","5:7","","VAL")
 M RANGE=VAL(120.57,"1,")
 S RANGE(6.31)=100,RANGE(0)=""
 Q
