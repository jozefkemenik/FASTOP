CREATE OR REPLACE FORCE VIEW VW_DFM_ARCHIVE_MEASURES
AS
   SELECT M.*
        , R.REV_EXP_ID
        , S.STATUS_ID
     FROM DFM_ARCHIVED_MEASURES M
LEFT JOIN DFM_REV_EXP R ON M.REV_EXP_SID = R.REV_EXP_SID
LEFT JOIN DFM_STATUS S ON M.STATUS_SID = S.STATUS_SID;
