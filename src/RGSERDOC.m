RGSERDOC ;RI/CBMI/DKM - Document Resource Support ;31-Mar-2015 22:52;DKM
 ;;1.0;SERIALIZATION FRAMEWORK;;07-Feb-2015 08:51
 ;=================================================================
 ; Outputs a document in binary format
 ;  IEN = IEN of document
 ;  PRE = Prefix before binary content (optional)
 ;  PST = Postfix after binary content (optional)
TOBINARY(IEN,PRE,PST) ;
 N TXT,ERR
 D TGET^TIUSRVR1(.TXT,IEN)
 I $D(@TXT) D
 .D:$L($G(PRE)) ADD^RGNETWWW(PRE)
 .D ADDARY^RGSER(TXT,"BL")
 .D:$L($G(PST)) ADD^RGNETWWW(PST)
 .K @TXT
 E  D SETSTAT^RGNETWWW(404)
 Q
