CREATE OR REPLACE FORCE VIEW VW_HICP_INDICATOR_CATEGORY
AS
    SELECT IC.*, C.CATEGORY_ID, C.DESCR AS CATEGORY_DESCR
      FROM HICP_INDICATOR_CODE_CATEGORY ICC
      JOIN HICP_INDICATOR_CODES IC
        ON IC.INDICATOR_ID = ICC.INDICATOR_ID
      JOIN HICP_CATEGORY C
        ON ICC.CATEGORY_SID = C.CATEGORY_SID;
