/* Formatted on 21-01-2021 15:38:28 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY FDMS_UPLOAD
AS
   /**************************************************************************
    *********************** PRIVATE SECTION **********************************
    **************************************************************************/

   /**************************************************************************
    *********************** PUBLIC SECTION ***********************************
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name getUploadInfo
   ----------------------------------------------------------------------------
   PROCEDURE getUploadInfo(o_user           OUT VARCHAR2
                         , o_date           OUT DATE
                         , p_round_sid   IN     NUMBER
                         , p_storage_sid IN     NUMBER
                         , p_provider_id IN     VARCHAR2
                         , p_country_id  IN     VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      SELECT U.UPDATE_USER, U.UPDATE_DATE
        INTO o_user, o_date
        FROM FDMS_PROVIDERS  P
             LEFT JOIN FDMS_INDICATOR_DATA_UPLOADS U
                ON U.PROVIDER_SID = P.PROVIDER_SID
               AND U.ROUND_SID = p_round_sid
               AND U.STORAGE_SID = p_storage_sid
               AND (U.COUNTRY_ID IS NULL OR U.COUNTRY_ID = p_country_id)
       WHERE P.PROVIDER_ID = p_provider_id;
   END getUploadInfo;

   ----------------------------------------------------------------------------
   -- @name getLatestUploadInfo
   ----------------------------------------------------------------------------
   PROCEDURE getLatestUploadInfo(o_user           OUT VARCHAR2
                               , o_date           OUT DATE
                               , o_round_sid      OUT NUMBER
                               , o_storage_sid    OUT NUMBER
                               , p_provider_id IN     VARCHAR2
                               , p_country_id  IN     VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      SELECT UPDATE_USER, UPDATE_DATE, ROUND_SID, STORAGE_SID
        INTO o_user, o_date, o_round_sid, o_storage_sid
        FROM (SELECT RANK() OVER (ORDER BY U.UPDATE_DATE DESC) BY_DATE_DESC, U.*
                FROM FDMS_INDICATOR_DATA_UPLOADS  U
                     JOIN FDMS_PROVIDERS P
                        ON P.PROVIDER_SID = U.PROVIDER_SID
                       AND (U.COUNTRY_ID IS NULL OR U.COUNTRY_ID = p_country_id)
               WHERE P.PROVIDER_ID = p_provider_id)
       WHERE BY_DATE_DESC = 1;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
   END getLatestUploadInfo;

   ----------------------------------------------------------------------------
   -- @name getCountryUploadsInfo
   ----------------------------------------------------------------------------
   PROCEDURE getCountryUploadsInfo(
      o_cur            OUT SYS_REFCURSOR
    , p_app_id      IN     VARCHAR2 DEFAULT FDMS_GETTERS.APP_ID
    , p_country_ids IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                NULL AS CORE_COMMONS.VARCHARARRAY
                                                             )
    , p_round_sid   IN     NUMBER DEFAULT NULL
    , p_storage_sid IN     NUMBER DEFAULT NULL
   )
   IS
      l_round_sid     ROUNDS.ROUND_SID%TYPE := CORE_GETTERS.currentOrPassedRound(p_round_sid, p_app_id);
      l_storage_sid   STORAGES.STORAGE_SID%TYPE
                         := COALESCE(p_storage_sid, CORE_GETTERS.getCurrentStorageSid(p_app_id));

      l_country_ids   VARCHARLIST := CORE_COMMONS.arrayToList(p_country_ids);
      l_country_count NUMBER(3) := l_country_ids.COUNT;
   BEGIN
      OPEN o_cur FOR
         SELECT U.COUNTRY_ID, U.UPDATE_DATE
           FROM FDMS_INDICATOR_DATA_UPLOADS  U
                JOIN FDMS_PROVIDERS P ON U.PROVIDER_SID = P.PROVIDER_SID
          WHERE U.ROUND_SID = l_round_sid
            AND U.STORAGE_SID = l_storage_sid
            AND P.IS_COUNTRY_UPLOAD = 1
            AND (l_country_count = 0 OR U.COUNTRY_ID IN (SELECT * FROM TABLE(l_country_ids)));
   END getCountryUploadsInfo;

   ----------------------------------------------------------------------------
   -- @name getIndicatorDataUploads
   ----------------------------------------------------------------------------
   PROCEDURE getIndicatorDataUploads(p_round_sid   IN     NUMBER
                                   , p_storage_sid IN     NUMBER
                                   , o_cur            OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT P.DESCR                               AS "providerDescr"
                , P.PROVIDER_ID                         AS "providerId"
                , COALESCE(U.UPDATE_DATE, U2.UPDATE_DATE) AS "lastUpdated"
                , COALESCE(U.UPDATE_USER, U2.UPDATE_USER) AS "updatedBy"
             FROM FDMS_PROVIDERS P
                  LEFT JOIN FDMS_INDICATOR_DATA_UPLOADS U
                     ON U.PROVIDER_SID = P.PROVIDER_SID
                    AND U.ROUND_SID = p_round_sid
                    AND U.STORAGE_SID = p_storage_sid
                  LEFT JOIN
                  (
                     WITH
                        RANKED
                        AS
                           (SELECT UPL.*
                                 , RANK()
                                   OVER(PARTITION BY UPL.PROVIDER_SID ORDER BY UPL.UPDATE_DATE DESC)
                                      STORAGE_RANK
                              FROM FDMS_INDICATOR_DATA_UPLOADS UPL
                                   JOIN FDMS_PROVIDERS PVD ON PVD.PROVIDER_SID = UPL.PROVIDER_SID
                             WHERE PVD.USE_LATEST_DATA = 1)
                     SELECT PROVIDER_SID, UPDATE_DATE, UPDATE_USER
                       FROM RANKED
                      WHERE STORAGE_RANK = 1
                  ) U2
                     ON U2.PROVIDER_SID = P.PROVIDER_SID
            WHERE P.IS_COUNTRY_UPLOAD = 0 AND P.IS_INPUT_DATA_UPLOAD = 1
         ORDER BY P.DESCR;
   END getIndicatorDataUploads;

   ----------------------------------------------------------------------------
   -- @name setIndicatorDataUpload
   ----------------------------------------------------------------------------
   PROCEDURE setIndicatorDataUpload(p_round_sid   IN     NUMBER
                                  , p_storage_sid IN     NUMBER
                                  , p_provider_id IN     VARCHAR2
                                  , p_user        IN     VARCHAR
                                  , o_res            OUT NUMBER
                                  , p_country_id  IN     VARCHAR2 DEFAULT NULL)
   IS
      l_provider_sid               FDMS_PROVIDERS.PROVIDER_SID%TYPE;
      l_provider_is_country_upload FDMS_PROVIDERS.IS_COUNTRY_UPLOAD%TYPE;
   BEGIN
      SELECT PROVIDER_SID, IS_COUNTRY_UPLOAD
        INTO l_provider_sid, l_provider_is_country_upload
        FROM FDMS_PROVIDERS
       WHERE PROVIDER_ID = p_provider_id;

      IF (l_provider_is_country_upload = 1 AND p_country_id IS NULL)
      OR (l_provider_is_country_upload = 0 AND p_country_id IS NOT NULL) THEN
         o_res := -2;
         RETURN;
      END IF;

      UPDATE FDMS_INDICATOR_DATA_UPLOADS
         SET UPDATE_DATE = SYSDATE, UPDATE_USER = p_user
       WHERE ROUND_SID = p_round_sid
         AND STORAGE_SID = p_storage_sid
         AND PROVIDER_SID = l_provider_sid
         AND (p_country_id IS NULL OR COUNTRY_ID = p_country_id);

      IF SQL%ROWCOUNT = 0 THEN
         INSERT INTO FDMS_INDICATOR_DATA_UPLOADS(ROUND_SID
                                               , STORAGE_SID
                                               , PROVIDER_SID
                                               , COUNTRY_ID
                                               , UPDATE_DATE
                                               , UPDATE_USER)
              VALUES (p_round_sid
                    , p_storage_sid
                    , l_provider_sid
                    , p_country_id
                    , SYSDATE
                    , p_user);
      END IF;

      IF l_provider_is_country_upload = 1 THEN
         -- Clear previously run tasks information
         DELETE FROM TASK_COUNTRIES
               WHERE COUNTRY_ID = p_country_id
                 AND ROUND_SID = p_round_sid
                 AND STORAGE_SID = p_storage_sid;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         o_res := -1;
   END setIndicatorDataUpload;

   ----------------------------------------------------------------------------
   -- @name getDeskUpload
   ----------------------------------------------------------------------------
   PROCEDURE getDeskUpload(o_user             OUT VARCHAR2
                         , o_date             OUT DATE
                         , o_cur_annual       OUT SYS_REFCURSOR
                         , o_cur_quarterly    OUT SYS_REFCURSOR
                         , p_country_id    IN     VARCHAR2
                         , p_send_data     IN     NUMBER
                         , p_round_sid     IN     NUMBER DEFAULT NULL
                         , p_storage_sid   IN     NUMBER DEFAULT NULL)
   IS
      l_round_sid     ROUNDS.ROUND_SID%TYPE := CORE_GETTERS.currentOrPassedRound(p_round_sid);
      l_storage_sid   STORAGES.STORAGE_SID%TYPE
                         := COALESCE(p_storage_sid, FDMS_GETTERS.getCurrentStorageSid());
      l_country_ids   CORE_COMMONS.VARCHARARRAY;
      l_provider_ids  CORE_COMMONS.VARCHARARRAY;
      l_indicator_ids CORE_COMMONS.VARCHARARRAY;
   BEGIN
      FDMS_UPLOAD.getUploadInfo(o_user
                              , o_date
                              , l_round_sid
                              , l_storage_sid
                              , 'DESK'
                              , p_country_id);

      IF p_send_data = 1 THEN
         l_country_ids(1)  := p_country_id;
         l_provider_ids(1) := 'DESK';

         FDMS_INDICATOR.getProvidersIndicatorData(o_cur_annual
                                                , l_provider_ids
                                                , l_country_ids
                                                , l_indicator_ids
                                                , NULL
                                                , 'A'
                                                , l_round_sid
                                                , l_storage_sid);

         FDMS_INDICATOR.getProvidersIndicatorData(o_cur_quarterly
                                                , l_provider_ids
                                                , l_country_ids
                                                , l_indicator_ids
                                                , NULL
                                                , 'Q'
                                                , l_round_sid
                                                , l_storage_sid);
      ELSE
         CORE_COMMONS.getEmptyCursor(o_cur_annual);
         CORE_COMMONS.getEmptyCursor(o_cur_quarterly);
      END IF;
   END getDeskUpload;

   ----------------------------------------------------------------------------
   -- @name getProviderUpload
   ----------------------------------------------------------------------------
   PROCEDURE getProviderUpload(o_user           OUT VARCHAR2
                             , o_date           OUT DATE
                             , o_cur            OUT SYS_REFCURSOR
                             , p_provider_id IN     VARCHAR2
                             , p_periodicity IN     VARCHAR2
                             , p_send_data   IN     NUMBER
                             , p_round_sid   IN     NUMBER DEFAULT NULL
                             , p_storage_sid IN     NUMBER DEFAULT NULL)
   IS
      l_round_sid     ROUNDS.ROUND_SID%TYPE := CORE_GETTERS.currentOrPassedRound(p_round_sid);
      l_storage_sid   STORAGES.STORAGE_SID%TYPE
                         := COALESCE(p_storage_sid, FDMS_GETTERS.getCurrentStorageSid());
      l_provider_ids  CORE_COMMONS.VARCHARARRAY;
      l_indicator_ids CORE_COMMONS.VARCHARARRAY;
      l_country_ids   CORE_COMMONS.VARCHARARRAY;
   BEGIN
      FDMS_UPLOAD.getUploadInfo(o_user
                              , o_date
                              , l_round_sid
                              , l_storage_sid
                              , p_provider_id);

      IF p_send_data = 1 THEN
         l_provider_ids(1) := p_provider_id;

         FDMS_INDICATOR.getProvidersIndicatorData(o_cur
                                                , l_provider_ids
                                                , l_country_ids
                                                , l_indicator_ids
                                                , NULL
                                                , p_periodicity
                                                , l_round_sid
                                                , l_storage_sid);
      ELSE
         CORE_COMMONS.getEmptyCursor(o_cur);
      END IF;
   END getProviderUpload;

   ----------------------------------------------------------------------------
   -- @name uploadFile
   ----------------------------------------------------------------------------
   PROCEDURE uploadFile(o_res               OUT NUMBER
                      , p_app_id        IN      VARCHAR2
                      , p_round_sid     IN      NUMBER
                      , p_storage_sid   IN      NUMBER
                      , p_cust_text_sid IN      NUMBER
                      , p_country_id    IN      VARCHAR2
                      , p_provider_id   IN      VARCHAR2
                      , p_file_name     IN      VARCHAR2
                      , p_content_type  IN      VARCHAR2
                      , p_content       IN      BLOB
                      , p_user          IN      VARCHAR)
   IS
      l_provider_sid       FDMS_PROVIDERS.PROVIDER_SID%TYPE;
      l_app_sid            NUMBER := CORE_GETTERS.getApplicationSid (p_app_id);
   BEGIN
      SELECT P.PROVIDER_SID
        INTO l_provider_sid
        FROM FDMS_PROVIDERS P
       WHERE P.PROVIDER_ID = p_provider_id;

      DELETE
        FROM FDMS_UPLOAD_FILES
       WHERE APP_SID = l_app_sid
         AND ROUND_SID = p_round_sid
         AND STORAGE_SID = p_storage_sid
         AND (p_cust_text_sid IS NULL OR CUST_TEXT_SID = p_cust_text_sid)
         AND (p_country_id IS NULL OR COUNTRY_ID = p_country_id)
         AND PROVIDER_SID = l_provider_sid;
      INSERT
        INTO FDMS_UPLOAD_FILES ( APP_SID
                               , ROUND_SID
                               , STORAGE_SID
                               , CUST_TEXT_SID
                               , COUNTRY_ID
                               , PROVIDER_SID
                               , FILE_NAME
                               , CONTENT_TYPE
                               , CONTENT
                               , LAST_CHANGE_USER)
      VALUES ( l_app_sid
             , p_round_sid
             , p_storage_sid
             , p_cust_text_sid
             , p_country_id
             , l_provider_sid
             , p_file_name
             , p_content_type
             , p_content
             , p_user)
   RETURNING FILE_SID
        INTO o_res;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         o_res := -1;
   END uploadFile;

   ----------------------------------------------------------------------------
   -- @name getFiles
   ----------------------------------------------------------------------------
   PROCEDURE getFiles(o_cur               OUT SYS_REFCURSOR
                    , p_app_id        IN      VARCHAR2
                    , p_round_sid     IN      NUMBER
                    , p_storage_sid   IN      NUMBER
                    , p_cust_text_sid IN      NUMBER)
   IS
      l_app_sid            NUMBER := CORE_GETTERS.getApplicationSid (p_app_id);
   BEGIN
      OPEN o_cur FOR
         SELECT U.FILE_SID         AS "fileSid"
              , U.FILE_NAME        AS "fileName"
              , G.DESCR            AS "country"
              , U.LAST_CHANGE_DATE AS "changeDate"
              , U.LAST_CHANGE_USER AS "changeUser"
              , P.DESCR            AS "providerName"
           FROM FDMS_UPLOAD_FILES U
           JOIN FDMS_PROVIDERS P
             ON U.PROVIDER_SID = P.PROVIDER_SID
LEFT OUTER JOIN GEO_AREAS G
             ON G.GEO_AREA_ID = U.COUNTRY_ID
          WHERE U.APP_SID = l_app_sid
            AND U.ROUND_SID = p_round_sid
            AND U.STORAGE_SID = p_storage_sid
            AND (p_cust_text_sid IS NULL OR U.CUST_TEXT_SID = p_cust_text_sid);
   END getFiles;

   ----------------------------------------------------------------------------
   -- @name downloadFile
   ----------------------------------------------------------------------------
   PROCEDURE downloadFile(o_cur         OUT SYS_REFCURSOR
                        , p_file_sid IN     NUMBER)
   IS
   BEGIN
      OPEN o_cur FOR
         SELECT FILE_NAME    AS "fileName"
              , CONTENT      AS "content"
              , CONTENT_TYPE AS "contentType"
           FROM FDMS_UPLOAD_FILES
          WHERE FILE_SID = p_file_sid;
   END downloadFile;

   ----------------------------------------------------------------------------
   -- @name removeOldFiles
   ----------------------------------------------------------------------------
   PROCEDURE removeOldFiles(p_round_sid   IN  NUMBER)
   IS
   BEGIN
      DELETE
        FROM FDMS_UPLOAD_FILES
       WHERE ROUND_SID = p_round_sid
         AND STORAGE_SID IN
             (SELECT STORAGE_SID
                FROM STORAGES
               WHERE IS_PERMANENT IS NULL OR IS_PERMANENT = 'N');
   END removeOldFiles;

   ----------------------------------------------------------------------------
   -- @name getEerData
   ----------------------------------------------------------------------------
   PROCEDURE getEerData(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
                 SELECT PERIODICITY_ID as "periodicityId"
                , (select indicator_sid from vw_fdms_indicators where provider_id = 'ERATES' and indicator_id = 'XUNNQ.3.0.30.442') as "indicatorSid"
                , (select scale_sid from fdms_scales where scale_id = 'UNIT') as "scaleSid"
                , (select descr from fdms_scales where scale_id = 'UNIT') as "seriesUnit"
                ,'XUNNQ.3.0.30.442' as "code"
                , COUNTRY_ID as "countryId"
                , START_YEAR as "startYear"
                , TIMESERIE_DATA as "timeserieData"
            FROM VW_EER_INDICATORS_DATA
           WHERE PROVIDER_ID = 'NEER'
             AND GEO_GROUP_ID = 'GR42'
             AND PERIODICITY_ID = 'A'             
         union all             
           --- 3.0.30.442.XUNRQ  
           SELECT PERIODICITY_ID as "periodicityId"
                , (select indicator_sid from vw_fdms_indicators where provider_id = 'ERATES' and indicator_id = 'XUNRQ.3.0.30.442') as "indicatorSid"
                , (select scale_sid from fdms_scales where scale_id = 'UNIT') as "scaleSid"
                , (select descr from fdms_scales where scale_id = 'UNIT') as "seriesUnit"
                , 'XUNRQ.3.0.30.442' as "code"
                , COUNTRY_ID as "countryId"
                , START_YEAR as "startYear"
                , TIMESERIE_DATA as "timeserieData"
            FROM VW_EER_INDICATORS_DATA
           WHERE PROVIDER_ID = 'REER_GDP'
             AND GEO_GROUP_ID = 'GR42'
             AND PERIODICITY_ID = 'A'; 
   END getEerData;

END FDMS_UPLOAD;
/
