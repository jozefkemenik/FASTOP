/* Formatted on 12-05-2020 13:47:18 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY DFM_APP_STATUS
AS
   /**************************************************************************
    * NAME:      DFM_APP_STATUS
    * PURPOSE:   DFM Application status setting functionality
    **************************************************************************/

   /**************************************************************************
    ************* PRIVATE ****************************************************
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name archiveMeasuresToCustomStorage
   -- @return number of measures archived or -1 if invalid params
   ----------------------------------------------------------------------------
   PROCEDURE archiveMeasuresToCustomStorage(
      p_round_sid     IN     NUMBER
    , p_storage_sid   IN     NUMBER
    , p_cust_text_sid IN     NUMBER
    , p_country_ids   IN     CORE_COMMONS.VARCHARARRAY
    , p_user          IN     VARCHAR2
    , o_res              OUT NUMBER
   )
   IS
      l_app_status_id ST_STATUS_REPO.STATUS_ID%TYPE := NULL;
      l_res           NUMBER(8);
   BEGIN
      -- Check if app status is not CLOSED
      CORE_GETTERS.getApplicationStatus(DFM_GETTERS.APP_ID, l_app_status_id);

      IF l_app_status_id = 'CLOSED' THEN
         o_res := -1;
      ELSE
         o_res := 0;

         FOR i IN 1 .. p_country_ids.COUNT LOOP
            DFM_COUNTRY_STATUS.archiveCountryMeasures(p_round_sid
                                                    , p_storage_sid
                                                    , p_cust_text_sid
                                                    , p_country_ids(i)
                                                    , p_user
                                                    , l_res);
            o_res := o_res + l_res;
         END LOOP;
      END IF;
   END archiveMeasuresToCustomStorage;

   /**************************************************************************
    ************* PUBLIC *****************************************************
    **************************************************************************/

   PROCEDURE setApplicationOpen(o_res OUT NUMBER)
   IS
   BEGIN
      CORE_APP_STATUS.setApplicationOpen(DFM_GETTERS.APP_ID, o_res);
   END setApplicationOpen;

   PROCEDURE setApplicationClosed(o_res OUT NUMBER)
   IS
   BEGIN
      CORE_APP_STATUS.setApplicationStatus(DFM_GETTERS.APP_ID
                                         , 'TR_PUBLISH'
                                         , 'CLOSED'
                                         , o_res);
   END setApplicationClosed;

   PROCEDURE setApplicationArchived(o_res OUT NUMBER)
   IS
   BEGIN
      CORE_APP_STATUS.setApplicationStatus(DFM_GETTERS.APP_ID, 'OPEN', 'ARCHIVE', o_res);
   END setApplicationArchived;

   PROCEDURE setApplicationTROpen(o_res OUT NUMBER)
   IS
   BEGIN
      CORE_APP_STATUS.setApplicationStatus(DFM_GETTERS.APP_ID, 'ARCHIVE', 'TR_OPEN', o_res);
   END setApplicationTROpen;

   PROCEDURE setApplicationTRPublish(p_round_sid     IN     NUMBER
                                   , p_storage_sid   IN     NUMBER
                                   , p_cust_text_sid IN     NUMBER
                                   , o_res              OUT NUMBER)
   IS
      l_app_sid               NUMBER := DFM_GETTERS.getCurrentAppSid();
      l_tr_publish_status_sid NUMBER := CORE_GETTERS.getStatusSid('TR_PUBLISH');
      l_tr_open_status_sid    NUMBER := CORE_GETTERS.getStatusSid('TR_OPEN');
   BEGIN
      o_res := -1;

      IF l_tr_publish_status_sid IS NOT NULL
     AND l_tr_open_status_sid IS NOT NULL
     AND DFM_GETTERS.isCurrentStorage(p_round_sid, p_storage_sid, p_cust_text_sid) > 0
     AND DFM_GETTERS.isCurrentStorageFinal() > 0 THEN
         UPDATE applications
            SET status_sid = l_tr_publish_status_sid, status_date = SYSTIMESTAMP
          WHERE app_sid = l_app_sid AND status_sid = l_tr_open_status_sid;

         o_res := SQL%ROWCOUNT;
      END IF;
   END setApplicationTRPublish;

   ----------------------------------------------------------------------------
   -- @name archiveMeasures
   -- @return number of measures archived or -1 if invalid params
   ----------------------------------------------------------------------------
   PROCEDURE archiveMeasures(p_round_sid     IN     NUMBER
                           , p_storage_sid   IN     NUMBER
                           , p_cust_text_sid IN     NUMBER
                           , p_country_ids   IN     CORE_COMMONS.VARCHARARRAY
                           , p_user          IN     VARCHAR2
                           , o_res              OUT NUMBER)
   IS
      l_cur           SYS_REFCURSOR;
      l_res           NUMBER(8);
      l_country       COUNTRIES%ROWTYPE;
      l_app_status_id ST_STATUS_REPO.STATUS_ID%TYPE := NULL;
      l_is_custom     STORAGES.IS_CUSTOM%TYPE;
   BEGIN
      SELECT IS_CUSTOM
        INTO l_is_custom
        FROM STORAGES
       WHERE STORAGE_SID = p_storage_sid;

      IF l_is_custom = 'Y' THEN
         archiveMeasuresToCustomStorage(p_round_sid
                                      , p_storage_sid
                                      , p_cust_text_sid
                                      , p_country_ids
                                      , p_user
                                      , o_res);
      ELSE
         -- Check if app status is OPEN
         CORE_GETTERS.getApplicationStatus(DFM_GETTERS.APP_ID, l_app_status_id);

         -- Check if passed in parameters correspond to the current storage
         IF l_app_status_id != 'OPEN'
         OR DFM_GETTERS.isCurrentStorage(p_round_sid, p_storage_sid, p_cust_text_sid) = 0 THEN
            o_res := -1;
         ELSE
            CORE_GETTERS.GETCOUNTRIES(l_cur, DFM_GETTERS.APP_ID);
            o_res := 0;

            LOOP
               FETCH l_cur INTO l_country;

               EXIT WHEN l_cur%NOTFOUND;
               DFM_COUNTRY_STATUS.archiveCountryMeasures(p_round_sid
                                                       , p_storage_sid
                                                       , p_cust_text_sid
                                                       , l_country.country_id
                                                       , p_user
                                                       , l_res);
               o_res := o_res + l_res;
            END LOOP;

            -- If current storage is FINAL then set application state to 'ARCHIVE'
            IF DFM_GETTERS.isCurrentStorageFinal() = 1 THEN
               DFM_APP_STATUS.setApplicationArchived(l_res);
            END IF;
         END IF;
      END IF;
   END archiveMeasures;

   ----------------------------------------------------------------------------
   -- @name createCustomStorage
   -- @return number of measures archived or -1 if invalid params
   ----------------------------------------------------------------------------
   PROCEDURE createCustomStorage(p_round_sid IN     NUMBER
                               , p_title     IN     VARCHAR2
                               , p_descr     IN     VARCHAR2
                               , o_res          OUT NUMBER)
   IS
   BEGIN
      IF CORE_COMMONS.ISCURRENTROUND(p_round_sid, DFM_GETTERS.APP_ID) = 0 THEN
         o_res := -1;
      ELSE
         INSERT INTO CUST_STORAGE_TEXTS(ROUND_SID, TITLE, DESCR)
              VALUES (p_round_sid, p_title, p_descr)
           RETURNING CUST_STORAGE_TEXT_SID
                INTO o_res;
      END IF;
   END createCustomStorage;
END DFM_APP_STATUS;
/