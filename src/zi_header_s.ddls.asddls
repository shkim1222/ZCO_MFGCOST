@EndUserText.label: '제조원가명세서 Header Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'HeaderAll'
  }
}
define root view entity ZI_Header_S
  as select from I_Language
    left outer join ZCO_MFGCOST_01 on 0 = 0
  association [0..*] to I_ABAPTransportRequestText as _ABAPTransportRequestText on $projection.TransportRequestID = _ABAPTransportRequestText.TransportRequestID
  composition [0..*] of ZI_Header as _Header
{
  @UI.facet: [ {
    id: 'ZI_Header', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: '제조원가명세서 Header', 
    position: 1 , 
    targetElement: '_Header'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _Header,
  @UI.hidden: true
  max( ZCO_MFGCOST_01.LAST_CHANGED_AT ) as LastChangedAtMax,
  @ObjectModel.text.association: '_ABAPTransportRequestText'
  @UI.identification: [ {
    position: 2 , 
    type: #WITH_INTENT_BASED_NAVIGATION, 
    semanticObjectAction: 'manage'
  } ]
  @Consumption.semanticObject: 'CustomizingTransport'
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  _ABAPTransportRequestText
  
}
where I_Language.Language = $session.system_language
