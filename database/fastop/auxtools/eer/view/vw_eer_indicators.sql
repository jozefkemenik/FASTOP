CREATE OR REPLACE FORCE VIEW VW_EER_INDICATORS
AS
    SELECT I.INDICATOR_SID
         , I.PERIODICITY_ID
         , P.PROVIDER_SID
         , P.PROVIDER_ID
         , C.INDICATOR_ID
      FROM EER_INDICATOR_CODES C
      JOIN EER_INDICATORS  I
        ON C.INDICATOR_CODE_SID = I.INDICATOR_CODE_SID
      JOIN EER_PROVIDERS P
        ON I.PROVIDER_SID = P.PROVIDER_SID;
