@EndUserText.label: '제조원가명세서 Item'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_Item
  as select from zco_mfgcost_02
  association [1..1] to ZI_Header_S as _HeaderAll on $projection.SingletonID = _HeaderAll.SingletonID
  association to parent ZI_Header as _Header on $projection.Nodeid = _Header.Nodeid
{
  @UI.hidden: true
  key nodeid as Nodeid,
  @EndUserText.label: 'Idx'
  key itemid as Itemid,
  @EndUserText.label: '정렬 순서'
  orderby as Orderby,
  calctype as Calctype,
  sign as Sign,
  calcnode as Calcnode,
  glaccountfrom as Glaccountfrom,
  glaccountto as Glaccountto,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  @Consumption.hidden: true
  local_last_changed_at as LocalLastChangedAt,
  @Consumption.hidden: true
  1 as SingletonID,
  _HeaderAll,
  _Header
  
}
