/* Formatted on 09-12-2020 14:21:28 (QP5 v5.313) */
CREATE OR REPLACE FORCE VIEW VW_FDMS_CTY_SCALES
AS
   SELECT DISTINCT
          G.COUNTRY_ID
        , COALESCE(SC.SCALE_ID, S.SCALE_ID) SCALE_ID
        , COALESCE(SC.DESCR, S.DESCR)       DESCR
        , COALESCE(SC.EXPONENT, S.EXPONENT) EXPONENT
     FROM COUNTRY_GROUPS  G
          JOIN FDMS_SCALES S ON S.SCALE_ID = 'BILLION'
          LEFT JOIN (
                       SELECT CS.COUNTRY_ID, S.SCALE_ID, S.DESCR, S.EXPONENT
                         FROM FDMS_CTY_SCALES CS JOIN FDMS_SCALES S ON S.SCALE_SID = CS.SCALE_SID
                    ) SC
             ON SC.COUNTRY_ID = G.COUNTRY_ID
    WHERE G.COUNTRY_GROUP_ID IN ('FDMS', 'OGCLC', 'AGG');