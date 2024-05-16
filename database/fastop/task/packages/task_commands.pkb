/* Formatted on 17-05-2021 17:44:43 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY TASK_COMMANDS
AS
   /**************************************************************************
    *********************** PRIVATE SECTION **********************************
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name getStepTypeSidById
   ----------------------------------------------------------------------------
   FUNCTION getStepTypeSidById(p_step_type_id IN VARCHAR2)
      RETURN NUMBER
   IS
      l_task_step_type_sid TASK_STEP_TYPES.TASK_STEP_TYPE_SID%TYPE;
   BEGIN
      SELECT TASK_STEP_TYPE_SID
        INTO l_task_step_type_sid
        FROM TASK_STEP_TYPES
       WHERE TASK_STEP_TYPE_ID = p_step_type_id;

      RETURN l_task_step_type_sid;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
   END getStepTypeSidById;

   ----------------------------------------------------------------------------
   -- @name getTaskSidById
   ----------------------------------------------------------------------------
   FUNCTION getTaskSidById(p_task_id IN VARCHAR2)
      RETURN NUMBER
   IS
      l_task_sid TASKS.TASK_SID%TYPE;
   BEGIN
      SELECT T.TASK_SID
        INTO l_task_sid
        FROM TASKS T
       WHERE T.TASK_ID = p_task_id;

      RETURN l_task_sid;
   END getTaskSidById;

   ----------------------------------------------------------------------------
   -- @name getTaskStatusSidById
   ----------------------------------------------------------------------------
   FUNCTION getTaskStatusSidById(p_task_status_id IN VARCHAR2)
      RETURN NUMBER
   IS
      l_task_status_sid TASK_STATUSES.TASK_STATUS_SID%TYPE;
   BEGIN
      SELECT S.TASK_STATUS_SID
        INTO l_task_status_sid
        FROM TASK_STATUSES S
       WHERE S.TASK_STATUS_ID = p_task_status_id;

      RETURN l_task_status_sid;
   END getTaskStatusSidById;

   ----------------------------------------------------------------------------
   -- @name allStepsDone return 1 if all steps are saved, 0 otherwise
   ----------------------------------------------------------------------------
   FUNCTION allStepsDone(p_task_run_sid IN NUMBER)
      RETURN NUMBER
   IS
      l_count NUMBER(4);
   BEGIN
      SELECT COUNT(*)
        INTO l_count
        FROM VW_TASK_LOGS
       WHERE TASK_RUN_SID = p_task_run_sid AND STEP_STATUS_ID NOT IN ('DONE', 'ERROR', 'WARNING');

      RETURN CASE l_count WHEN 0 THEN 1 ELSE 0 END;
   END allStepsDone;

   ----------------------------------------------------------------------------
   -- @name confirmFinishTask
   ----------------------------------------------------------------------------
   PROCEDURE confirmFinishTask(p_task_run_sid IN NUMBER)
   IS
      l_count           NUMBER(8);
      l_task_status_sid TASK_STATUSES.TASK_STATUS_SID%TYPE;
   BEGIN
      SELECT COUNT(*)
        INTO l_count
        FROM VW_TASK_LOGS
       WHERE TASK_RUN_SID = p_task_run_sid AND STEP_STATUS_ID = 'ERROR';

      IF l_count > 0 THEN
         l_task_status_sid := getTaskStatusSidById('ERROR');
      ELSE
         SELECT COUNT(*)
           INTO l_count
           FROM VW_TASK_LOGS
          WHERE TASK_RUN_SID = p_task_run_sid AND STEP_STATUS_ID = 'WARNING';

         IF l_count > 0 THEN
            l_task_status_sid := getTaskStatusSidById('WARNING');
         ELSE
            l_task_status_sid := getTaskStatusSidById('DONE');
         END IF;
      END IF;

      UPDATE TASK_RUNS
         SET TASK_STATUS_SID = l_task_status_sid, END_RUN = SYSTIMESTAMP
       WHERE TASK_RUN_SID = p_task_run_sid;
   END confirmFinishTask;

   /**************************************************************************
    *********************** PUBLIC SECTION ***********************************
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name prepareTask
   ----------------------------------------------------------------------------
   PROCEDURE prepareTask(p_app_id      IN     VARCHAR2
                       , p_task_id     IN     VARCHAR2
                       , p_country_ids IN     CORE_COMMONS.VARCHARARRAY
                       , p_prep_steps  IN     NUMBER
                       , p_user        IN     VARCHAR2
                       , o_res            OUT NUMBER
                       , p_concurrency IN     NUMBER DEFAULT 1)
   IS
      l_country_ids     VARCHARLIST := CORE_COMMONS.arrayToList(p_country_ids);
      l_task_sid        TASKS.TASK_SID%TYPE := getTaskSidById(p_task_id);
      l_task_status_sid TASK_STATUSES.TASK_STATUS_SID%TYPE;
      l_country_id      GEO_AREAS.GEO_AREA_ID%TYPE;
      l_task_run_sid    TASK_RUNS.TASK_RUN_SID%TYPE;
      l_count           NUMBER(4);
      l_round_sid       ROUNDS.ROUND_SID%TYPE := CORE_GETTERS.getCurrentRoundSid(p_app_id);
      l_storage_sid     STORAGES.STORAGE_SID%TYPE := CORE_GETTERS.getCurrentStorageSid(p_app_id);
   BEGIN
      l_task_status_sid := getTaskStatusSidById('READY');

      -- create new task in TASK_RUNS
      INSERT INTO TASK_RUNS(TASK_STATUS_SID
                          , ALL_PREP_STEPS
                          , CONCURRENCY
                          , START_RUN
                          , USER_RUN)
           VALUES (l_task_status_sid
                 , p_prep_steps
                 , p_concurrency
                 , SYSTIMESTAMP
                 , p_user)
        RETURNING TASK_RUN_SID
             INTO l_task_run_sid;

      -- create country tasks if they don't exist yet
      FOR i IN 1 .. l_country_ids.COUNT LOOP
         BEGIN
            l_country_id := l_country_ids(i);

            IF p_task_id IN ('CALCULATION', 'IEA-CALCULATION') THEN
               -- Clear other tasks outdated information
               DELETE FROM TASK_COUNTRIES
                     WHERE COUNTRY_ID = l_country_id
                       AND ROUND_SID = l_round_sid
                       AND STORAGE_SID = l_storage_sid
                       AND TASK_SID IN (SELECT TASK_SID
                                          FROM TASKS
                                         WHERE TASK_ID IN ('CYCLICAL-ADJUSTMENTS', 'VALIDATION'));
            ELSIF p_task_id = 'CYCLICAL-ADJUSTMENTS' AND l_country_ids.COUNT = 1 THEN
               -- Clear validation task outdated information
               DELETE FROM TASK_COUNTRIES
                     WHERE COUNTRY_ID = l_country_id
                       AND ROUND_SID = l_round_sid
                       AND STORAGE_SID = l_storage_sid
                       AND TASK_SID IN (SELECT TASK_SID
                                         FROM TASKS
                                        WHERE TASK_ID IN ('VALIDATION', 'OG-AGGREGATION'));
            ELSIF p_task_id IN ('KNP', 'AGGREGATION') THEN
               -- Clear other tasks outdated information
               DELETE FROM TASK_COUNTRIES
                     WHERE COUNTRY_ID = l_country_id
                       AND ROUND_SID = l_round_sid
                       AND STORAGE_SID = l_storage_sid
                       AND TASK_SID IN (SELECT TASK_SID
                                          FROM TASKS
                                         WHERE TASK_ID IN ('AGGREGATION', 'WORLD-AGGREGATION'));
            END IF;

            SELECT COUNT(*)
              INTO l_count
              FROM TASK_COUNTRIES
             WHERE TASK_SID = l_task_sid
               AND COUNTRY_ID = l_country_id
               AND ROUND_SID = l_round_sid
               AND STORAGE_SID = l_storage_sid;

            IF l_count = 0 THEN
               INSERT INTO TASK_COUNTRIES(TASK_SID
                                        , COUNTRY_ID
                                        , ROUND_SID
                                        , STORAGE_SID
                                        , TASK_RUN_SID)
                    VALUES (l_task_sid
                          , l_country_id
                          , l_round_sid
                          , l_storage_sid
                          , l_task_run_sid);
            END IF;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               NULL;
         END;
      END LOOP;

      l_task_status_sid := getTaskStatusSidById('RUNNING');

      -- update running task for participating countries
      UPDATE TASK_COUNTRIES
         SET TASK_RUN_SID = l_task_run_sid
       WHERE TASK_SID = l_task_sid
         AND ROUND_SID = l_round_sid
         AND STORAGE_SID = l_storage_sid
         AND COUNTRY_ID IN (SELECT * FROM TABLE(l_country_ids))
         AND TASK_RUN_SID NOT IN (SELECT TASK_RUN_SID
                                    FROM TASK_RUNS
                                   WHERE TASK_STATUS_SID = l_task_status_sid);

      -- rollback if could not update for all countries
      IF SQL%ROWCOUNT != l_country_ids.COUNT THEN
         ROLLBACK;
         o_res := -1;
      ELSE
         o_res := l_task_run_sid;

         -- set task status to running
         UPDATE TASK_RUNS
            SET TASK_STATUS_SID = l_task_status_sid
          WHERE TASK_RUN_SID = l_task_run_sid;
      END IF;
   END prepareTask;

   ----------------------------------------------------------------------------
   -- @name addTaskRunPrepStep
   ----------------------------------------------------------------------------
   PROCEDURE addTaskRunPrepStep(p_task_run_sid IN NUMBER, o_res OUT NUMBER)
   IS
   BEGIN
      IF TASK_GETTERS.getTaskRunStatusId(p_task_run_sid) = 'ABORT' THEN
         o_res := -1;
         RETURN;
      END IF;

         UPDATE TASK_RUNS
            SET PREP_STEPS = PREP_STEPS + 1
          WHERE TASK_RUN_SID = p_task_run_sid
      RETURNING PREP_STEPS
           INTO o_res;
   END addTaskRunPrepStep;

   ----------------------------------------------------------------------------
   -- @name addConcurrentSteps
   ----------------------------------------------------------------------------
   PROCEDURE addConcurrentSteps(p_task_run_sid IN NUMBER, p_steps IN CORE_COMMONS.SIDSARRAY)
   IS
      l_running_sid TASK_STATUSES.TASK_STATUS_SID%TYPE := getTaskStatusSidById('RUNNING');
   BEGIN
      FOR i IN 1 .. p_steps.COUNT LOOP
        <<update_task_logs_concurrency>>
         UPDATE TASK_LOGS
            SET CONCURRENCY = CONCURRENCY + 1
          WHERE TASK_RUN_SID = p_task_run_sid AND STEP_NUMBER = p_steps(i);

         IF SQL%ROWCOUNT = 0 THEN
            BEGIN
               INSERT INTO TASK_LOGS(TASK_RUN_SID, STEP_NUMBER, STEP_STATUS_SID)
                    VALUES (p_task_run_sid, p_steps(i), l_running_sid);
            EXCEPTION
               -- in case another connection has inserted the record
               -- in the mean time, just go back and update it
               WHEN DUP_VAL_ON_INDEX THEN
                  GOTO update_task_logs_concurrency;
            END;
         END IF;

         COMMIT;
      END LOOP;

      UPDATE TASK_RUNS
         SET ALL_STEPS =
                (SELECT COUNT(*)
                   FROM TASK_LOGS
                  WHERE TASK_RUN_SID = p_task_run_sid)
       WHERE TASK_RUN_SID = p_task_run_sid;
   END addConcurrentSteps;

   ----------------------------------------------------------------------------
   -- @name setTaskRunAllSteps
   ----------------------------------------------------------------------------
   PROCEDURE setTaskRunAllSteps(p_task_run_sid IN NUMBER, p_num_steps IN NUMBER, o_res OUT NUMBER)
   IS
   BEGIN
      UPDATE TASK_RUNS
         SET ALL_STEPS = p_num_steps
       WHERE TASK_RUN_SID = p_task_run_sid;

      o_res := SQL%ROWCOUNT;
   END setTaskRunAllSteps;

   ----------------------------------------------------------------------------
   -- @name finishTask
   ----------------------------------------------------------------------------
   PROCEDURE finishTask(p_task_run_sid   IN     NUMBER
                      , p_task_status_id IN     VARCHAR2
                      , p_num_steps      IN     NUMBER
                      , o_res               OUT NUMBER)
   IS
      l_task_status_sid TASK_STATUSES.TASK_STATUS_SID%TYPE
         := getTaskStatusSidById(
               CASE p_task_status_id WHEN 'DONE' THEN 'SAVING' ELSE p_task_status_id END
            );
      l_concurrency     TASK_RUNS.CONCURRENCY%TYPE;
      l_workers_done    TASK_RUNS.WORKERS_DONE%TYPE;
   BEGIN
      IF TASK_GETTERS.getTaskRunStatusId(p_task_run_sid) IN ('ABORT', 'ERROR') THEN
         o_res := -1;
         RETURN;
      END IF;

      IF p_task_status_id IN ('ABORT', 'ERROR') THEN
         UPDATE TASK_RUNS
            SET TASK_STATUS_SID = l_task_status_sid
              , STEPS           = COALESCE(p_num_steps, STEPS)
              , END_RUN         = SYSTIMESTAMP
          WHERE TASK_RUN_SID = p_task_run_sid;

         o_res := SQL%ROWCOUNT;
         RETURN;
      END IF;

         UPDATE TASK_RUNS
            SET WORKERS_DONE = WORKERS_DONE + 1
          WHERE TASK_RUN_SID = p_task_run_sid
      RETURNING CONCURRENCY, WORKERS_DONE
           INTO l_concurrency, l_workers_done;

      IF l_workers_done < l_concurrency THEN
         o_res := 0;
         RETURN;
      END IF;

      UPDATE TASK_RUNS
         SET TASK_STATUS_SID = l_task_status_sid
           , STEPS           = COALESCE(p_num_steps, STEPS)
           , END_RUN         = SYSTIMESTAMP
       WHERE TASK_RUN_SID = p_task_run_sid;

      COMMIT;

      IF p_task_status_id = 'DONE' AND allStepsDone(p_task_run_sid) = 1 THEN
         confirmFinishTask(p_task_run_sid);
      END IF;

      o_res := SQL%ROWCOUNT;
   END finishTask;

   ----------------------------------------------------------------------------
   -- @name logStep
   ----------------------------------------------------------------------------
   PROCEDURE logStep(p_task_run_sid    IN     NUMBER
                   , p_step_number     IN     NUMBER
                   , p_step_descr      IN     VARCHAR2
                   , p_step_status_id  IN     VARCHAR2
                   , p_step_exceptions IN     NUMBER
                   , p_step_message    IN     VARCHAR2
                   , p_step_type_id    IN     VARCHAR2
                   , o_res                OUT NUMBER)
   IS
      l_status_sid    TASK_STATUSES.TASK_STATUS_SID%TYPE := getTaskStatusSidById(p_step_status_id);
      l_step_type_sid TASK_STEP_TYPES.TASK_STEP_TYPE_SID%TYPE := getStepTypeSidById(p_step_type_id);
      l_error_sid     TASK_STATUSES.TASK_STATUS_SID%TYPE := getTaskStatusSidById('ERROR');
      l_warning_sid   TASK_STATUSES.TASK_STATUS_SID%TYPE := getTaskStatusSidById('WARNING');
      l_concurrency   TASK_LOGS.CONCURRENCY%TYPE;
      l_workers_done  TASK_LOGS.WORKERS_DONE%TYPE;
   BEGIN
      IF TASK_GETTERS.getTaskRunStatusId(p_task_run_sid) = 'ABORT' THEN
         o_res := -1;
         RETURN;
      END IF;

     <<update_task_logs_status>>
         UPDATE TASK_LOGS
            SET STEP_DESCR      = p_step_descr
              , STEP_STATUS_SID =
                   CASE
                      WHEN STEP_STATUS_SID = l_error_sid OR l_status_sid = l_error_sid THEN
                         l_error_sid
                      WHEN STEP_STATUS_SID = l_warning_sid OR l_status_sid = l_warning_sid THEN
                         l_warning_sid
                      ELSE
                         l_status_sid
                   END
              , STEP_TIMESTAMP  = SYSTIMESTAMP
              , STEP_EXCEPTIONS = STEP_EXCEPTIONS + p_step_exceptions
              , STEP_MESSAGE   =
                      CASE WHEN STEP_MESSAGE IS NULL THEN '' ELSE STEP_MESSAGE || CHR(10) END
                   || p_step_message
              , STEP_TYPE_SID   = l_step_type_sid
              , WORKERS_DONE    = WORKERS_DONE + CASE p_step_status_id WHEN 'SAVING' THEN 0 ELSE 1 END
          WHERE TASK_RUN_SID = p_task_run_sid AND STEP_NUMBER = p_step_number
      RETURNING TASK_LOG_SID, CONCURRENCY, WORKERS_DONE
           INTO o_res, l_concurrency, l_workers_done;

      IF SQL%ROWCOUNT = 0 THEN
         BEGIN
            INSERT INTO TASK_LOGS(TASK_RUN_SID
                                , STEP_NUMBER
                                , STEP_DESCR
                                , STEP_STATUS_SID
                                , STEP_TIMESTAMP
                                , STEP_EXCEPTIONS
                                , STEP_MESSAGE
                                , STEP_TYPE_SID
                                , WORKERS_DONE)
                 VALUES (p_task_run_sid
                       , p_step_number
                       , p_step_descr
                       , l_status_sid
                       , SYSTIMESTAMP
                       , p_step_exceptions
                       , p_step_message
                       , l_step_type_sid
                       , CASE p_step_status_id WHEN 'SAVING' THEN 0 ELSE 1 END)
              RETURNING TASK_LOG_SID, CONCURRENCY, WORKERS_DONE
                   INTO o_res, l_concurrency, l_workers_done;
         EXCEPTION
            -- in case another connection has inserted the record
            -- in the mean time, just go back and update it
            WHEN DUP_VAL_ON_INDEX THEN
               GOTO update_task_logs_status;
         END;
      END IF;

      COMMIT;

      IF p_step_status_id != 'SAVING' AND l_workers_done >= l_concurrency THEN
         UPDATE TASK_RUNS
            SET STEPS = STEPS + 1
          WHERE TASK_RUN_SID = p_task_run_sid;

         IF TASK_GETTERS.getTaskRunStatusId(p_task_run_sid) = 'SAVING' AND allStepsDone(p_task_run_sid) = 1 THEN
            confirmFinishTask(p_task_run_sid);
         END IF;
      END IF;
   END logStep;

   ----------------------------------------------------------------------------
   -- @name logStepValidations
   ----------------------------------------------------------------------------
   PROCEDURE logStepValidations(p_task_log_sid    IN     NUMBER
                              , p_labels          IN     VARCHAR2
                              , p_indicator_codes IN     CORE_COMMONS.VARCHARARRAY
                              , p_actual          IN     CORE_COMMONS.VARCHARARRAY
                              , p_validation1     IN     CORE_COMMONS.VARCHARARRAY
                              , p_validation2     IN     CORE_COMMONS.VARCHARARRAY
                              , p_failed          IN     CORE_COMMONS.VARCHARARRAY
                              , o_res                OUT NUMBER)
   IS
   BEGIN
      IF p_indicator_codes.COUNT > 0 THEN
         FORALL i IN 1 .. p_indicator_codes.COUNT
            INSERT INTO TASK_LOG_VALIDATIONS(TASK_LOG_SID
                                           , LABELS
                                           , INDICATOR_ID
                                           , ACTUAL
                                           , VALIDATION1
                                           , VALIDATION2
                                           , FAILED)
                 VALUES (p_task_log_sid
                       , p_labels
                       , p_indicator_codes(i)
                       , p_actual(i)
                       , p_validation1(i)
                       , p_validation2(i)
                       , p_failed(i));

         o_res := SQL%ROWCOUNT;
      ELSE
         o_res := 0;
      END IF;
   END logStepValidations;
END TASK_COMMANDS;
