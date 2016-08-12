RGSEFHIR ;RI/CBMI/DKM - Generic FHIR Support ;08-Aug-2016 08:42;DKM
 ;;1.0;SERIALIZATION FRAMEWORK;;07-Feb-2015 08:51
 ;=================================================================
 ; Generates an operation outcome resource
 ;  ID    = Dialog offset (base = 9981000)
 ;  TMPLn = Optional parameters for template
OPEROUT(ID,TMPL1,TMPL2,TMPL3,TMPL4,TMPL5) ;
 N STATUS,ERROR,N0
 S ID=ID+9981000,N0=$G(^DI(.84,ID,0)),STATUS=+$P(N0,U,5),ERROR=$P(N0,U,2)=1
 I '$L(N0) S STATUS="500:Missing dialog #"_ID,ERROR=1
 E  I '$G(RGSER("OPEROUT")) D
 .S RGSER("OPEROUT")=ERROR
 .D:ERROR RESET^RGNETWWW
 .D GET^RGSERGET(.RGSER,"*/OperationOutcome",ID)
 D:ERROR SETSTAT^RGNETWWW($P(STATUS,":"),$P(STATUS,":",2,999),0)
 Q
 ; Process any attribute properties
 ; An attribute property begins with "attr:" and is used to generate
 ; additional attributes on an embedded resource.
 ;  .PROP = Property array
 ;  .ATR  = Attribute array to receive attributes
PROP2ATR(PROP,ATR) ;
 N NM,LP,X,Y
 S NM="attr:"
 F  S NM=$O(PROP("B",NM)) Q:$P(NM,":")'="attr"  D
 .F LP=0:0 S LP=$O(PROP("B",NM,LP)) Q:'LP  D
 ..S X=PROP(LP,0),Y=$G(PROP(LP,10))
 ..Q:$P(X,U,3)'="N"!'$L(Y)
 ..S X=$P(X,U),ATR(99,$P(X,":",2))=Y
 Q
 ; Reformats a variable pointer for use as a resource id.
 ; Returned id is formatted as <file #>-<ien>.
 ;  VP = Variable pointer value
VP2ID(VP) ;
 Q:'$L(VP) ""
 N X
 S X=$P(VP,";",2)
 S:X'["(" X=X_"("
 S X=+$P($G(@(U_X_"0)")),U,2)
 Q $S(X:X_"-"_+VP,1:"")
 ; Value set iterator
ITERVS(CTX) ;
 I '$Q D ITER(CTX,"ValueSet_") Q
 Q $$ITER(CTX)
 ; Serialization file iterator
ITER(CTX,ROOT) ;
 N TMP,LAST,IEN,SER
 S TMP=$$TMPGBL^RGNETWWW(CTX)
 I '$Q D  Q
 .S @TMP@("IEN")=0,^("SER")=RGSER("SER"),(^("LAST"),^("ROOT"))=ROOT
 S LAST=@TMP@("LAST"),IEN=^("IEN"),SER=^("SER"),ROOT=^("ROOT")
 F  D  Q:IEN
 .I 'IEN D  Q:IEN
 ..S LAST=$O(^RGSER(998.1,SER,10,"B",LAST))
 ..I $E(LAST,1,$L(ROOT))=ROOT S @TMP@("LAST")=LAST
 ..E  S IEN=-1
 .S IEN=+$O(^RGSER(998.1,SER,10,"B",LAST,IEN)),@TMP@("IEN")=IEN
 Q $S(IEN=-1:0,1:IEN)
 ; List resources for conformance document.
 ; Referenced within metadata.CONFORMANCE template to dynamically
 ; generate supported resources.
RESCONF() ;
 N RESNAME,RESIEN,RESNUM
 S RESNAME="",RESNUM=0
 F  S RESNAME=$O(^RGSER(998.1,RGSER("SER"),10,"B",RESNAME)) Q:'$L(RESNAME)  S RESIEN=$O(^(RESNAME,0)) D
 .Q:RESNAME="metadata"!(RESNAME["/")
 .Q:$P(^RGSER(998.1,RGSER("SER"),10,RESIEN,0),U,2)
 .D TEMPLATE^RGSERGET("CONFORMANCE_RESOURCE")
 .S RESNUM=RESNUM+1
 Q:$Q ""
 Q
 ; List search parameter conformance for a resource.
 ; Referenced within metadata.CONFORMANCE_RESOURCE template.
SRPCONF() ;
 N SRPNAME,SRPIEN,SRPTYPE,SRPNUM
 S SRPNAME="",SRPNUM=0
 F  S SRPNAME=$O(^RGSER(998.1,RGSER("SER"),10,RESIEN,40,"B",SRPNAME)) Q:'$L(SRPNAME)  S SRPIEN=$O(^(SRPNAME,0)) D
 .Q:$E(SRPNAME)="@"
 .S SRPTYPE=$P(^RGSER(998.1,RGSER("SER"),10,RESIEN,40,SRPIEN,0),U,3)
 .S SRPTYPE=$$LOW^XLFSTR($$EXTERNAL^DILFD(998.13,2,,SRPTYPE))
 .I $L(SRPTYPE) D
 ..D TEMPLATE^RGSERGET("CONFORMANCE_PARAMETER")
 ..S SRPNUM=SRPNUM+1
 Q:$Q ""
 Q
 ; Parses an identifier type.  Format is:
 ;   <code>,<display>,<system>
 ;   .TYPE = Identifier type to parse.
 ; Returned as TYPE(0) = code, TYPE(1) = display, TYPE(2) = system
PARSIDTP(TYPE) ;
 S TYPE(0)=$P(TYPE,","),TYPE(1)=$P(TYPE,",",2),TYPE(2)=$P(TYPE,",",3)
 S:'$L(TYPE(1)) TYPE(1)=TYPE(0)
 S:'$L(TYPE(2)) TYPE(2)="http://va.gov/identifier"
 S TYPE(2)=$$SYSTEM^RGSER(TYPE(2))
 Q
