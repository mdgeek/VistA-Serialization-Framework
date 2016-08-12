RGSEOAUA ;RI/CBMI/DKM - OAuth2 Authorization Endpoint ;27-Mar-2015 11:57;DKM
 ;;1.0;SERIALIZATION FRAMEWORK;;14-March-2014;Build 1
 ;=================================================================
 ; Authorization end point
ENDPOINT(DATA,ARGS) ;
 S DATA("INTF")="RGSEJSON"
 D MSERVER^RGSER(.DATA,.ARGS,$T(+0))
 Q
 ; GET method
MGET N RT,GT,FLOW,CLIENT
 S RT=$G(PARAMS("response_type",1,1))
 S GT=$G(PARAMS("grant_type",1,1))
 S CLIENT=$G(PARAMS("client_id",1,1))
 I '$$GETCLNT^RGSEOAU(.CLIENT) D SETERR^RGSER(404) Q
 S FLOW=$S(RT="code":"W",RT="token":"U",GT="password":"P",GT="client_credentials":"C",1:"?")
 I FLOW'=CLIENT("flow") D SETERR^RGSER(403) Q
 D @("AUTH"_FLOW)
 Q
 ; Web server flow: authorization code grant
AUTHW N CODE,LOCATION,STATE
 Q:'$$VALIDRDU
 Q:'$$AUTH^RGSER(1)
 D SETERR^RGSER(302)
 S CODE=$$NEWAUTH(.CLIENT,DUZ)
 S STATE=$G(PARAMS("state",1,1))
 S LOCATION=CLIENT("redirect_uri")_"?code="_CODE
 S:$L(STATE) LOCATION=LOCATION_"&state="_STATE
 D ADDHDR^RGSER("Location: "_LOCATION)
 Q
 ; User-agent flow: implicit grant
AUTHU N ATKN
 Q:'$$VALIDRDU
 Q:'$$AUTH^RGSER(1)
 S ATKN=$$NEWATKN^RGSEOAUT(.CLIENT,DUZ,$G(PARAMS("scope",1,1)))
 D BLDRSP^RGSEOAUT(ATKN)
 Q
 ; Username and password flow
AUTHP D SETERR^RGSER(501)
 Q
 ; Client credentials flow: access token
AUTHC D SETERR^RGSER(501)
 Q
 ; Generate a new authorization code
NEWAUTH(CLIENT,USER) ;
 N AUTH
 S AUTH=$$UUID^RGSER,AUTH("user")=USER,AUTH("client")=CLIENT
 D SETOBJ^RGSEOAU(.AUTH,"AUTH")
 Q AUTH
 ; Fetches (and removes) an authorization from the data store
GETAUTH(AUTH) ;
 D GETOBJ^RGSEOAU(.AUTH,"AUTH",1)
 Q
 ; Validates the redirect uri
VALIDRDU() 
 I CLIENT("redirect_uri")'=$G(PARAMS("redirect_uri",1,1)) D SETERR^RGSER(404) Q 0
 Q 1
