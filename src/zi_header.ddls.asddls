@EndUserText.label: '제조원가명세서 Header'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_Header
  as select from zco_mfgcost_01
  association to parent ZI_Header_S as _HeaderAll on $projection.SingletonID = _HeaderAll.SingletonID
  composition [0..*] of ZI_Item as _Item
{
  @EndUserText.label: 'Idx'
  key nodeid as Nodeid,
  @EndUserText.label: '정렬 순서'
  orderby as Orderby,
  hierarchylevel as Hierarchylevel,
  @EndUserText.label: '부모 Node'
  parentnodeid as Parentnodeid,
  drillstate as Drillstate,
  description as Description,
  @EndUserText.label: '사용여부'
  useyn as Useyn,
  @EndUserText.label: '조인여부'
  joinyn as Joinyn,
  @EndUserText.label: '이동여부'
  moveyn as Moveyn,
  @EndUserText.label: '계산기간'
  periodtype as Periodtype,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  @Consumption.hidden: true
  local_last_changed_at as LocalLastChangedAt,
  @Consumption.hidden: true
  1 as SingletonID,
  _HeaderAll,
  _Item
  
}
