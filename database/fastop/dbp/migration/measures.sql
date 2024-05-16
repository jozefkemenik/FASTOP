/* Formatted on 12/17/2019 13:10:23 (QP5 v5.252.13127.32847) */
INSERT INTO GD_CTY_VERSIONS (COUNTRY_ID, VERSION)
   SELECT DISTINCT COUNTRY_ID, VERSION
     FROM DBP_MEASURES@SCOPAX M
    WHERE     0 =
                 (SELECT COUNT (*)
                    FROM GD_CTY_VERSIONS V
                   WHERE     V.COUNTRY_ID = M.COUNTRY_ID
                         AND V.VERSION = M.VERSION)
          AND COUNTRY_ID IN (SELECT COUNTRY_ID FROM COUNTRIES);

INSERT INTO DBP_MEASURES (ROUND_SID
,                         MEASURE_SID
,                         TITLE
,                         DESCR
,                         SOURCE_SID
,                         ESA_SID
,                         ACC_PRINCIP_SID
,                         ADOPT_STATUS_SID
,                         DATA
,                         START_YEAR
,                         CTY_VERSION_SID)
   SELECT M.ROUND_SID
,         M.MEASURE_SID
,         M.TITLE
,         M.DESCR
,         M.SOURCE_SID
,         M.ESA_SID
,         M.ACC_PRINCIP_SID
,         M.ADOPT_STATUS_SID
,         M.DATA
,         M.START_YEAR
,         V.CTY_VERSION_SID
     FROM DBP_MEASURES@SCOPAX M
          JOIN ROUNDS R ON R.ROUND_SID = M.ROUND_SID
          JOIN COUNTRIES C ON C.COUNTRY_ID = M.COUNTRY_ID
          JOIN GD_CTY_VERSIONS V
             ON V.COUNTRY_ID = M.COUNTRY_ID AND V.VERSION = M.VERSION
          JOIN DBP_EXERCISES E ON E.EXERCISE_SID = M.EXERCISE_SID
    WHERE E.EXERCISE_ID IN ('BOTH', 'DBP');