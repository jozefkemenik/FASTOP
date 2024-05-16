/* Formatted on 07-07-2021 13:56:07 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY CORE_GETTERS
AS
   /******************************************************************************
      NAME:       CORE_GETTERS
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        27/03/2019   lubiesz       1. Created this package.
   ******************************************************************************/

   /**************************************************************************
    *********************** PRIVATE SECTION **********************************
    **************************************************************************/

   T_APP_ID CORE_TYPES.T_APP_ID;

   ----------------------------------------------------------------------------
   -- @name getAppStorageSid - gets current storage for the app
   ----------------------------------------------------------------------------
   FUNCTION getAppStorageSid(p_app_id IN VARCHAR2, p_storage_sid IN NUMBER)
      RETURN NUMBER
   IS
      l_app_sid       APPLICATIONS.APP_SID%TYPE := getApplicationSid(p_app_id);
      ret_storage_sid STORAGES.STORAGE_SID%TYPE;
   BEGIN
      -- the first storage assigned to the app which is not smaller than p_storage_sid
      SELECT S.STORAGE_SID
        INTO ret_storage_sid
        FROM STORAGES S
       WHERE S.ORDER_BY =
             (SELECT MIN(S2.ORDER_BY)
                FROM STORAGES  S1
                     JOIN STORAGES S2
                        ON S1.STORAGE_SID = p_storage_sid
                       AND S2.ORDER_BY >= S1.ORDER_BY
                       AND S2.IS_CUSTOM = 'N'
                     JOIN STORAGE_APPLICATIONS A
                        ON A.APP_SID = l_app_sid AND S2.STORAGE_SID = A.STORAGE_SID);

      RETURN ret_storage_sid;
   END getAppStorageSid;

   /**************************************************************************
    *********************** PUBLIC SECTION ***********************************
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name currentOrPassedRound
   ----------------------------------------------------------------------------
   FUNCTION currentOrPassedRound(p_round_sid IN NUMBER, p_app_id IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   AS
      l_round_sid ROUNDS.ROUND_SID%TYPE;
   BEGIN
      IF p_round_sid IS NULL OR p_round_sid = 0 THEN
         l_round_sid := getCurrentRoundSid(p_app_id);
      ELSE
         l_round_sid := p_round_sid;
      END IF;

      RETURN l_round_sid;
   END currentOrPassedRound;

   ----------------------------------------------------------------------------
   -- @name getApplicationSid
   ----------------------------------------------------------------------------
   FUNCTION getApplicationSid(p_app_id IN VARCHAR2)
      RETURN NUMBER
   IS
      l_app_sid APPLICATIONS.APP_SID%TYPE;
   BEGIN
      BEGIN
         SELECT app_sid
           INTO l_app_sid
           FROM APPLICATIONS
          WHERE UPPER(app_id) = UPPER(p_app_id);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_app_sid := NULL;
      END;

      RETURN l_app_sid;
   END getApplicationSid;

   ----------------------------------------------------------------------------
   -- @name getApplicationStatus
   ----------------------------------------------------------------------------
   FUNCTION getApplicationStatus(p_app_id IN VARCHAR2)
      RETURN VARCHAR2
   IS
      l_app_status_id ST_STATUS_REPO.STATUS_ID%TYPE;
   BEGIN
      BEGIN
         SELECT S.STATUS_ID
           INTO l_app_status_id
           FROM APPLICATIONS A LEFT JOIN ST_STATUS_REPO S ON A.STATUS_SID = S.STATUS_SID
          WHERE UPPER(A.APP_ID) = UPPER(p_app_id);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_app_status_id := NULL;
      END;

      RETURN l_app_status_id;
   END getApplicationStatus;

   ----------------------------------------------------------------------------
   -- @name getApplicationStatus
   ----------------------------------------------------------------------------
   PROCEDURE getApplicationStatus(p_app_id IN VARCHAR2, o_status_id OUT VARCHAR2)
   IS
   BEGIN
      o_status_id := getApplicationStatus(p_app_id);
   END getApplicationStatus;

   ----------------------------------------------------------------------------
   -- @name getCountries
   ----------------------------------------------------------------------------
   PROCEDURE getCountries(p_country_ids IN CORE_COMMONS.VARCHARARRAY, o_cur OUT SYS_REFCURSOR)
   IS
      l_country_ids     VARCHARLIST := CORE_COMMONS.arrayToList(p_country_ids);
   BEGIN
      OPEN o_cur FOR SELECT GEO_AREA_ID AS COUNTRY_ID
                          , DESCR
                          , CODEISO3
                          , CODE_FGD
                          , ORDER_BY
                       FROM GEO_AREAS
                      WHERE GEO_AREA_ID IN (SELECT * FROM TABLE(l_country_ids));
   END getCountries;

   ----------------------------------------------------------------------------
   -- @name getCountries
   ----------------------------------------------------------------------------
   PROCEDURE getCountries(cur              OUT SYS_REFCURSOR
                        , p_app_id      IN     VARCHAR2 DEFAULT NULL
                        , p_active_only IN     NUMBER DEFAULT 1)
   IS
      l_country_group_id COUNTRY_GROUPS.COUNTRY_GROUP_ID%TYPE := 'EU';
   BEGIN
      IF p_app_id IS NOT NULL THEN
         BEGIN
            SELECT COALESCE(A.COUNTRY_GROUP_ID, 'EU')
              INTO l_country_group_id
              FROM APPLICATIONS A
             WHERE UPPER(A.APP_ID) = UPPER(p_app_id);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               l_country_group_id := 'EU';
         END;
      END IF;

      getCountryGroupCountries(l_country_group_id, cur, p_active_only);
   END getCountries;

   ----------------------------------------------------------------------------
   -- @name getCountryGroupCountries
   ----------------------------------------------------------------------------
   PROCEDURE getCountryGroupCountries(p_country_group_id IN     VARCHAR2
                                    , o_cur                 OUT SYS_REFCURSOR
                                    , p_active_only      IN     NUMBER DEFAULT 1)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT C.*
             FROM COUNTRIES C JOIN COUNTRY_GROUPS CG ON CG.COUNTRY_ID = C.COUNTRY_ID
            WHERE CG.COUNTRY_GROUP_ID = p_country_group_id
              AND (p_active_only = 0 OR CG.IS_ACTIVE = p_active_only)
         ORDER BY CG.ORDER_BY, C.ORDER_BY;
   END getCountryGroupCountries;

   ----------------------------------------------------------------------------
   -- @name getGeoAreasByCountryGroup
   ----------------------------------------------------------------------------
   PROCEDURE getGeoAreasByCountryGroup(p_country_group_id IN     VARCHAR2
                                     , o_cur                 OUT SYS_REFCURSOR
                                     , p_active_only      IN     NUMBER DEFAULT 1)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT G.GEO_AREA_ID AS COUNTRY_ID, G.CODEISO3, G.CODE_FGD, G.DESCR
             FROM GEO_AREAS G JOIN COUNTRY_GROUPS CG ON CG.COUNTRY_ID = G.GEO_AREA_ID
            WHERE UPPER(CG.COUNTRY_GROUP_ID) = UPPER(p_country_group_id)
              AND (p_active_only = 0 OR CG.IS_ACTIVE = p_active_only)
         ORDER BY CG.ORDER_BY, G.ORDER_BY;
   END getGeoAreasByCountryGroup;

   ----------------------------------------------------------------------------
   -- @name getCurrentRound
   ----------------------------------------------------------------------------
   PROCEDURE getCurrentRound(p_app_id IN VARCHAR2 DEFAULT NULL, o_cur OUT SYS_REFCURSOR)
   IS
      l_current_round ROUNDS.ROUND_SID%TYPE := CORE_GETTERS.getCurrentRoundSid(p_app_id);
   BEGIN
      OPEN o_cur FOR SELECT *
                       FROM vw_rounds
                      WHERE round_sid = l_current_round;
   END getCurrentRound;

   ----------------------------------------------------------------------------
   -- @name getCurrentRoundSid
   ----------------------------------------------------------------------------
   FUNCTION getCurrentRoundSid(p_app_id IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      l_round_param NUMBER(4);
   BEGIN
      l_round_param := TO_NUMBER(CORE_GETTERS.getParameter('CURRENT_ROUND'));
      RETURN getLatestApplicationRound(p_app_id, l_round_param);
   END getCurrentRoundSid;

   ----------------------------------------------------------------------------
   -- @name getCurrentStorageSid
   ----------------------------------------------------------------------------
   FUNCTION getCurrentStorageSid(p_app_id IN VARCHAR2)
      RETURN NUMBER
   IS
   BEGIN
      RETURN getAppStorageSid(p_app_id
                            , CORE_GETTERS.getParameter(CORE_GETTERS.CURRENT_STORAGE_PARAM));
   END getCurrentStorageSid;

   ----------------------------------------------------------------------------
   -- @name getEU27CountryCodes
   ----------------------------------------------------------------------------
   PROCEDURE getEU27CountryCodes(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR   SELECT COUNTRY_ID
                         FROM VW_EU27_COUNTRIES
                     ORDER BY COUNTRY_ID ASC;
   END getEU27CountryCodes;

   ----------------------------------------------------------------------------
   -- @name getGeoAreas
   ----------------------------------------------------------------------------
   PROCEDURE getGeoAreas(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR   SELECT GEO_AREA_ID AS "geoAreaId", CODEISO3 AS "codeIso3"
                         FROM GEO_AREAS
                     ORDER BY ORDER_BY;
   END getGeoAreas;

   ----------------------------------------------------------------------------
   -- @name getLatestApplicationRound
   ----------------------------------------------------------------------------
   FUNCTION getLatestApplicationRound(p_app_id         IN VARCHAR2
                                    , p_round_sid      IN NUMBER
                                    , p_history_offset IN NUMBER DEFAULT 0)
      RETURN NUMBER
   IS
      l_app_sid             APPLICATIONS.APP_SID%TYPE;
      l_latest_round        ROUNDS.ROUND_SID%TYPE := p_round_sid;
      l_latest_year         ROUNDS.YEAR%TYPE;
      l_latest_order_period PERIODS.ORDER_PERIOD%TYPE;
      l_latest_version      ROUNDS.VERSION%TYPE;
   BEGIN
      IF p_app_id IS NOT NULL THEN
         SELECT R.YEAR, R.ORDER_PERIOD, R.VERSION
           INTO l_latest_year, l_latest_order_period, l_latest_version
           FROM VW_ROUNDS R
          WHERE R.ROUND_SID = p_round_sid;

         -- Check if the APP_SID called by the function exists in the DB
         BEGIN
            SELECT APP_SID
              INTO l_app_sid
              FROM APPLICATIONS
             WHERE UPPER(APP_ID) = UPPER(p_app_id);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               raise_application_error(
                  -20001
                , 'Application not defined - ' || SQLCODE || ' -ERROR- ' || SQLERRM
               );
         END;

         BEGIN
            SELECT t.round_sid
              INTO l_latest_round
              FROM (SELECT R.ROUND_SID
                         , ROW_NUMBER() OVER (ORDER BY R.YEAR DESC, R.ORDER_PERIOD DESC, R.VERSION DESC) AS row_num
                      FROM ROUND_APPLICATIONS RA JOIN VW_ROUNDS R ON RA.ROUND_SID = R.ROUND_SID
                     WHERE RA.APP_SID = l_app_sid
                       AND R.ACTIVATED = 1
                       AND R.ROUND_TYPE = 'N'
                       AND (R.YEAR < l_latest_year
                         OR (R.YEAR = l_latest_year AND R.ORDER_PERIOD < l_latest_order_period)
                         OR (R.YEAR = l_latest_year
                         AND R.ORDER_PERIOD = l_latest_order_period
                         AND R.VERSION <= l_latest_version))) t
             WHERE t.row_num = 1 + p_history_offset;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               l_latest_round := p_round_sid;
         END;
      END IF;

      RETURN l_latest_round;
   END getLatestApplicationRound;

   ----------------------------------------------------------------------------
   -- @name getLatestApplicationRound
   ----------------------------------------------------------------------------
   PROCEDURE getLatestApplicationRound(o_res          OUT NUMBER
                                     , p_app_id    IN     VARCHAR2
                                     , p_round_sid IN     NUMBER)
   IS
   BEGIN
      SELECT getLatestApplicationRound(p_app_id, p_round_sid) INTO o_res FROM DUAL;
   END getLatestApplicationRound;

   ----------------------------------------------------------------------------
   -- @name getParameter
   ----------------------------------------------------------------------------
   FUNCTION getParameter(p_param_id IN VARCHAR2)
      RETURN VARCHAR2
   IS
      c1rec PARAMS%ROWTYPE;

      CURSOR c1
      IS
         SELECT *
           FROM PARAMS
          WHERE param_id = p_param_id;
   BEGIN
      OPEN c1;

      FETCH c1 INTO c1Rec;

      CLOSE c1;

      RETURN c1Rec.VALUE;
   END getParameter;

   ----------------------------------------------------------------------------
   -- @name getParameter
   ----------------------------------------------------------------------------
   PROCEDURE getParameter(p_param_id IN     VARCHAR2
                        , o_descr       OUT VARCHAR2
                        , o_value       OUT VARCHAR2)
   IS
   BEGIN
      SELECT DESCR
           , VALUE
        INTO o_descr
           , o_value
        FROM PARAMS
       WHERE PARAM_ID = p_param_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         o_descr := NULL;
         o_value := NULL;
   END getParameter;

   ----------------------------------------------------------------------------
   -- @name getRoundInfo
   ----------------------------------------------------------------------------
   PROCEDURE getRoundInfo(o_round_sid    OUT NUMBER
                        , o_year         OUT NUMBER
                        , o_descr        OUT VARCHAR2
                        , o_period       OUT VARCHAR2
                        , o_period_id    OUT VARCHAR2
                        , o_version      OUT NUMBER
                        , p_app_id    IN     VARCHAR2 DEFAULT NULL
                        , p_round_sid IN     NUMBER DEFAULT NULL)
   AS
      l_round_sid ROUNDS.ROUND_SID%TYPE
                     := COALESCE(p_round_sid, CORE_GETTERS.GETCURRENTROUNDSID(p_app_id));
   BEGIN
      SELECT R.ROUND_SID
           , R.YEAR
           , R.DESCR
           , P.DESCR PERIOD
           , P.PERIOD_ID
           , R.VERSION
        INTO o_round_sid
           , o_year
           , o_descr
           , o_period
           , o_period_id
           , o_version
        FROM ROUNDS R JOIN PERIODS P ON P.PERIOD_SID = R.PERIOD_SID
       WHERE R.ROUND_SID = l_round_sid;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         o_round_sid := NULL;
         o_period_id := NULL;
         o_period    := NULL;
         o_year      := NULL;
         o_descr     := NULL;
         o_version   := NULL;
   END;

   ----------------------------------------------------------------------------
   -- @name getRounds
   ----------------------------------------------------------------------------
   PROCEDURE getRounds(o_cur OUT SYS_REFCURSOR, p_app_id IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT R.ROUND_SID, R.YEAR, R.PERIOD_DESCR, R.VERSION, R.DESCR
             FROM VW_ROUNDS R
            WHERE R.ACTIVATED >= 0
              AND (p_app_id IS NULL
                   OR UPPER(p_app_id) = T_APP_ID.DFM
                   OR R.ROUND_SID IN
                         (SELECT RA.ROUND_SID
                            FROM ROUND_APPLICATIONS RA JOIN APPLICATIONS A ON A.APP_SID = RA.APP_SID
                           WHERE UPPER(A.APP_ID) = UPPER(p_app_id))
                  )
         ORDER BY R.YEAR DESC, R.ORDER_PERIOD DESC, R.VERSION DESC;
   END getRounds;

   ----------------------------------------------------------------------------
   -- @name getRoundYear
   ----------------------------------------------------------------------------
   PROCEDURE getRoundYear(p_round_sid IN NUMBER, o_res OUT NUMBER)
   IS
   BEGIN
      BEGIN
         SELECT YEAR
           INTO o_res
           FROM ROUNDS
          WHERE ROUND_SID = p_round_sid;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            o_res := NULL;
      END;
   END getRoundYear;

   ----------------------------------------------------------------------------
   -- @name getRoundSid
   ----------------------------------------------------------------------------
   PROCEDURE getRoundSid(p_year    IN      NUMBER
                       , p_period  IN      VARCHAR2
                       , p_version IN      NUMBER
                       , o_res         OUT NUMBER)
   IS
   BEGIN
      BEGIN
         SELECT ROUND_SID
           INTO o_res
           FROM VW_ROUNDS
          WHERE YEAR = p_year
            AND UPPER(PERIOD_ID) = UPPER(p_period)
            AND VERSION = p_version;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            o_res := NULL;
      END;
   END getRoundSid;

   ----------------------------------------------------------------------------
   -- @name getScales
   ----------------------------------------------------------------------------
   PROCEDURE getScales(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
         SELECT SCALE_SID AS "sid", SCALE_ID AS "id", DESCR AS "description" FROM scales
         UNION ALL
         SELECT -1, NULL, '< not set >'
           FROM DUAL;
   END;

   ----------------------------------------------------------------------------
   -- @name getStatusSid
   ----------------------------------------------------------------------------
   FUNCTION getStatusSid(p_status_id IN VARCHAR2)
      RETURN NUMBER
   IS
      l_status_sid ST_STATUS_REPO.STATUS_SID%TYPE;
   BEGIN
      BEGIN
         SELECT status_sid
           INTO l_status_sid
           FROM ST_STATUS_REPO
          WHERE status_id = p_status_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_status_sid := NULL;
      END;

      RETURN l_status_sid;
   END getStatusSid;

   ----------------------------------------------------------------------------
   -- @name getStorageInfo
   ----------------------------------------------------------------------------
   PROCEDURE getStorageInfo(o_storage_sid    OUT NUMBER
                          , o_descr          OUT VARCHAR2
                          , o_storage_id     OUT VARCHAR2
                          , p_app_id      IN     VARCHAR2
                          , p_storage_sid IN     NUMBER DEFAULT NULL)
   AS
      l_storage_sid STORAGES.STORAGE_SID%TYPE
                       := COALESCE(p_storage_sid, getCurrentStorageSid(p_app_id));
   BEGIN
      SELECT S.STORAGE_SID, S.DESCR, S.STORAGE_ID
        INTO o_storage_sid, o_descr, o_storage_id
        FROM storages S
       WHERE S.STORAGE_SID = l_storage_sid;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         o_storage_sid := NULL;
         o_descr       := NULL;
         o_storage_id  := NULL;
   END;

   ----------------------------------------------------------------------------
   -- @name getStorages
   ----------------------------------------------------------------------------
   PROCEDURE getStorages(p_app_id IN VARCHAR2, o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR   SELECT S.STORAGE_SID                                      AS "storageSid"
                            , S.STORAGE_ID                                       AS "storageId"
                            , S.DESCR                                            AS "descr"
                            , S.ALT_DESCR                                        AS "altDescr"
                            , S.ORDER_BY                                         AS "orderBy"
                            , (CASE S.IS_CUSTOM    WHEN 'Y' THEN 1 ELSE 0 END)   AS "isCustom"
                            , (CASE S.IS_PERMANENT WHEN 'Y' THEN 1 ELSE 0 END)   AS "isPermanent"
                            , (CASE S.IS_FULL      WHEN 'Y' THEN 1 ELSE 0 END)   AS "isFull"
                         FROM STORAGES S
                              JOIN STORAGE_APPLICATIONS SA ON S.STORAGE_SID = SA.STORAGE_SID
                              JOIN APPLICATIONS A ON SA.APP_SID = A.APP_SID
                        WHERE UPPER(A.APP_ID) = UPPER(p_app_id)
                     ORDER BY S.ORDER_BY;
   END getStorages;

   ----------------------------------------------------------------------------
   -- @name getStorageSid
   ----------------------------------------------------------------------------
   FUNCTION getStorageSid(p_storage_id IN VARCHAR2)
      RETURN NUMBER
   IS
      l_storage_sid STORAGES.STORAGE_SID%TYPE;
   BEGIN
      BEGIN
         SELECT S.STORAGE_SID
           INTO l_storage_sid
           FROM storages s
          WHERE S.STORAGE_ID = p_storage_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_storage_sid := NULL;
      END;

      RETURN l_storage_sid;
   END getStorageSid;

   ----------------------------------------------------------------------------
   -- @name getStorageSid
   ----------------------------------------------------------------------------
   PROCEDURE getStorageSid(p_storage_id IN VARCHAR2, o_res OUT NUMBER)
   AS
   BEGIN
      SELECT getStorageSid(p_storage_id) INTO o_res FROM DUAL;
   END getStorageSid;

   ----------------------------------------------------------------------------
   -- @name isCurrentStorage - function used to verify if passed in
   --    parameters correspond to the current storage
   -- @return 1 if ok, 0 if failed
   ----------------------------------------------------------------------------
   FUNCTION isCurrentStorage(p_app_id IN VARCHAR2, p_round_sid IN NUMBER, p_storage_sid IN NUMBER)
      RETURN NUMBER
   IS
      l_ret NUMBER(1) := 1;
   BEGIN
      IF p_round_sid != CORE_GETTERS.getCurrentRoundSid(p_app_id)
      OR p_storage_sid != getCurrentStorageSid(p_app_id) THEN
         l_ret := 0;
      END IF;

      RETURN l_ret;
   END isCurrentStorage;

   ----------------------------------------------------------------------------
   -- @name isCurrentStorageFinal
   ----------------------------------------------------------------------------
   FUNCTION isCurrentStorageFinal(p_app_id IN VARCHAR2)
      RETURN NUMBER
   IS
      l_final_storage_sid   STORAGES.STORAGE_SID%TYPE
                               := CORE_GETTERS.getStorageSid(CORE_GETTERS.FINAL_STORAGE_ID);
      l_current_storage_sid STORAGES.STORAGE_SID%TYPE := getCurrentStorageSid(p_app_id);
      l_ret                 NUMBER(1) := 0;
   BEGIN
      IF l_final_storage_sid = l_current_storage_sid THEN
         l_ret := 1;
      END IF;

      RETURN l_ret;
   END isCurrentStorageFinal;

   ----------------------------------------------------------------------------
   -- @name getYearsRange
   ----------------------------------------------------------------------------
   PROCEDURE getYearsRange(p_app_id IN VARCHAR2, o_res OUT NUMBER)
   IS
   BEGIN
      SELECT YEARS_RANGE
        INTO o_res
        FROM APPLICATIONS
       WHERE APP_ID = UPPER(p_app_id);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         o_res := 0;
   END getYearsRange;

   ----------------------------------------------------------------------------
   -- @name getGeoAreaMappings
   ----------------------------------------------------------------------------
   PROCEDURE getGeoAreaMappings(o_cur            OUT SYS_REFCURSOR
                              , p_mapping_ids IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               ))

   IS
      l_mapping_ids     VARCHARLIST := CORE_COMMONS.arrayToList(p_mapping_ids);
      l_mapping_count   NUMBER(3) := l_mapping_ids.COUNT;
   BEGIN
      OPEN o_cur FOR
         SELECT SOURCE_DESCR AS "source"
              , GEO_AREA_ID  AS "geoAreaId"
           FROM GEO_AREA_MAPPINGS
          WHERE ( l_mapping_count = 0
                  OR MAPPING_ID IS NULL
                  OR MAPPING_ID IN (SELECT * FROM TABLE(l_mapping_ids))
                );
   END getGeoAreaMappings;

   ----------------------------------------------------------------------------
   -- @name getRoundStorageInfo
   ----------------------------------------------------------------------------
   PROCEDURE getRoundStorageInfo(o_round_sid          OUT NUMBER
                               , o_round_id           OUT VARCHAR2
                               , o_storage_sid        OUT NUMBER
                               , o_storage_id         OUT VARCHAR2
                               , o_cust_text_sid      OUT NUMBER
                               , o_cust_text_id       OUT VARCHAR2
                               , p_round_sid      IN      NUMBER
                               , p_storage_sid    IN      NUMBER
                               , p_cust_text_sid  IN      NUMBER DEFAULT NULL)
   IS
   BEGIN
     BEGIN
         SELECT ROUND_SID, DESCR
           INTO o_round_sid, o_round_id
           FROM ROUNDS
          WHERE ROUND_SID = p_round_sid;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
          o_round_sid := NULL;
          o_round_id  := NULL;
     END;

     BEGIN
         SELECT STORAGE_SID, STORAGE_ID
           INTO o_storage_sid, o_storage_id
           FROM STORAGES
          WHERE STORAGE_SID = p_storage_sid;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
          o_storage_sid := NULL;
          o_storage_id  := NULL;
     END;

     BEGIN
         SELECT CUST_STORAGE_TEXT_SID, TITLE
           INTO o_cust_text_sid, o_cust_text_id
           FROM CUST_STORAGE_TEXTS
          WHERE CUST_STORAGE_TEXT_SID = p_cust_text_sid
            AND ROUND_SID = p_round_sid;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
          o_cust_text_sid := NULL;
          o_cust_text_id  := NULL;
     END;
   END getRoundStorageInfo;

   ----------------------------------------------------------------------------
   -- @name getApplicationCountries
   ----------------------------------------------------------------------------
   PROCEDURE getApplicationCountries(p_app_id IN     VARCHAR2
                                   , o_cur       OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
         SELECT CG.COUNTRY_ID
           FROM COUNTRY_GROUPS CG
           JOIN GEO_AREAS GA ON CG.COUNTRY_ID = GA.GEO_AREA_ID
           JOIN APPLICATIONS A ON A.COUNTRY_GROUP_ID = CG.COUNTRY_GROUP_ID
          WHERE UPPER(A.APP_ID) = UPPER(p_app_id)
            AND GA.GEO_AREA_TYPE = 'COUNTRY'
            AND CG.IS_ACTIVE = 1;
   END getApplicationCountries;

   ----------------------------------------------------------------------------
   -- @name getCurrency
   ----------------------------------------------------------------------------
   PROCEDURE getCurrency(p_geo_area_id IN    VARCHAR2
                       , o_currency      OUT VARCHAR2)
   IS
   BEGIN
       SELECT CURRENCY
         INTO o_currency
         FROM GEO_AREAS
        WHERE GEO_AREA_ID = p_geo_area_id;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        o_currency := NULL;
   END getCurrency;

END CORE_GETTERS;
/
