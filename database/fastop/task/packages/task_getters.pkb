/* Formatted on 17-05-2021 18:13:40 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY TASK_GETTERS
AS
   /**************************************************************************
    *********************** PRIVATE SECTION **********************************
    **************************************************************************/

   /**************************************************************************
    *********************** PUBLIC SECTION ***********************************
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name getCountryTask
   ----------------------------------------------------------------------------
   PROCEDURE getCountryTask(o_cur            OUT SYS_REFCURSOR
                          , p_app_id      IN     VARCHAR2
                          , p_task_id     IN     VARCHAR2
                          , p_country_id  IN     VARCHAR2
                          , p_round_sid   IN     NUMBER DEFAULT NULL
                          , p_storage_sid IN     NUMBER DEFAULT NULL)
   IS
      l_round_sid   ROUNDS.ROUND_SID%TYPE
                       := COALESCE(p_round_sid, CORE_GETTERS.getCurrentRoundSid(p_app_id));
      l_storage_sid STORAGES.STORAGE_SID%TYPE
                       := COALESCE(p_storage_sid, CORE_GETTERS.getCurrentStorageSid(p_app_id));
   BEGIN
      OPEN o_cur FOR
         SELECT R.TASK_RUN_SID
              , S.TASK_STATUS_ID
              , R.USER_RUN
              , R.END_RUN
              , R.ALL_STEPS
              , R.STEPS STEPS_COMPLETED
              , R.ALL_PREP_STEPS
              , R.PREP_STEPS
           FROM TASK_COUNTRIES  C
                JOIN TASKS T ON T.TASK_SID = C.TASK_SID
                JOIN TASK_RUNS R ON R.TASK_RUN_SID = C.TASK_RUN_SID
                JOIN TASK_STATUSES S ON S.TASK_STATUS_SID = R.TASK_STATUS_SID
          WHERE UPPER(T.TASK_ID) = UPPER(p_task_id)
            AND C.COUNTRY_ID = p_country_id
            AND C.ROUND_SID = l_round_sid
            AND C.STORAGE_SID = l_storage_sid;
   END getCountryTask;

   ----------------------------------------------------------------------------
   -- @name getCtyTaskExceptions
   ----------------------------------------------------------------------------
   PROCEDURE getCtyTaskExceptions(p_task_id     IN     VARCHAR2
                                , p_country_id  IN     VARCHAR2
                                , p_round_sid   IN     NUMBER
                                , p_storage_sid IN     NUMBER
                                , o_cur            OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT L.STEP_NUMBER, L.STEP_EXCEPTIONS, TST.TASK_STEP_TYPE_ID
             FROM TASK_COUNTRIES C
                  JOIN TASKS T ON T.TASK_SID = C.TASK_SID AND T.TASK_ID = p_task_id
                  JOIN TASK_LOGS L ON L.TASK_RUN_SID = C.TASK_RUN_SID
                  LEFT JOIN TASK_STEP_TYPES TST ON TST.TASK_STEP_TYPE_SID = L.STEP_TYPE_SID
            WHERE C.COUNTRY_ID = p_country_id
              AND C.ROUND_SID = p_round_sid
              AND C.STORAGE_SID = p_storage_sid
         ORDER BY L.STEP_NUMBER;
   END getCtyTaskExceptions;

   ----------------------------------------------------------------------------
   -- @name getTaskLogs
   ----------------------------------------------------------------------------
   PROCEDURE getTaskLogs(p_task_run_sid   IN     NUMBER
                       , o_task_status_id    OUT VARCHAR2
                       , o_cur               OUT SYS_REFCURSOR)
   IS
   BEGIN
      o_task_status_id := getTaskRunStatusId(p_task_run_sid);

      OPEN o_cur FOR
           SELECT L.STEP_NUMBER
                , L.STEP_DESCR
                , S.TASK_STATUS_ID STEP_STATUS_ID
                , L.STEP_TIMESTAMP
                , L.STEP_EXCEPTIONS
                , L.STEP_MESSAGE
             FROM TASK_LOGS L JOIN TASK_STATUSES S ON S.TASK_STATUS_SID = L.STEP_STATUS_SID
            WHERE L.TASK_RUN_SID = p_task_run_sid
         ORDER BY L.STEP_NUMBER;
   END getTaskLogs;

   ----------------------------------------------------------------------------
   -- @name getTaskLogValidations
   ----------------------------------------------------------------------------
   PROCEDURE getTaskLogValidations(p_country_id  IN     VARCHAR2
                                 , p_step        IN     NUMBER
                                 , p_round_sid   IN     NUMBER
                                 , p_storage_sid IN     NUMBER
                                 , o_cur            OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT V.INDICATOR_ID
                , V.LABELS
                , V.ACTUAL
                , V.VALIDATION1
                , V.VALIDATION2
                , V.FAILED
             FROM TASK_COUNTRIES CTY
                  JOIN TASKS T ON T.TASK_SID = CTY.TASK_SID AND T.TASK_ID = 'VALIDATION'
                  JOIN TASK_RUNS R
                     ON CTY.COUNTRY_ID = p_country_id
                    AND CTY.ROUND_SID = p_round_sid
                    AND CTY.STORAGE_SID = p_storage_sid
                    AND R.TASK_RUN_SID = CTY.TASK_RUN_SID
                  JOIN TASK_LOGS L ON L.TASK_RUN_SID = R.TASK_RUN_SID AND L.STEP_NUMBER = p_step
                  JOIN TASK_LOG_VALIDATIONS V ON V.TASK_LOG_SID = L.TASK_LOG_SID
         ORDER BY V.INDICATOR_ID;
   END getTaskLogValidations;

   ----------------------------------------------------------------------------
   -- @name getTaskRunStatusId
   ----------------------------------------------------------------------------
   FUNCTION getTaskRunStatusId(p_task_run_sid IN VARCHAR2)
      RETURN VARCHAR2
   IS
      l_task_status_id TASK_STATUSES.TASK_STATUS_ID%TYPE;
   BEGIN
      SELECT S.TASK_STATUS_ID
        INTO l_task_status_id
        FROM TASK_RUNS R JOIN TASK_STATUSES S ON S.TASK_STATUS_SID = R.TASK_STATUS_SID
       WHERE R.TASK_RUN_SID = p_task_run_sid;

      RETURN l_task_status_id;
   END getTaskRunStatusId;

   ----------------------------------------------------------------------------
   -- @name getCountriesTasks
   ----------------------------------------------------------------------------
   PROCEDURE getCountriesTasks(o_cur            OUT SYS_REFCURSOR
                             , p_app_id      IN     VARCHAR2
                             , p_task_id     IN     VARCHAR2
                             , p_round_sid   IN     NUMBER DEFAULT NULL
                             , p_storage_sid IN     NUMBER DEFAULT NULL)
   IS
      l_round_sid   ROUNDS.ROUND_SID%TYPE
                       := COALESCE(p_round_sid, CORE_GETTERS.getCurrentRoundSid(p_app_id));
      l_storage_sid STORAGES.STORAGE_SID%TYPE
                       := COALESCE(p_storage_sid, CORE_GETTERS.getCurrentStorageSid(p_app_id));
   BEGIN
      OPEN o_cur FOR
         SELECT R.TASK_RUN_SID
              , S.TASK_STATUS_ID
              , C.COUNTRY_ID
              , R.USER_RUN
              , R.END_RUN
           FROM TASK_COUNTRIES C
                JOIN TASKS T         ON T.TASK_SID = C.TASK_SID
                JOIN TASK_RUNS R     ON R.TASK_RUN_SID = C.TASK_RUN_SID
                JOIN TASK_STATUSES S ON S.TASK_STATUS_SID = R.TASK_STATUS_SID
          WHERE UPPER(T.TASK_ID) = UPPER(p_task_id)
            AND C.ROUND_SID = l_round_sid
            AND C.STORAGE_SID = l_storage_sid
            AND R.TASK_RUN_SID IN (
                SELECT MAX(R1.TASK_RUN_SID) OVER (PARTITION BY C1.COUNTRY_ID)
                  FROM TASK_COUNTRIES  C1
                       JOIN TASKS T1         ON T1.TASK_SID = C1.TASK_SID
                       JOIN TASK_RUNS R1     ON R1.TASK_RUN_SID = C1.TASK_RUN_SID
                       JOIN TASK_STATUSES S1 ON S1.TASK_STATUS_SID = R1.TASK_STATUS_SID
                 WHERE UPPER(T1.TASK_ID) = UPPER(p_task_id)
                   AND C1.ROUND_SID = l_round_sid
                   AND C1.STORAGE_SID = l_storage_sid
                );
   END getCountriesTasks;

   ----------------------------------------------------------------------------
   -- @name getTasks
   ----------------------------------------------------------------------------
   PROCEDURE getTasks(o_cur             OUT SYS_REFCURSOR
                    , p_country_ids  IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(NULL AS CORE_COMMONS.VARCHARARRAY)
                    , p_storage_sids IN     CORE_COMMONS.SIDSARRAY    DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
                    , p_round_sids   IN     CORE_COMMONS.SIDSARRAY    DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
                    , p_status_ids   IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(NULL AS CORE_COMMONS.VARCHARARRAY)
                    , p_task_sids    IN     CORE_COMMONS.SIDSARRAY    DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY))
   IS
      l_country_ids      VARCHARLIST := CORE_COMMONS.arrayToList(p_country_ids);
      l_country_count    NUMBER(3)   := p_country_ids.COUNT;
      l_storage_sids     SIDSLIST    := CORE_COMMONS.arrayToSidsList(p_storage_sids);
      l_storage_count    NUMBER(3)   := p_storage_sids.COUNT;
      l_round_sids       SIDSLIST    := CORE_COMMONS.arrayToSidsList(p_round_sids);
      l_round_count      NUMBER(3)   := p_round_sids.COUNT;
      l_status_ids       VARCHARLIST := CORE_COMMONS.arrayToList(p_status_ids);
      l_status_count     NUMBER(3)   := p_status_ids.COUNT;
      l_task_sids        SIDSLIST    := CORE_COMMONS.arrayToSidsList(p_task_sids);
      l_task_count       NUMBER(3)   := p_task_sids.COUNT;
   BEGIN
     OPEN o_cur FOR
        SELECT 
                V.TASK_SID AS "task_sid"
              , V.TASK_RUN_SID AS "task_run_sid"
              , V.COUNTRY_ID AS "country_id"
              , V.STORAGE_SID AS "storage_sid"
              , V.ROUND_SID AS "round_sid"
              , V.TASK_ID AS "task_id"
              , V.TASK_DESCR AS "task_descr"
              , V.TASK_STATUS_ID AS "task_status_id"
              , V.STATUS_DESCR AS "status_descr"
              , V.USER_RUN AS "user_run"
              , V.END_RUN AS "end_run"
              , V.ALL_STEPS AS "all_steps"
              , V.STEPS AS "steps"
              , V.ALL_PREP_STEPS AS "all_prep_steps"
              , V.PREP_STEPS AS "prep_steps"
              , CONCAT(CONCAT(R.PERIOD_DESCR,' '), R.YEAR) AS "round_descr"
              , G.DESCR AS "country_descr"
              , STRG.STORAGE_ID AS "storage_id"
              , STRG.DESCR AS "storage_descr"
          FROM VW_TASK_CTY_RUNS V
               JOIN STORAGES STRG ON STRG.STORAGE_SID = V.STORAGE_SID
               JOIN GEO_AREAS G   ON G.GEO_AREA_ID = V.COUNTRY_ID
               JOIN VW_ROUNDS R   ON R.ROUND_SID = V.ROUND_SID
         WHERE     (l_country_count = 0  OR V.COUNTRY_ID     IN (SELECT * FROM TABLE(l_country_ids)))
               AND (l_storage_count = 0  OR V.STORAGE_SID    IN (SELECT * FROM TABLE(l_storage_sids)))
               AND (l_round_count   = 0  OR V.ROUND_SID      IN (SELECT * FROM TABLE(l_round_sids)))
               AND (l_task_count    = 0  OR V.TASK_SID        IN (SELECT * FROM TABLE(l_task_sids)))
               AND (l_status_count  = 0  OR V.TASK_STATUS_ID IN (SELECT * FROM TABLE(l_status_ids)));
   END getTasks;

   ----------------------------------------------------------------------------
   -- @name getTaskCountriesDict
   ----------------------------------------------------------------------------
   PROCEDURE getTaskCountriesDict(o_cur           OUT SYS_REFCURSOR
                                , p_status_ids IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(NULL AS CORE_COMMONS.VARCHARARRAY))
   IS
      l_status_ids      VARCHARLIST := CORE_COMMONS.arrayToList(p_status_ids);
      l_status_count    NUMBER(3)   := l_status_ids.COUNT;
   BEGIN
      OPEN o_cur FOR
        SELECT V.COUNTRY_ID as VALUE
             , G.DESCR as NAME
          FROM GEO_AREAS G
               JOIN VW_TASK_CTY_RUNS V ON G.GEO_AREA_ID = V.COUNTRY_ID
         WHERE (l_status_count = 0 OR V.TASK_STATUS_ID IN (SELECT * FROM TABLE(l_status_ids)))
      GROUP BY V.COUNTRY_ID, G.DESCR, G.ORDER_BY
      ORDER BY G.ORDER_BY, G.DESCR;
   END getTaskCountriesDict;

   ----------------------------------------------------------------------------
   -- @name getTaskRoundsDict
   ----------------------------------------------------------------------------
   PROCEDURE getTaskRoundsDict(o_cur           OUT SYS_REFCURSOR
                             , p_status_ids IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(NULL AS CORE_COMMONS.VARCHARARRAY))
   IS
      l_status_ids      VARCHARLIST := CORE_COMMONS.arrayToList(p_status_ids);
      l_status_count    NUMBER(3)   := l_status_ids.COUNT;
   BEGIN
      OPEN o_cur FOR
        SELECT DISTINCT V.ROUND_SID as VALUE
             , CONCAT(CONCAT(R.PERIOD_DESCR,' '), R.YEAR) as NAME
          FROM VW_TASK_CTY_RUNS V
               JOIN VW_ROUNDS R ON R.ROUND_SID = V.ROUND_SID
         WHERE (l_status_count = 0 OR V.TASK_STATUS_ID IN (SELECT * FROM TABLE(l_status_ids)));
     END getTaskRoundsDict;

   ----------------------------------------------------------------------------
   -- @name getTaskStoragesDict
   ----------------------------------------------------------------------------
   PROCEDURE getTaskStoragesDict(o_cur           OUT SYS_REFCURSOR
                               , p_status_ids IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(NULL AS CORE_COMMONS.VARCHARARRAY))
      IS
      l_status_ids      VARCHARLIST := CORE_COMMONS.arrayToList(p_status_ids);
      l_status_count    NUMBER(3)   := l_status_ids.COUNT;
     BEGIN
        OPEN o_cur FOR
            SELECT DISTINCT S.STORAGE_SID as VALUE
                 , S.DESCR as NAME
              FROM STORAGES S
                   JOIN VW_TASK_CTY_RUNS V ON S.STORAGE_SID = V.STORAGE_SID
             WHERE (l_status_count = 0 OR V.TASK_STATUS_ID IN (SELECT * FROM TABLE(l_status_ids)));
     END getTaskStoragesDict;
     
   ----------------------------------------------------------------------------
   -- @name getTaskNamesDict
   ----------------------------------------------------------------------------
   PROCEDURE getTaskNamesDict(o_cur           OUT SYS_REFCURSOR
                            , p_status_ids IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(NULL AS CORE_COMMONS.VARCHARARRAY))
   IS
      l_status_ids      VARCHARLIST := CORE_COMMONS.arrayToList(p_status_ids);
      l_status_count    NUMBER(3)   := l_status_ids.COUNT;
   BEGIN
       OPEN o_cur FOR
           SELECT DISTINCT V.TASK_SID as VALUE
                , V.TASK_DESCR as NAME
             FROM VW_TASK_CTY_RUNS V
            WHERE (l_status_count = 0 OR V.TASK_STATUS_ID IN (SELECT * FROM TABLE(l_status_ids)));
   END getTaskNamesDict;

END TASK_GETTERS;
