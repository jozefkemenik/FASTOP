CREATE OR REPLACE FORCE VIEW VW_DWH_INDICATORS
AS
    SELECT I.INDICATOR_SID
         , I.PERIODICITY_ID
         , C.INDICATOR_ID
         , C.DESCR
         , P.PROVIDER_ID
      FROM DWH_INDICATORS I
      JOIN DWH_INDICATOR_CODES C ON I.INDICATOR_CODE_SID = C.INDICATOR_CODE_SID
      JOIN DWH_PROVIDERS P ON I.PROVIDER_SID = P.PROVIDER_SID;
