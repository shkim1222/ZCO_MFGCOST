@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'I_JournalEntryItem - GET'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZR_CO_MFGCOST_JE as select from I_JournalEntryItem
{
    key SourceLedger,
    key CompanyCode,
    key Ledger,
    FiscalYearPeriod,
    GLAccount,    
    @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
    AmountInCompanyCodeCurrency,
    CompanyCodeCurrency,
    ProfitCenter, 
    Product
}
