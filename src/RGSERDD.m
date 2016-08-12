RGSERDD ;RI/CBMI/DKM - Data dictionary logic ;28-May-2015 09:34;DKM
 ;;1.0;SERIALIZATION FRAMEWORK;;14-March-2014;Build 1
 ;=================================================================
 ; Convert to pattern (Used by B xref of 998.11:.01)
TOPTRN(NM) ;
 Q $$TOPTRN^RGNETWWW(NM)
 ; Input transform for 998.12:10
ITXCTRL(X,DA) ;
 I '$L(X)!($L(X)>250) K X Q
 N TYPE
 S TYPE=$P($G(^RGSER(998.1,DA(2),10,DA(1),30,DA,0)),U,3)
 I '$L(TYPE) K X Q
 I TYPE="C" D ^DIM Q
 I TYPE="T" K:'$O(^RGSER(998.1,DA(2),10,DA(1),50,"B",X,0)) X Q
 I "NSW"[TYPE Q
 I "IOM"[TYPE D  Q
 .N RGSER
 .S RGSER="RGSER",RGSER("SER")=DA(2),RGSER("SERNM")=$P(^RGSER(998.1,DA(2),0),U)
 .K:'$L($$GETGBL^RGSERGET(X,1)) X
 K X
 Q
