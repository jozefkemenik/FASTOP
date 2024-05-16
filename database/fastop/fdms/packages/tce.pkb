/* Formatted on 21-01-2021 13:08:36 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY FDMS_TCE
AS
   ----------------------------------------------------------------------------
   -- @name getTceReportIndicatorSid
   ----------------------------------------------------------------------------
   FUNCTION getTceReportIndicatorSid(p_indicator_id IN VARCHAR2)
      RETURN NUMBER
   IS
      l_indicator_sid NUMBER;
   BEGIN
      RETURN FDMS_GETTERS.getIndicatorSid(p_indicator_id, FDMS_TCE.TCE_RESULTS_PROVIDER_ID);
   END getTceReportIndicatorSid;

   ----------------------------------------------------------------------------
   -- @name getTceResultsMatrixSid
   ----------------------------------------------------------------------------
   FUNCTION getTceResultsMatrixSid(p_round_sid IN NUMBER, p_storage_sid IN NUMBER)
      RETURN NUMBER
   IS
      l_round_sid      ROUNDS.ROUND_SID%TYPE := CORE_GETTERS.currentOrPassedRound(p_round_sid);
      l_storage_sid    STORAGES.STORAGE_SID%TYPE
         := COALESCE(p_storage_sid, CORE_GETTERS.getCurrentStorageSid(FDMS_GETTERS.APP_ID));
      l_provider_sid   FDMS_PROVIDERS.PROVIDER_SID%TYPE
                          := FDMS_GETTERS.getProviderSid(FDMS_TCE.TCE_RESULTS_PROVIDER_ID);
      l_tce_matrix_sid FDMS_TCE_MATRICES.TCE_MATRIX_SID%TYPE := -1;
   BEGIN
      BEGIN
         SELECT TCE_MATRIX_SID
           INTO l_tce_matrix_sid
           FROM FDMS_TCE_MATRICES
          WHERE PROVIDER_SID = l_provider_sid
            AND ROUND_SID = l_round_sid
            AND STORAGE_SID = l_storage_sid;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            setTceMatrix(l_round_sid
                       , l_storage_sid
                       , FDMS_TCE.TCE_RESULTS_PROVIDER_ID
                       , l_tce_matrix_sid);
      END;

      RETURN l_tce_matrix_sid;
   END getTceResultsMatrixSid;

   ----------------------------------------------------------------------------
   -- @name setTceMatrix
   ----------------------------------------------------------------------------
   PROCEDURE setTceMatrix(p_round_sid   IN     NUMBER
                        , p_storage_sid IN     NUMBER
                        , p_provider_id IN     VARCHAR2
                        , o_res            OUT NUMBER)
   IS
      l_round_sid    ROUNDS.ROUND_SID%TYPE := CORE_GETTERS.currentOrPassedRound(p_round_sid);
      l_storage_sid  STORAGES.STORAGE_SID%TYPE
         := COALESCE(p_storage_sid, CORE_GETTERS.getCurrentStorageSid(FDMS_GETTERS.APP_ID));
      l_provider_sid FDMS_PROVIDERS.PROVIDER_SID%TYPE := FDMS_GETTERS.getProviderSid(p_provider_id);
   BEGIN
      IF CORE_GETTERS.isCurrentStorage(FDMS_GETTERS.APP_ID, l_round_sid, l_storage_sid) = 0 THEN
         o_res := -3;
         RETURN;
      END IF;

      SELECT TCE_MATRIX_SID
        INTO o_res
        FROM FDMS_TCE_MATRICES
       WHERE PROVIDER_SID = l_provider_sid
         AND ROUND_SID = l_round_sid
         AND STORAGE_SID = l_storage_sid;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         INSERT INTO FDMS_TCE_MATRICES(PROVIDER_SID, ROUND_SID, STORAGE_SID)
              VALUES (l_provider_sid, l_round_sid, l_storage_sid)
           RETURNING TCE_MATRIX_SID
                INTO o_res;
   END setTceMatrix;

   ----------------------------------------------------------------------------
   -- @name setTceMatrixData
   ----------------------------------------------------------------------------
   PROCEDURE setTceMatrixData(p_matrix_sid    IN     NUMBER
                            , p_exp_cty_id    IN     VARCHAR2
                            , p_exp_line_nr   IN     NUMBER
                            , p_prnt_cty_ids  IN     CORE_COMMONS.VARCHARARRAY
                            , p_prnt_col_nbrs IN     CORE_COMMONS.SIDSARRAY
                            , p_values        IN     CORE_COMMONS.VARCHARARRAY
                            , o_res              OUT NUMBER)
   IS
   BEGIN
      o_res := p_prnt_cty_ids.COUNT;

      FOR i IN 1 .. p_prnt_cty_ids.COUNT LOOP
         UPDATE FDMS_TCE_MATRIX_DATA
            SET EXPORTER_LINE_INDEX = p_exp_line_nr
              , PARTNER_COL_INDEX   = p_prnt_col_nbrs(i)
              , VALUE               = p_values(i)
          WHERE TCE_MATRIX_SID = p_matrix_sid
            AND EXPORTER_CTY_ID = p_exp_cty_id
            AND PARTNER_CTY_ID = p_prnt_cty_ids(i);

         IF SQL%ROWCOUNT = 0 THEN
            INSERT INTO FDMS_TCE_MATRIX_DATA(TCE_MATRIX_SID
                                           , EXPORTER_LINE_INDEX
                                           , EXPORTER_CTY_ID
                                           , PARTNER_COL_INDEX
                                           , PARTNER_CTY_ID
                                           , VALUE)
                 VALUES (p_matrix_sid
                       , p_exp_line_nr
                       , p_exp_cty_id
                       , p_prnt_col_nbrs(i)
                       , p_prnt_cty_ids(i)
                       , p_values(i));
         END IF;
      END LOOP;
   END setTceMatrixData;

   ----------------------------------------------------------------------------
   -- @name getTceMatrixData
   ----------------------------------------------------------------------------
   PROCEDURE getTceMatrixData(o_cur            OUT SYS_REFCURSOR
                            , p_provider_id IN     VARCHAR2
                            , p_round_sid   IN     NUMBER DEFAULT NULL
                            , p_storage_sid IN     NUMBER DEFAULT NULL)
   IS
      l_round_sid    ROUNDS.ROUND_SID%TYPE := p_round_sid;
      l_storage_sid  STORAGES.STORAGE_SID%TYPE := p_storage_sid;
      l_provider_sid FDMS_PROVIDERS.PROVIDER_SID%TYPE := FDMS_GETTERS.getProviderSid(p_provider_id);
      l_user         FDMS_INDICATOR_DATA_UPLOADS.UPDATE_USER%TYPE;
      l_date         FDMS_INDICATOR_DATA_UPLOADS.UPDATE_DATE%TYPE;
   BEGIN
      IF p_round_sid IS NULL OR p_storage_sid IS NULL THEN
         l_round_sid   := CORE_GETTERS.getCurrentRoundSid(FDMS_GETTERS.APP_ID);
         l_storage_sid := FDMS_GETTERS.getCurrentStorageSid();

         FDMS_UPLOAD.getUploadInfo(l_user
                                 , l_date
                                 , l_round_sid
                                 , l_storage_sid
                                 , p_provider_id);

         IF l_date IS NULL THEN
            FDMS_UPLOAD.getLatestUploadInfo(l_user
                                          , l_date
                                          , l_round_sid
                                          , l_storage_sid
                                          , p_provider_id);
         END IF;
      END IF;

      OPEN o_cur FOR
         SELECT D.EXPORTER_CTY_ID, D.PARTNER_CTY_ID, D.VALUE
           FROM FDMS_TCE_MATRIX_DATA  D
                JOIN FDMS_TCE_MATRICES M ON D.TCE_MATRIX_SID = M.TCE_MATRIX_SID
          WHERE M.PROVIDER_SID = l_provider_sid
            AND M.ROUND_SID = l_round_sid
            AND M.STORAGE_SID = l_storage_sid;
   END getTceMatrixData;

   ----------------------------------------------------------------------------
   -- @name getTceResults
   ----------------------------------------------------------------------------
   PROCEDURE getTceResults(p_round_sid   IN     NUMBER
                         , p_storage_sid IN     NUMBER
                         , p_country_id  IN     VARCHAR2
                         , o_cur            OUT SYS_REFCURSOR)
   IS
      l_round_sid ROUNDS.ROUND_SID%TYPE
                     := CORE_GETTERS.currentOrPassedRound(p_round_sid, FDMS_GETTERS.APP_ID);
   BEGIN
      OPEN o_cur FOR
         SELECT INDICATOR_SID || '_' || DATA_TYPE AS KEY_ID
              , START_YEAR
              , TIMESERIE_DATA
           FROM VW_TCE_RESULTS
          WHERE EXPORTER_CTY_ID = p_country_id
            AND ROUND_SID = l_round_sid
            AND STORAGE_SID = p_storage_sid
            AND PROVIDER_ID = FDMS_TCE.TCE_RESULTS_PROVIDER_ID
            AND PERIODICITY_ID = 'A';
   END getTceResults;

   ----------------------------------------------------------------------------
   -- @name getTceReportDefinition
   ----------------------------------------------------------------------------
   PROCEDURE getTceReportDefinition(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR   SELECT DESCR
                            , ORDER_BY
                            , GN_INDICATOR_SID || '_' || GN_DATA_TYPE AS GN_KEY_ID
                            , SN_INDICATOR_SID || '_' || SN_DATA_TYPE AS SN_KEY_ID
                            , GS_INDICATOR_SID || '_' || GS_DATA_TYPE AS GS_KEY_ID
                         FROM FDMS_TCE_REPORT_DEFINITION
                     ORDER BY ORDER_BY;
   END getTceReportDefinition;

   ----------------------------------------------------------------------------
   -- @name setTceResults
   ----------------------------------------------------------------------------
   PROCEDURE setTceResults(o_res              OUT NUMBER
                         , p_country_id    IN     VARCHAR2
                         , p_indicator_ids IN     CORE_COMMONS.VARCHARARRAY
                         , p_data_types    IN     CORE_COMMONS.VARCHARARRAY
                         , p_start_year    IN     NUMBER
                         , p_time_series   IN     CORE_COMMONS.VARCHARARRAY
                         , p_user          IN     VARCHAR2
                         , p_round_sid     IN     NUMBER DEFAULT NULL
                         , p_storage_sid   IN     NUMBER DEFAULT NULL)
   IS
      l_tce_matrix_sid FDMS_TCE_MATRICES.TCE_MATRIX_SID%TYPE
                          := getTceResultsMatrixSid(p_round_sid, p_storage_sid);
   BEGIN
      IF l_tce_matrix_sid <= 0 THEN
         o_res := l_tce_matrix_sid;
         RETURN;
      END IF;

      o_res := p_indicator_ids.COUNT;

      FOR i IN 1 .. p_indicator_ids.COUNT LOOP
         UPDATE FDMS_TCE_RESULTS
            SET START_YEAR     = p_start_year
              , TIMESERIE_DATA = p_time_series(i)
              , UPDATE_DATE    = SYSDATE
              , UPDATE_USER    = p_user
          WHERE EXPORTER_CTY_ID = p_country_id
            AND TCE_MATRIX_SID = l_tce_matrix_sid
            AND INDICATOR_SID = FDMS_TCE.getTceReportIndicatorSid(p_indicator_ids(i))
            AND DATA_TYPE = p_data_types(i);

         IF SQL%ROWCOUNT = 0 THEN
            INSERT INTO FDMS_TCE_RESULTS(TCE_MATRIX_SID
                                       , EXPORTER_CTY_ID
                                       , INDICATOR_SID
                                       , DATA_TYPE
                                       , START_YEAR
                                       , TIMESERIE_DATA
                                       , UPDATE_USER)
                 VALUES (l_tce_matrix_sid
                       , p_country_id
                       , FDMS_TCE.getTceReportIndicatorSid(p_indicator_ids(i))
                       , p_data_types(i)
                       , p_start_year
                       , p_time_series(i)
                       , p_user);
         END IF;
      END LOOP;
   END setTceResults;

   ----------------------------------------------------------------------------
   -- @name getTceResultsCountries
   ----------------------------------------------------------------------------
   PROCEDURE getTceResultsCountries(p_round_sid   IN     NUMBER DEFAULT NULL
                                  , p_storage_sid IN     NUMBER DEFAULT NULL
                                  , o_cur            OUT SYS_REFCURSOR)
   IS
      l_round_sid ROUNDS.ROUND_SID%TYPE
                     := CORE_GETTERS.currentOrPassedRound(p_round_sid, FDMS_GETTERS.APP_ID);
   BEGIN
      OPEN o_cur FOR
           SELECT G.CODEISO3
                , G.GEO_AREA_ID AS COUNTRY_ID
                , G.CODE_FGD
                , G.DESCR
             FROM GEO_AREAS G
             JOIN COUNTRY_GROUPS CG ON CG.COUNTRY_ID = G.GEO_AREA_ID
             JOIN (SELECT DISTINCT R.EXPORTER_CTY_ID AS COUNTRY_ID
                     FROM FDMS_TCE_RESULTS R
                     JOIN FDMS_TCE_MATRICES M ON R.TCE_MATRIX_SID = M.TCE_MATRIX_SID
                     JOIN FDMS_PROVIDERS P ON M.PROVIDER_SID = P.PROVIDER_SID
                    WHERE (p_round_sid IS NULL OR M.ROUND_SID = l_round_sid)
                      AND (p_storage_sid IS NULL OR M.STORAGE_SID = p_storage_sid)
                      AND P.PROVIDER_ID = FDMS_TCE.TCE_RESULTS_PROVIDER_ID
                  ) RS ON RS.COUNTRY_ID = G.GEO_AREA_ID
            WHERE CG.COUNTRY_GROUP_ID = 'TCE'
         ORDER BY CG.ORDER_BY, G.ORDER_BY;
   END getTceResultsCountries;

   ----------------------------------------------------------------------------
   -- @name getTCEIndicatorData
   ----------------------------------------------------------------------------
   PROCEDURE getTCEIndicatorData(o_cur               OUT  SYS_REFCURSOR
                               , p_country_ids    IN      CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                         NULL AS CORE_COMMONS.VARCHARARRAY
                                                                       )
                               , p_indicator_ids  IN      CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                         NULL AS CORE_COMMONS.VARCHARARRAY
                                                                       )
                               , p_partner_ids    IN      CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                         NULL AS CORE_COMMONS.VARCHARARRAY
                                                                       )
                               , p_periodicity_id IN      VARCHAR2
                               , p_round_sid      IN      NUMBER DEFAULT NULL
                               , p_storage_sid    IN      NUMBER DEFAULT NULL
   )
   IS
      l_round_sid       ROUNDS.ROUND_SID%TYPE := CORE_GETTERS.currentOrPassedRound(p_round_sid);
      l_storage_sid     STORAGES.STORAGE_SID%TYPE := COALESCE(p_storage_sid, FDMS_GETTERS.getCurrentStorageSid());
      l_country_ids     VARCHARLIST := CORE_COMMONS.arrayToList(p_country_ids);
      l_country_count   NUMBER(3) := l_country_ids.COUNT;
      l_indicator_ids   VARCHARLIST := CORE_COMMONS.arrayToList(p_indicator_ids);
      l_indicator_count NUMBER(3) := l_indicator_ids.COUNT;
      l_partner_ids     VARCHARLIST := CORE_COMMONS.arrayToList(p_partner_ids);
      l_partner_count   NUMBER(3) := l_partner_ids.COUNT;
   BEGIN
     OPEN o_cur FOR
           SELECT EXPORTER_CTY_ID AS COUNTRY_ID
                , INDICATOR_ID
                , 'UNIT' AS SCALE_ID
                , START_YEAR
                , TIMESERIE_DATA
                , PERIODICITY_ID
                , COUNTRY_DESCR
                , 'UNIT' AS SCALE_DESCR
                , UPDATE_DATE
                , DATA_SOURCE
                , DATA_TYPE
             FROM VW_TCE_RESULTS
            WHERE PROVIDER_ID = FDMS_TCE.TCE_RESULTS_PROVIDER_ID
              AND ROUND_SID = l_round_sid
              AND STORAGE_SID = l_storage_sid
              AND PERIODICITY_ID = p_periodicity_id
              AND (l_country_count = 0 OR EXPORTER_CTY_ID IN (SELECT * FROM TABLE(l_country_ids)))
              AND (l_indicator_count = 0 OR INDICATOR_ID IN (SELECT * FROM TABLE(l_indicator_ids)))
              AND (l_partner_count = 0 OR DATA_TYPE IN (SELECT * FROM TABLE(l_partner_ids)))
         ORDER BY EXPORTER_CTY_ID, INDICATOR_ID;
   END getTCEIndicatorData;

   ----------------------------------------------------------------------------
   -- @name getTCETradeItemData
   ----------------------------------------------------------------------------
   PROCEDURE getTCETradeItemData(o_cur               OUT  SYS_REFCURSOR
                               , p_country_ids    IN      CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                         NULL AS CORE_COMMONS.VARCHARARRAY
                                                                       )
                               , p_tradeItem_ids  IN      CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                         NULL AS CORE_COMMONS.VARCHARARRAY
                                                                       )
                               , p_periodicity_id IN      VARCHAR2
                               , p_round_sid      IN      NUMBER DEFAULT NULL
                               , p_storage_sid    IN      NUMBER DEFAULT NULL
   )
   IS
      l_round_sid       ROUNDS.ROUND_SID%TYPE := CORE_GETTERS.currentOrPassedRound(p_round_sid);
      l_storage_sid     STORAGES.STORAGE_SID%TYPE := COALESCE(p_storage_sid, FDMS_GETTERS.getCurrentStorageSid());
      l_country_ids     VARCHARLIST := CORE_COMMONS.arrayToList(p_country_ids);
      l_country_count   NUMBER(3) := l_country_ids.COUNT;
      l_tradeItem_ids   VARCHARLIST := CORE_COMMONS.arrayToList(p_tradeItem_ids);
      l_tradeItem_count NUMBER(3) := l_tradeItem_ids.COUNT;
   BEGIN
     OPEN o_cur FOR
           SELECT EXPORTER_CTY_ID AS COUNTRY_ID
                , INDICATOR_ID
                , 'UNIT' AS SCALE_ID
                , START_YEAR
                , TIMESERIE_DATA
                , PERIODICITY_ID
                , COUNTRY_DESCR
                , 'UNIT' AS SCALE_DESCR
                , UPDATE_DATE
                , DATA_SOURCE
                , DATA_TYPE
             FROM VW_TCE_RESULTS
            WHERE PROVIDER_ID = FDMS_TCE.TCE_RESULTS_PROVIDER_ID
              AND ROUND_SID = l_round_sid
              AND STORAGE_SID = l_storage_sid
              AND PERIODICITY_ID = p_periodicity_id
              AND (l_country_count = 0 OR EXPORTER_CTY_ID IN (SELECT * FROM TABLE(l_country_ids)))
              AND (l_tradeItem_count = 0 OR (INDICATOR_ID || '.' || DATA_TYPE) IN (SELECT * FROM TABLE(l_tradeItem_ids)))
         ORDER BY EXPORTER_CTY_ID, INDICATOR_ID;
   END getTCETradeItemData;

   ----------------------------------------------------------------------------
   -- @name getTcePartners
   ----------------------------------------------------------------------------
   PROCEDURE getTcePartners(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
     OPEN o_cur FOR
           SELECT PARTNER_ID AS "code"
                , DESCR      AS "descr"
             FROM FDMS_TCE_PARTNERS
         ORDER BY DESCR ASC;
   END getTcePartners;

   ----------------------------------------------------------------------------
   -- @name getTceTradeItems
   ----------------------------------------------------------------------------
   PROCEDURE getTceTradeItems(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
     OPEN o_cur FOR
           SELECT D.DESCR
                , (SELECT V.INDICATOR_ID FROM VW_FDMS_INDICATORS V WHERE V.INDICATOR_SID = D.GN_INDICATOR_SID) AS GN_INDICATOR_ID
                , D.GN_DATA_TYPE
                , (SELECT V.INDICATOR_ID FROM VW_FDMS_INDICATORS V WHERE V.INDICATOR_SID = D.SN_INDICATOR_SID) AS SN_INDICATOR_ID
                , D.SN_DATA_TYPE
                , (SELECT V.INDICATOR_ID FROM VW_FDMS_INDICATORS V WHERE V.INDICATOR_SID = D.GS_INDICATOR_SID) AS GS_INDICATOR_ID
                , D.GS_DATA_TYPE
             FROM FDMS_TCE_REPORT_DEFINITION D
            WHERE D.IS_SEARCHABLE = 1
         ORDER BY D.ORDER_BY;
   END getTceTradeItems;

END FDMS_TCE;
