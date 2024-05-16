CREATE OR REPLACE PACKAGE BODY AUXTOOLS_EER_GETTERS
AS
   /**************************************************************************
    *********************** PRIVATE SECTION **********************************
    **************************************************************************/

   /**************************************************************************
    *********************** PUBLIC SECTION ***********************************
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name getProviderSid
   ----------------------------------------------------------------------------
   FUNCTION getProviderSid(p_provider_id IN VARCHAR2)
      RETURN NUMBER
   IS
      l_provider_sid EER_PROVIDERS.PROVIDER_SID%TYPE;
   BEGIN
      SELECT PROVIDER_SID
        INTO l_provider_sid
        FROM EER_PROVIDERS
       WHERE PROVIDER_ID = UPPER(p_provider_id);

      RETURN l_provider_sid;
   END getProviderSid;

   ----------------------------------------------------------------------------
   -- @name getIndicatorSid
   ----------------------------------------------------------------------------
   FUNCTION getIndicatorSid(p_indicator_id    IN       VARCHAR2
                          , p_provider_id     IN       VARCHAR2
                          , p_periodicity_id  IN       VARCHAR2)
      RETURN NUMBER
   IS
      l_indicator_sid EER_INDICATORS.INDICATOR_SID%TYPE;
   BEGIN
      SELECT INDICATOR_SID
        INTO l_indicator_sid
        FROM VW_EER_INDICATORS
       WHERE INDICATOR_ID = UPPER(p_indicator_id)
         AND PROVIDER_ID = UPPER(p_provider_id)
         AND PERIODICITY_ID = UPPER(p_periodicity_id);

      RETURN l_indicator_sid;
   END getIndicatorSid;

   ----------------------------------------------------------------------------
   -- @name getGeoGroupSid
   ----------------------------------------------------------------------------
   FUNCTION getGeoGroupSid(p_geo_grp_id  IN     VARCHAR2
                         , p_active_only IN     NUMBER DEFAULT 1)
      RETURN NUMBER
   IS
      l_geo_grp_sid   EER_GEO_GROUP.GEO_GROUP_SID%TYPE := NULL;
   BEGIN
      IF p_geo_grp_id IS NOT NULL THEN
          SELECT GEO_GROUP_SID
            INTO l_geo_grp_sid
            FROM EER_GEO_GROUP
           WHERE GEO_GROUP_ID = UPPER(p_geo_grp_id)
             AND (p_active_only = 0 OR IS_ACTIVE = p_active_only);
      END IF;

      RETURN l_geo_grp_sid;

   END getGeoGroupSid;

   ----------------------------------------------------------------------------
   -- @name getEerGeoGroupsWithMembers
   ----------------------------------------------------------------------------
   PROCEDURE getEerGeoGroupsWithMembers(o_cur            OUT SYS_REFCURSOR
                                      , p_active_only IN     NUMBER DEFAULT 1)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT GEO_GROUP_ID
                , LISTAGG(GEO_MEMBER, ',') WITHIN GROUP (ORDER BY ORDER_BY) MEMBERS
             FROM VW_EER_GEO_GROUPS
            WHERE (p_active_only = 0 OR IS_ACTIVE = p_active_only)
         GROUP BY GEO_GROUP_ID;
   END getEerGeoGroupsWithMembers;

   ----------------------------------------------------------------------------
   -- @name getEerGeoGroups
   ----------------------------------------------------------------------------
   PROCEDURE getEerGeoGroups(o_cur            OUT SYS_REFCURSOR
                           , p_active_only IN     NUMBER DEFAULT 1)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT GEO_GROUP_ID AS "geoGrpId"
                , DESCR        AS "descr"
                , ALIAS        AS "alias"
                , IS_ACTIVE    AS "isActive"
                , IS_DEFAULT   AS "isDefault"
             FROM EER_GEO_GROUP
            WHERE (p_active_only = 0 OR IS_ACTIVE = p_active_only)
         ORDER BY GEO_GROUP_ID;
   END getEerGeoGroups;

   ----------------------------------------------------------------------------
   -- @name getBaseYear
   ----------------------------------------------------------------------------
   PROCEDURE getBaseYear(o_res OUT  NUMBER)
   IS
   BEGIN
        SELECT CORE_GETTERS.getParameter(AUXTOOLS_EER_GETTERS.BASE_YEAR_PARAM)
          INTO o_res
          FROM DUAL;
   END getBaseYear;

   ----------------------------------------------------------------------------
   -- @name getNeerCountries
   ----------------------------------------------------------------------------
   PROCEDURE getNeerCountries(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT M.GEO_AREA_ID AS COUNTRY_ID
                , M.DESCR
                , M.ORDER_BY
             FROM VW_EER_GEO_MAPPINGS M
            WHERE M.ORDER_BY IS NOT NULL
         ORDER BY ORDER_BY, DESCR;
   END getNeerCountries;

   ----------------------------------------------------------------------------
   -- @name isCalculated
   ----------------------------------------------------------------------------
   PROCEDURE isCalculated(p_provider_id IN      VARCHAR2
                        , o_res            OUT  NUMBER)
   IS
      l_data_location   EER_PROVIDERS.DATA_LOCATION%TYPE := NULL;
   BEGIN
      o_res := -1;
      SELECT DATA_LOCATION
        INTO l_data_location
        FROM EER_PROVIDERS
       WHERE PROVIDER_ID = p_provider_id;

      IF l_data_location = 'EER_INDICATOR_DATA'
      THEN
          SELECT COUNT(*)
            INTO o_res
            FROM VW_EER_INDICATORS_DATA
           WHERE PROVIDER_ID = p_provider_id;
      ELSIF l_data_location = 'EER_MATRIX_DATA'
      THEN
          SELECT COUNT(*)
            INTO o_res
            FROM VW_EER_MATRIX_DATA
           WHERE PROVIDER_ID = p_provider_id;
      END IF;
   END isCalculated;

   ----------------------------------------------------------------------------
   -- @name setBaseYear
   ----------------------------------------------------------------------------
   PROCEDURE setBaseYear(p_year  IN      NUMBER
                        , o_res     OUT  NUMBER)
   IS
    BEGIN
        o_res := -1;
        UPDATE PARAMS
        SET VALUE = p_year
        WHERE PARAM_ID = AUXTOOLS_EER_GETTERS.BASE_YEAR_PARAM;

        o_res := SQL%ROWCOUNT;
    END setBaseYear;

END AUXTOOLS_EER_GETTERS;
/
