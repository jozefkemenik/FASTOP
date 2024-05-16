/* Formatted on 12/17/2019 12:55:13 (QP5 v5.252.13127.32847) */
INSERT INTO DRM_ARCHIVED_MEASURES (ROUND_SID
,                                  MEASURE_SID
,                                  COUNTRY_ID
,                                  TITLE
,                                  DESCR
,                                  ESA_SID
,                                  ACC_PRINCIP_SID
,                                  ADOPT_STATUS_SID
,                                  DATA
,                                  START_YEAR
,                                  ONE_OFF_SID
,                                  ONE_OFF_TYPE_SID
,                                  YEAR)
   SELECT M.ROUND_SID
,         M.MEASURE_SID
,         M.COUNTRY_ID
,         M.TITLE
,         M.DESCR
,         M.ESA_SID
,         M.ACC_PRINCIP_SID
,         M.ADOPT_STATUS_SID
,         M.DATA
,         M.START_YEAR
,         M.ONE_OFF_SID
,         M.ONE_OFF_TYPE_SID
,         M.YEAR
     FROM DBP_MEASURES@SCOPAX M
          JOIN ROUNDS R ON R.ROUND_SID = M.ROUND_SID
          JOIN DBP_EXERCISES E ON E.EXERCISE_SID = M.EXERCISE_SID
    WHERE E.EXERCISE_ID IN ('BOTH', 'DRM');

COMMIT;