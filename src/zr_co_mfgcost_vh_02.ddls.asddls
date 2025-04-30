@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Ledger VH'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZR_CO_MFGCOST_VH_02 as select from I_Ledger
association [1..1] to I_LedgerText on I_LedgerText.Ledger = I_Ledger.Ledger 
                                  and I_LedgerText.Language = '3'
{
    key Ledger,
    IsLeadingLedger,
    I_LedgerText.LedgerName
}
