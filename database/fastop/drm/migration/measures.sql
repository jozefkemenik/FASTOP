INSERT INTO DRM_MEASURES (COUNTRY_ID
,                         TITLE
,                         DESCR
,                         ESA_SID
,                         ACC_PRINCIP_SID
,                         ADOPT_STATUS_SID
,                         DATA
,                         START_YEAR
,                         ONE_OFF_SID
,                         ONE_OFF_TYPE_SID
,                         YEAR)
SELECT
        COUNTRY_ID
,       TITLE
,       DESCR
,       ESA_SID
,       ACC_PRINCIP_SID
,       ADOPT_STATUS_SID
,       DATA
,       START_YEAR
,       ONE_OFF_SID
,       ONE_OFF_TYPE_SID
,       YEAR
FROM DRM_ARCHIVED_MEASURES
WHERE ROUND_SID = (SELECT VALUE FROM PARAMS WHERE PARAM_ID = 'CURRENT_ROUND');

COMMIT;