create or replace PACKAGE BODY FDMS_ROUND
AS
    /**************************************************************************
     *********************** PRIVATE SECTION **********************************
     **************************************************************************/
    TYPE NEW_ROUND IS RECORD
    (
        YEAR       NUMBER
,       PERIOD_SID  NUMBER
    );

    TYPE NEW_ROUND_PARAM_CHECK IS RECORD
    (
        INPUT_YEAR_OK       NUMBER
,       INPUT_PERIOD_SID_OK NUMBER
    );

    TYPE CUSTOM_ROUND_PARAM_CHECK IS RECORD
    (
        INPUT_YEAR_OK       NUMBER
,       INPUT_PERIOD_SID_OK NUMBER
,       INPUT_VERSION_OK    NUMBER
    );
    
    T_APP_ID        CORE_TYPES.T_APP_ID;
    T_INPUT         CORE_TYPES.T_INPUT;
    T_ACTIVATION    CORE_TYPES.T_ACTIVATION;
    T_PARAMS        CORE_TYPES.T_PARAM_NAME;
    T_DFM_PARAMS    CORE_TYPES.T_DFM_PARAMS;
    T_STATUS_REPO   CORE_TYPES.T_STATUS_REPO;

    ----------------------------------------------------------------------------
    -- @name getNextRound
    ----------------------------------------------------------------------------
    FUNCTION getNextRound
        RETURN NEW_ROUND
    IS
        l_round_order_period NUMBER;
        l_max_period_order   NUMBER;
        l_res                NEW_ROUND;
    BEGIN
        -- max period
        SELECT MAX(ORDER_PERIOD)
        INTO l_max_period_order
        FROM PERIODS
        WHERE ROUND_TYPE = 'N';

        -- select latest round in the Rounds table
        SELECT YEAR, ORDER_PERIOD
        INTO l_res.YEAR, l_round_order_period
        FROM
        (
            SELECT R.YEAR, P.ORDER_PERIOD
            FROM ROUNDS R JOIN PERIODS P ON R.PERIOD_SID = P.PERIOD_SID
            ORDER BY R.YEAR DESC, P.ORDER_PERIOD DESC
        )
        WHERE ROWNUM = 1;

        IF l_round_order_period = l_max_period_order
        THEN
            l_res.YEAR := l_res.YEAR + 1;
        END IF;

        SELECT PERIOD_SID
        INTO l_res.PERIOD_SID
        FROM PERIODS
        WHERE ORDER_PERIOD = MOD(l_round_order_period, l_max_period_order) + 1;

        RETURN l_res;
    END getNextRound;

    ----------------------------------------------------------------------------
    -- @name checkStorage
    ----------------------------------------------------------------------------
    FUNCTION checkStorage
        RETURN NUMBER
    IS
    BEGIN
        RETURN FDMS_GETTERS.isCurrentStorageFinal();
    END checkStorage;

    ----------------------------------------------------------------------------
    -- @name checkNewRoundParams
    ----------------------------------------------------------------------------
    FUNCTION checkNewRoundParams(p_year         IN     NUMBER
,                                p_period_sid   IN     NUMBER)
        RETURN NEW_ROUND_PARAM_CHECK
    IS
        l_next_round  NEW_ROUND := getNextRound();
        l_res         NEW_ROUND_PARAM_CHECK;
    BEGIN
        IF p_year = l_next_round.YEAR
        THEN
            l_res.INPUT_YEAR_OK := T_INPUT.OK;
        ELSE
            l_res.INPUT_YEAR_OK := T_INPUT.NOK;
        END IF;

        IF p_period_sid = l_next_round.PERIOD_SID
        THEN
            l_res.INPUT_PERIOD_SID_OK := T_INPUT.OK;
        ELSE
            l_res.INPUT_PERIOD_SID_OK := T_INPUT.NOK;
        END IF;

        RETURN l_res;
    END checkNewRoundParams;

    ----------------------------------------------------------------------------
    -- @name checkCustomRoundParams
    ----------------------------------------------------------------------------
    FUNCTION checkCustomRoundParams(p_year         IN     NUMBER
,                                   p_period_sid   IN     NUMBER
,                                   p_version      IN     NUMBER)
        RETURN CUSTOM_ROUND_PARAM_CHECK
    IS
        l_current_round_sid             NUMBER := CORE_GETTERS.getCurrentRoundSid();
        l_current_year                  NUMBER;
        l_custom_round_period_order     NUMBER;
        l_current_round_period_order    NUMBER;
        l_version                       NUMBER;
        l_res         CUSTOM_ROUND_PARAM_CHECK;
    BEGIN
        -- check round's year (current round year or current round year -1)
        SELECT YEAR
          INTO l_current_year
          FROM ROUNDS
         WHERE ROUND_SID = l_current_round_sid;

        IF p_year = l_current_year OR p_year = l_current_year - 1
        THEN
            l_res.INPUT_YEAR_OK := T_INPUT.OK;
        ELSE
            l_res.INPUT_YEAR_OK := T_INPUT.NOK;
        END IF;

        -- check if for the same year p_period_order <= current_round.p_period_order
        SELECT ORDER_PERIOD
          INTO l_custom_round_period_order
          FROM PERIODS
         WHERE PERIOD_SID = p_period_sid;

         SELECT P.ORDER_PERIOD
           INTO l_current_round_period_order
           FROM ROUNDS R
           JOIN PERIODS P
             ON R.PERIOD_SID = P.PERIOD_SID
          WHERE R.ROUND_SID =  l_current_round_sid;

        IF p_year != l_current_year OR (p_year = l_current_year AND l_custom_round_period_order <= l_current_round_period_order)
        THEN
            l_res.INPUT_PERIOD_SID_OK := T_INPUT.OK;
        ELSE
            l_res.INPUT_PERIOD_SID_OK := T_INPUT.NOK;
        END IF;

        -- check if for giver year and period there's version => 1
        BEGIN
            SELECT MAX(VERSION)
              INTO l_version
              FROM ROUNDS
             WHERE YEAR = p_year
               AND PERIOD_SID = p_period_sid;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_version := NULL;
        END;

        IF l_version IS NOT NULL AND l_version >= 1
        THEN
            l_res.INPUT_VERSION_OK := T_INPUT.OK;
        ELSE
            l_res.INPUT_VERSION_OK := T_INPUT.NOK;
        END IF;

        RETURN l_res;
    END checkCustomRoundParams;

    /**************************************************************************
     *********************** PUBLIC SECTION ***********************************
     **************************************************************************/

    ----------------------------------------------------------------------------
    -- @name getNextRoundInfo
    ----------------------------------------------------------------------------
    PROCEDURE getNextRoundInfo(o_cur OUT SYS_REFCURSOR)
    IS
        l_next_round  NEW_ROUND := getNextRound();
    BEGIN
        OPEN o_cur FOR
            SELECT
                   l_next_round.YEAR as "year"
            ,      DESCR as "periodDesc"
            ,      PERIOD_ID || ' ' || l_next_round.YEAR as "title"
            ,      PERIOD_SID as "periodSid"
            FROM PERIODS
            WHERE PERIOD_SID = l_next_round.PERIOD_SID;
    END getNextRoundInfo;

    ----------------------------------------------------------------------------
    -- @name getRounds
    ----------------------------------------------------------------------------
    PROCEDURE getRounds(o_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT
                R.ROUND_SID AS "roundSid"
            ,   R.YEAR AS "year"
            ,   P.DESCR AS "periodDesc"
            ,   R.DESCR AS "title"
            ,   CASE WHEN R.ROUND_SID = CORE_GETTERS.getCurrentRoundSid() THEN T_ACTIVATION.ACTIVE ELSE T_ACTIVATION.INACTIVE END as "isActive"
            ,   R.ACTIVATED AS "activated"
            ,   R.ACTIVATION_DATE AS "activationDate"
            ,   R.ACTIVATION_USER AS "activationUser"
            ,   R.VERSION AS "version"
            FROM ROUNDS R JOIN PERIODS P ON R.PERIOD_SID = P.PERIOD_SID
            WHERE P.ROUND_TYPE = 'N'
            ORDER BY R.YEAR DESC, P.ORDER_PERIOD DESC, R.VERSION DESC;
    END getRounds;

    ----------------------------------------------------------------------------
    -- @name checkNewRoundPreconditions
    ----------------------------------------------------------------------------
    PROCEDURE checkNewRoundPreconditions(p_year                   IN     NUMBER
,                                        p_period_sid             IN     NUMBER
,                                        o_input_year_ok          OUT    NUMBER
,                                        o_input_period_sid_ok    OUT    NUMBER
,                                        o_storage_ok             OUT    NUMBER)
    IS
        l_round_params_check  NEW_ROUND_PARAM_CHECK := checkNewRoundParams(p_year, p_period_sid);
    BEGIN
        o_input_year_ok := l_round_params_check.INPUT_YEAR_OK;
        o_input_period_sid_ok := l_round_params_check.INPUT_PERIOD_SID_OK;
        o_storage_ok := checkStorage();
    END checkNewRoundPreconditions;

    ----------------------------------------------------------------------------
    -- @name createNewRound
    ----------------------------------------------------------------------------
    PROCEDURE createNewRound(p_year                   IN     NUMBER
,                            p_period_sid             IN     NUMBER
,                            p_desc                   IN     VARCHAR2
,                            o_input_year_ok          OUT    NUMBER
,                            o_input_period_sid_ok    OUT    NUMBER
,                            o_grid_round_app_id      OUT    VARCHAR2
,                            o_grids_ok               OUT    NUMBER)
    IS
        l_round_params_check       NEW_ROUND_PARAM_CHECK := checkNewRoundParams(p_year, p_period_sid);
        l_current_round_sid        NUMBER := CORE_GETTERS.getCurrentRoundSid();
        l_new_round_sid            NUMBER;
        l_previous_grid_round_sid  NUMBER;
        e_next_round               EXCEPTION;
       
    BEGIN
        SAVEPOINT begin_new_round;

        o_input_year_ok := l_round_params_check.INPUT_YEAR_OK;
        o_input_period_sid_ok := l_round_params_check.INPUT_PERIOD_SID_OK;

        IF o_input_year_ok = T_INPUT.OK AND o_input_period_sid_ok = T_INPUT.OK
        THEN
            -- insert new round
            INSERT INTO ROUNDS (YEAR, PERIOD_SID, DESCR, ACTIVATED)
            VALUES (p_year, p_period_sid, p_desc, T_ACTIVATION.INACTIVE)
            RETURNING ROUND_SID INTO l_new_round_sid;

            -- add applications participating in the new round
            INSERT INTO ROUND_APPLICATIONS (ROUND_SID, APP_SID)
            SELECT l_new_round_sid
            ,      APP_SID
            FROM PERIOD_APPLICATIONS
            WHERE PERIOD_SID = p_period_sid;

            -- check for which grid app (SCP or DBP) is the current round
            BEGIN
                SELECT A.APP_ID
                INTO o_grid_round_app_id
                FROM ROUND_APPLICATIONS R JOIN APPLICATIONS A ON A.APP_SID = R.APP_SID
                WHERE   R.ROUND_SID = l_new_round_sid
                    AND A.APP_ID IN (t_app_id.DBP, t_app_id.SCP);
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    o_grid_round_app_id := NULL;
            END;
            
            -- TODO: refactor the below, so it does not tightly couple FDMS with DBP and SCP
            -- if SCP or DBP round then prepare the grids
            IF o_grid_round_app_id IS NOT NULL
            THEN
                l_previous_grid_round_sid := CORE_GETTERS.getLatestApplicationRound(o_grid_round_app_id, l_current_round_sid);
                o_grids_ok := GD_ROUND.prepareNextRound(l_previous_grid_round_sid, l_new_round_sid);

                IF o_grids_ok != T_INPUT.OK
                THEN
                    RAISE e_next_round;
                END IF;
            END IF;
        END IF;
        EXCEPTION WHEN e_next_round THEN
            ROLLBACK TO begin_new_round;
            RAISE;
    END createNewRound;

    ----------------------------------------------------------------------------
    -- @name createCustomRound
    ----------------------------------------------------------------------------
    PROCEDURE createCustomRound(p_year                   IN     NUMBER
,                               p_period_sid             IN     NUMBER
,                               p_version                IN     NUMBER
,                               p_desc                   IN     VARCHAR2
,                               o_input_year_ok          OUT    NUMBER
,                               o_input_period_sid_ok    OUT    NUMBER
,                               o_input_version_ok       OUT    NUMBER)
    IS
        l_round_params_check       CUSTOM_ROUND_PARAM_CHECK := checkCustomRoundParams(p_year, p_period_sid, p_version);
        l_current_round_sid        NUMBER := CORE_GETTERS.getCurrentRoundSid();
        l_new_round_sid            NUMBER;
        l_previous_grid_round_sid  NUMBER;
        e_next_round               EXCEPTION;

    BEGIN
        SAVEPOINT begin_new_round;

        o_input_year_ok := l_round_params_check.INPUT_YEAR_OK;
        o_input_period_sid_ok := l_round_params_check.INPUT_PERIOD_SID_OK;
        o_input_version_ok := l_round_params_check.INPUT_VERSION_OK;

        IF o_input_year_ok = T_INPUT.OK AND o_input_period_sid_ok = T_INPUT.OK AND o_input_version_ok = T_INPUT.OK
        THEN
            -- insert new round
            INSERT INTO ROUNDS (YEAR, PERIOD_SID, DESCR, ACTIVATED, VERSION)
            VALUES (p_year, p_period_sid, p_desc, T_ACTIVATION.INACTIVE, p_version)
            RETURNING ROUND_SID INTO l_new_round_sid;

            -- add FDMS to the new custom round
            INSERT INTO ROUND_APPLICATIONS (ROUND_SID, APP_SID)
            VALUES (l_new_round_sid, FDMS_GETTERS.getCurrentAppSid());

            -- add DFM to the new custom round
            INSERT INTO ROUND_APPLICATIONS (ROUND_SID, APP_SID)
            VALUES (l_new_round_sid, DFM_GETTERS.getCurrentAppSid());

            -- add DRM to the new custom round
            INSERT INTO ROUND_APPLICATIONS (ROUND_SID, APP_SID)
            VALUES (l_new_round_sid, DRM_GETTERS.getCurrentAppSid());

        END IF;
        EXCEPTION WHEN dup_val_on_index THEN
            ROLLBACK TO begin_new_round;
            RAISE;
    END createCustomRound;

    ----------------------------------------------------------------------------
    -- @name checkActivateRound
    ----------------------------------------------------------------------------
    PROCEDURE checkActivateRound(p_round_sid        IN    NUMBER
,                                o_round_ok        OUT    NUMBER
,                                o_storage_ok      OUT    NUMBER
,                                o_app_status_cur  OUT    SYS_REFCURSOR)
    IS
    BEGIN
        -- check round
        BEGIN
            SELECT 1
            INTO o_round_ok
            FROM ROUNDS
            WHERE ROUND_SID = p_round_sid
              AND ACTIVATED = T_ACTIVATION.INACTIVE;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                o_round_ok := T_INPUT.NOK;
        END;

        -- check storage
        o_storage_ok := checkStorage();

        -- get app status
        OPEN o_app_status_cur FOR
            SELECT A.APP_ID AS "appId",
                   S.APP_DESCR AS "status",
                   CASE WHEN S.STATUS_ID = T_STATUS_REPO.OPEN THEN 0 ELSE 1 END AS "statusChange"
              FROM ROUND_APPLICATIONS RA
              JOIN APPLICATIONS A ON RA.APP_SID = A.APP_SID
              JOIN ST_STATUS_REPO S ON A.STATUS_SID = S.STATUS_SID
             WHERE RA.ROUND_SID = p_round_sid;
    END checkActivateRound;

    ----------------------------------------------------------------------------
    -- @name activateRound
    ----------------------------------------------------------------------------
    PROCEDURE activateRound(p_round_sid  IN   NUMBER
,                           p_user       IN   VARCHAR2
,                           o_res        OUT  NUMBER)
    IS
        l_new_round_sid      NUMBER;
        l_open_status_sid    NUMBER := CORE_GETTERS.getStatusSid (T_STATUS_REPO.OPEN);
        l_current_round_sid  ROUNDS.ROUND_SID%TYPE := CORE_GETTERS.getCurrentRoundSid();
        l_round_check        NUMBER;
        l_new_round_version  NUMBER;
        e_spr_upd            EXCEPTION;
    BEGIN
        -- check if the round exists and was not activated
        SELECT ROUND_SID
        INTO l_new_round_sid
        FROM ROUNDS
        WHERE ROUND_SID = p_round_sid
          AND ACTIVATED = T_ACTIVATION.INACTIVE;

       -- make round active
       UPDATE ROUNDS
          SET ACTIVATED = T_ACTIVATION.ACTIVE
       ,      ACTIVATION_DATE = CURRENT_TIMESTAMP
       ,      ACTIVATION_USER = p_user
        WHERE ROUND_SID = l_new_round_sid;

        -- set current round parameter
        UPDATE PARAMS
        SET VALUE = l_new_round_sid
        WHERE PARAM_ID = T_PARAMS.CURRENT_ROUND;
        o_res := SQL%ROWCOUNT;

        -- if version > 1 set storage to
        SELECT VERSION
          INTO l_new_round_version
          FROM ROUNDS
         WHERE ROUND_SID = l_new_round_sid;

        -- reset custom storage
        UPDATE DFM_PARAMS
        SET VALUE = NULL
        WHERE PARAM_ID = T_DFM_PARAMS.CURRENT_CUST_STORAGE;
        o_res := o_res + SQL%ROWCOUNT;

         IF l_new_round_version <= 1
         THEN
            -- set first storage as active
            UPDATE PARAMS
            SET VALUE = (SELECT STORAGE_SID FROM STORAGES WHERE ORDER_BY = 1)
            WHERE PARAM_ID = CORE_GETTERS.CURRENT_STORAGE_PARAM;
            o_res := o_res + SQL%ROWCOUNT;
        ELSE
            -- set FINAL storage as active
            UPDATE PARAMS
            SET VALUE = CORE_GETTERS.getStorageSid(CORE_GETTERS.FINAL_STORAGE_ID)
            WHERE PARAM_ID = CORE_GETTERS.CURRENT_STORAGE_PARAM;
            o_res := o_res + SQL%ROWCOUNT;
        END IF;

        -- reset application status
        UPDATE APPLICATIONS
        SET STATUS_SID = l_open_status_sid
        WHERE APP_SID IN (SELECT APP_SID FROM ROUND_APPLICATIONS WHERE ROUND_SID = l_new_round_sid);

         -- cleanup upload data
         FDMS_UPLOAD.removeOldFiles(l_current_round_sid);
    END activateRound;

   ----------------------------------------------------------------------------
   -- @name moveToNextStorage - procedure used to change current storage
   ----------------------------------------------------------------------------
   PROCEDURE moveToNextStorage (p_round_sid   IN  NUMBER
,                               p_storage_sid IN  NUMBER
,                               o_res         OUT NUMBER)
   IS
      l_next_storage_sid   NUMBER;
      l_app_status_id   VARCHAR2 (10 BYTE) := NULL;
   BEGIN
      -- Check if app status is OPEN
      CORE_GETTERS.getApplicationStatus (T_APP_ID.FDMS, l_app_status_id);

      -- Check if passed in parameters correspond to the current storage
      IF    l_app_status_id != T_STATUS_REPO.OPEN
         OR FDMS_GETTERS.isCurrentStorage (p_round_sid
,                                          p_storage_sid) = 0
      THEN
        o_res := -1;
      ELSE
          -- get next storage sid
          BEGIN
              SELECT NEXT_STORAGE_SID
              INTO l_next_storage_sid
              FROM STORAGES
              WHERE STORAGE_SID = p_storage_sid;
          EXCEPTION
              WHEN NO_DATA_FOUND
                  THEN l_next_storage_sid := NULL;
          END;

          IF l_next_storage_sid IS NOT NULL
          THEN
             UPDATE PARAMS
                SET VALUE = l_next_storage_sid
              WHERE PARAM_ID = CORE_GETTERS.CURRENT_STORAGE_PARAM;

              o_res := SQL%ROWCOUNT;
          ELSE
              CORE_APP_STATUS.setApplicationStatus(FDMS_GETTERS.APP_ID, T_STATUS_REPO.OPEN, T_STATUS_REPO.ST_CLOSED, o_res);

              o_res := SQL%ROWCOUNT;
          END IF;
      END IF;
   END moveToNextStorage;

    ----------------------------------------------------------------------------
    -- @name getPeriods
    ----------------------------------------------------------------------------
    PROCEDURE getPeriods(o_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT
                PERIOD_SID AS "periodSid"
            ,   PERIOD_ID AS "periodId"
            ,   DESCR AS "descr"
            ,   ORDER_PERIOD AS "order"
            FROM PERIODS
            WHERE ROUND_TYPE = 'N'
            ORDER BY ORDER_PERIOD ASC;
    END getPeriods;

    ----------------------------------------------------------------------------
    -- @name getLatestVersion
    ----------------------------------------------------------------------------
    PROCEDURE getLatestVersion(p_year        IN  NUMBER
,                              p_period_sid  IN  NUMBER
,                              o_res         OUT NUMBER)
    IS
    BEGIN
        SELECT MAX(VERSION)
          INTO o_res
          FROM ROUNDS
         WHERE YEAR = p_year
           AND PERIOD_SID = p_period_sid;
    END getLatestVersion;

END FDMS_ROUND;
