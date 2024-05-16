/* Formatted on 15-04-2021 20:28:07 (QP5 v5.313) */
CREATE OR REPLACE FORCE VIEW VW_FDMS_INDICATOR_DATA
AS
   SELECT I.INDICATOR_ID
        , D.*
        , I.PROVIDER_ID
        , I.PERIODICITY_ID
        , I.ESA_CODE
        , I.DATA_SOURCE
        , COALESCE(S.SCALE_ID, 'UNIT')     SCALE_ID
        , COALESCE(S.SCALE_DESCR, 'Units') SCALE_DESCR
        , T.IS_CUSTOM                      CUSTOM_STORAGE
        , I.AMECO_CODE
        , I.AMECO_TRN
        , I.AMECO_AGG
        , I.AMECO_UNIT
        , I.AMECO_REF
     FROM VW_FDMS_INDICATORS  I
          JOIN FDMS_INDICATOR_DATA D ON D.INDICATOR_SID = I.INDICATOR_SID
          JOIN STORAGES T ON T.STORAGE_SID = D.STORAGE_SID
          LEFT JOIN VW_FDMS_CTY_INDICATOR_SCALES S
             ON S.COUNTRY_ID = D.COUNTRY_ID AND S.INDICATOR_SID = I.INDICATOR_SID
   -- The below to be removed once the forecast transfer matrix sheet is changed to use the new RRF indicator codes
   UNION ALL
   SELECT CASE I.INDICATOR_ID
             WHEN 'UTAF2GGRRF' THEN 'UTAF2GR'
             WHEN 'UD76PAYS13' THEN 'UYTGEU'
             ELSE SUBSTR(I.INDICATOR_ID, 1, LENGTH(I.INDICATOR_ID) - 2)
          END
             INDICATOR_ID
        , D.*
        , I.PROVIDER_ID
        , I.PERIODICITY_ID
        , I.ESA_CODE
        , I.DATA_SOURCE
        , COALESCE(S.SCALE_ID, 'UNIT')
             SCALE_ID
        , COALESCE(S.SCALE_DESCR, 'Units')
             SCALE_DESCR
        , T.IS_CUSTOM
             CUSTOM_STORAGE
        , I.AMECO_CODE
        , I.AMECO_TRN
        , I.AMECO_AGG
        , I.AMECO_UNIT
        , I.AMECO_REF
     FROM VW_FDMS_INDICATORS  I
          JOIN FDMS_INDICATOR_DATA D ON D.INDICATOR_SID = I.INDICATOR_SID
          JOIN STORAGES T ON T.STORAGE_SID = D.STORAGE_SID
          LEFT JOIN VW_FDMS_CTY_INDICATOR_SCALES S
             ON S.COUNTRY_ID = D.COUNTRY_ID AND S.INDICATOR_SID = I.INDICATOR_SID
    WHERE I.PROVIDER_ID = 'DESK'
      AND D.ROUND_SID < (SELECT ROUND_SID FROM VW_ROUNDS WHERE YEAR = 2021 AND PERIOD_ID = 'AUT')
      AND I.INDICATOR_ID IN ('UUCGRRF'
                           , 'UIGG0RRF'
                           , 'UKTGRRF'
                           , 'UTGCRRF'
                           , 'UROGRRF'
                           , 'UTAFGGRRF'
                           , 'UTAF2GGRRF'
                           , 'UD76PAYS13');
