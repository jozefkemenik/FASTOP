SET DEFINE OFF;

INSERT INTO FDMS_INDICATOR_MAPPINGS(SOURCE_CODE, SOURCE_DESCR, SCALE_SID, INDICATOR_SID)
    SELECT 'Y_Gap(HP)' AS SOURCE_CODE
         , 'OutputGapHP' AS SOURCE_DESCR
         , (SELECT SCALE_SID FROM FDMS_SCALES WHERE SCALE_ID = 'UNIT') AS SCALE_SID
         , INDICATOR_SID
      FROM VW_FDMS_INDICATORS
     WHERE PROVIDER_ID = 'EUCAM10'
       AND INDICATOR_ID = 'AVGDGT10.1.0.0.0'
       AND PERIODICITY_ID = 'A';        


INSERT INTO FDMS_INDICATOR_MAPPINGS(SOURCE_CODE, SOURCE_DESCR, SCALE_SID, INDICATOR_SID)
    SELECT 'Y_GAP(PF)' AS SOURCE_CODE
         , 'OutputGapPf' AS SOURCE_DESCR
         , (SELECT SCALE_SID FROM FDMS_SCALES WHERE SCALE_ID = 'UNIT') AS SCALE_SID
         , INDICATOR_SID
      FROM VW_FDMS_INDICATORS
     WHERE PROVIDER_ID = 'EUCAM10'
       AND INDICATOR_ID = 'AVGDGP10.1.0.0.0'
       AND PERIODICITY_ID = 'A';        


INSERT INTO FDMS_INDICATOR_MAPPINGS(SOURCE_CODE, SOURCE_DESCR, SCALE_SID, INDICATOR_SID)
    SELECT 'GDP' AS SOURCE_CODE
         , 'Real GDP' AS SOURCE_DESCR
         , (SELECT SCALE_SID FROM FDMS_SCALES WHERE SCALE_ID = 'BILLION') AS SCALE_SID
         , INDICATOR_SID
      FROM VW_FDMS_INDICATORS
     WHERE PROVIDER_ID = 'EUCAM10'
       AND INDICATOR_ID = 'OVGD.1.1.0.0'
       AND PERIODICITY_ID = 'A';        


INSERT INTO FDMS_INDICATOR_MAPPINGS(SOURCE_CODE, SOURCE_DESCR, SCALE_SID, INDICATOR_SID)
    SELECT 'Trend_GDP' AS SOURCE_CODE
         , 'Trend GDP' AS SOURCE_DESCR
         , (SELECT SCALE_SID FROM FDMS_SCALES WHERE SCALE_ID = 'BILLION') AS SCALE_SID
         , INDICATOR_SID
      FROM VW_FDMS_INDICATORS
     WHERE PROVIDER_ID = 'EUCAM10'
       AND INDICATOR_ID = 'OVGDT10.1.0.0.0'
       AND PERIODICITY_ID = 'A';        


INSERT INTO FDMS_INDICATOR_MAPPINGS(SOURCE_CODE, SOURCE_DESCR, SCALE_SID, INDICATOR_SID)
    SELECT 'GDP deflator_' AS SOURCE_CODE
         , 'GDPdefl' AS SOURCE_DESCR
         , (SELECT SCALE_SID FROM FDMS_SCALES WHERE SCALE_ID = 'UNIT') AS SCALE_SID
         , INDICATOR_SID
      FROM VW_FDMS_INDICATORS
     WHERE PROVIDER_ID = 'EUCAM10'
       AND INDICATOR_ID = 'PVGD.3.1.99.0'
       AND PERIODICITY_ID = 'A';        


INSERT INTO FDMS_INDICATOR_MAPPINGS(SOURCE_CODE, SOURCE_DESCR, SCALE_SID, INDICATOR_SID)
    SELECT 'Y_Pot' AS SOURCE_CODE
         , 'Pot_GDP' AS SOURCE_DESCR
         , (SELECT SCALE_SID FROM FDMS_SCALES WHERE SCALE_ID = 'BILLION') AS SCALE_SID
         , INDICATOR_SID
      FROM VW_FDMS_INDICATORS
     WHERE PROVIDER_ID = 'EUCAM10'
       AND INDICATOR_ID = 'OVGDP10.1.0.0.0'
       AND PERIODICITY_ID = 'A';        


