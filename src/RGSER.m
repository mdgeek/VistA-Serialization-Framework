RGSER ;RI/CBMI/DKM - Core Serialization Support ;07-Aug-2016 04:44;DKM
 ;;1.0;SERIALIZATION FRAMEWORK;;14-March-2014;Build 280
 ; RPC: Perform a GET operation
 ;=================================================================
FETCH(DATA,PATH,SLCT,PARAMS) ;
 N RGNETREQ,RGNETRSP
 S RGNETREQ("PATH")=PATH_"/"_$G(SLCT)
 D INIT^RGNETWWW,GET^RGSERGET(.PARAMS,.PATH,.SLCT,,"P"),CLEANUP^RGNETWWW
 S DATA=RGNETRSP
 Q
 ; GET method handler
MGET N X,ID,PATH,RGSER
 D GETFMT
 S PATH=RGNETREQ("PATH"),X=$L(PATH,"/")
 S:X#2 ID=$P(PATH,"/",X),PATH=$P(PATH,"/",1,X-1)
 K:$G(ID)="_search" ID
 D GET^RGSERGET(.RGSER,PATH,.ID,,"P"),ADDHDRX(.RGSER)
 Q
 ; POST method
MPOST D SETSTAT^RGNETWWW(405)
 Q
 ; PUT method
MPUT D SETSTAT^RGNETWWW(405)
 Q
 ; DELETE method
MDELETE D SETSTAT^RGNETWWW(405)
 Q
 ; Get expected response format
GETFMT I $D(RGNETREQ("PARAMS","_format")) D
 .S RGSER("FORMAT")=RGNETREQ("PARAMS","_format",1,1)
 .K RGNETREQ("PARAMS","_format")
 E  S RGSER("FORMAT")=$G(RGNETREQ("HDR","accept"))
 Q
 ; Returns the presence of specified flag(s).
 ; If ALL is true, presence of all flags are required.
 ; If false (the default), only one flag must be present.
HASFLAG(FLG,ALL) ;
 N X,T
 S ALL='$G(ALL),T=1
 F X=1:1:$L(FLG) S T=FLAGS[$E(FLG,X) Q:T=ALL
 Q T
 ; Escape reserved characters
ESCAPE(X) ;
 N Y,Z,C,R,L
 S R=$$ESCMAP^@RGSER("INTF"),L=$P(R,U),R=$P(R,U,2)
 F Z=1:1 S Y=$P($T(@L+Z^@R),";;",2) Q:'$L(Y)  D
 .S C=$P(Y,";")
 .S:$E(C)="#" C=$C(+$E(C,2,99))
 .S:X[C X=$$SUBST^RGUT(X,C,$P(Y,";",2,9999))
 Q X
 ; Serialize a date.
FMTDATE(DT) ;
 Q $$FMTDATE^@(RGSER("INTF"))(.DT)
 ; Concatenate array elements into a string
ARY2STR(ARY,DLM) ;
 N X,RES
 S RES="",DLM=$G(DLM)
 F X=0:0 S X=$O(ARY(X)) Q:'X  S RES=RES_$S($L(RES):DLM,1:"")_$G(ARY(X))_$G(ARY(X,0))
 Q RES
 ; Adds additional headers
ADDHDRX(RGSER) ;
 N LP,HDR
 I $G(RGSER("SER")) D
 .F LP=0:0 S LP=$O(^RGSER(998.1,RGSER("SER"),20,LP)) Q:'LP  S HDR=^(LP,0) D:$L(HDR) ADDHDR^RGNETWWW(HDR)
 Q
 ; Add array of values to output buffer.
 ; AR may be by reference or indirection
 ; FLG: B = encode as binary, L = add CRLF, W = is word processing root, R = don't escape
ADDARY(AR,FLG) ;
 N RT,B
 S RT=$S($D(AR)=1:AR,1:$NA(AR)),FLG=$G(FLG),B=FLG["B"
 D ADDTXT(RT,FLG):'B,ADDBIN(RT,FLG):B
 Q
ADDTXT(RT,FLG) ;
 N LP,L,W,R,X
 S L=$S(FLG["L":$C(13,10),1:""),W=FLG["W",R=FLG["R",LP=$S(W:0,1:"")
 F  S LP=$O(@RT@(LP)) Q:$S(W:'LP,1:'$L(LP))  D
 .S X=$S(W:@RT@(LP,0),1:@RT@(LP))_L
 .S:'R X=$$ESCAPE(X)
 .D ADD^RGNETWWW(X)
 Q
ADDBIN(RT,FLG) ;
 N X,Z,VL,LP,I,L,W
 S Z="=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
 S (VL,X)="",L=$S(FLG["L":$C(13,10),1:""),W=FLG["W",LP=$S(W:0,1:"")
 F  S LP=$O(@RT@(LP)) Q:'$L(LP)  D
 .S X=X_$S(W:@RT@(LP,0),1:@RT@(LP))_L
 .F  Q:$L(X)<3  D
 ..S VL=VL_$$B64ENC($E(X,1,3)),X=$E(X,4,9999)
 .I $L(VL)>131 D ADD^RGNETWWW(VL) S VL=""
 S:$L(X) VL=VL_$$B64ENC(X)
 D:$L(VL) ADD^RGNETWWW(VL)
 Q
 ; Encode input as Base 64
B64ENC(X) N Z1,Z2,Z3,Z4
 S Z3=0,Z1=""
 F Z4=1:1:3 S Z2=$A(X,Z4),Z3=Z3*256+$S(Z2<0:0,1:Z2)
 F Z4=1:1:4 S Z1=$E(Z,Z3#64+2)_Z1,Z3=Z3\64
 Q Z1
 ; Return table # given name
TABLE(T) Q $S(T=+T:T,1:+$O(^DIC("B",TABLE,0)))
 ; Format system attribute
SYSTEM(SYSTEM) ;
 N PATH
 S:'($D(SYSTEM)#10) SYSTEM="@"
 S PATH=$P(SYSTEM,"/",2,999),SYSTEM=$P(SYSTEM,"/")
 S:$E(SYSTEM)="#" SYSTEM="@"_$TR($P(^DIC($E(SYSTEM,2,9999),0),U)," /","__")
 S:$E(SYSTEM)="@" SYSTEM=$$LOCALSYS($E(SYSTEM,2,9999))
 Q SYSTEM_$S($L(PATH):"/"_PATH,1:"")
 ; Prepend local system root to path
LOCALSYS(PATH) ;
 Q $$CONCAT^RGNETWWW("http://"_$$LOW^XLFSTR($$KSP^XUPARAM("WHERE")),.PATH)
 ; Returns true if path matches specified pattern
ISMATCH(PATH,PTRN) ;
 Q $TR(PATH,"-_","XX")?@PTRN
