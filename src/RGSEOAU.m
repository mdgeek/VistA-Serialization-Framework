RGSEOAU ;RI/CBMI/DKM - OAuth2 Support ;27-Mar-2015 11:21;DKM
 ;;1.0;SERIALIZATION FRAMEWORK;;14-March-2014;Build 1
 ;=================================================================
 ; Register a client application
 ; Returns client id^client secret
REGAPP(APPNAME,REDIRECT) ;
 N IENS,FDA,ID,SECRET
 S IENS=$O(^RGSER(998.3,"B",APPNAME,0))
 S IENS=$S(IENS:IENS_",",1:"+1,")
 S ID=$$UUID^RGSER,SECRET=$$UUID^RGSER
 S FDA=$NA(FDA(998.3,IENS))
 S @FDA@(.01)=APPNAME
 S @FDA@(1)=ID
 S @FDA@(2)=SECRET
 S @FDA@(3)=3600
 S @FDA@(10)=REDIRECT
 D UPDATE^DIE("E","FDA")
 Q:$Q ID_U_SECRET
 Q
 ; Lookup client by id
 ; Returns true if successful
GETCLNT(CLIENT) ;
 Q:'$D(CLIENT) 0
 Q:$D(CLIENT)=11 1
 N IEN,N0,RU
 S IEN=$S('$L(CLIENT):0,1:$O(^RGSER(998.3,"C",CLIENT,0)))
 Q:'IEN 0
 S N0=$G(^RGSER(998.3,IEN,0)),RU=$G(^(10))
 S CLIENT=$P(N0,U,2),CLIENT("redirect_uri")=RU,CLIENT("name")=$P(N0,U)
 S CLIENT("secret")=$P(N0,U,3),CLIENT("lifespan")=$P(N0,U,4),CLIENT("flow")=$P(N0,U,5)
 S:'CLIENT("lifespan") CLIENT("lifespan")=3600
 Q 1
 ; Get root of OAUTH data store
STORE(NODE) ;
 N X
 S X=$NA(^XTMP("RGSER_OAUTH"))
 Q $S($D(NODE):$NA(@X@(NODE)),1:X)
 ; Fetches an object of the given type from the data store
GETOBJ(OBJ,TYPE,REMOVE) ;
 Q:'$L($G(OBJ))
 N STORE
 S STORE=$$STORE(TYPE)
 M OBJ=@STORE@(OBJ)
 K:$G(REMOVE) @STORE@(OBJ)
 Q
 ; Writes an object of the given type to the data store
SETOBJ(OBJ,TYPE) ;
 N STORE
 S STORE=$$STORE(TYPE)
 K @STORE@(OBJ)
 M @STORE@(OBJ)=OBJ
 Q
 ; Removes an object of the given type from the data store
DELOBJ(OBJ,TYPE) ;
 K:$L($G(OBJ)) @$$STORE(TYPE)@(OBJ)
 Q
