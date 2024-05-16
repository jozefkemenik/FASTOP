CREATE OR REPLACE PACKAGE BODY IDR_OG_PARAMS
AS
   ----------------------------------------------------------------------------
   -- @name getBaselineVariables
   ----------------------------------------------------------------------------
   PROCEDURE getBaselineVariables(o_cur  OUT  SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
        SELECT
               VARIABLE_SID     as "variableSid"
,              VARIABLE_ID      as "variableId"
,              COUNTRY_ID       as "countryId"
,              ORDER_BY         as "orderBy"
,              GROUP_BY_COUNTRY as "groupByCountry"
          FROM OG_BASELINE_VARIABLES
      ORDER BY ORDER_BY;
   END getBaselineVariables;

   ----------------------------------------------------------------------------
   -- @name getBaselineData
   ----------------------------------------------------------------------------
   PROCEDURE getBaselineData(o_cur         OUT  SYS_REFCURSOR
,                            p_round_sid   IN   NUMBER
,                            p_country_ids IN   CORE_COMMONS.VARCHARARRAY)

   IS
        l_country_ids  VARCHARLIST := NULL;
   BEGIN
      IF p_country_ids.COUNT > 0
      THEN
        l_country_ids := CORE_COMMONS.arrayToList (p_country_ids);
      END IF;

      OPEN o_cur FOR
        SELECT
               V.VARIABLE_ID as "variableId"
,              D.COUNTRY_ID  as "countryId"
,              D.YEAR        as "year"
,              D.VALUE       as "value"
          FROM OG_BASELINE_DATA D
          JOIN OG_BASELINE_VARIABLES V
            ON D.VARIABLE_SID = V.VARIABLE_SID
         WHERE D.ROUND_SID = p_round_sid
           AND ( l_country_ids IS NULL OR D.COUNTRY_ID IN ( SELECT * FROM TABLE (l_country_ids) ) );
   END getBaselineData;

   ----------------------------------------------------------------------------
   -- @name hasBaselineData
   ----------------------------------------------------------------------------
   PROCEDURE hasBaselineData(p_round_sid   IN   NUMBER
,                            p_country_id  IN   VARCHAR2
,                            o_res         OUT  NUMBER)
   IS
   BEGIN
      SELECT COUNT(*)
        INTO o_res
        FROM OG_BASELINE_DATA D
        JOIN OG_BASELINE_VARIABLES V
          ON D.VARIABLE_SID = V.VARIABLE_SID
       WHERE D.ROUND_SID = p_round_sid
         AND (p_country_id IS NULL OR D.COUNTRY_ID = p_country_id);
   END hasBaselineData;

   ----------------------------------------------------------------------------
   -- @name getCountryParams
   ----------------------------------------------------------------------------
   PROCEDURE getCountryParams(o_cur  OUT  SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
        SELECT
               PARAM_SID     as "paramSid"
,              PARAM_ID      as "paramId"
,              DATA_TYPE     as "dataType"
,              DEFAULT_VALUE as "defaultValue"
          FROM OG_COUNTRY_PARAMS
      ORDER BY ORDER_BY ASC;
   END getCountryParams;

   ----------------------------------------------------------------------------
   -- @name getCountryParamsData
   ----------------------------------------------------------------------------
   PROCEDURE getCountryParamsData(o_cur         OUT  SYS_REFCURSOR
,                                 p_round_sid   IN   NUMBER
,                                 p_country_ids IN   CORE_COMMONS.VARCHARARRAY)
   IS
        l_country_ids  VARCHARLIST := NULL;
   BEGIN
      IF p_country_ids.COUNT > 0
      THEN
        l_country_ids := CORE_COMMONS.arrayToList (p_country_ids);
      END IF;

      OPEN o_cur FOR
        SELECT
               D.COUNTRY_ID as "countryId"
,              P.PARAM_ID   as "paramId"
,              D.VALUE      as "value"
          FROM OG_COUNTRY_PARAMS_DATA D
          JOIN OG_COUNTRY_PARAMS P
            ON P.PARAM_SID = D.COUNTRY_PARAM_SID
         WHERE D.ROUND_SID = p_round_sid
           AND ( l_country_ids IS NULL OR D.COUNTRY_ID IN ( SELECT * FROM TABLE (l_country_ids) ) );
   END getCountryParamsData;

   ----------------------------------------------------------------------------
   -- @name hasCountryParamsData
   ----------------------------------------------------------------------------
   PROCEDURE hasCountryParamsData(p_round_sid   IN   NUMBER
,                                 p_country_id  IN   VARCHAR2
,                                 o_res         OUT  NUMBER)
   IS
   BEGIN
      SELECT COUNT(*)
        INTO o_res
        FROM OG_COUNTRY_PARAMS_DATA D
        JOIN OG_COUNTRY_PARAMS P
          ON P.PARAM_SID = D.COUNTRY_PARAM_SID
       WHERE D.ROUND_SID = p_round_sid
         AND (p_country_id IS NULL OR D.COUNTRY_ID = p_country_id);
   END hasCountryParamsData;

   ----------------------------------------------------------------------------
   -- @name uploadBaselineData
   ----------------------------------------------------------------------------
   PROCEDURE uploadBaselineData(p_round_sid         IN       NUMBER
,                               p_variable_sids     IN  OUT  CORE_COMMONS.SIDSARRAY
,                               p_country_ids       IN  OUT  CORE_COMMONS.VARCHARARRAY
,                               p_years             IN  OUT  CORE_COMMONS.SIDSARRAY
,                               p_values            IN  OUT  CORE_COMMONS.VARCHARARRAY
,                               o_res               OUT      NUMBER)
   IS
      l_updated_variable_sids SIDSLIST;
   BEGIN
      o_res := p_variable_sids.COUNT;

      -- Bulk update existing data and collect updated variables
      FORALL i IN 1 .. p_variable_sids.COUNT
            UPDATE OG_BASELINE_DATA ID
               SET ID.VALUE         = p_values(i)
             WHERE ID.ROUND_SID     = p_round_sid
               AND ID.VARIABLE_SID  = p_variable_sids(i)
               AND ID.COUNTRY_ID    = p_country_ids(i)
               AND ID.YEAR          = p_years(i)
         RETURNING ID.VARIABLE_SID
              BULK COLLECT INTO l_updated_variable_sids;

      -- Remove updated variables from the variable list
      FOR i IN 1 .. p_variable_sids.COUNT LOOP
         IF p_variable_sids(i) MEMBER OF l_updated_variable_sids THEN
            p_variable_sids.DELETE(i);
            p_country_ids.DELETE(i);
            p_years.DELETE(i);
            p_values.DELETE(i);
         END IF;
      END LOOP;

      -- Bulk insert remaining variables
      FORALL idx IN INDICES OF p_variable_sids
         INSERT INTO OG_BASELINE_DATA( ROUND_SID
                                     , VARIABLE_SID
                                     , COUNTRY_ID
                                     , YEAR
                                     , VALUE)
              VALUES (p_round_sid
                    , p_variable_sids(idx)
                    , p_country_ids(idx)
                    , p_years(idx)
                    , p_values(idx));
   END uploadBaselineData;

   ----------------------------------------------------------------------------
   -- @name uploadCountryParameters
   ----------------------------------------------------------------------------
   PROCEDURE uploadCountryParameters(p_round_sid         IN       NUMBER
,                                    p_parameter_sids    IN  OUT  CORE_COMMONS.SIDSARRAY
,                                    p_country_ids       IN  OUT  CORE_COMMONS.VARCHARARRAY
,                                    p_values            IN  OUT  CORE_COMMONS.VARCHARARRAY
,                                    o_res               OUT      NUMBER)
   IS
      l_updated_parameter_sids SIDSLIST;
   BEGIN
      o_res := p_parameter_sids.COUNT;

      -- Bulk update existing data and collect updated parameters
      FORALL i IN 1 .. p_parameter_sids.COUNT
            UPDATE OG_COUNTRY_PARAMS_DATA ID
               SET ID.VALUE              = p_values(i)
             WHERE ID.ROUND_SID          = p_round_sid
               AND ID.COUNTRY_PARAM_SID  = p_parameter_sids(i)
               AND ID.COUNTRY_ID         = p_country_ids(i)
         RETURNING ID.COUNTRY_PARAM_SID
              BULK COLLECT INTO l_updated_parameter_sids;

      -- Remove updated variables from the variable list
      FOR i IN 1 .. p_parameter_sids.COUNT LOOP
         IF p_parameter_sids(i) MEMBER OF l_updated_parameter_sids THEN
            p_parameter_sids.DELETE(i);
            p_country_ids.DELETE(i);
            p_values.DELETE(i);
         END IF;
      END LOOP;

      -- Bulk insert remaining parameters
      FORALL idx IN INDICES OF p_parameter_sids
         INSERT INTO OG_COUNTRY_PARAMS_DATA( ROUND_SID
                                           , COUNTRY_PARAM_SID
                                           , COUNTRY_ID
                                           , VALUE)
              VALUES (p_round_sid
                    , p_parameter_sids(idx)
                    , p_country_ids(idx)
                    , p_values(idx));
   END uploadCountryParameters;

   ----------------------------------------------------------------------------
   -- @name updateYearsRange
   ----------------------------------------------------------------------------
   PROCEDURE updateYearsRange(p_years_range   IN   NUMBER
,                             p_app_id        IN   VARCHAR2
,                             o_res           OUT  NUMBER)
   IS
   BEGIN
      UPDATE APPLICATIONS
         SET YEARS_RANGE = p_years_range
       WHERE APP_ID = UPPER(p_app_id);

      o_res := SQL%ROWCOUNT;
   END updateYearsRange;

   ----------------------------------------------------------------------------
   -- @name getParameter
   ----------------------------------------------------------------------------
   PROCEDURE getParameter(p_round_sid     IN   NUMBER
,                         p_parameter_id  IN   VARCHAR2
,                         o_res           OUT  VARCHAR2)
   IS
   BEGIN
      SELECT VALUE
       INTO o_res
       FROM OG_PARAMS
      WHERE ROUND_SID = p_round_sid
        AND UPPER (PARAM_ID) = UPPER(p_parameter_id);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         o_res := NULL;
   END getParameter;

   ----------------------------------------------------------------------------
   -- @name updateParameter
   ----------------------------------------------------------------------------
   PROCEDURE updateParameter(p_round_sid        IN   NUMBER
,                            p_parameter_id     IN   VARCHAR2
,                            p_parameter_value  IN   VARCHAR2
,                            o_res              OUT  NUMBER)
   IS
   BEGIN
      UPDATE OG_PARAMS
         SET VALUE = p_parameter_value
       WHERE ROUND_SID = p_round_sid
         AND UPPER (PARAM_ID) = UPPER(p_parameter_id);
      o_res := SQL%ROWCOUNT;

      IF o_res = 0 THEN
        INSERT INTO OG_PARAMS (ROUND_SID, PARAM_ID, VALUE)
        VALUES (p_round_sid, p_parameter_id, p_parameter_value);
        o_res := SQL%ROWCOUNT;
      END IF;
   END updateParameter;

   ----------------------------------------------------------------------------
   -- @name getParameters
   ----------------------------------------------------------------------------
   PROCEDURE getParameters(p_round_sid     IN   NUMBER
,                          o_cur           OUT  SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
          SELECT PARAM_ID as "code",
                 VALUE as "value"
           FROM OG_PARAMS
          WHERE ROUND_SID = p_round_sid;
   END getParameters;

   ----------------------------------------------------------------------------
   -- @name updateParameters
   ----------------------------------------------------------------------------
   PROCEDURE updateParameters(p_round_sid         IN   NUMBER
,                             p_parameter_ids     IN   CORE_COMMONS.VARCHARARRAY
,                             p_parameter_values  IN   CORE_COMMONS.VARCHARARRAY
,                             o_res               OUT  NUMBER)
   IS
      l_res NUMBER;
   BEGIN
      o_res := p_parameter_ids.COUNT;

      FOR i IN 1 .. p_parameter_ids.COUNT LOOP
         updateParameter(p_round_sid, p_parameter_ids(i), p_parameter_values(i), l_res);
         o_res := o_res + l_res;
      END LOOP;
   END updateParameters;

END IDR_OG_PARAMS;
