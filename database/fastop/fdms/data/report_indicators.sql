DECLARE
   TYPE t_array IS VARRAY(200) OF VARCHAR2(64);

   PROCEDURE setAmecoReportIndicators
   IS
      l_array t_array
                 := t_array('OCPH'
                          , 'OCTG'
                          , 'OIGT'
                          , 'OIGCO'
                          , 'OIGEQ'
                          , 'OIGOT'
                          , 'OIST'
                          , 'OXGN'
                          , 'OXSN'
                          , 'OMGN' -- 10
                          , 'OMSN'
                          , 'OVGD'
                          , 'UOOMDR'
                          , 'UOOMDE'
                          , 'Quarterly'
                          , 'Quarterly'
                          , 'Quarterly'
                          , 'Quarterly'
                          , 'Quarterly'
                          , 'Quarterly' -- 20
                          , 'Quarterly'
                          , 'Quarterly'
                          , 'Quarterly'
                          , 'Quarterly'
                          , 'Quarterly'
                          , 'UDMDCE'
                          , 'UDMDCR'
                          , 'OIGG'
                          , 'UDMDKE'
                          , 'UDMDKTR' -- 30
                          , 'OIGDW'
                          , 'UOOMSCE'
                          , 'UIGDW'
                          , 'UOOMSIE'
                          , 'UOOMSKE'
                          , 'UCPH'
                          , 'UCTG'
                          , 'UIGT'
                          , 'UIGCO'
                          , 'UIGEQ' -- 40
                          , 'UIGOT'
                          , 'UIST'
                          , 'UXGN'
                          , 'UXSN'
                          , 'UMGN'
                          , 'UMSN'
                          , 'UVGD'
                          , 'UOOMDCE'
                          , 'UOOMDIE'
                          , 'UTVTBP' -- 50
                          , 'UYVTBP'
                          , 'UOOMDKE'
                          , 'For future use'
                          , 'ZCPIH'
                          , 'ZCPIN'
                          , 'ZHPI'
                          , 'UVGE'
                          , 'OVGE'
                          , 'NETD'
                          , 'FETD' -- 60
                          , 'UWCD'
                          , 'UWWD'
                          , 'NWTD'
                          , 'FWTD'
                          , 'UUCGR' -- new rrf
                          , 'UIGG0R' -- new rrf
                          , 'UKTGR' -- new rrf
                          , 'UTGCR' -- new rrf
                          , 'UROGR' -- new rrf
                          , 'UTAFGGR' -- 70 -- new rrf
                          , 'UTAF2GR' -- new rrf
                          , 'UYTGEU' -- new rrf
                          , 'URCGR'
                          , 'UKTTR'
                          , 'NPTD'
                          , 'NPAN'
                          , 'NPAN1'
                          , 'NUTN'
                          , 'NETN'
                          , 'ZUTN' -- 80
                          , 'NETD8'
                          , 'NUTN8'
                          , 'NLFS'
                          , 'NPAN18'
                          , 'NLHA'
                          , 'NELN'
                          , 'UWCH'
                          , 'UWSH'
                          , 'UOGH'
                          , 'UYNH' -- 90
                          , 'UCTRH'
                          , 'UTYH'
                          , 'UCTPH'
                          , 'UEHH'
                          , 'UCPH0'
                          , 'UITH'
                          , 'UKOH'
                          , 'UTLDIHN'
                          , 'UTLDINF'
                          , 'UGVAC' -- 100
                          , 'UYVC'
                          , 'UTVC'
                          , 'UWCC'
                          , 'UOGC'
                          , 'UYNC'
                          , 'UCTRC'
                          , 'UTYC'
                          , 'UEHC'
                          , 'UITC'
                          , 'UKOC' -- 110
                          , 'UCTREU'
                          , 'UKTGEU'
                          , 'UTVG'
                          , 'UTYG'
                          , 'UTSG'
                          , 'UTAG'
                          , 'UROG'
                          , 'UCCG0'
                          , 'UCIG0'
                          , 'UWCG' -- 120
                          , 'UYTGH'
                          , 'UYIG'
                          , 'UYVG'
                          , 'UUOG'
                          , 'UKTTG'
                          , 'UIGG0'
                          , 'UKOG'
                          , 'UDGG'
                          , 'UUTG'
                          , 'UTKG' -- 130
                          , 'UTEU'
                          , 'UYIGE'
                          , 'UYEU'
                          , 'UCTRG'
                          , 'NPLN9'
                          , 'UVGDH'
                          , 'UBLGE'
                          , 'UOOMSR'
                          , 'UOOMSE'
                          , 'UBRA' -- 140
                          , 'UBTA'
                          , 'UBKA'
                          , 'UPOMN'
                          , 'UKCG0'
                          , 'UCTGI'
                          , 'UYTGM'
                          , 'DXGI'
                          , 'UKTG995'
                          , 'DXGE'
                          , 'DMGI' -- 150
                          , 'UBCABOP'
                          , 'DMGE'
                          , 'UDMGCE'
                          , 'UDMGCR'
                          , 'UDMGKE'
                          , 'UDMGKTR'
                          , 'UBIKBOP'
                          , 'TRIT'
                          , 'TRDT'
                          , 'TRSC' -- 160
                          , 'WCPINEG'
                          , 'WCPIENG'
                          , 'WCPIFOO'
                          , 'WCPIUNF'
                          , 'WCPISER'
                          , 'Quarterly'
                          , 'Quarterly'
                          , 'Quarterly'
                          , 'Quarterly'
                          , 'Quarterly' -- 170
                          , 'Quarterly'
                          , 'ZCPINEG'
                          , 'ZCPIENG'
                          , 'ZCPIFOO'
                          , 'ZCPIUNF'
                          , 'ZCPISER'
                          , 'ZCPIXEF');
   BEGIN
      FOR i IN 1 .. l_array.LAST LOOP
        INSERT INTO FDMS_REPORT_INDICATORS (INDICATOR_CODE_SID, REPORT_SID, ORDER_BY)
          SELECT INDICATOR_CODE_SID
               , (SELECT REPORT_SID FROM FDMS_REPORTS WHERE REPORT_ID = 'AMECO') AS REPORT_SID
               , i AS ORDER_BY
            FROM (
                     SELECT INDICATOR_CODE_SID
                       FROM FDMS_INDICATOR_CODES
                      WHERE INDICATOR_ID = l_array(i)
                 );
      END LOOP;

   END setAmecoReportIndicators;

   PROCEDURE setBudgReportIndicators
   IS
   BEGIN
      INSERT INTO FDMS_REPORT_INDICATORS (INDICATOR_CODE_SID, REPORT_SID, ORDER_BY)
        SELECT INDICATOR_CODE_SID
             , (SELECT REPORT_SID FROM FDMS_REPORTS WHERE REPORT_ID = 'BUDG') AS REPORT_SID
             , ROWNUM AS ORDER_BY
          FROM (
                 SELECT INDICATOR_CODE_SID
                   FROM FDMS_INDICATOR_CODES
                  WHERE INDICATOR_ID IN ('DMGE.1.0.99.0'
                                       , 'HVGDP.1.0.0.0'
                                       , 'HVGDP.1.0.212.0'
                                       , 'HVGDP.1.0.99.0'
                                       , 'HVGNP.1.0.0.0'
                                       , 'HVGNP.1.0.212.0'
                                       , 'HVGNP.1.0.99.0'
                                       , 'NPTD.1.0.0.0'
                                       , 'OVGN.1.0.0.0'
                                       , 'OVGN.1.0.99.0'
                                       , 'PCPH.3.1.0.0'
                                       , 'PCPH.3.1.99.0'
                                       , 'PVGD.3.1.0.0'
                                       , 'PVGD.3.1.99.0'
                                       , 'PVGD.6.1.0.0'
                                       , 'PVGD.6.1.99.0'
                                       , 'UCPH.1.0.0.0'
                                       , 'UCPH.1.0.99.0'
                                       , 'UCTG0.1.0.0.0'
                                       , 'UCTG0.1.0.99.0'
                                       , 'UGSG.1.0.0.0'
                                       , 'UGSG.1.0.99.0'
                                       , 'UIGG0.1.0.0.0'
                                       , 'UIGG0.1.0.99.0'
                                       , 'UKCG0.1.0.0.0'
                                       , 'UKCG0.1.0.99.0'
                                       , 'UUTG.1.0.99.0'
                                       , 'UUTGI.1.0.99.0'
                                       , 'UVGD.1.0.0.0'
                                       , 'UVGD.1.0.99.0'
                                       , 'UVGN.1.0.0.0'
                                       , 'UVGN.1.0.99.0'
                                       , 'UWCG.1.0.0.0'
                                       , 'UWCG.1.0.99.0'
                                       , 'XNE.1.0.99.0'
                                       , 'ZCPIH.6.0.0.0')
               ORDER BY INDICATOR_ID
               );
   END setBudgReportIndicators;
BEGIN
   setAmecoReportIndicators();
   setBudgReportIndicators();
END;