INSERT INTO FDMS_INDICATOR_MAPPINGS(SOURCE_CODE, SOURCE_DESCR, SCALE_SID, INDICATOR_SID)
    SELECT 'Pot_Tot_Hrs' AS SOURCE_CODE
         , 'Pot_TotHrs' AS SOURCE_DESCR
         , (SELECT SCALE_SID FROM FDMS_SCALES WHERE SCALE_ID = 'MILLION') AS SCALE_SID
         , INDICATOR_SID
      FROM VW_FDMS_INDICATORS
     WHERE PROVIDER_ID = 'EUCAM10'
       AND INDICATOR_ID = 'NLHTP.1.0.0.0'
       AND PERIODICITY_ID = 'A';        


INSERT INTO FDMS_INDICATOR_MAPPINGS(SOURCE_CODE, SOURCE_DESCR, SCALE_SID, INDICATOR_SID)
    SELECT 'Capital' AS SOURCE_CODE
         , 'Capital' AS SOURCE_DESCR
         , (SELECT SCALE_SID FROM FDMS_SCALES WHERE SCALE_ID = 'BILLION') AS SCALE_SID
         , INDICATOR_SID
      FROM VW_FDMS_INDICATORS
     WHERE PROVIDER_ID = 'EUCAM10'
       AND INDICATOR_ID = 'OKND10.1.0.0.0'
       AND PERIODICITY_ID = 'A';        


INSERT INTO FDMS_INDICATOR_MAPPINGS(SOURCE_CODE, SOURCE_DESCR, SCALE_SID, INDICATOR_SID)
    SELECT 'Investment' AS SOURCE_CODE
         , 'Investment' AS SOURCE_DESCR
         , (SELECT SCALE_SID FROM FDMS_SCALES WHERE SCALE_ID = 'BILLION') AS SCALE_SID
         , INDICATOR_SID
      FROM VW_FDMS_INDICATORS
     WHERE PROVIDER_ID = 'EUCAM10'
       AND INDICATOR_ID = 'OIGT.1.1.0.0'
       AND PERIODICITY_ID = 'A';        


INSERT INTO FDMS_INDICATOR_MAPPINGS(SOURCE_CODE, SOURCE_DESCR, SCALE_SID, INDICATOR_SID)
    SELECT 'Pot_Empl' AS SOURCE_CODE
         , 'Pot_Empl' AS SOURCE_DESCR
         , (SELECT SCALE_SID FROM FDMS_SCALES WHERE SCALE_ID = 'THOUSAND') AS SCALE_SID
         , INDICATOR_SID
      FROM VW_FDMS_INDICATORS
     WHERE PROVIDER_ID = 'EUCAM10'
       AND INDICATOR_ID = 'NETDP.1.0.0.0'
       AND PERIODICITY_ID = 'A';        


INSERT INTO FDMS_INDICATOR_MAPPINGS(SOURCE_CODE, SOURCE_DESCR, SCALE_SID, INDICATOR_SID)
    SELECT 'Empl' AS SOURCE_CODE
         , 'Empl' AS SOURCE_DESCR
         , (SELECT SCALE_SID FROM FDMS_SCALES WHERE SCALE_ID = 'THOUSAND') AS SCALE_SID
         , INDICATOR_SID
      FROM VW_FDMS_INDICATORS
     WHERE PROVIDER_ID = 'EUCAM10'
       AND INDICATOR_ID = 'NETD.1.0.0.0'
       AND PERIODICITY_ID = 'A';        


