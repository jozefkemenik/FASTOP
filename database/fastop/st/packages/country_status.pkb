/* Formatted on 18/11/2021 16:26:57 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY ST_COUNTRY_STATUS
AS
   /**************************************************************************
    ************* PRIVATE SECTION ********************************************
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name getStatusSidById
   ----------------------------------------------------------------------------
   FUNCTION getStatusSidById(p_status_id IN VARCHAR2)
      RETURN NUMBER
   IS
      l_status_sid ST_STATUS_REPO.STATUS_SID%TYPE;
   BEGIN
      SELECT STATUS_SID
        INTO l_status_sid
        FROM ST_STATUS_REPO
       WHERE STATUS_ID = p_status_id;

      RETURN l_status_sid;
   END getStatusSidById;

   /**************************************************************************
    ************* PUBLIC SECTION *********************************************
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name getActions
   ----------------------------------------------------------------------------
   PROCEDURE getActions(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR   SELECT A.ACTION_SID, A.ACTION_ID, A.DESCR
                         FROM ST_ACTIONS A
                     ORDER BY A.ACTION_SID;
   END getActions;

   ----------------------------------------------------------------------------
   -- @name getCtyStatusChanges
   ----------------------------------------------------------------------------
   PROCEDURE getCtyStatusChanges(o_cur            OUT SYS_REFCURSOR
                               , p_country_ids IN     CORE_COMMONS.VARCHARARRAY
                               , p_round_sid   IN     NUMBER)
   IS
      l_cty_count NUMBER(3) := p_country_ids.COUNT;
      l_countries VARCHARLIST := CORE_COMMONS.arrayToList(p_country_ids);
   BEGIN
      OPEN o_cur FOR
         SELECT SC.COUNTRY_ID           "countryId"
              , SC.FIRST_INPUT_DATE     "firstInputDate"
              , SC.LAST_INPUT_DATE      "lastInputDate"
              , SC.LAST_SUBMIT_DATE     "submitionDate"
              , SC.LAST_VALIDATION_DATE "validationDate"
              , SC.OUTPUT_GAP_DATE      "outputGapDate"
              , SC.LAST_ARCHIVING_DATE  "archiveDate"
           FROM st_cty_status_changes SC
          WHERE SC.ROUND_SID = p_round_sid
            AND (l_cty_count = 0 OR SC.COUNTRY_ID IN (SELECT * FROM TABLE(l_countries)));
   END getCtyStatusChanges;

   ----------------------------------------------------------------------------
   -- @name getCountryStatuses
   -- @return country statuses for the app countries and for the round and storage
   ----------------------------------------------------------------------------
   PROCEDURE getCountryStatuses(o_cur              OUT SYS_REFCURSOR
                              , p_app_id        IN     VARCHAR2
                              , p_country_ids   IN     CORE_COMMONS.VARCHARARRAY
                              , p_round_sid     IN     NUMBER
                              , p_storage_sid   IN     NUMBER DEFAULT NULL
                              , p_cust_text_sid IN     NUMBER DEFAULT NULL)
   IS
      l_cty_count   NUMBER(3) := p_country_ids.COUNT;
      l_country_ids VARCHARLIST := CORE_COMMONS.arrayToList(p_country_ids);
   BEGIN
      IF l_cty_count > 0 THEN
         OPEN o_cur FOR
              SELECT GA.GEO_AREA_ID                       "countryId"
                   , GA.DESCR                             "countryDescr"
                   , S1.LAST_CHANGE_DATE                  "lastChangeDate"
                   , S1.UPDATE_USER                       "lastChangeUser"
                   , COALESCE(S1.STATUS_SID, S2.STATUS_SID) "statusSid"
                   , COALESCE(S1.STATUS_ID, S2.STATUS_ID) "statusId"
                   , COALESCE(S1.APP_DESCR, S2.APP_DESCR) "statusDescr"
                   , COALESCE(S1.TR_DESCR, S2.TR_DESCR)   "statusTrDescr"
                FROM applications A
                     JOIN geo_areas GA
                        ON GA.GEO_AREA_ID IN (SELECT * FROM TABLE(l_country_ids))
                       AND A.APP_ID = p_app_id
                     JOIN st_status_repo S2 ON S2.STATUS_ID = 'ACTIVE'
                     JOIN COUNTRY_GROUPS CG
                        ON CG.COUNTRY_GROUP_ID = COALESCE(A.COUNTRY_GROUP_ID, 'EU')
                       AND GA.GEO_AREA_ID = CG.COUNTRY_ID
                     LEFT JOIN
                     (SELECT CS.*, S.STATUS_ID, S.APP_DESCR, S.TR_DESCR
                        FROM st_cty_status_curr CS
                             JOIN st_status_repo S ON S.STATUS_SID = CS.STATUS_SID
                       WHERE CS.ROUND_SID = p_round_sid
                         AND (p_storage_sid IS NULL OR CS.STORAGE_SID = p_storage_sid)
                         AND (p_cust_text_sid IS NULL OR CS.CUST_TEXT_SID = p_cust_text_sid)) S1
                        ON S1.COUNTRY_ID = GA.GEO_AREA_ID AND S1.APP_SID = A.APP_SID
            ORDER BY CG.ORDER_BY, GA.ORDER_BY;
      ELSE
         OPEN o_cur FOR   SELECT CTY.COUNTRY_ID    "countryId"
                               , CTY.DESCR         "countryDescr"
                               , RS.LAST_CHANGE_DATE "lastChangeDate"
                               , RS.UPDATE_USER    "lastChangeUser"
                               , RS.STATUS_SID     "statusSid"
                               , RS.STATUS_ID      "statusId"
                               , RS.APP_DESCR      "statusDescr"
                               , RS.TR_DESCR       "statusTrDescr"
                            FROM COUNTRIES CTY
                                 JOIN COUNTRY_GROUPS CG
                                    ON CG.COUNTRY_GROUP_ID = (SELECT COALESCE(COUNTRY_GROUP_ID, 'EU')
                                                                FROM APPLICATIONS
                                                               WHERE APP_ID = p_app_id)
                                   AND CTY.COUNTRY_ID = CG.COUNTRY_ID
                                   AND CG.IS_ACTIVE = 1
                                 LEFT JOIN
                                 (                                          -- countries with status
                                  SELECT CS.COUNTRY_ID
                                       , CS.LAST_CHANGE_DATE
                                       , CS.UPDATE_USER
                                       , S.STATUS_SID
                                       , S.STATUS_ID
                                       , S.APP_DESCR
                                       , S.TR_DESCR
                                    FROM st_cty_status_curr CS
                                         JOIN st_status_repo S ON S.STATUS_SID = CS.STATUS_SID
                                         JOIN applications A ON A.APP_SID = CS.APP_SID
                                   WHERE A.APP_ID = p_app_id
                                     AND CS.ROUND_SID = p_round_sid
                                     AND (p_storage_sid IS NULL OR CS.STORAGE_SID = p_storage_sid)
                                     AND (p_cust_text_sid IS NULL
                                       OR CS.CUST_TEXT_SID = p_cust_text_sid)
                                  UNION ALL
                                  -- countries without status yet
                                  SELECT C.COUNTRY_ID
                                       , NULL LAST_CHANGE_DATE
                                       , NULL UPDATE_USER
                                       , S.STATUS_SID
                                       , S.STATUS_ID
                                       , S.APP_DESCR
                                       , S.TR_DESCR
                                    FROM COUNTRIES C JOIN ST_STATUS_REPO S ON S.STATUS_ID = 'ACTIVE'
                                   WHERE C.COUNTRY_ID NOT IN
                                            (SELECT CS.COUNTRY_ID
                                               FROM VW_ST_CTY_STATUS_CURR CS
                                              WHERE CS.APP_ID = p_app_id
                                                AND CS.ROUND_SID = p_round_sid
                                                AND (p_storage_sid IS NULL
                                                  OR CS.STORAGE_SID = p_storage_sid)
                                                AND (p_cust_text_sid IS NULL
                                                  OR CS.CUST_TEXT_SID = p_cust_text_sid))) RS
                                    ON CTY.COUNTRY_ID = RS.COUNTRY_ID
                        ORDER BY CG.ORDER_BY, CTY.ORDER_BY;
      END IF;
   END getCountryStatuses;

   ----------------------------------------------------------------------------
   -- @name getCountryAcceptedDates
   -- @return dates of latest storage acceptance per country
   ----------------------------------------------------------------------------
   PROCEDURE getCountryAcceptedDates(o_cur                  OUT SYS_REFCURSOR
                                   , p_app_id            IN     VARCHAR2
                                   , p_country_ids       IN     CORE_COMMONS.VARCHARARRAY
                                   , p_only_full_storage IN     NUMBER DEFAULT 0
                                   , p_only_full_round   IN     NUMBER DEFAULT 0)
   IS
      l_cty_count   NUMBER(3) := p_country_ids.COUNT;
      l_country_ids VARCHARLIST := CORE_COMMONS.arrayToList(p_country_ids);
   BEGIN
      IF l_cty_count = 0 THEN
         SELECT CTY.COUNTRY_ID
           BULK COLLECT INTO l_country_ids
           FROM COUNTRIES  CTY
                JOIN COUNTRY_GROUPS CG
                   ON CG.COUNTRY_GROUP_ID = (SELECT COALESCE(COUNTRY_GROUP_ID, 'EU')
                                               FROM APPLICATIONS
                                              WHERE APP_ID = p_app_id)
                  AND CTY.COUNTRY_ID = CG.COUNTRY_ID;
      END IF;

      OPEN o_cur FOR
         SELECT GA.GEO_AREA_ID            "countryId"
              , ACCEPTED.LAST_CHANGE_DATE "lastAcceptedDate"
              , ACCEPTED.ROUND_SID        "roundSid"
              , ACCEPTED.STORAGE_SID      "storageSid"
           FROM geo_areas  GA
                LEFT JOIN
                (
                   WITH
                      RANKED
                      AS
                         (SELECT CS.COUNTRY_ID
                               , CS.ROUND_SID
                               , CS.STORAGE_SID
                               , CS.LAST_CHANGE_DATE
                               , RANK()
                                 OVER(PARTITION BY CS.COUNTRY_ID
                                      ORDER BY R.YEAR DESC, R.ORDER_PERIOD DESC, S.ORDER_BY DESC)
                                    STORAGE_RANK
                            FROM st_cty_status_curr  CS
                                 JOIN APPLICATIONS A ON A.APP_SID = CS.APP_SID
                                 JOIN ST_STATUS_REPO SR
                                    ON SR.STATUS_ID = 'ACCEPTED' AND SR.STATUS_SID = CS.STATUS_SID
                                 JOIN VW_ROUNDS R
                                    ON R.ROUND_TYPE = 'N'
                                   AND (p_only_full_round = 0 OR R.IS_FULL = 'Y')
                                   AND R.ROUND_SID = CS.ROUND_SID
                                 JOIN STORAGES S
                                    ON S.IS_CUSTOM = 'N'
                                   AND (p_only_full_storage = 0 OR S.IS_FULL = 'Y')
                                   AND S.STORAGE_SID = CS.STORAGE_SID
                           WHERE A.APP_ID = p_app_id)
                   SELECT COUNTRY_ID, ROUND_SID, STORAGE_SID, LAST_CHANGE_DATE
                     FROM RANKED
                    WHERE STORAGE_RANK = 1
                ) ACCEPTED
                   ON ACCEPTED.COUNTRY_ID = GA.GEO_AREA_ID
          WHERE GA.GEO_AREA_ID IN (SELECT * FROM TABLE(l_country_ids));
   END getCountryAcceptedDates;

   ----------------------------------------------------------------------------
   -- @name setCountryStatus
   ----------------------------------------------------------------------------
   PROCEDURE setCountryStatus(o_res              OUT NUMBER
                            , o_cur              OUT SYS_REFCURSOR
                            , p_app_id        IN     VARCHAR2
                            , p_country_id    IN     VARCHAR2
                            , p_old_status_id IN     VARCHAR2
                            , p_new_status_id IN     VARCHAR2
                            , p_user          IN     VARCHAR2
                            , p_comment       IN     VARCHAR2
                            , p_send_mail     IN     NUMBER
                            , p_round_sid     IN     NUMBER
                            , p_storage_sid   IN     NUMBER DEFAULT NULL
                            , p_cust_text_sid IN     NUMBER DEFAULT NULL)
   IS
      l_cty_status_curr_sid ST_CTY_STATUS_CURR.CTY_STATUS_CURR_SID%TYPE;
      l_old_status_id       ST_STATUS_REPO.STATUS_ID%TYPE;
      l_new_status_sid      ST_STATUS_REPO.STATUS_SID%TYPE := getStatusSidById(p_new_status_id);
      l_country_ids         CORE_COMMONS.VARCHARARRAY;
      l_comment_sid         ST_CTY_STATUS_COMMENTS.CTY_STATUS_COMMENT_SID%TYPE;
      l_sent_emails         NUMBER(8);
   BEGIN
      BEGIN
         -- get current country status
         SELECT CS.CTY_STATUS_CURR_SID, CS.STATUS_ID
           INTO l_cty_status_curr_sid, l_old_status_id
           FROM VW_ST_CTY_STATUS_CURR CS
          WHERE CS.APP_ID = p_app_id
            AND CS.COUNTRY_ID = p_country_id
            AND CS.ROUND_SID = p_round_sid
            AND (p_storage_sid IS NULL OR CS.STORAGE_SID = p_storage_sid)
            AND (p_cust_text_sid IS NULL OR CS.CUST_TEXT_SID = p_cust_text_sid);

         IF p_old_status_id IS NULL OR p_old_status_id = l_old_status_id THEN
            UPDATE ST_CTY_STATUS_CURR CS
               SET CS.STATUS_SID       = l_new_status_sid
                 , CS.UPDATE_USER      = p_user
                 , CS.LAST_CHANGE_DATE = SYSDATE
             WHERE CS.CTY_STATUS_CURR_SID = l_cty_status_curr_sid;

            o_res := SQL%ROWCOUNT;
         ELSE
            o_res := -1;                                                       -- invalid old status
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            IF p_old_status_id != 'ACTIVE' THEN
               o_res := -1;                                                    -- invalid old status
            ELSE
               INSERT INTO ST_CTY_STATUS_CURR(APP_SID
                                            , COUNTRY_ID
                                            , ROUND_SID
                                            , STORAGE_SID
                                            , CUST_TEXT_SID
                                            , STATUS_SID
                                            , UPDATE_USER
                                            , LAST_CHANGE_DATE)
                    VALUES ((SELECT A.APP_SID
                               FROM APPLICATIONS A
                              WHERE A.APP_ID = p_app_id)
                          , p_country_id
                          , p_round_sid
                          , p_storage_sid
                          , p_cust_text_sid
                          , l_new_status_sid
                          , p_user
                          , SYSDATE)
                 RETURNING CTY_STATUS_CURR_SID
                      INTO l_cty_status_curr_sid;

               o_res := SQL%ROWCOUNT;
            END IF;
      END;

      IF o_res > 0 THEN
         IF p_comment IS NOT NULL THEN
            ST_STATUS_COMMENTS.setStatusComment(l_comment_sid
                                              , l_cty_status_curr_sid
                                              , l_new_status_sid
                                              , p_user
                                              , p_comment);
         END IF;

         IF p_app_id = 'DBP' OR p_app_id = 'SCP' THEN
            ST_STATUS_CHANGES.updateStatusChanges(p_round_sid
                                                , p_country_id
                                                , p_old_status_id
                                                , p_new_status_id);
         END IF;

         IF p_send_mail = 1 THEN
            ST_MAIL.sendMailNotification(p_app_id
                                       , p_country_id
                                       , p_old_status_id
                                       , p_new_status_id
                                       , l_sent_emails);
         END IF;
      END IF;

      l_country_ids(1) := p_country_id;
      getCountryStatuses(o_cur
                       , p_app_id
                       , l_country_ids
                       , p_round_sid
                       , p_storage_sid
                       , p_cust_text_sid);
   END setCountryStatus;

   ----------------------------------------------------------------------------
   -- @name setManyCountriesStatus
   ----------------------------------------------------------------------------
   PROCEDURE setManyCountriesStatus(o_res              OUT NUMBER
                                  , p_app_id        IN     VARCHAR2
                                  , p_country_ids   IN     CORE_COMMONS.VARCHARARRAY
                                  , p_new_status_id IN     VARCHAR2
                                  , p_user          IN     VARCHAR2
                                  , p_comment       IN     VARCHAR2
                                  , p_round_sid     IN     NUMBER
                                  , p_storage_sid   IN     NUMBER DEFAULT NULL
                                  , p_cust_text_sid IN     NUMBER DEFAULT NULL)
   IS
      l_app_sid              APPLICATIONS.APP_SID%TYPE := CORE_GETTERS.getApplicationSid(p_app_id);
      l_status_sid           ST_STATUS_REPO.STATUS_SID%TYPE := getStatusSidById(p_new_status_id);
      l_country_ids          VARCHARLIST := CORE_COMMONS.arrayToList(p_country_ids);
      l_country_count        NUMBER(4) := p_country_ids.COUNT;
      l_cty_status_curr_sid  ST_CTY_STATUS_CURR.CTY_STATUS_CURR_SID%TYPE;
      l_cty_status_curr_sids SIDSLIST;
      l_comment_sid          ST_CTY_STATUS_COMMENTS.CTY_STATUS_COMMENT_SID%TYPE;
   BEGIN
         UPDATE ST_CTY_STATUS_CURR CS
            SET CS.STATUS_SID = l_status_sid, CS.UPDATE_USER = p_user, CS.LAST_CHANGE_DATE = SYSDATE
          WHERE CS.APP_SID = l_app_sid
            AND (l_country_count = 0 OR CS.COUNTRY_ID IN (SELECT * FROM TABLE(l_country_ids)))
            AND CS.ROUND_SID = p_round_sid
            AND (p_storage_sid IS NULL OR CS.STORAGE_SID = p_storage_sid)
            AND (p_cust_text_sid IS NULL OR CS.CUST_TEXT_SID = p_cust_text_sid)
      RETURNING CS.CTY_STATUS_CURR_SID
           BULK COLLECT INTO l_cty_status_curr_sids;

      o_res := SQL%ROWCOUNT;

      IF o_res > 0 AND p_comment IS NOT NULL THEN
         FOR i IN 1 .. l_cty_status_curr_sids.COUNT LOOP
            ST_STATUS_COMMENTS.setStatusComment(l_comment_sid
                                              , l_cty_status_curr_sids(i)
                                              , l_status_sid
                                              , p_user
                                              , p_comment);
         END LOOP;
      END IF;

      IF l_country_count > 0 AND l_country_count != o_res THEN
         FOR i IN 1 .. l_country_count LOOP
            BEGIN
               INSERT INTO ST_CTY_STATUS_CURR(APP_SID
                                            , COUNTRY_ID
                                            , ROUND_SID
                                            , STORAGE_SID
                                            , CUST_TEXT_SID
                                            , STATUS_SID
                                            , LAST_CHANGE_DATE
                                            , UPDATE_USER)
                    VALUES (l_app_sid
                          , l_country_ids(i)
                          , p_round_sid
                          , p_storage_sid
                          , p_cust_text_sid
                          , l_status_sid
                          , SYSDATE
                          , p_user)
                 RETURNING CTY_STATUS_CURR_SID
                      INTO l_cty_status_curr_sid;

               o_res := o_res + 1;

               IF p_comment IS NOT NULL THEN
                  ST_STATUS_COMMENTS.setStatusComment(l_comment_sid
                                                    , l_cty_status_curr_sid
                                                    , l_status_sid
                                                    , p_user
                                                    , p_comment);
               END IF;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  NULL;
            END;
         END LOOP;
      END IF;
   END setManyCountriesStatus;
END ST_COUNTRY_STATUS;
/