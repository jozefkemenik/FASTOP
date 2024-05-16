/* Formatted on 20-05-2021 17:35:09 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY FDMS_INDICATOR
AS
   /**************************************************************************
    *********************** PRIVATE SECTION **********************************
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name setIndicatorData
   ----------------------------------------------------------------------------
   PROCEDURE setIndicatorData(p_app_id        IN     VARCHAR2
                            , p_country_ids   IN     CORE_COMMONS.VARCHARARRAY
                            , p_indicator_sid IN     NUMBER
                            , p_scale_sids    IN     CORE_COMMONS.SIDSARRAY
                            , p_start_year    IN     NUMBER
                            , p_time_series   IN     CORE_COMMONS.VARCHARARRAY
                            , p_user          IN     VARCHAR
                            , o_res              OUT NUMBER
                            , p_round_sid     IN     NUMBER DEFAULT NULL
                            , p_storage_sid   IN     NUMBER DEFAULT NULL
                            , p_archive_data  IN     NUMBER DEFAULT NULL)
   IS
      l_round_sid   ROUNDS.ROUND_SID%TYPE := CORE_GETTERS.currentOrPassedRound(p_round_sid, p_app_id);
      l_storage_sid STORAGES.STORAGE_SID%TYPE
                       := COALESCE(p_storage_sid, CORE_GETTERS.getCurrentStorageSid(p_app_id));
      l_scale_sid   FDMS_CTY_INDICATOR_SCALES.SCALE_SID%TYPE;
   BEGIN
      IF p_archive_data = 1 THEN
         NULL;
      ELSIF CORE_GETTERS.isCurrentStorage(p_app_id, l_round_sid, l_storage_sid) = 0 THEN
         o_res := -3;
         RETURN;
      END IF;

      o_res := p_country_ids.COUNT;

      FOR i IN 1 .. p_country_ids.COUNT LOOP
         BEGIN
            SELECT S.SCALE_SID
              INTO l_scale_sid
              FROM FDMS_CTY_INDICATOR_SCALES S
             WHERE S.COUNTRY_ID = p_country_ids(i) AND S.INDICATOR_SID = p_indicator_sid;

            IF l_scale_sid != p_scale_sids(i) THEN
               o_res := -2;                           -- scale is different than the one used before
               RETURN;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               INSERT INTO FDMS_CTY_INDICATOR_SCALES(COUNTRY_ID, INDICATOR_SID, SCALE_SID)
                    VALUES (p_country_ids(i), p_indicator_sid, p_scale_sids(i));
         END;

         UPDATE FDMS_INDICATOR_DATA ID
            SET START_YEAR     = p_start_year
              , TIMESERIE_DATA = p_time_series(i)
              , UPDATE_DATE    = SYSDATE
              , UPDATE_USER    = p_user
          WHERE ID.COUNTRY_ID = p_country_ids(i)
            AND ID.INDICATOR_SID = p_indicator_sid
            AND ID.ROUND_SID = l_round_sid
            AND ID.STORAGE_SID = l_storage_sid;

         IF SQL%ROWCOUNT = 0 THEN
            INSERT INTO FDMS_INDICATOR_DATA(COUNTRY_ID
                                          , INDICATOR_SID
                                          , ROUND_SID
                                          , STORAGE_SID
                                          , START_YEAR
                                          , TIMESERIE_DATA
                                          , UPDATE_DATE
                                          , UPDATE_USER)
                 VALUES (p_country_ids(i)
                       , p_indicator_sid
                       , l_round_sid
                       , l_storage_sid
                       , p_start_year
                       , p_time_series(i)
                       , SYSDATE
                       , p_user);
         END IF;
      END LOOP;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         o_res := -1;                                           -- scale_id not found in FDMS_SCALES
   END setIndicatorData;

   /**************************************************************************
    *********************** PUBLIC SECTION ***********************************
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name addIndicator
   ----------------------------------------------------------------------------
   PROCEDURE addIndicator(p_indicator_id   IN     VARCHAR2
                        , p_provider_id    IN     VARCHAR2
                        , p_periodicity_id IN     VARCHAR2
                        , o_res               OUT NUMBER)
   IS
      l_provider_sid       FDMS_PROVIDERS.PROVIDER_SID%TYPE;
      l_indicator_code_sid FDMS_INDICATOR_CODES.INDICATOR_CODE_SID%TYPE;
   BEGIN
      SELECT P.PROVIDER_SID
        INTO l_provider_sid
        FROM FDMS_PROVIDERS P
       WHERE P.PROVIDER_ID = p_provider_id;

      SELECT C.INDICATOR_CODE_SID
        INTO l_indicator_code_sid
        FROM FDMS_INDICATOR_CODES C
       WHERE C.INDICATOR_ID = p_indicator_id;

      INSERT INTO FDMS_INDICATORS(INDICATOR_CODE_SID, PROVIDER_SID, PERIODICITY_ID)
           VALUES (l_indicator_code_sid, l_provider_sid, p_periodicity_id)
        RETURNING INDICATOR_SID
             INTO o_res;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
      WHEN NO_DATA_FOUND THEN
         o_res := -1;
   END addIndicator;

   ----------------------------------------------------------------------------
   -- @name copyFromFDMSStorage
   ----------------------------------------------------------------------------
   PROCEDURE copyFromFDMSStorage(
      o_res              OUT NUMBER
    , p_app_id        IN     VARCHAR2
    , p_country_ids   IN     CORE_COMMONS.VARCHARARRAY
    , p_provider_ids  IN     CORE_COMMONS.VARCHARARRAY
    , p_round_sid     IN     NUMBER
    , p_storage_sid   IN     NUMBER
    , p_indicator_ids IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
   )
   IS
      l_country_ids     VARCHARLIST := CORE_COMMONS.arrayToList(p_country_ids);
      l_provider_ids    VARCHARLIST := CORE_COMMONS.arrayToList(p_provider_ids);
      l_indicator_ids   VARCHARLIST := CORE_COMMONS.arrayToList(p_indicator_ids);
      l_indicator_count NUMBER(8) := p_indicator_ids.COUNT;
      l_round_sid       ROUNDS.ROUND_SID%TYPE := CORE_GETTERS.getCurrentRoundSid(p_app_id);
      l_storage_sid     STORAGES.STORAGE_SID%TYPE := CORE_GETTERS.getCurrentStorageSid(p_app_id);
   BEGIN
      IF (p_app_id = FDMS_GETTERS.APP_ID) THEN
         o_res := -1;
      ELSE
         DELETE FROM FDMS_INDICATOR_DATA ID
               WHERE ID.COUNTRY_ID IN (SELECT * FROM TABLE(l_country_ids))
                 AND ID.ROUND_SID = l_round_sid
                 AND ID.STORAGE_SID = l_storage_sid
                 AND ID.INDICATOR_SID IN
                        (SELECT I.INDICATOR_SID
                           FROM VW_FDMS_INDICATORS I
                          WHERE I.PROVIDER_ID IN (SELECT * FROM TABLE(l_provider_ids))
                            AND (l_indicator_count = 0
                              OR I.INDICATOR_ID IN (SELECT * FROM TABLE(l_indicator_ids))));

         INSERT INTO FDMS_INDICATOR_DATA(INDICATOR_SID
                                       , COUNTRY_ID
                                       , ROUND_SID
                                       , STORAGE_SID
                                       , START_YEAR
                                       , END_YEAR
                                       , TIMESERIE_DATA
                                       , UPDATE_DATE
                                       , UPDATE_USER
                                       , OG_FULL)
            SELECT INDICATOR_SID
                 , COUNTRY_ID
                 , l_round_sid
                 , l_storage_sid
                 , START_YEAR
                 , END_YEAR
                 , TIMESERIE_DATA
                 , UPDATE_DATE
                 , UPDATE_USER
                 , OG_FULL
              FROM FDMS_INDICATOR_DATA ID
             WHERE ID.COUNTRY_ID IN (SELECT * FROM TABLE(l_country_ids))
               AND ID.ROUND_SID = p_round_sid
               AND ID.STORAGE_SID = p_storage_sid
               AND ID.INDICATOR_SID IN
                      (SELECT I.INDICATOR_SID
                         FROM VW_FDMS_INDICATORS I
                        WHERE I.PROVIDER_ID IN (SELECT * FROM TABLE(l_provider_ids))
                          AND (l_indicator_count = 0
                            OR I.INDICATOR_ID IN (SELECT * FROM TABLE(l_indicator_ids))));

         o_res := SQL%ROWCOUNT;
      END IF;
   END copyFromFDMSStorage;

   ----------------------------------------------------------------------------
   -- @name getAmecoPhData
   ----------------------------------------------------------------------------
   PROCEDURE getAmecoPhData(
      o_cur              OUT SYS_REFCURSOR
    , p_country_ids   IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_indicator_ids IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_round_sid     IN     NUMBER DEFAULT NULL
   )
   IS
      l_round_sid       ROUNDS.ROUND_SID%TYPE := CORE_GETTERS.currentOrPassedRound(p_round_sid);
      l_country_ids     VARCHARLIST := CORE_COMMONS.arrayToList(p_country_ids);
      l_country_count   NUMBER(3) := l_country_ids.COUNT;
      l_indicator_ids   VARCHARLIST := CORE_COMMONS.arrayToList(p_indicator_ids);
      l_indicator_count NUMBER(3) := l_indicator_ids.COUNT;
   BEGIN
      OPEN o_cur FOR
         SELECT D.COUNTRY_ID
              , D.INDICATOR_ID
              , D.SCALE_ID
              , D.START_YEAR
              , D.TIMESERIE_DATA
              , D.PERIODICITY_ID
           FROM VW_FDMS_AMECO_PH_DATA D
          WHERE D.ROUND_SID = (SELECT MAX(ROUND_SID)
                                 FROM VW_FDMS_AMECO_PH_DATA
                                WHERE ROUND_SID <= l_round_sid)
            AND (l_country_count = 0 OR D.COUNTRY_ID IN (SELECT * FROM TABLE(l_country_ids)))
            AND (l_indicator_count = 0 OR D.INDICATOR_ID IN (SELECT * FROM TABLE(l_indicator_ids)));
   END getAmecoPhData;

   ----------------------------------------------------------------------------
   -- @name getCountryTableData
   ----------------------------------------------------------------------------
   PROCEDURE getCountryTableData(
      o_cur              OUT SYS_REFCURSOR
    , p_country_ids   IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_og_full       IN     NUMBER DEFAULT NULL
    , p_round_sid     IN     NUMBER DEFAULT NULL
    , p_storage_sid   IN     NUMBER DEFAULT NULL
    , p_cust_text_sid IN     NUMBER DEFAULT NULL
   )
   IS
      l_provider_ids  CORE_COMMONS.VARCHARARRAY;
      l_indicator_ids CORE_COMMONS.VARCHARARRAY;
      i               NUMBER(4) := 1;
   BEGIN
      l_provider_ids(1)  := 'PRE_PROD';

      -- temporarily here, the country table definition should go to fdms_dt_tables eventually
      l_indicator_ids(i) := 'OVGD.6.1.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'OCPH.6.1.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'OCTG.6.1.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'OIGT.6.1.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'OIGEQ.6.1.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'OXGS.6.1.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'OMGS.6.1.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'OVGN.6.0.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'CUNF.1.0.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'CIST.1.0.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'CBGS.1.0.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'FETD9.6.0.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'ZUTN.1.0.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'HWCDW.6.1.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'PLCD.6.1.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'QLCD.6.1.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'ASGH.1.0.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'PVGD.6.1.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'ZCPIH.6.0.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'APGN.6.1.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'UBGN.1.0.310.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'UBCA.1.0.310.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'UBLA.1.0.310.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'UBLGE.1.0.319.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'UBLGAP.1.0.319.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'UBLGAPS.1.0.319.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'UDGG.1.0.319.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'ZCPIN.6.0.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'UVGD.1.0.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'UCPH.1.0.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'UCTG.1.0.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'UIGT.1.0.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'UIGEQ.1.0.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'UXGS.1.0.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'UMGS.1.0.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'UVGN.1.0.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'UCPH.1.0.310.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'UCTG.1.0.310.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'UIGT.1.0.310.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'UIGEQ.1.0.310.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'UXGS.1.0.310.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'UMGS.1.0.310.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'OVGD.1.0.212.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'OXGS.1.0.30.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'OMGS.1.0.30.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'UBGS.1.0.30.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'UBCA.1.0.30.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'OVGD.6.1.212.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'OXGS.6.0.30.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'OMGS.6.0.30.0';
      i                  := i + 1;

      -- new inicators that should be used instead of the *.1.0.0.0 ones
      l_indicator_ids(i) := 'UVGD.1.1.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'UVGN.1.1.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'UCPH.1.1.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'UCTG.1.1.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'UIGT.1.1.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'UIGEQ.1.1.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'UXGS.1.1.0.0';
      i                  := i + 1;
      l_indicator_ids(i) := 'UMGS.1.1.0.0';
      i                  := i + 1;

      getProvidersIndicatorData(o_cur
                              , l_provider_ids
                              , p_country_ids
                              , l_indicator_ids
                              , p_og_full
                              , 'A'
                              , p_round_sid
                              , p_storage_sid
                              , p_cust_text_sid);
   END getCountryTableData;

   ----------------------------------------------------------------------------
   -- @name getDetailedTablesData
   ----------------------------------------------------------------------------
   PROCEDURE getDetailedTablesData(
      o_cur               OUT SYS_REFCURSOR
    , p_country_ids    IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                   NULL AS CORE_COMMONS.VARCHARARRAY
                                                                )
    , p_og_full        IN     NUMBER DEFAULT NULL
    , p_periodicity_id IN     VARCHAR2 DEFAULT 'A'
    , p_round_sid      IN     NUMBER DEFAULT NULL
    , p_storage_sid    IN     NUMBER DEFAULT NULL
    , p_cust_text_sid  IN     NUMBER DEFAULT NULL
   )
   IS
      l_provider_ids  CORE_COMMONS.VARCHARARRAY;
      l_indicator_ids CORE_COMMONS.VARCHARARRAY;
      l_cur           SYS_REFCURSOR;
   BEGIN
      l_provider_ids(1) := 'PRE_PROD';

      FDMS_DETAILED_TABLE.getTableIndicatorIds(l_cur, p_periodicity_id);

      FETCH l_cur BULK COLLECT INTO l_indicator_ids;

      CLOSE l_cur;

      getProvidersIndicatorData(o_cur
                              , l_provider_ids
                              , p_country_ids
                              , l_indicator_ids
                              , p_og_full
                              , p_periodicity_id
                              , p_round_sid
                              , p_storage_sid
                              , p_cust_text_sid);
   END getDetailedTablesData;

   ----------------------------------------------------------------------------
   -- @name getProvidersIndicatorData
   ----------------------------------------------------------------------------
   PROCEDURE getProvidersIndicatorData(
      o_cur               OUT SYS_REFCURSOR
    , p_provider_ids   IN     CORE_COMMONS.VARCHARARRAY
    , p_country_ids    IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                   NULL AS CORE_COMMONS.VARCHARARRAY
                                                                )
    , p_indicator_ids  IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                   NULL AS CORE_COMMONS.VARCHARARRAY
                                                                )
    , p_og_full        IN     NUMBER DEFAULT NULL
    , p_periodicity_id IN     VARCHAR2 DEFAULT 'A'
    , p_round_sid      IN     NUMBER DEFAULT NULL
    , p_storage_sid    IN     NUMBER DEFAULT NULL
    , p_cust_text_sid  IN     NUMBER DEFAULT NULL
    , p_codes          IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(NULL AS CORE_COMMONS.VARCHARARRAY)                            
    , p_trns           IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(NULL AS CORE_COMMONS.VARCHARARRAY) 
    , p_aggs           IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(NULL AS CORE_COMMONS.VARCHARARRAY) 
    , p_units          IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(NULL AS CORE_COMMONS.VARCHARARRAY)
    , p_refs           IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(NULL AS CORE_COMMONS.VARCHARARRAY)
   )
   IS
      l_round_sid       ROUNDS.ROUND_SID%TYPE := CORE_GETTERS.currentOrPassedRound(p_round_sid);
      l_storage_sid     STORAGES.STORAGE_SID%TYPE
                           := COALESCE(p_storage_sid, FDMS_GETTERS.getCurrentStorageSid());
      l_country_ids     VARCHARLIST := CORE_COMMONS.arrayToList(p_country_ids);
      l_country_count   NUMBER(3) := l_country_ids.COUNT;
      l_provider_ids    VARCHARLIST := CORE_COMMONS.arrayToList(p_provider_ids);
      l_indicator_ids   VARCHARLIST := CORE_COMMONS.arrayToList(p_indicator_ids);
      l_indicator_count NUMBER(3) := l_indicator_ids.COUNT;   
      l_trns            VARCHARLIST := CORE_COMMONS.arrayToList(p_trns);
      l_trns_count      NUMBER(3) := l_trns.COUNT;   
      l_aggs            VARCHARLIST := CORE_COMMONS.arrayToList(p_aggs);
      l_aggs_count      NUMBER(3) := l_aggs.COUNT;   
      l_units           VARCHARLIST := CORE_COMMONS.arrayToList(p_units);
      l_units_count     NUMBER(3) := l_units.COUNT;   
      l_refs            VARCHARLIST := CORE_COMMONS.arrayToList(p_refs);
      l_refs_count      NUMBER(3) := l_refs.COUNT;   
      l_codes           VARCHARLIST := CORE_COMMONS.arrayToList(p_codes);
      l_codes_count     NUMBER(3) := l_codes.COUNT;
   BEGIN
      -- do not change the order of the columns!
      -- to improve performance the results are fetched as array (column names are not returned)
      OPEN o_cur FOR
           SELECT D.COUNTRY_ID
                , D.INDICATOR_ID
                , D.SCALE_ID
                , D.START_YEAR
                , D.TIMESERIE_DATA
                , D.PERIODICITY_ID
                , G.DESCR AS COUNTRY_DESCR
                , D.SCALE_DESCR
                , D.UPDATE_DATE
                , D.DATA_SOURCE
             FROM VW_FDMS_INDICATOR_DATA D JOIN GEO_AREAS G ON G.GEO_AREA_ID = D.COUNTRY_ID
            WHERE D.PROVIDER_ID IN (SELECT * FROM TABLE(l_provider_ids))
              AND D.PERIODICITY_ID = p_periodicity_id
              AND D.ROUND_SID = l_round_sid
              AND D.STORAGE_SID = l_storage_sid
              AND (D.CUSTOM_STORAGE = 'N' OR (D.CUSTOM_STORAGE = 'Y' AND D.CUST_TEXT_SID = p_cust_text_sid))
              AND (l_country_count = 0 OR D.COUNTRY_ID IN (SELECT * FROM TABLE(l_country_ids)))
              AND (l_indicator_count = 0 OR D.INDICATOR_ID IN (SELECT * FROM TABLE(l_indicator_ids)))
              AND (p_og_full IS NULL OR D.OG_FULL = p_og_full)
              AND (l_trns_count = 0 OR D.AMECO_TRN IN (SELECT * FROM TABLE(l_trns)))
              AND (l_aggs_count = 0 OR D.AMECO_AGG IN (SELECT * FROM TABLE(l_aggs)))
              AND (l_units_count = 0 OR D.AMECO_UNIT IN (SELECT * FROM TABLE(l_units)))
              AND (l_refs_count = 0 OR D.AMECO_REF IN (SELECT * FROM TABLE(l_refs)))
              AND (l_codes_count = 0 OR D.AMECO_CODE IN (SELECT * FROM TABLE(l_codes)))
         ORDER BY D.COUNTRY_ID, D.INDICATOR_ID;
   END getProvidersIndicatorData;

   ----------------------------------------------------------------------------
   -- @name getProvidersIndicatorData
   ----------------------------------------------------------------------------
   PROCEDURE getProvidersIndicatorData(
      o_cur               OUT SYS_REFCURSOR
    , p_app_id         IN     VARCHAR2
    , p_provider_ids   IN     CORE_COMMONS.VARCHARARRAY
    , p_country_ids    IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                   NULL AS CORE_COMMONS.VARCHARARRAY
                                                                )
    , p_indicator_ids  IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                   NULL AS CORE_COMMONS.VARCHARARRAY
                                                                )
    , p_og_full        IN     NUMBER DEFAULT NULL
    , p_periodicity_id IN     VARCHAR2 DEFAULT 'A'
   )
   IS
      l_round_sid   ROUNDS.ROUND_SID%TYPE := CORE_GETTERS.getCurrentRoundSid(p_app_id);
      l_storage_sid STORAGES.STORAGE_SID%TYPE := CORE_GETTERS.getCurrentStorageSid(p_app_id);
   BEGIN
      getProvidersIndicatorData(o_cur
                              , p_provider_ids
                              , p_country_ids
                              , p_indicator_ids
                              , p_og_full
                              , p_periodicity_id
                              , l_round_sid
                              , l_storage_sid);
   END getProvidersIndicatorData;

   ----------------------------------------------------------------------------
   -- @name getProvidersLatestData
   ----------------------------------------------------------------------------
   PROCEDURE getProvidersLatestData(
      o_cur               OUT SYS_REFCURSOR
    , p_provider_ids   IN     CORE_COMMONS.VARCHARARRAY
    , p_country_ids    IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                   NULL AS CORE_COMMONS.VARCHARARRAY
                                                                )
    , p_indicator_ids  IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                   NULL AS CORE_COMMONS.VARCHARARRAY
                                                                )
    , p_og_full        IN     NUMBER DEFAULT NULL
    , p_periodicity_id IN     VARCHAR2 DEFAULT 'A'
   )
   IS
      l_round_sid   ROUNDS.ROUND_SID%TYPE := CORE_GETTERS.getCurrentRoundSid(FDMS_GETTERS.APP_ID);
      l_storage_sid STORAGES.STORAGE_SID%TYPE := FDMS_GETTERS.getCurrentStorageSid();
      l_user        FDMS_INDICATOR_DATA_UPLOADS.UPDATE_USER%TYPE;
      l_date        FDMS_INDICATOR_DATA_UPLOADS.UPDATE_DATE%TYPE;
   BEGIN
      -- check if data has been uploaded for all listed providers, if not find it in previous storages
      FOR i IN 1 .. p_provider_ids.COUNT LOOP
         FDMS_UPLOAD.getUploadInfo(l_user
                                 , l_date
                                 , l_round_sid
                                 , l_storage_sid
                                 , p_provider_ids(i));

         IF l_date IS NULL THEN
            -- it assumes all passed providers are uploaded together - to be revisited
            FDMS_UPLOAD.getLatestUploadInfo(l_user
                                          , l_date
                                          , l_round_sid
                                          , l_storage_sid
                                          , p_provider_ids(i));
            EXIT;
         END IF;
      END LOOP;

      getProvidersIndicatorData(o_cur
                              , p_provider_ids
                              , p_country_ids
                              , p_indicator_ids
                              , p_og_full
                              , p_periodicity_id
                              , l_round_sid
                              , l_storage_sid);
   END getProvidersLatestData;

   ----------------------------------------------------------------------------
   -- @name getProvidersForecastData
   ----------------------------------------------------------------------------
   PROCEDURE getProvidersForecastData(
      o_cur               OUT SYS_REFCURSOR
    , p_forecast_id    IN     VARCHAR2
    , p_provider_ids   IN     CORE_COMMONS.VARCHARARRAY
    , p_country_ids    IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                   NULL AS CORE_COMMONS.VARCHARARRAY
                                                                )
    , p_indicator_ids  IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                   NULL AS CORE_COMMONS.VARCHARARRAY
                                                                )
    , p_og_full        IN     NUMBER DEFAULT NULL
    , p_periodicity_id IN     VARCHAR2 DEFAULT 'A'
   )
   IS
      l_round_sid   FDMS_FORECASTS.ROUND_SID%TYPE;
      l_storage_sid FDMS_FORECASTS.STORAGE_SID%TYPE;
   BEGIN
      FDMS_FORECAST.getRoundAndStorage(p_forecast_id, l_round_sid, l_storage_sid);

      getProvidersIndicatorData(o_cur
                              , p_provider_ids
                              , p_country_ids
                              , p_indicator_ids
                              , p_og_full
                              , p_periodicity_id
                              , l_round_sid
                              , l_storage_sid);
   END getProvidersForecastData;

   ----------------------------------------------------------------------------
   -- @name getIndicatorCodes
   ----------------------------------------------------------------------------
   PROCEDURE getIndicatorCodes(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR SELECT INDICATOR_ID FROM FDMS_INDICATOR_CODES;
   END getIndicatorCodes;

   ----------------------------------------------------------------------------
   -- @name getForecastIndicatorCodes
   ----------------------------------------------------------------------------
   PROCEDURE getForecastIndicatorCodes(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
        SELECT INDICATOR_ID
          FROM FDMS_INDICATOR_CODES
         WHERE FORECAST = 1;
   END getForecastIndicatorCodes;

   ----------------------------------------------------------------------------
   -- @name getIndicatorNames
   ----------------------------------------------------------------------------
   PROCEDURE getIndicatorNames(p_indicator_ids IN     CORE_COMMONS.VARCHARARRAY
                             , o_cur              OUT SYS_REFCURSOR)
   IS
      l_indicator_ids VARCHARLIST := CORE_COMMONS.arrayToList(p_indicator_ids);
   BEGIN
      OPEN o_cur FOR SELECT INDICATOR_ID, DESCR
                       FROM FDMS_INDICATOR_CODES
                      WHERE INDICATOR_ID IN (SELECT * FROM TABLE(l_indicator_ids));
   END getIndicatorNames;

   ----------------------------------------------------------------------------
   -- @name getReportIndicators
   ----------------------------------------------------------------------------
   PROCEDURE getReportIndicators(o_cur OUT SYS_REFCURSOR, p_report_id IN VARCHAR2)
   IS
   BEGIN
      OPEN o_cur FOR   SELECT INDICATOR_ID, DESCR AS INDICATOR_DESCR, ORDER_BY
                         FROM VW_FDMS_REPORT_INDICATORS
                        WHERE REPORT_ID = p_report_id
                     ORDER BY ORDER_BY;
   END getReportIndicators;

   ----------------------------------------------------------------------------
   -- @name getIndicators
   ----------------------------------------------------------------------------
   PROCEDURE getIndicators(o_cur               OUT SYS_REFCURSOR
                         , p_provider_id    IN     VARCHAR2 DEFAULT NULL
                         , p_periodicity_id IN     VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      OPEN o_cur FOR
         SELECT I.INDICATOR_SID  AS "indicatorSid"
              , I.INDICATOR_ID   AS "indicatorId"
              , I.PERIODICITY_ID AS "periodicityId"
              , I.DESCR          AS "indicatorDescr"
           FROM VW_FDMS_INDICATORS I
          WHERE (p_provider_id IS NULL OR I.PROVIDER_ID = p_provider_id)
            AND (p_periodicity_id IS NULL OR I.PERIODICITY_ID = p_periodicity_id);
   END getIndicators;

   ----------------------------------------------------------------------------
   -- @name isOgFull
   ----------------------------------------------------------------------------
   PROCEDURE isOgFull(o_res            OUT NUMBER
                    , p_country_id  IN     VARCHAR2
                    , p_round_sid   IN     NUMBER
                    , p_storage_sid IN     NUMBER)
   IS
   BEGIN
      SELECT COUNT(*)
        INTO o_res
        FROM VW_FDMS_INDICATOR_DATA D
       WHERE D.PROVIDER_ID = 'PRE_PROD'
         AND D.INDICATOR_ID = 'AVGDGP.1.0.0.0'
         AND D.COUNTRY_ID = p_country_id
         AND D.ROUND_SID = p_round_sid
         AND D.STORAGE_SID = p_storage_sid
         AND D.OG_FULL = 1;
   END isOgFull;

   ----------------------------------------------------------------------------
   -- @name setIndicatorData
   ----------------------------------------------------------------------------
   PROCEDURE setIndicatorData(p_app_id         IN     VARCHAR2
                            , p_country_id     IN     VARCHAR2
                            , p_indicator_id   IN     VARCHAR2
                            , p_provider_id    IN     VARCHAR2
                            , p_periodicity_id IN     VARCHAR2
                            , p_scale_id       IN     VARCHAR2
                            , p_start_year     IN     NUMBER
                            , p_time_serie     IN     VARCHAR2
                            , p_user           IN     VARCHAR
                            , o_res               OUT NUMBER
                            , p_round_sid      IN     NUMBER DEFAULT NULL
                            , p_storage_sid    IN     NUMBER DEFAULT NULL
                            , p_archive_data   IN     NUMBER DEFAULT NULL)
   IS
      l_indicator_sid      FDMS_INDICATORS.INDICATOR_SID%TYPE;
      l_indicator_code_sid FDMS_INDICATOR_CODES.INDICATOR_CODE_SID%TYPE;
      l_provider_sid       FDMS_PROVIDERS.PROVIDER_SID%TYPE;
      l_scale_sid          FDMS_SCALES.SCALE_SID%TYPE;
      l_country_ids        CORE_COMMONS.VARCHARARRAY;
      l_scale_sids         CORE_COMMONS.SIDSARRAY;
      l_time_series        CORE_COMMONS.VARCHARARRAY;
   BEGIN
      BEGIN
         SELECT C.INDICATOR_CODE_SID
           INTO l_indicator_code_sid
           FROM FDMS_INDICATOR_CODES C
          WHERE C.INDICATOR_ID = p_indicator_id;

         SELECT P.PROVIDER_SID
           INTO l_provider_sid
           FROM FDMS_PROVIDERS P
          WHERE P.PROVIDER_ID = p_provider_id;

         SELECT S.SCALE_SID
           INTO l_scale_sid
           FROM FDMS_SCALES S
          WHERE S.SCALE_ID = p_scale_id;

         BEGIN
            SELECT I.INDICATOR_SID
              INTO l_indicator_sid
              FROM FDMS_INDICATORS I
             WHERE I.INDICATOR_CODE_SID = l_indicator_code_sid
               AND I.PROVIDER_SID = l_provider_sid
               AND I.PERIODICITY_ID = p_periodicity_id;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               INSERT INTO FDMS_INDICATORS(INDICATOR_CODE_SID, PROVIDER_SID, PERIODICITY_ID)
                    VALUES (l_indicator_code_sid, l_provider_sid, p_periodicity_id)
                 RETURNING INDICATOR_SID
                      INTO l_indicator_sid;
         END;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            o_res := -1;                          -- invalid indicator code, provider id or scale id
            RETURN;
      END;

      l_country_ids(1) := p_country_id;
      l_scale_sids(1)  := l_scale_sid;
      l_time_series(1) := p_time_serie;

      setIndicatorData(p_app_id
                     , l_country_ids
                     , l_indicator_sid
                     , l_scale_sids
                     , p_start_year
                     , l_time_series
                     , p_user
                     , o_res
                     , p_round_sid
                     , p_storage_sid
                     , p_archive_data);
   END setIndicatorData;

   ----------------------------------------------------------------------------
   -- @name setIndicatorData
   ----------------------------------------------------------------------------
   PROCEDURE setIndicatorData(o_res               OUT NUMBER
                            , p_app_id         IN     VARCHAR2
                            , p_country_id     IN     VARCHAR2
                            , p_indicator_sids IN OUT CORE_COMMONS.SIDSARRAY
                            , p_scale_sids     IN     CORE_COMMONS.SIDSARRAY
                            , p_start_years    IN     CORE_COMMONS.SIDSARRAY
                            , p_time_series    IN     CORE_COMMONS.VARCHARARRAY
                            , p_user           IN     VARCHAR
                            , p_round_sid      IN     NUMBER DEFAULT NULL
                            , p_storage_sid    IN     NUMBER DEFAULT NULL
                            , p_og_full        IN     NUMBER DEFAULT NULL)
   IS
      l_round_sid              ROUNDS.ROUND_SID%TYPE := CORE_GETTERS.currentOrPassedRound(p_round_sid, p_app_id);
      l_storage_sid            STORAGES.STORAGE_SID%TYPE
                                  := COALESCE(p_storage_sid, CORE_GETTERS.getCurrentStorageSid(p_app_id));
      l_scale_sid              FDMS_CTY_INDICATOR_SCALES.SCALE_SID%TYPE;
      l_updated_indicator_sids SIDSLIST;
      l_indicator_sids SIDSLIST := CORE_COMMONS.arrayToSidsList(p_indicator_sids);
   BEGIN
      IF CORE_GETTERS.isCurrentStorage(p_app_id, l_round_sid, l_storage_sid) = 0 THEN
         o_res := -3;
         RETURN;
      END IF;

      o_res := l_indicator_sids.COUNT;

      FOR i IN 1 .. l_indicator_sids.COUNT LOOP
         BEGIN
            SELECT S.SCALE_SID
              INTO l_scale_sid
              FROM FDMS_CTY_INDICATOR_SCALES S
             WHERE S.COUNTRY_ID = p_country_id AND S.INDICATOR_SID = l_indicator_sids(i);

            IF l_scale_sid != p_scale_sids(i) THEN
               o_res := -2;                           -- scale is different than the one used before
               RETURN;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               INSERT INTO FDMS_CTY_INDICATOR_SCALES(COUNTRY_ID, INDICATOR_SID, SCALE_SID)
                    VALUES (p_country_id, l_indicator_sids(i), p_scale_sids(i));
         END;
      END LOOP;

      -- Bulk update existing data and collect updated indicators
      FORALL i IN 1 .. l_indicator_sids.COUNT
            UPDATE FDMS_INDICATOR_DATA ID
               SET START_YEAR     = p_start_years(i)
                 , TIMESERIE_DATA = p_time_series(i)
                 , UPDATE_DATE    = SYSDATE
                 , UPDATE_USER    = p_user
                 , OG_FULL        = p_og_full
             WHERE ID.COUNTRY_ID = p_country_id
               AND ID.INDICATOR_SID = l_indicator_sids(i)
               AND ID.ROUND_SID = l_round_sid
               AND ID.STORAGE_SID = l_storage_sid
         RETURNING ID.INDICATOR_SID
              BULK COLLECT INTO l_updated_indicator_sids;

      -- Remove updated indicators from the indicator list
      FOR i IN 1 .. l_indicator_sids.COUNT LOOP
         IF l_indicator_sids(i) MEMBER OF l_updated_indicator_sids THEN
            l_indicator_sids.DELETE(i);
         END IF;
      END LOOP;

      -- Bulk insert remaining indicators
      FORALL idx IN INDICES OF l_indicator_sids
         INSERT INTO FDMS_INDICATOR_DATA(COUNTRY_ID
                                       , INDICATOR_SID
                                       , ROUND_SID
                                       , STORAGE_SID
                                       , START_YEAR
                                       , TIMESERIE_DATA
                                       , UPDATE_DATE
                                       , UPDATE_USER
                                       , OG_FULL)
              VALUES (p_country_id
                    , l_indicator_sids(idx)
                    , l_round_sid
                    , l_storage_sid
                    , p_start_years(idx)
                    , p_time_series(idx)
                    , SYSDATE
                    , p_user
                    , p_og_full);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         o_res := -4;                                         -- multiple records for same indicator
         ROLLBACK;
      WHEN NO_DATA_FOUND THEN
         o_res := -1;                                           -- scale_id not found in FDMS_SCALES
   END setIndicatorData;

   ----------------------------------------------------------------------------
   -- @name setIndicatorData
   ----------------------------------------------------------------------------
   PROCEDURE setIndicatorData(o_res               OUT NUMBER
                            , p_app_id         IN     VARCHAR2
                            , p_country_id     IN     VARCHAR2
                            , p_indicator_ids  IN     CORE_COMMONS.VARCHARARRAY
                            , p_provider_id    IN     VARCHAR2
                            , p_periodicity_id IN     VARCHAR2
                            , p_scale_id       IN     VARCHAR2
                            , p_start_year     IN     NUMBER
                            , p_time_series    IN     CORE_COMMONS.VARCHARARRAY
                            , p_user           IN     VARCHAR
                            , p_add_missing    IN     NUMBER DEFAULT NULL
                            , p_round_sid      IN     NUMBER DEFAULT NULL
                            , p_storage_sid    IN     NUMBER DEFAULT NULL
                            , p_og_full        IN     NUMBER DEFAULT NULL)
   IS
      l_indicator_code_sid FDMS_INDICATOR_CODES.INDICATOR_CODE_SID%TYPE;
      l_provider_sid       FDMS_PROVIDERS.PROVIDER_SID%TYPE;
      l_scale_sid          FDMS_SCALES.SCALE_SID%TYPE;
      l_indicator_sids     CORE_COMMONS.SIDSARRAY;
      l_scale_sids         CORE_COMMONS.SIDSARRAY;
      l_start_years        CORE_COMMONS.SIDSARRAY;
   BEGIN
      BEGIN
         SELECT P.PROVIDER_SID
           INTO l_provider_sid
           FROM FDMS_PROVIDERS P
          WHERE P.PROVIDER_ID = p_provider_id;

         SELECT S.SCALE_SID
           INTO l_scale_sid
           FROM FDMS_SCALES S
          WHERE S.SCALE_ID = p_scale_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            o_res := -11;                                         -- invalid provider id or scale id
            RETURN;
      END;

      FOR i IN 1 .. p_indicator_ids.COUNT LOOP
         BEGIN
            SELECT C.INDICATOR_CODE_SID
              INTO l_indicator_code_sid
              FROM FDMS_INDICATOR_CODES C
             WHERE C.INDICATOR_ID = p_indicator_ids(i);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               IF p_add_missing = 1 THEN
                  INSERT INTO FDMS_INDICATOR_CODES(INDICATOR_ID, AMECO_CODE, AMECO_TRN, AMECO_AGG, AMECO_UNIT, AMECO_REF)
                      VALUES(p_indicator_ids(i)
                           , REGEXP_SUBSTR(p_indicator_ids(i), '(^[-]?\w+)(.([0-9]+).([0-9]+).([0-9]+).([0-9]+))?', 1, 1, NULL, 1)
                           , REGEXP_SUBSTR(p_indicator_ids(i), '(^[-]?\w+)(.([0-9]+).([0-9]+).([0-9]+).([0-9]+))?', 1, 1, NULL, 3)
                           , REGEXP_SUBSTR(p_indicator_ids(i), '(^[-]?\w+)(.([0-9]+).([0-9]+).([0-9]+).([0-9]+))?', 1, 1, NULL, 4)
                           , REGEXP_SUBSTR(p_indicator_ids(i), '(^[-]?\w+)(.([0-9]+).([0-9]+).([0-9]+).([0-9]+))?', 1, 1, NULL, 5)
                           , REGEXP_SUBSTR(p_indicator_ids(i), '(^[-]?\w+)(.([0-9]+).([0-9]+).([0-9]+).([0-9]+))?', 1, 1, NULL, 6)
                    )
                    RETURNING INDICATOR_CODE_SID
                         INTO l_indicator_code_sid;
               ELSE
                  o_res := -12;                                            -- invalid indicator code
                  RETURN;
               END IF;
         END;

        <<get_local_indicator_sid>>
         BEGIN
            SELECT I.INDICATOR_SID
              INTO l_indicator_sids(i)
              FROM FDMS_INDICATORS I
             WHERE I.INDICATOR_CODE_SID = l_indicator_code_sid
               AND I.PROVIDER_SID = l_provider_sid
               AND I.PERIODICITY_ID = p_periodicity_id;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  INSERT INTO FDMS_INDICATORS(INDICATOR_CODE_SID, PROVIDER_SID, PERIODICITY_ID)
                       VALUES (l_indicator_code_sid, l_provider_sid, p_periodicity_id)
                    RETURNING INDICATOR_SID
                         INTO l_indicator_sids(i);
               EXCEPTION
                  -- in case another connection has inserted the record
                  -- in the mean time, just go back and get it
                  WHEN DUP_VAL_ON_INDEX THEN
                     GOTO get_local_indicator_sid;
               END;
         END;

         l_scale_sids(i) := l_scale_sid;
         l_start_years(i) := p_start_year;
      END LOOP;

      setIndicatorData(o_res
                     , p_app_id
                     , p_country_id
                     , l_indicator_sids
                     , l_scale_sids
                     , l_start_years
                     , p_time_series
                     , p_user
                     , p_round_sid
                     , p_storage_sid
                     , p_og_full);
   END setIndicatorData;

   ----------------------------------------------------------------------------
   -- @name getProviderIndicators
   ----------------------------------------------------------------------------
   PROCEDURE getProviderIndicators(p_provider_id IN VARCHAR2, o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
         SELECT V.INDICATOR_ID, V.EUROSTAT_CODE, T.TRANSFORMATION_ID
           FROM VW_FDMS_INDICATORS  V
                LEFT JOIN FDMS_TRANSFORMATIONS T ON V.TRANSFORMATION_SID = T.TRANSFORMATION_SID
          WHERE V.PROVIDER_ID = p_provider_id;
   END getProviderIndicators;

   ----------------------------------------------------------------------------
   -- @name transferAmecoToScopax temporary solution for copying ameco indicators to scopax
   ----------------------------------------------------------------------------
   PROCEDURE transferAmecoToScopax(p_round_sid   IN     NUMBER
                                 , p_storage_sid IN     NUMBER
                                 , o_res            OUT NUMBER)
   IS
      l_ameco_indicator_sids SIDSLIST;
      l_countries VARCHARLIST;
      l_v1_round_sid         NUMBER;
   BEGIN
      SELECT I.INDICATOR_SID
        BULK COLLECT INTO l_ameco_indicator_sids
        FROM INDICATOR_LISTS  IL
             JOIN WORKBOOK_GROUPS WG
                ON WG.WORKBOOK_GROUP_SID = IL.WORKBOOK_GROUP_SID
               AND WG.WORKBOOK_GROUP_ID = 'linked_tables'
             RIGHT JOIN INDICATORS I ON I.INDICATOR_SID = IL.INDICATOR_SID AND I.SOURCE = 'AMECO'
       WHERE I.INDICATOR_ID IN ('1.2.0.0.UVGD', '1.0.0.0.UVGDOG')
          OR IL.INDICATOR_LIST_SID IS NOT NULL;

      -- find first version of the current round (same year and period)
      SELECT ROUND_SID
        INTO l_v1_round_sid
        FROM ROUNDS
       WHERE VERSION = 1
         AND (YEAR, PERIOD_SID) = (SELECT YEAR, PERIOD_SID FROM ROUNDS WHERE ROUND_SID = p_round_sid);

      IF l_v1_round_sid = p_round_sid
      THEN
          DELETE FROM AMECO_INDIC_DATA
                WHERE ROUND_SID = p_round_sid
                  AND INDICATOR_SID IN (SELECT * FROM TABLE(l_ameco_indicator_sids));

          INSERT INTO AMECO_INDIC_DATA(COUNTRY_ID
                                     , INDICATOR_SID
                                     , ROUND_SID
                                     , START_YEAR
                                     , VECTOR
                                     , LAST_CHANGE_USER
                                     , LAST_CHANGE_DATE)
             SELECT D.COUNTRY_ID
                  , I.INDICATOR_SID
                  , D.ROUND_SID
                  , D.START_YEAR
                  , IDR_CALCULATED.scaleTimeSerie(D.TIMESERIE_DATA, S.SCALE_ID)
                  , 'FDMSSTAR'
                  , SYSDATE
               FROM VW_FDMS_INDICATOR_DATA  D
                    JOIN INDICATORS I
                       ON I.INDICATOR_ID =
                             SUBSTR(D.INDICATOR_ID, INSTR(D.INDICATOR_ID, '.', 1) + 1)
                          || '.'
                          || SUBSTR(D.INDICATOR_ID, 1, INSTR(D.INDICATOR_ID, '.', 1) - 1)
                    LEFT JOIN SCALES S ON S.SCALE_SID = I.SCALE_SID
              WHERE D.PROVIDER_ID = 'PRE_PROD'
                AND PERIODICITY_ID = 'A'
                AND I.INDICATOR_SID IN (SELECT * FROM TABLE(l_ameco_indicator_sids))
                AND D.ROUND_SID = p_round_sid
                AND D.STORAGE_SID = p_storage_sid;
      ELSE
               SELECT DISTINCT COUNTRY_ID
                 BULK COLLECT INTO l_countries
                 FROM VW_FDMS_INDICATOR_DATA
                WHERE ROUND_SID = p_round_sid
                  AND STORAGE_SID = p_storage_sid
                  AND PROVIDER_ID = 'DESK'
                  AND PERIODICITY_ID = 'A';

           MERGE INTO AMECO_INDIC_DATA A
                USING (
                   SELECT l_v1_round_sid AS ROUND_SID
                        , I.INDICATOR_SID
                        , D.COUNTRY_ID
                        , D.START_YEAR
                        , IDR_CALCULATED.scaleTimeSerie(D.TIMESERIE_DATA, S.SCALE_ID) AS VECTOR
                     FROM VW_FDMS_INDICATOR_DATA  D
                          JOIN INDICATORS I
                             ON I.INDICATOR_ID =
                                   SUBSTR(D.INDICATOR_ID, INSTR(D.INDICATOR_ID, '.', 1) + 1)
                                || '.'
                                || SUBSTR(D.INDICATOR_ID, 1, INSTR(D.INDICATOR_ID, '.', 1) - 1)
                          LEFT JOIN SCALES S ON S.SCALE_SID = I.SCALE_SID
                    WHERE D.ROUND_SID = p_round_sid
                      AND D.STORAGE_SID = p_storage_sid
                      AND D.PROVIDER_ID = 'PRE_PROD'
                      AND D.PERIODICITY_ID = 'A'
                      AND I.INDICATOR_SID IN (SELECT * FROM TABLE(l_ameco_indicator_sids))
                      AND D.COUNTRY_ID IN (SELECT * FROM TABLE(l_countries))
                ) I
                   ON (A.ROUND_SID = I.ROUND_SID AND A.INDICATOR_SID = I.INDICATOR_SID AND A.COUNTRY_ID = I.COUNTRY_ID)
         WHEN MATCHED
                 THEN UPDATE SET
                          A.START_YEAR = I.START_YEAR
                        , A.VECTOR = I.VECTOR
                        , A.LAST_CHANGE_USER = 'FDMSSTAR|' || TO_CHAR(p_round_sid)
                        , A.LAST_CHANGE_DATE = SYSDATE;
      END IF;

      o_res := SQL%ROWCOUNT;
   END transferAmecoToScopax;

   ----------------------------------------------------------------------------
   -- @name getIndicatorScales
   ----------------------------------------------------------------------------
   PROCEDURE getIndicatorScales(o_cur               OUT SYS_REFCURSOR
                              , p_provider_id    IN     VARCHAR2
                              , p_periodicity_id IN     VARCHAR2
                              , p_indicator_ids  IN     CORE_COMMONS.VARCHARARRAY
                              , p_country_ids    IN     CORE_COMMONS.VARCHARARRAY)
   IS
      l_indicator_ids VARCHARLIST := CORE_COMMONS.arrayToList(p_indicator_ids);
      l_country_ids   VARCHARLIST := CORE_COMMONS.arrayToList(p_country_ids);
   BEGIN
      OPEN o_cur FOR
         SELECT S.SCALE_ID
              , S.DESCR
              , S.EXPONENT
              , CS.COUNTRY_ID
              , I.INDICATOR_ID
           FROM VW_FDMS_INDICATORS  I
                JOIN FDMS_CTY_INDICATOR_SCALES CS ON I.INDICATOR_SID = CS.INDICATOR_SID
                JOIN FDMS_SCALES S ON CS.SCALE_SID = S.SCALE_SID
          WHERE CS.COUNTRY_ID IN (SELECT * FROM TABLE(l_country_ids))
            AND I.INDICATOR_ID IN (SELECT * FROM TABLE(l_indicator_ids))
            AND I.PERIODICITY_ID = p_periodicity_id
            AND I.PROVIDER_ID = p_provider_id;
   END getIndicatorScales;

   ----------------------------------------------------------------------------
   -- @name getCtyIndicatorScales
   ----------------------------------------------------------------------------
   PROCEDURE getCtyIndicatorScales(o_cur               OUT SYS_REFCURSOR
                                 , p_provider_id    IN     VARCHAR2)
   IS
   BEGIN
      OPEN o_cur FOR
         SELECT S.COUNTRY_ID || '_' || S.INDICATOR_SID AS "CTY_IND"
              , S.SCALE_SID
           FROM FDMS_CTY_INDICATOR_SCALES S
           JOIN VW_FDMS_INDICATORS I
             ON I.INDICATOR_SID = S.INDICATOR_SID
          WHERE I.PROVIDER_ID = p_provider_id;
   END getCtyIndicatorScales;


   ----------------------------------------------------------------------------
   -- @name getIndicatorsMappings
   ----------------------------------------------------------------------------
   PROCEDURE getIndicatorsMappings(o_cur               OUT SYS_REFCURSOR
                                 , p_provider_id    IN     VARCHAR2)
   IS
   BEGIN
      OPEN o_cur FOR
         SELECT M.INDICATOR_SID AS "indicatorSid"
              , M.INDICATOR_ID  AS "indicatorId"
              , M.SCALE_SID     AS "scaleSid"
              , M.SCALE_ID      AS "scaleId"
              , M.SOURCE_CODE   AS "sourceCode"
              , M.SOURCE_DESCR  AS "sourceDescr"
           FROM VW_FDMS_INDICATORS_MAPPINGS M
          WHERE M.PROVIDER_ID = p_provider_id;
   END getIndicatorsMappings;

   ----------------------------------------------------------------------------
   -- @name setIndicatorCodes
   ----------------------------------------------------------------------------
   PROCEDURE setIndicatorCodes(o_res      OUT NUMBER
                              ,p_sid IN     NUMBER
                              ,p_descr        IN     VARCHAR2
                              ,p_forecast     IN     NUMBER )
   IS
   BEGIN
      
         UPDATE FDMS_INDICATOR_CODES IC
            SET IC.FORECAST = p_forecast
              , IC.DESCR = p_descr
            WHERE IC.INDICATOR_CODE_SID=p_sid;
         o_res := SQL%ROWCOUNT;
   END setIndicatorCodes;

END FDMS_INDICATOR;
/
