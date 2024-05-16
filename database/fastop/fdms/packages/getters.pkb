/* Formatted on 27-11-2020 14:06:21 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY FDMS_GETTERS
AS
   ----------------------------------------------------------------------------
   -- @name getCtyScale
   ----------------------------------------------------------------------------
   PROCEDURE getCtyScale(p_country_id IN     VARCHAR2
                       , o_scale_id      OUT VARCHAR2
                       , o_descr         OUT VARCHAR2
                       , o_exponent      OUT NUMBER)
   IS
   BEGIN
      SELECT S.SCALE_ID, S.DESCR, S.EXPONENT
        INTO o_scale_id, o_descr, o_exponent
        FROM VW_FDMS_CTY_SCALES S
       WHERE S.COUNTRY_ID = p_country_id;
   END getCtyScale;

   ----------------------------------------------------------------------------
   -- @name getCurrentAppSid
   ----------------------------------------------------------------------------
   FUNCTION getCurrentAppSid
      RETURN NUMBER
   IS
   BEGIN
      RETURN CORE_GETTERS.getApplicationSid(FDMS_GETTERS.APP_ID);
   END getCurrentAppSid;

   ----------------------------------------------------------------------------
   -- @name getScales
   ----------------------------------------------------------------------------
   PROCEDURE getScales(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
         SELECT SCALE_SID AS "scaleSid", SCALE_ID AS "scaleId", DESCR AS "descr" FROM FDMS_SCALES;
   END getScales;

   ----------------------------------------------------------------------------
   -- @name getCurrentStorageSid
   ----------------------------------------------------------------------------
   FUNCTION getCurrentStorageSid
      RETURN NUMBER
   IS
   BEGIN
      RETURN CORE_GETTERS.getCurrentStorageSid(FDMS_GETTERS.APP_ID);
   END getCurrentStorageSid;

   ----------------------------------------------------------------------------
   -- @name isCurrentStorage - function used to verify if passed in
   --    parameters correspond to the current storage
   -- @return 1 if ok, 0 if failed
   ----------------------------------------------------------------------------
   FUNCTION isCurrentStorage(p_round_sid IN NUMBER, p_storage_sid IN NUMBER)
      RETURN NUMBER
   IS
   BEGIN
      RETURN CORE_GETTERS.isCurrentStorage(FDMS_GETTERS.APP_ID, p_round_sid, p_storage_sid);
   END isCurrentStorage;

   ----------------------------------------------------------------------------
   -- @name isCurrentStorageFinal
   ----------------------------------------------------------------------------
   FUNCTION isCurrentStorageFinal
      RETURN NUMBER
   IS
   BEGIN
      RETURN CORE_GETTERS.isCurrentStorageFinal(FDMS_GETTERS.APP_ID);
   END isCurrentStorageFinal;

   ----------------------------------------------------------------------------
   -- @name getProviders
   ----------------------------------------------------------------------------
   PROCEDURE getProviders(o_cur OUT SYS_REFCURSOR, p_app_id IN VARCHAR2)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT P.PROVIDER_ID, P.DESCR
             FROM FDMS_PROVIDERS P
            WHERE P.DATA_LOCATION IS NOT NULL
              AND (UPPER(p_app_id) = APP_ID OR P.PROVIDER_ID = 'PRE_PROD' OR P.IS_COUNTRY_UPLOAD = 1)
         ORDER BY PROVIDER_ID;
   END getProviders;

   ----------------------------------------------------------------------------
   -- @name getProviderDataLocation
   ----------------------------------------------------------------------------
   PROCEDURE getProviderDataLocation(p_provider_id IN VARCHAR2, o_res OUT VARCHAR2)
   IS
   BEGIN
      SELECT DATA_LOCATION
        INTO o_res
        FROM FDMS_PROVIDERS
       WHERE UPPER(PROVIDER_ID) = UPPER(p_provider_id);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         o_res := NULL;
   END getProviderDataLocation;

   ----------------------------------------------------------------------------
   -- @name getProviderSid
   ----------------------------------------------------------------------------
   FUNCTION getProviderSid(p_provider_id IN VARCHAR2)
      RETURN NUMBER
   IS
      l_provider_sid FDMS_PROVIDERS.PROVIDER_SID%TYPE;
   BEGIN
      SELECT PROVIDER_SID
        INTO l_provider_sid
        FROM FDMS_PROVIDERS
       WHERE UPPER(PROVIDER_ID) = UPPER(p_provider_id);

      RETURN l_provider_sid;
   END getProviderSid;

   ----------------------------------------------------------------------------
   -- @name getIndicatorSid
   ----------------------------------------------------------------------------
   FUNCTION getIndicatorSid(p_indicator_id   IN VARCHAR2
                          , p_provider_id    IN VARCHAR2
                          , p_periodicity_id IN VARCHAR2 DEFAULT 'A' )
      RETURN NUMBER
   IS
      l_indicator_sid NUMBER;
   BEGIN
      SELECT INDICATOR_SID
        INTO l_indicator_sid
        FROM VW_FDMS_INDICATORS
       WHERE UPPER(PROVIDER_ID) = UPPER(p_provider_id)
         AND UPPER(INDICATOR_ID) = UPPER(p_indicator_id)
         AND PERIODICITY_ID = p_periodicity_id;

      RETURN l_indicator_sid;
   END getIndicatorSid;

   ----------------------------------------------------------------------------
   -- @name getIndicatorGeoAreas
   ----------------------------------------------------------------------------
   PROCEDURE getIndicatorGeoAreas(p_app_id IN     VARCHAR2
                                , o_cur       OUT SYS_REFCURSOR )
   IS
   BEGIN
      OPEN o_cur FOR
            SELECT GEO_AREA_ID AS COUNTRY_ID
                 , DESCR
              FROM GEO_AREAS
             WHERE GEO_AREA_ID IN
                 ( SELECT COUNTRY_ID AS GEO_AREA_ID
                     FROM VW_FDMS_INDICATOR_DATA
                    WHERE PROVIDER_ID IN
                        ( SELECT P.PROVIDER_ID
                            FROM FDMS_PROVIDERS P
                           WHERE P.DATA_LOCATION IS NOT NULL
                             AND (UPPER(p_app_id) = APP_ID OR P.PROVIDER_ID = 'PRE_PROD' OR P.IS_COUNTRY_UPLOAD = 1)
                        )
                UNION ALL
                   SELECT EXPORTER_CTY_ID AS GEO_AREA_ID
                     FROM VW_TCE_RESULTS
                 )
          ORDER BY ORDER_BY;
   END getIndicatorGeoAreas;

   ----------------------------------------------------------------------------
   -- @name getProviderCountries
   ----------------------------------------------------------------------------
   PROCEDURE getProviderCountries(p_provider_ids  IN      CORE_COMMONS.VARCHARARRAY
                                , o_cur              OUT  SYS_REFCURSOR )
   IS
      l_provider_ids    VARCHARLIST := CORE_COMMONS.arrayToList(p_provider_ids);
   BEGIN
      OPEN o_cur FOR
            SELECT G.GEO_AREA_ID AS COUNTRY_ID
                 , G.DESCR
              FROM GEO_AREAS G
             WHERE GEO_AREA_ID IN
                 ( SELECT COUNTRY_ID AS GEO_AREA_ID
                     FROM VW_FDMS_INDICATOR_DATA
                    WHERE PROVIDER_ID IN (SELECT * FROM TABLE(l_provider_ids))
                 )
          ORDER BY ORDER_BY;
   END getProviderCountries;

   ----------------------------------------------------------------------------
   -- @name getProviderIndicators
   ----------------------------------------------------------------------------
   PROCEDURE getProviderIndicators(p_provider_ids    IN      CORE_COMMONS.VARCHARARRAY
                                 , p_periodicity_id  IN      VARCHAR2
                                 , o_cur                OUT  SYS_REFCURSOR )
   IS
      l_provider_ids    VARCHARLIST := CORE_COMMONS.arrayToList(p_provider_ids);
   BEGIN
      OPEN o_cur FOR
            SELECT DISTINCT 
                   C.INDICATOR_ID
                 , C.DESCR
              FROM FDMS_INDICATOR_CODES C
              JOIN FDMS_INDICATORS I
                ON C.INDICATOR_CODE_SID = I.INDICATOR_CODE_SID
              JOIN FDMS_PROVIDERS P
                ON I.PROVIDER_SID = P.PROVIDER_SID
             WHERE I.PERIODICITY_ID = p_periodicity_id
               AND P.PROVIDER_ID IN (SELECT * FROM TABLE(l_provider_ids))
          ORDER BY C.INDICATOR_ID;
   END getProviderIndicators;

   ----------------------------------------------------------------------------
   -- @name getProviderIndicatorsMappings
   ----------------------------------------------------------------------------
   PROCEDURE getProviderIndicatorsMappings(p_provider_ids    IN      CORE_COMMONS.VARCHARARRAY
                                         , p_periodicity_id  IN      VARCHAR2
                                         , o_cur                OUT  SYS_REFCURSOR )
   IS
      l_provider_ids    VARCHARLIST := CORE_COMMONS.arrayToList(p_provider_ids);
   BEGIN
      OPEN o_cur FOR
            SELECT INDICATOR_ID
                 , SOURCE_CODE
                 , SOURCE_DESCR
              FROM VW_FDMS_INDICATORS_MAPPINGS
             WHERE PERIODICITY_ID = p_periodicity_id
               AND PROVIDER_ID IN (SELECT * FROM TABLE(l_provider_ids));
   END getProviderIndicatorsMappings;

   ----------------------------------------------------------------------------
   -- @name getIndicatorsTree
   ----------------------------------------------------------------------------
   PROCEDURE getIndicatorsTree(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
        SELECT CODE
             , DESCR
             , INDICATOR_ID
             , ORDER_BY
             , PARENT_CODE
             , LEVEL
         FROM  FDMS_INDICATOR_TREE
        START WITH PARENT_CODE IS NULL
      CONNECT BY PRIOR CODE = PARENT_CODE
        ORDER SIBLINGS BY ORDER_BY;
   END getIndicatorsTree;

   ----------------------------------------------------------------------------
   -- @name getProviderPeriodicityIndCode
   ----------------------------------------------------------------------------
   
    PROCEDURE getProviderPeriodicityIndCode(o_pro OUT SYS_REFCURSOR
                                        ,o_per OUT SYS_REFCURSOR
                                        ,o_ind OUT SYS_REFCURSOR
    )
    IS
    BEGIN
        OPEN o_pro FOR 
        SELECT          P.PROVIDER_ID as NAME,
                        P.PROVIDER_SID as VALUE 
        FROM FDMS_PROVIDERS P ORDER BY P.PROVIDER_ID ;
        
        OPEN o_per FOR 
        SELECT  DISTINCT 
                        I.PERIODICITY_ID as NAME,
                        I.PERIODICITY_ID as VALUE 
        FROM FDMS_INDICATORS I ORDER BY I.PERIODICITY_ID;
        
        OPEN o_ind FOR 
        SELECT          IC.INDICATOR_ID as NAME,
                        IC.INDICATOR_CODE_SID as VALUE 
        FROM FDMS_INDICATOR_CODES IC ORDER BY IC.INDICATOR_ID;
    END getProviderPeriodicityIndCode;


    ----------------------------------------------------------------------------
   -- @name getIndicatorsBySidProviderPeriodicity
   ----------------------------------------------------------------------------
   PROCEDURE getIndicatorsBySidProviderPeriodicity(p_indicator_sids    IN      CORE_COMMONS.SIDSARRAY
                                   , p_periodicity_ids    IN      CORE_COMMONS.VARCHARARRAY
                                   , p_provider_sids    IN      CORE_COMMONS.SIDSARRAY
                                   , o_cur                OUT  SYS_REFCURSOR )
   IS
      l_indicator_sids     SIDSLIST    := CORE_COMMONS.arrayToSidsList(p_indicator_sids);
      l_indicator_count    NUMBER(3)   := l_indicator_sids.COUNT; 
      l_periodicity_ids    VARCHARLIST := CORE_COMMONS.arrayToList(p_periodicity_ids);
      l_periodicity_count  NUMBER(3)   := l_periodicity_ids.COUNT;
      l_provider_sids      SIDSLIST    := CORE_COMMONS.arrayToSidsList(p_provider_sids);
      l_provider_count     NUMBER(3)   := l_provider_sids.COUNT;
  
   BEGIN
      OPEN o_cur FOR
          SELECT DISTINCT
                 INDICATOR_SID as "indicator_sid"
               , INDICATOR_ID as  "indicator_id"
               , DESCR as  "indicator_descr"
               , PERIODICITY_ID as  "periodicity_id"
               , PROVIDER_ID as "provider_id"
               , DESCR as "provider_descr"
            FROM VW_FDMS_INDICATORS
           WHERE (l_indicator_count = 0 OR INDICATOR_CODE_SID IN (SELECT * FROM TABLE(l_indicator_sids)))
             AND (l_provider_count = 0 OR PROVIDER_SID IN (SELECT * FROM TABLE(l_provider_sids)))
             AND (l_periodicity_count = 0 OR PERIODICITY_ID IN (SELECT * FROM TABLE(l_periodicity_ids)))
        ORDER BY INDICATOR_ID;

   END getIndicatorsBySidProviderPeriodicity;
   
   ----------------------------------------------------------------------------
   -- @name getIndicatorsByIds
   ----------------------------------------------------------------------------
   PROCEDURE getIndicatorCodesByIds(p_indicator_sids    IN      CORE_COMMONS.SIDSARRAY
                                    ,p_forecast  IN NUMBER
                                   ,o_cur                OUT  SYS_REFCURSOR )
   IS
      l_indicator_sids    SIDSLIST := CORE_COMMONS.arrayToSidsList(p_indicator_sids);
      l_indicator_count    NUMBER(3)   := l_indicator_sids.COUNT; 
  
   BEGIN
  
      OPEN o_cur FOR
            SELECT C.INDICATOR_CODE_SID as "indicator_code_sid"
                 , C.INDICATOR_ID as  "indicator_id"
                 , C.DESCR as  "descr"
                 , C.EUROSTAT_CODE as "eurostat_code"
                 , C.FORECAST as "forecast"
                 , C.AMECO_CODE as "ameco_code"
                 , C.AMECO_TRN as "ameco_trn"
                 , C.AMECO_AGG as "ameco_agg"
                 , C.AMECO_UNIT as "ameco_unit"
                 , C.AMECO_REF as "ameco_ref"
              FROM FDMS_INDICATOR_CODES C
             WHERE (l_indicator_count = 0 OR C.INDICATOR_CODE_SID IN (SELECT * FROM TABLE(l_indicator_sids)))
               AND (p_forecast < 0 OR C.FORECAST = p_forecast)
          ORDER BY C.INDICATOR_ID;
   END getIndicatorCodesByIds;

END FDMS_GETTERS;
/
