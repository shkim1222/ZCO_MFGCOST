CLASS zcl_co_mfgcost_01 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .

    DATA: pt_response TYPE TABLE OF ZR_CO_MFGCOST_01,
          ps_response LIKE LINE OF pt_response.

    TYPES : BEGIN OF ty_node,
                nodeid  TYPE string,
                sign    TYPE string,
            END OF ty_node.

    TYPES : BEGIN OF ty_param,
                lv_company      TYPE string,
                lv_periodType   TYPE string,
                lv_period       TYPE string,
                lv_join         TYPE c LENGTH 1,
                lv_glfrom       TYPE string,
                lv_glto         TYPE string,
                lv_glaccount    TYPE string,
                lv_plant        TYPE string,
                lv_ledger       TYPE string,
                lv_movegl       TYPE string,
            END OF ty_param.

    TYPES : BEGIN OF ty_return,
                glaccount   TYPE string,
                movegl      TYPE string,
            END of ty_return.

    DATA : lv_fiscalAll TYPE c LENGTH 7 VALUE '1998012',
           lv_fiscalbef TYPE c LENGTH 7,
           lv_fiscal    TYPE c LENGTH 7,
           lt_node      TYPE TABLE OF ty_node,
           ls_node      LIKE LINE OF lt_node.

  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS calc_gl         IMPORTING lv_param  TYPE ty_param.
    METHODS calc_node       IMPORTING lv_node   LIKE lt_node.
    METHODS create_gl       IMPORTING lv_param  TYPE ty_param RETURNING VALUE(ty_return)    TYPE ty_return.
    METHODS create_period   IMPORTING lv_param  TYPE ty_param RETURNING VALUE(period)       TYPE string.
ENDCLASS.

