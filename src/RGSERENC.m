RGSERENC ;RI/CBMI/DKM - Encounter Resource Support ;01-Apr-2015 16:50;DKM
 ;;1.0;SERIALIZATION FRAMEWORK;;07-Feb-2015 08:51
 ;=================================================================
 ; Get encounter types
GETTYPES I '$D(RGSER("RGSERENC.SVCCAT")) D
 .N SC,X
 .S (SLCT,RGSER("RGSERENC.SVCCAT"))=$$TMPGBL^RGNETWWW,TP=1
 .D GETLST^XPAR(.SC,"ALL","RGCWENCX VISIT TYPES","I")
 .M @SLCT=SC
 Q
 ; Retrieve an encounter type
RETRIEVE(IEN) ;
 D RETRIEVE^RGSERGET(RGSER("RGSERENC.SVCCAT"),IEN,"~")
 Q
 ; Retrieve the encounter status
GETSTAT(IEN) ;
 N STATUS
 I $L($T(ISLOCKED^BEHOENCX)) D
 .S STATUS=$S($$ISLOCKED^BEHOENCX(IEN):"finished",1:"in progress")
 E  D
 .S STATUS=$S($$VISREFDT(IEN)\1'=$$DT^XLFDT:"finished",1:"in progress")
 Q STATUS
 ; Returns reference date for visit lock check
VISREFDT(IEN) ;
 N ADM,DIS,DAT
 S DAT=$P($G(^AUPNVSIT(+IEN,0)),U,2)
 Q:'DAT ""
 S ADM=$O(^DGPM("AVISIT",IEN,0))
 Q:'ADM DAT
 S DIS=$P($G(^DGPM(ADM,0)),U,17)
 Q $S(DIS:$P($G(^DGPM(DIS,0)),U),1:DT)
