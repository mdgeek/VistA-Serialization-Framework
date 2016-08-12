RGSERLAB ;RI/CBMI/DKM - Return lab observations. ;04-Aug-2016 22:02;DKM
 ;;1.0;SERIALIZATION FRAMEWORK;;07-Feb-2015 08:51
 ;=================================================================
 ; Return lab results
EN(RESULTS,DFN,ID,BEG,END,MAX) ;
 N LRDFN,LRIDT,LRSUB,LRSEQ,LR0
 I $L($G(ID)) D
 .S LRSUB=$P(ID,"-")
 .I "^CH^MI^AP^"'[(U_LRSUB_U) S DFN=0 Q
 .S LRDFN=+$P(ID,"-",3),LRIDT=$P(ID,"-",2),LR0=$G(^LR(LRDFN,0))
 .I $P(LR0,U,2)'=2 S DFN=0 Q
 .I '$G(DFN) S DFN=+$P(LR0,U,3) Q
 .I DFN'=$P(LR0,U,3) S DFN=0 Q
 .S (BEG,END)=9999999-LRIDT
 E  S DFN=+$G(DFN),LRDFN=$G(^DPT(DFN,"LR")),LRSUB=""
 Q:'DFN
 Q:'LRDFN
 K ^TMP("LRRR",$J,DFN)
 D RR^LR7OR1(DFN,,BEG,END,LRSUB,,,MAX)
 S LRSUB=""
 F  S LRSUB=$O(^TMP("LRRR",$J,DFN,LRSUB)),LRIDT=0 Q:LRSUB=""  D  Q:MAX'>0
 .F  S LRIDT=$O(^TMP("LRRR",$J,DFN,LRSUB,LRIDT)) Q:'LRIDT  D  Q:MAX'>0
 ..S LR0=$G(^LR(LRDFN,LRSUB,LRIDT,0)),LRSEQ=0
 ..F  S LRSEQ=$O(^TMP("LRRR",$J,DFN,LRSUB,LRIDT,LRSEQ)) Q:'LRSEQ  D PROCESS(^(LRSEQ)) Q:MAX'>0
 K ^TMP("LRRR",$J,DFN)
 Q
 ; Process an entry
 ; AU: LUNG,LT (gm)^200^^^^F^^^^^^^^^LUNG,LT (gm)^200^^^;AU;
 ; CH: 179^2^L*^meq/L^23 - 31^F^^^82830.0000^Carbon Dioxide Content^99NLT^11733^^^CO2^CH 0917 3^1209^^72"
 ; CY: GROSS DESCRIPTION^Swab for PAP smear^^^^I^^TX^^^&GDT^^^^GROSS DESCRIPTION^^^;CY;7039672.99999
 ; EM: ORGAN/TISSUE^LYMPH NODE^^^^F^1^CE^08000^SNM^&ANT^^^^ORG/TISS^^^;EM;7049691
 ; MI: URINE SCREEN^Positive^^^^P^^^^^^^^^URINE SCREEN^^^;MI;7079882.8562^71
 ; MI: ORGANISM^ESCHERICHIA COLI;3+ ^^^^P^^^^^^^^^ORGANISM^^^;MI;7079882.8562^71
 ; MI: R^R^^^^P^^^^^^^^^R^^^;MI;7079882.8562^71
 ; SP: MORPHOLOGY^NEGATIVE FOR MALIGNANT CELLS^^^^F^1^CE^09460^SNM^&IMP^^^^_MORPH^^^;SP;7049482
PROCESS(LRX) ;
 N ANID,ARY,LRN,X
 S LRN=+$P($P($G(^LAB(60,+LRX,0)),U,5),";",2)
 S ANID=LRSUB_"-"_LRIDT_"-"_LRDFN_"-"_$S(LRN:LRN,1:LRSEQ)
 I $L($G(ID)),ID'=ANID Q
 S ARY=$$ARY^RGSEROBS(RESULTS),MAX=MAX-1
 D PUT("id",ANID)
 D PUT("collected",9999999-LRIDT)
 S X=$P(LR0,U,3)
 D PUT("issued",X)
 D PUT("status","final")
 D PUT("reliability","ok")
 D PUT("value",$P(LRX,U,2))
 D PUT("interpretation",$P(LRX,U,3))
 D PUT("units",$P(LRX,U,4))
 S X=$P(LRX,U,5)
 D PUT("low",$P(X," - ")),PUT("high",$P(X," - ",2))
 D PUT("localName",$P(LRX,U,15))
 S LOINC=$S(LRN:+$P($P($G(^LR(LRDFN,LRSUB,LRIDT,LRN)),U,3),"!",3),1:"")
 S X=+$P(LRX,U,19)
 I X D  ;specimen
 .D PUT("specimen",$$GET1^DIQ(61,X_",",2),$$GET1^DIQ(61,X_",",4.1)) ;SNOMED
 .D PUT("sample",$$GET1^DIQ(61,X_",",4.1))
 .S:'LOINC LOINC=$$GET1^DIQ(60.01,X_","_+LRX_",",95.3)
 I LOINC D
 .D PUT("code",$$GET1^DIQ(95.3,LOINC_",",.01),$$GET1^DIQ(95.3,LOINC_",",80))
 .D PUT("code_system","http://loinc.org/")
 E  I LRX D
 .D FILE^RGSEROBS("code",+LRX,60)
 .D PUT("code_system",$$LOCALSYS^RGSER("lab"))
 E  D
 .S X=$P(LRX,U)
 .S:'$L(X) X=$P(LRX,U,15)
 .D PUT("code",$S($L(X):X,1:"UNKNOWN"))
 .D PUT("code_system",$$LOCALSYS^RGSER("lab"))
 S X=$P(LRX,U,16)
 D PUT("groupID",X)
 D PUT("type",$S(LRSUB="CH":$$TYPE($P(X," ")),1:LRSUB))
 S X=+$P(LRX,U,17)
 D:X PUT("labOrderID",X)
 S X=$$ORDER(X,+LRX)
 D:X PUT("orderID",X)
 D FILE^RGSEROBS("patient",DFN,2)
 D FACILITY^RGSEROBS($P(LR0,U,14))
 D COMMENT
 Q
 ; Return #100 order given order # and test.
ORDER(LABORD,TEST) ;
 N Y,D,S,T
 S Y="",D=$O(^LRO(69,"C",LABORD,0))
 I D D
 .S S=0
 .F  S S=$O(^LRO(69,"C",LABORD,D,S)),T=0 Q:S<1  D  Q:Y
 ..F  S T=$O(^LRO(69,D,1,S,2,T)) Q:T<1  I +$G(^(T,0))=TEST S Y=+$P(^(0),U,7) Q
 Q Y
 ; Process comment (if any)
COMMENT N CMNT,LP,X
 S (LP,CMNT)=""
 F  S LP=$O(^TMP("LRRR",$J,DFN,LRSUB,LRIDT,"N",LP)) Q:'$L(LP)  S X=$G(^(LP))_$G(^(LP,0)) D
 .S CMNT=CMNT_$S($L(CMNT):$C(13,10),1:"")_X
 D PUT("comments",CMNT)
 Q
 ; Return name of lab section
TYPE(X) N LPY,Y
 S Y=X
 D FIND^DIC(68,,.01,"PQX",X,,"B",,,"LPY")
 S:$G(LPY("DILIST",1,0)) Y=$P(LPY("DILIST",1,0),U,2) ;name
 Q Y
 ; Write to target array
PUT(NAME,INTERNAL,EXTERNAL) ;
 D PUT^RGSEROBS(.NAME,.INTERNAL,.EXTERNAL)
 Q
