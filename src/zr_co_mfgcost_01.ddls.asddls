@EndUserText.label: '제조원가명세서 Data'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_CO_MFGCOST_01'
define custom entity ZR_CO_MFGCOST_01
with parameters 
    P_Ledger : char2,
    P_Companycode : char4,
    P_FiscalYearPeriod : char7,
    P_Plant : char4,
    P_Type : char1
{
    
    key Orderby : abap.numc(2);
        NodeID : abap.numc(2);
        HierarchyLevel : abap.char(10);
        ParentNodeID : abap.char(10);
        DrillState : abap.char(20);
        Description : abap.char(100);
        moveyn : abap.char(1);
        movegl : abap.string(1000);
        @Semantics.amount.currencyCode: 'fieldCur'
        total : abap.curr(23,2);
        
//        @Semantics.amount.currencyCode: 'fieldCur'
//        ts : abap.curr(23,2);
//        
//        @Semantics.amount.currencyCode: 'fieldCur'
//        cbn : abap.curr(23,2);
//        
//        @Semantics.amount.currencyCode: 'fieldCur'
//        th : abap.curr(23,2);
        
        // 월별 조회용으로 구분하기 쉽게 필드 새로 생성함.
        @Semantics.amount.currencyCode: 'fieldCur'
        jan : abap.curr(23,2);
        @Semantics.amount.currencyCode: 'fieldCur'
        feb : abap.curr(23,2);
        @Semantics.amount.currencyCode: 'fieldCur'
        mar : abap.curr(23,2);
        @Semantics.amount.currencyCode: 'fieldCur'
        apr : abap.curr(23,2);
        @Semantics.amount.currencyCode: 'fieldCur'
        may : abap.curr(23,2);
        @Semantics.amount.currencyCode: 'fieldCur'
        jun : abap.curr(23,2);
        @Semantics.amount.currencyCode: 'fieldCur'
        jul : abap.curr(23,2);
        @Semantics.amount.currencyCode: 'fieldCur'
        aug : abap.curr(23,2);
        @Semantics.amount.currencyCode: 'fieldCur'
        sep : abap.curr(23,2);
        @Semantics.amount.currencyCode: 'fieldCur'
        oct : abap.curr(23,2);
        @Semantics.amount.currencyCode: 'fieldCur'
        nov : abap.curr(23,2);
        @Semantics.amount.currencyCode: 'fieldCur'
        dece : abap.curr(23,2);
        
        fieldCur : abap.cuky( 5 );
        
        return_code : abap.char( 3 );
        return_msg : abap.string( 1000 );
}
