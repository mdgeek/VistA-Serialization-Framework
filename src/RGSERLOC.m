RGSERLOC ;RI/CBMI/DKM - Location Resource Support ;04-Aug-2016 23:16;DKM
 ;;1.0;SERIALIZATION FRAMEWORK;;07-Feb-2015 08:51
 ;=================================================================
 ; Return location type
GETTYPE(TYPE,SERVICE) ;
 N TP
 S TP=""
 I TYPE="C" D  Q TP
 .S TP=$$SET^RGUT(SERVICE,"P:PSY;S:SU;M:GIM;R:RH;N:NEUR")
 .S:'$L(TP) TP="OF"
 Q:TYPE="I" "HRAD"
 Q:TYPE="W" "HOSP"
 Q ""
 ; Return location status
GETSTAT(INACT,REACT) ;
 N AC,IN
 S AC="active",IN="inactive"
 Q:'INACT AC
 Q:INACT>DT AC
 Q:'REACT IN
 Q:REACT>INACT AC
 Q IN
