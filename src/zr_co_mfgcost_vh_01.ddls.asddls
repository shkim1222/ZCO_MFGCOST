@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Node VH'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_CO_MFGCOST_VH_01 as select from ZI_Header
{
    @EndUserText.label: '대상 node'
    key Nodeid,
    @EndUserText.label: '내역'
    Description
}
where Useyn = 'Y'
