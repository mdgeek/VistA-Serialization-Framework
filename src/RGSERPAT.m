RGSERPAT ;RI/CBMI/DKM - Patient Resource Support ;04-Aug-2016 18:18;DKM
 ;;1.0;SERIALIZATION FRAMEWORK;;07-Feb-2015 08:51
 ;=================================================================
HRN(DFN) ; Return HRN given DFN
 N X
 S X=$G(^AUPNPAT(DFN,41,+$G(DUZ(2)),0))
 Q $S($P(X,U,3):"",1:$P(X,U,2))
ICN(DFN) ; Return ICN given DFN
 N X
 S X=$$GETICN^MPIF001(DFN)
 Q $S(X<0:"",1:X)
 ; Iterator for traversing name xref
NAMEITER(CTX) ;
 I '$Q D NAMEITER^RGSERGET(CTX,$NA(^DPT("B"))) Q
 Q $$NAMEITER^RGSERGET(CTX)
 ; Convert marital status to HL7-compliant code
MARITAL(C) ;
 Q:C="MARRIED" "M^Married"
 Q:C="DIVORCED" "D^Divorced"
 Q:C="NEVER MARRIED" "S^Never Married"
 Q:C="SEPARATED" "L^Legally Separated"
 Q:C="WIDOWED" "W^Widowed"
 Q "UNK^Unknown"
 ; Convert county IEN to name
COUNTY(STATE,COUNTY) ;
 Q $S('COUNTY:"",1:$P($G(^DIC(5,STATE,1,COUNTY,0)),U))
