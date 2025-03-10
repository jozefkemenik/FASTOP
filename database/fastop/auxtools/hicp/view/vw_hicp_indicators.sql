CREATE OR REPLACE FORCE VIEW VW_HICP_INDICATORS
AS
    SELECT I.INDICATOR_SID, I.PERIODICITY_ID, I.DATA_TYPE, I.EUROSTAT_CODE, C.*
      FROM HICP_INDICATOR_CODES C
 LEFT JOIN HICP_INDICATORS  I
        ON C.INDICATOR_CODE_SID = I.INDICATOR_CODE_SID;
