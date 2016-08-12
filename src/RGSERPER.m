RGSERPER ;RI/CBMI/DKM - User/Practitioner/Person Resource Support ;31-Mar-2015 18:40;DKM
 ;;1.0;SERIALIZATION FRAMEWORK;;07-Feb-2015 08:51
 ;=================================================================
 ; Iterator for traversing name xref
NAMEITER(CTX) ;
 I '$Q D NAMEITER^RGSERGET(CTX,$NA(^VA(200,"B"))) Q
 Q $$NAMEITER^RGSERGET(CTX)