INSERT INTO FDMS_INDICATOR_MAPPINGS(SOURCE_CODE, SOURCE_DESCR, SCALE_SID, INDICATOR_SID)
    SELECT 'Pot_LF' AS SOURCE_CODE
         , 'Pot_LF' AS SOURCE_DESCR
         , (SELECT SCALE_SID FROM FDMS_SCALES WHERE SCALE_ID = 'THOUSAND') AS SCALE_SID
         , INDICATOR_SID
      FROM VW_FDMS_INDICATORS
     WHERE PROVIDER_ID = 'EUCAM10'
       AND INDICATOR_ID = 'NLTNP.1.0.0.0'
       AND PERIODICITY_ID = 'A';        


INSERT INTO FDMS_INDICATOR_MAPPINGS(SOURCE_CODE, SOURCE_DESCR, SCALE_SID, INDICATOR_SID)
    SELECT 'NAWRU' AS SOURCE_CODE
         , 'NAWRU' AS SOURCE_DESCR
         , (SELECT SCALE_SID FROM FDMS_SCALES WHERE SCALE_ID = 'UNIT') AS SCALE_SID
         , INDICATOR_SID
      FROM VW_FDMS_INDICATORS
     WHERE PROVIDER_ID = 'EUCAM10'
       AND INDICATOR_ID = 'ZNAWRU10.1.0.0.0'
       AND PERIODICITY_ID = 'A';        


INSERT INTO FDMS_INDICATOR_MAPPINGS(SOURCE_CODE, SOURCE_DESCR, SCALE_SID, INDICATOR_SID)
    SELECT 'UnEmpl_Rate' AS SOURCE_CODE
         , 'UnEmpl_Rate' AS SOURCE_DESCR
         , (SELECT SCALE_SID FROM FDMS_SCALES WHERE SCALE_ID = 'UNIT') AS SCALE_SID
         , INDICATOR_SID
      FROM VW_FDMS_INDICATORS
     WHERE PROVIDER_ID = 'EUCAM10'
       AND INDICATOR_ID = 'ZUTN10.1.0.0.0'
       AND PERIODICITY_ID = 'A';        


INSERT INTO FDMS_INDICATOR_MAPPINGS(SOURCE_CODE, SOURCE_DESCR, SCALE_SID, INDICATOR_SID)
    SELECT 'HperE' AS SOURCE_CODE
         , 'HperE' AS SOURCE_DESCR
         , (SELECT SCALE_SID FROM FDMS_SCALES WHERE SCALE_ID = 'UNIT') AS SCALE_SID
         , INDICATOR_SID
      FROM VW_FDMS_INDICATORS
     WHERE PROVIDER_ID = 'EUCAM10'
       AND INDICATOR_ID = 'NLHA.1.0.0.0'
       AND PERIODICITY_ID = 'A';        


INSERT INTO FDMS_INDICATOR_MAPPINGS(SOURCE_CODE, SOURCE_DESCR, SCALE_SID, INDICATOR_SID)
    SELECT 'Tot_Hrs' AS SOURCE_CODE
         , 'TotHrs' AS SOURCE_DESCR
         , (SELECT SCALE_SID FROM FDMS_SCALES WHERE SCALE_ID = 'MILLION') AS SCALE_SID
         , INDICATOR_SID
      FROM VW_FDMS_INDICATORS
     WHERE PROVIDER_ID = 'EUCAM10'
       AND INDICATOR_ID = 'NLHT.1.0.0.0'
       AND PERIODICITY_ID = 'A';        


INSERT INTO FDMS_INDICATOR_MAPPINGS(SOURCE_CODE, SOURCE_DESCR, SCALE_SID, INDICATOR_SID)
    SELECT 'Tot_Pop' AS SOURCE_CODE
         , 'Total Pop' AS SOURCE_DESCR
         , (SELECT SCALE_SID FROM FDMS_SCALES WHERE SCALE_ID = 'THOUSAND') AS SCALE_SID
         , INDICATOR_SID
      FROM VW_FDMS_INDICATORS
     WHERE PROVIDER_ID = 'EUCAM10'
       AND INDICATOR_ID = 'NPTD.1.0.0.0'
       AND PERIODICITY_ID = 'A';        

/
COMMIT;