CLASS zcl_co_mfgcost_01 IMPLEMENTATION.

  METHOD create_gl.

        DATA : lv_glfrom    TYPE c LENGTH 10,
               lv_glto      TYPE c LENGTH 10,
               lv_movegl    TYPE string.

        lv_glfrom = |{ lv_param-lv_glfrom ALPHA = IN }|.
        lv_glto   = |{ lv_param-lv_glto   ALPHA = IN }|.

        IF lv_glfrom IS NOT INITIAL and lv_glto IS NOT INITIAL.
            ty_return-glaccount = |( GLAccount between '{ lv_glfrom }' and '{ lv_glto }' )|.
            ty_return-movegl = lv_glfrom && '&' && lv_glto.
        ELSE.
            ty_return-glaccount = |( GLAccount = '{ lv_glfrom }' )|.
            ty_return-movegl = lv_glfrom.
        ENDIF.

    ENDMETHOD.

    METHOD create_period.
        "1:오픈~전월, 2:오픈~당월, 3:당월
        CASE lv_param-lv_periodType.
            WHEN '1'.
                period = |FiscalYearPeriod between '{ lv_fiscalAll }' and '{ lv_fiscalbef }'|.
            WHEN '2'.
                period = |FiscalYearPeriod between '{ lv_fiscalAll }' and '{ lv_fiscal }'|.
            WHEN '3'.
                period = |FiscalYearPeriod between '{ lv_fiscalAll }' and '{ lv_fiscal }'|.
                "period = |FiscalYearPeriod = '{ lv_fiscal }'|.
        ENDCASE.
     ENDMETHOD.

    METHOD calc_gl.

        DATA(lv_sql_glaccount) = lv_param-lv_glaccount.
        DATA(lv_sql_fiscal) = lv_param-lv_period.

        "Join 해서 처리하는 쿼리
        IF lv_param-lv_join EQ 'Y'.
            TRY.
                SELECT A~FiscalYearPeriod,  SUM( AmountInCompanyCodeCurrency ) AS AmountInGlobalCurrency
                "SUM( AmountInGlobalCurrency ) AS AmountInGlobalCurrency
                  FROM ZR_CO_MFGCOST_JE as A
                 INNER JOIN ZR_CO_MFGCOST_PL as B
                         ON A~product = B~Product
                        AND b~Plant = @lv_param-lv_plant
                 WHERE SourceLedger = @lv_param-lv_ledger
                   AND Ledger = @lv_param-lv_ledger
                   AND Companycode = @lv_param-lv_company
                   AND (lv_sql_glaccount)
                   AND (lv_sql_fiscal)
                 GROUP BY A~FiscalYearPeriod
                 ORDER BY A~FiscalYearPeriod
                 INTO TABLE @DATA(lt_amount).
             CATCH CX_SY_DYNAMIC_OSQL_SYNTAX INTO DATA(lv_error).
                DATA(lv_errormsg) = lv_error->get_longtext( ).
            ENDTRY.
        ELSE.
            TRY.
                SELECT FiscalYearPeriod, SUM( AmountInCompanyCodeCurrency ) AS AmountInGlobalCurrency
                "SUM( AmountInGlobalCurrency ) AS AmountInGlobalCurrency
                  FROM ZR_CO_MFGCOST_JE
                 WHERE SourceLedger = @lv_param-lv_ledger
                   AND Ledger = @lv_param-lv_ledger
                   AND Companycode = @lv_param-lv_company
                   AND (lv_sql_glaccount)
                   AND (lv_sql_fiscal)
                 GROUP BY FiscalYearPeriod
                 ORDER BY FiscalYearPeriod
                 INTO TABLE @lt_amount.
             CATCH CX_SY_DYNAMIC_OSQL_SYNTAX INTO lv_error.
                lv_errormsg = lv_error->get_longtext( ).
            ENDTRY.
        ENDIF.

        "데이터 구하고 나서, LOOP로 각 변수에 값 넣어야함.
        DATA : lv_befTotal TYPE ZR_CO_MFGCOST_01-total.
        lv_befTotal = 0.

        LOOP AT lt_amount INTO DATA(ls_amount).
            DATA(lv_month) = ls_amount-FiscalYearPeriod+4(3).

            "8월 기말 -> 9월 기초이므로 FiscalYearPeriod가 8월인 데이터를 9월필드에 보여줘야함
            IF lv_param-lv_periodType EQ '1'.
                lv_month = lv_month + 1.
            ENDIF.

            "조회년도에 해당하는 데이터만 자신의 월로 추가. 조회년도에 해당하지 않는 년도+월은 더해서 001에 게산해줘야함.
            IF ls_amount-FiscalYearPeriod+0(4) EQ lv_fiscal+0(4).
                CASE lv_month.
                    WHEN '001'. ps_response-jan  = ls_amount-amountinglobalcurrency.
                    WHEN '002'. ps_response-feb  = ls_amount-amountinglobalcurrency.
                    WHEN '003'. ps_response-mar  = ls_amount-amountinglobalcurrency.
                    WHEN '004'. ps_response-apr  = ls_amount-amountinglobalcurrency.
                    WHEN '005'. ps_response-may  = ls_amount-amountinglobalcurrency.
                    WHEN '006'. ps_response-jun  = ls_amount-amountinglobalcurrency.
                    WHEN '007'. ps_response-jul  = ls_amount-amountinglobalcurrency.
                    WHEN '008'. ps_response-aug  = ls_amount-amountinglobalcurrency.
                    WHEN '009'. ps_response-sep  = ls_amount-amountinglobalcurrency.
                    WHEN '010'. ps_response-oct  = ls_amount-amountinglobalcurrency.
                    WHEN '011'. ps_response-nov  = ls_amount-amountinglobalcurrency.
                    WHEN '012'. ps_response-dece = ls_amount-amountinglobalcurrency.
                ENDCASE.
            ELSE.
                lv_befTotal += ls_amount-amountinglobalcurrency.
            ENDIF.
        ENDLOOP.

        "ex) 기말, 기초 데이터는 보여지는 월까지의 누적이어야함. 8월 데이터는 0~8월까지의 누적, 9월은 0~9까지의 누적
        IF lv_param-lv_periodType EQ '1' OR lv_param-lv_periodType EQ '2'.
            DATA(lv_selFiscal) = lv_fiscal+4(3).
            DATA(lv_calFiscal) = 000.

            WHILE lv_calFiscal <= lv_selfiscal.
                CASE lv_calFiscal.
                    WHEN '001'. ps_response-jan  += lv_befTotal.
                    WHEN '002'. ps_response-feb  += ps_response-jan.
                    WHEN '003'. ps_response-mar  += ps_response-feb.
                    WHEN '004'. ps_response-apr  += ps_response-mar.
                    WHEN '005'. ps_response-may  += ps_response-apr.
                    WHEN '006'. ps_response-jun  += ps_response-may.
                    WHEN '007'. ps_response-jul  += ps_response-jun.
                    WHEN '008'. ps_response-aug  += ps_response-jul.
                    WHEN '009'. ps_response-sep  += ps_response-aug.
                    WHEN '010'. ps_response-oct  += ps_response-sep.
                    WHEN '011'. ps_response-nov  += ps_response-oct.
                    WHEN '012'. ps_response-dece += ps_response-nov.
                ENDCASE.
                lv_calFiscal += 1.
            ENDWHILE.
        ENDIF.

        ps_response-total = ps_response-jan + ps_response-feb + ps_response-mar + ps_response-apr + ps_response-may + ps_response-jun
                          + ps_response-jul + ps_response-aug + ps_response-sep + ps_response-oct + ps_response-nov + ps_response-dece.
    ENDMETHOD.

    METHOD calc_node.
        LOOP AT lt_node INTO ls_node.
            "구하고자 하는 대상이 되는 Node
            READ TABLE pt_response INTO DATA(ls_response) WITH KEY NodeID = ls_node-nodeid.
            IF sy-subrc NE 0. CONTINUE. ENDIF.

            "외주 가공비의 케이스 적용 = 상위node에서 이동하고 하위노드에서는 이동 안함.
            IF ps_response-moveyn EQ 'Y'.
                IF ps_response-movegl IS NOT INITIAL.
                    ps_response-movegl = ps_response-movegl && ',' && ls_response-movegl.
                ELSE.
                    ps_response-movegl = ls_response-movegl.
                ENDIF.
            ENDIF.

            CASE ls_node-sign.
                WHEN '1'.
                    ps_response-jan  += ls_response-jan.
                    ps_response-feb  += ls_response-feb.
                    ps_response-mar  += ls_response-mar.
                    ps_response-apr  += ls_response-apr.
                    ps_response-may  += ls_response-may.
                    ps_response-jun  += ls_response-jun.
                    ps_response-jul  += ls_response-jul.
                    ps_response-aug  += ls_response-aug.
                    ps_response-sep  += ls_response-sep.
                    ps_response-oct  += ls_response-oct.
                    ps_response-nov  += ls_response-nov.
                    ps_response-dece += ls_response-dece.
                WHEN '2'.
                    ps_response-jan  -= ls_response-jan.
                    ps_response-feb  -= ls_response-feb.
                    ps_response-mar  -= ls_response-mar.
                    ps_response-apr  -= ls_response-apr.
                    ps_response-may  -= ls_response-may.
                    ps_response-jun  -= ls_response-jun.
                    ps_response-jul  -= ls_response-jul.
                    ps_response-aug  -= ls_response-aug.
                    ps_response-sep  -= ls_response-sep.
                    ps_response-oct  -= ls_response-oct.
                    ps_response-nov  -= ls_response-nov.
                    ps_response-dece -= ls_response-dece.
            ENDCASE.
          ENDLOOP.
          ps_response-total = ps_response-jan + ps_response-feb + ps_response-mar + ps_response-apr + ps_response-may + ps_response-jun
                            + ps_response-jul + ps_response-aug + ps_response-sep + ps_response-oct + ps_response-nov + ps_response-dece.

    ENDMETHOD.

    METHOD if_rap_query_provider~select.

        IF io_request->is_data_requested( ).

            DATA(lt_parameters) = io_request->get_parameters( ).
            DATA : lv_param TYPE ty_param.

            lv_param-lv_ledger  = lt_parameters[ parameter_name = 'P_LEDGER' ]-value.
            lv_param-lv_company = lt_parameters[ parameter_name = 'P_COMPANYCODE' ]-value.
            lv_param-lv_plant   = lt_parameters[ parameter_name = 'P_PLANT' ]-value.

            "날짜
            lv_fiscal = lt_parameters[ parameter_name = 'P_FISCALYEARPERIOD' ]-value.

            DATA : lv_year  TYPE i,
                   lv_month TYPE i,
                   lv_month2 TYPE c LENGTH 3.

            lv_year = lv_fiscal+0(4).
            lv_month = lv_fiscal+4(3).

            " 전월 계산
            IF lv_month = 1.
              lv_month = 12.
              lv_year = lv_year - 1.
            ELSE.
              lv_month = lv_month - 1.
            ENDIF.

            lv_month2 = lv_month.
            lv_month2 = |{ lv_month2 ALPHA = IN }|.
            lv_fiscalBef = |{ lv_year }{ lv_month2 }|.

            DATA(lv_top) = io_request->get_paging( )->get_page_size( ).
            IF lv_top < 0.
              lv_top = 1.
            ENDIF.

            DATA(lv_skip) = io_request->get_paging( )->get_offset( ).

            "사용중인 Header 구조만 가져오기
            SELECT *
              FROM zco_mfgcost_01
             WHERE useyn = 'Y'
            ORDER BY hierarchylevel DESCENDING, orderby ASCENDING
             INTO TABLE @DATA(lt_header).

            SELECT *
              FROM zco_mfgcost_02
             ORDER BY orderby
              INTO TABLE @DATA(lt_item).

            SELECT SINGLE Currency
              FROM I_CompanyCodeVH
             WHERE companycode = @lv_param-lv_company
              INTO @DATA(lv_currency).

            "gl계산
            LOOP AT lt_header INTO DATA(ls_header).
                ps_response = CORRESPONDING #( ls_header ).
                ps_response-fieldCur = lv_currency.

                lv_param-lv_join = ls_header-joinyn.
                lv_param-lv_periodtype = ls_header-periodtype.
                lv_param-lv_period = create_period( lv_param ).

                "gl기준으로 데이터 가져오는 것 만 처리.
                LOOP AT lt_item INTO DATA(ls_item) WHERE nodeid = ls_header-nodeid and calctype = '1'.
                    lv_param-lv_glfrom = ls_item-glaccountfrom.
                    lv_param-lv_glto = ls_item-glaccountto.

                    DATA(lv_return) = create_gl( lv_param ).

                    IF lv_param-lv_glaccount IS NOT INITIAL.
                        lv_param-lv_glaccount = lv_param-lv_glaccount && ' OR ' && lv_return-glaccount.
                    ELSE.
                        lv_param-lv_glaccount = lv_return-glaccount.
                    ENDIF.

                    IF lv_param-lv_movegl IS NOT INITIAL.
                        lv_param-lv_movegl = lv_param-lv_movegl && ',' && lv_return-movegl.
                    ELSE.
                        lv_param-lv_movegl = lv_return-movegl.
                    ENDIF.
                ENDLOOP.

                IF lv_param-lv_glaccount IS NOT INITIAL.
                    calc_gl( lv_param ).
                ENDIF.

                ps_response-movegl = lv_param-lv_movegl.

                APPEND ps_response TO pt_response.
                CLEAR : ps_response.
                lv_param-lv_join = ''.
                lv_param-lv_periodtype = ''.
                lv_param-lv_period = ''.
                lv_param-lv_glfrom = ''.
                lv_param-lv_glto = ''.
                lv_param-lv_glaccount = ''.
                lv_param-lv_movegl = ''.
            ENDLOOP.

            "노드 계산
            LOOP AT lt_header INTO ls_header.

                "node 기준으로 처리.
                LOOP AT lt_item INTO ls_item WHERE nodeid = ls_header-nodeid and calctype = '2'.
                    ls_node-nodeid = ls_item-calcnode.
                    ls_node-sign = ls_item-sign.
                    APPEND ls_node TO lt_node.
                    CLEAR : ls_node.
                ENDLOOP.
                IF lt_node[] IS NOT INITIAL.
                    READ TABLE pt_response INTO ps_response WITH KEY NodeID = ls_header-nodeid.
                    calc_node( lt_node ).
                    MODIFY pt_response FROM ps_response TRANSPORTING jan feb mar apr may jun jul aug sep oct nov dece total movegl where NodeID = ls_header-nodeid.
                ENDIF.
                CLEAR : ps_response, lt_node.
            ENDLOOP.

            SORT pt_response BY Orderby.
            io_response->set_total_number_of_records( lines( pt_response ) ).
            io_response->set_data( pt_response ).
        ENDIF.

    ENDMETHOD.
ENDCLASS.
