CREATE OR REPLACE PACKAGE BODY AUXTOOLS_HICP
AS
   /**************************************************************************
    *********************** PRIVATE SECTION **********************************
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name getDataTypeFromDataset
   ----------------------------------------------------------------------------
   FUNCTION getDataTypeFromDataset(p_dataset IN VARCHAR2)
      RETURN VARCHAR2
   IS
      l_dataset VARCHAR2(20) := UPPER(p_dataset);
      l_data_type VARCHAR2(1);
   BEGIN
      IF l_dataset = 'TAX_RATES'
      THEN
        l_data_type := 'T';
      ELSIF l_dataset = 'INDEX'
      THEN
        l_data_type := 'I';
      END IF;

      RETURN l_data_type;
   END getDataTypeFromDataset;

   ----------------------------------------------------------------------------
   -- @name addIndicatorsToCategory
   ----------------------------------------------------------------------------
   PROCEDURE addIndicatorsToCategory(p_category_sid      IN     NUMBER
                                   , p_indicator_ids     IN     CORE_COMMONS.VARCHARARRAY)
   IS
   BEGIN
      FOR i IN 1 .. p_indicator_ids.COUNT LOOP
        INSERT INTO HICP_INDICATOR_CODE_CATEGORY(INDICATOR_ID, CATEGORY_SID)
             VALUES (p_indicator_ids(i), p_category_sid);
      END LOOP;
   END addIndicatorsToCategory;

   /**************************************************************************
    *********************** PUBLIC SECTION ***********************************
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name getEurostatCodes
   ----------------------------------------------------------------------------
   PROCEDURE getEurostatCodes(o_cur            OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
        SELECT INDICATOR_SID
             , EUROSTAT_CODE
          FROM VW_HICP_INDICATORS
         WHERE EUROSTAT_CODE IS NOT NULL;
   END getEurostatCodes;

   ----------------------------------------------------------------------------
   -- @name saveIndicatorsData
   ----------------------------------------------------------------------------
   PROCEDURE saveIndicatorsData(
             p_indicator_sids     IN OUT CORE_COMMONS.SIDSARRAY
           , p_country_ids        IN     CORE_COMMONS.VARCHARARRAY
           , p_start_years        IN     CORE_COMMONS.SIDSARRAY
           , p_time_series        IN     CORE_COMMONS.VARCHARARRAY
           , p_user               IN     VARCHAR
           , o_res                   OUT NUMBER
   )
   IS
      l_updated_indicator_sids SIDSLIST;
   BEGIN
      o_res := p_indicator_sids.COUNT;

      -- Bulk update existing data and collect updated indicators
      FORALL i IN 1 .. p_indicator_sids.COUNT
            UPDATE HICP_INDICATOR_DATA ID
               SET START_YEAR     = p_start_years(i)
                 , TIMESERIE_DATA = p_time_series(i)
                 , UPDATE_DATE    = SYSDATE
                 , UPDATE_USER    = p_user
             WHERE ID.COUNTRY_ID = p_country_ids(i)
               AND ID.INDICATOR_SID = p_indicator_sids(i)
         RETURNING ID.INDICATOR_SID
              BULK COLLECT INTO l_updated_indicator_sids;

      -- Remove updated indicators from the indicator list
      FOR i IN 1 .. p_indicator_sids.COUNT LOOP
         IF p_indicator_sids(i) MEMBER OF l_updated_indicator_sids THEN
            p_indicator_sids.DELETE(i);
         END IF;
      END LOOP;

      -- Bulk insert remaining indicators
      FORALL idx IN INDICES OF p_indicator_sids
         INSERT INTO HICP_INDICATOR_DATA(COUNTRY_ID
                                       , INDICATOR_SID
                                       , START_YEAR
                                       , TIMESERIE_DATA
                                       , UPDATE_DATE
                                       , UPDATE_USER)
              VALUES (p_country_ids(idx)
                    , p_indicator_sids(idx)
                    , p_start_years(idx)
                    , p_time_series(idx)
                    , SYSDATE
                    , p_user);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         o_res := -4;                                         -- multiple records for same indicator
         ROLLBACK;

   END saveIndicatorsData;

   ----------------------------------------------------------------------------
   -- @name getUserCategories
   ----------------------------------------------------------------------------
    PROCEDURE getUserCategories(p_user IN     VARCHAR
                              , o_cur     OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
        SELECT C.CATEGORY_SID
             , C.CATEGORY_ID
             , C.DESCR
             , C.ROOT_INDICATOR_ID
             , C.BASE_INDICATOR_ID
             , C.ORDER_BY
             , CASE C.OWNER WHEN 'DEFAULT' THEN 1 ELSE 0 END AS IS_DEFAULT
             , (SELECT LISTAGG(R.CHILD_CATEGORY_SID, ',')
                  FROM HICP_CATEGORY_REL R
                 WHERE R.PARENT_CATEGORY_SID = C.CATEGORY_SID
               ) AS CHILD_SIDS
             , (SELECT LISTAGG(I.INDICATOR_ID, ',')
                  FROM HICP_INDICATOR_CODE_CATEGORY I
                 WHERE I.CATEGORY_SID = C.CATEGORY_SID
               ) AS INDICATOR_IDS
          FROM HICP_CATEGORY C
         WHERE C.OWNER = 'DEFAULT' OR UPPER(C.OWNER) = UPPER(p_user);
   END getUserCategories;

   ----------------------------------------------------------------------------
   -- @name getCountries
   -- @Deprecated: replaced with MongoDb
   ----------------------------------------------------------------------------
   PROCEDURE getCountries(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
        SELECT
               GEO_AREA_ID AS "countryId"
             , (CASE GEO_AREA_ID
                    WHEN 'EU28' THEN 'EU28 [discontinued]'
                    WHEN 'EU' THEN 'EU [EU27]'
                    ELSE DESCR
                END) AS "descr"
          FROM GEO_AREAS
         WHERE GEO_AREA_ID IN (SELECT DISTINCT COUNTRY_ID FROM HICP_INDICATOR_DATA)
      ORDER BY DESCR;
   END getCountries;

   ----------------------------------------------------------------------------
   -- @name getDatasetData
   -- @Deprecated: replaced with MongoDb
   ----------------------------------------------------------------------------
    PROCEDURE getDatasetData(o_cur               OUT SYS_REFCURSOR
                           , p_dataset        IN     VARCHAR2
                           , p_country_id     IN     VARCHAR2)
   IS
   BEGIN
     OPEN o_cur FOR
        SELECT INDICATOR_CODE_SID
             , START_YEAR
             , TIMESERIE_DATA
             , DATA_TYPE
          FROM VW_HICP_INDICATORS_DATA
         WHERE (DATA_TYPE = 'W' OR DATA_TYPE = getDataTypeFromDataset(p_dataset))
           AND COUNTRY_ID = p_country_id;
   END getDatasetData;

   ----------------------------------------------------------------------------
   -- @name getExcelDatasetData
   -- @Deprecated: replaced with MongoDb
   ----------------------------------------------------------------------------
   PROCEDURE getExcelDatasetData(o_cur               OUT SYS_REFCURSOR
                               , p_dataset        IN      VARCHAR2
                               , p_country_id     IN      VARCHAR2
                               , p_indicator_ids  IN      CORE_COMMONS.VARCHARARRAY)
   IS
        l_indicator_ids     VARCHARLIST := CORE_COMMONS.arrayToList(p_indicator_ids);
   BEGIN
      OPEN o_cur FOR
         SELECT C.INDICATOR_CODE_SID as "indicatorCodeSid"
              , C.INDICATOR_ID as "indicatorId"
              , C.DESCR as "descr"
              , I.INDICATOR_SID as "indicatorSid"
              , I.DATA_TYPE AS "dataType"
              , D.START_YEAR AS "startYear"
              , D.TIMESERIE_DATA AS "timeserieData"
              , D.UPDATE_DATE AS "lastUpdated"
              , D.UPDATE_USER AS "updatedBy"
           FROM HICP_INDICATOR_CODES C
      LEFT JOIN HICP_INDICATORS I
             ON I.INDICATOR_CODE_SID = C.INDICATOR_CODE_SID
LEFT OUTER JOIN HICP_INDICATOR_DATA D
             ON D.INDICATOR_SID = I.INDICATOR_SID AND D.COUNTRY_ID = p_country_id
          WHERE (I.DATA_TYPE = 'W' OR I.DATA_TYPE = getDataTypeFromDataset(p_dataset))
            AND C.INDICATOR_ID IN (SELECT * FROM TABLE(l_indicator_ids))
            ORDER BY C.INDICATOR_CODE_SID;
   END getExcelDatasetData;

   ----------------------------------------------------------------------------
   -- @name getIndicatorCodes
   ----------------------------------------------------------------------------
   PROCEDURE getIndicatorCodes(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
     OPEN o_cur FOR
        SELECT I.INDICATOR_CODE_SID
             , I.INDICATOR_ID
             , I.DESCR
             , ( SELECT LISTAGG(IR.PARENT_CODE_SID || ',') WITHIN GROUP (ORDER BY IR.PARENT_CODE_SID)
                   FROM HICP_INDICATOR_CODE_REL IR
                  WHERE IR.CHILD_CODE_SID = I.INDICATOR_CODE_SID ) AS PARENTS
          FROM VW_HICP_INDICATORS I
         WHERE (I.DATA_TYPE = 'I' OR I.DATA_TYPE IS NULL)
      ORDER BY I.INDICATOR_CODE_SID;
   END getIndicatorCodes;

   ----------------------------------------------------------------------------
   -- @name getIndicators
   ----------------------------------------------------------------------------
   PROCEDURE getIndicators(p_data_type IN     VARCHAR2
                         , o_cur          OUT SYS_REFCURSOR)
   IS
   BEGIN
     OPEN o_cur FOR
        SELECT INDICATOR_CODE_SID
             , INDICATOR_ID
             , INDICATOR_SID
             , DESCR
             , PERIODICITY_ID
             , DATA_TYPE
             , EUROSTAT_CODE
          FROM VW_HICP_INDICATORS
         WHERE DATA_TYPE = p_data_type;
   END getIndicators;

   ----------------------------------------------------------------------------
   -- @name getData
   -- @Deprecated: replaced with MongoDb
   ----------------------------------------------------------------------------
   PROCEDURE getData(o_cur               OUT SYS_REFCURSOR
                   , p_country_id     IN     VARCHAR2
                   , p_data_type      IN     VARCHAR2
                   , p_indicator_ids  IN     CORE_COMMONS.VARCHARARRAY)
   IS
        l_indicator_ids     VARCHARLIST := CORE_COMMONS.arrayToList(p_indicator_ids);
   BEGIN
     OPEN o_cur FOR
        SELECT INDICATOR_ID
             , PERIODICITY_ID
             , START_YEAR
             , TIMESERIE_DATA
         FROM VW_HICP_INDICATORS_DATA
        WHERE DATA_TYPE = p_data_type
          AND COUNTRY_ID = p_country_id
          AND INDICATOR_ID IN (SELECT * FROM TABLE(l_indicator_ids));
   END getData;

   ----------------------------------------------------------------------------
   -- @name getAnomaliesStartYear
   ----------------------------------------------------------------------------
   PROCEDURE getAnomaliesStartYear(o_res  OUT NUMBER)
   IS
   BEGIN
      o_res := CORE_GETTERS.getParameter('HICP_ANOM_START');
   END getAnomaliesStartYear;

   ----------------------------------------------------------------------------
   -- @name getAnomaliesEndYear
   ----------------------------------------------------------------------------
   PROCEDURE getAnomaliesEndYear(o_res  OUT NUMBER)
   IS
   BEGIN
      o_res := CORE_GETTERS.getParameter('HICP_ANOM_END');
   END getAnomaliesEndYear;

   ----------------------------------------------------------------------------
   -- @name insertCategory
   ----------------------------------------------------------------------------
   PROCEDURE insertCategory(p_category_id       IN     VARCHAR2
                          , p_descr             IN     VARCHAR2
                          , p_root_indicator_id IN     VARCHAR2
                          , p_base_indicator_id IN     VARCHAR2
                          , p_indicator_ids     IN     CORE_COMMONS.VARCHARARRAY
                          , p_owner             IN     VARCHAR2
                          , o_res                  OUT NUMBER)
   IS
        l_category_sid  HICP_CATEGORY.CATEGORY_SID%TYPE := -1;
   BEGIN
      INSERT INTO HICP_CATEGORY(CATEGORY_ID, DESCR, ROOT_INDICATOR_ID, BASE_INDICATOR_ID, OWNER)
           VALUES (p_category_id, p_descr, p_root_indicator_id, p_base_indicator_id, p_owner)
        RETURNING CATEGORY_SID
             INTO o_res;

      addIndicatorsToCategory(o_res, p_indicator_ids);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END insertCategory;

   ----------------------------------------------------------------------------
   -- @name updateCategory
   ----------------------------------------------------------------------------
   PROCEDURE updateCategory(p_category_sid      IN     NUMBER
                          , p_category_id       IN     VARCHAR2
                          , p_descr             IN     VARCHAR2
                          , p_root_indicator_id IN     VARCHAR2
                          , p_base_indicator_id IN     VARCHAR2
                          , p_indicator_ids     IN     CORE_COMMONS.VARCHARARRAY
                          , p_owner             IN     VARCHAR2
                          , o_res                  OUT NUMBER)
   IS
   BEGIN
      IF UPPER(p_owner) = 'DEFAULT' THEN
        o_res := NULL;
      ELSE
        UPDATE HICP_CATEGORY
           SET CATEGORY_ID = p_category_id
             , DESCR = p_descr
             , ROOT_INDICATOR_ID = p_root_indicator_id
             , BASE_INDICATOR_ID = p_base_indicator_id
         WHERE CATEGORY_SID = p_category_sid
           AND UPPER(OWNER) = UPPER(p_owner);

           o_res := SQL%ROWCOUNT;
           IF o_res > 0 THEN
               DELETE FROM HICP_INDICATOR_CODE_CATEGORY
                     WHERE CATEGORY_SID = p_category_sid;

               addIndicatorsToCategory(p_category_sid, p_indicator_ids);
           END IF;
      END IF;
   END updateCategory;

   ----------------------------------------------------------------------------
   -- @name deleteCategory
   ----------------------------------------------------------------------------
   PROCEDURE deleteCategory(p_category_sid      IN     NUMBER
                          , p_owner             IN     VARCHAR2
                          , o_res                  OUT NUMBER)
   IS
   BEGIN
      IF UPPER(p_owner) = 'DEFAULT' THEN
        o_res := NULL;
      ELSE
        DELETE FROM HICP_INDICATOR_CODE_CATEGORY
              WHERE CATEGORY_SID = (
                        SELECT CATEGORY_SID
                          FROM HICP_CATEGORY
                         WHERE CATEGORY_SID = p_category_sid
                           AND UPPER(OWNER) = UPPER(p_owner)
                    );

        DELETE FROM HICP_CATEGORY
              WHERE CATEGORY_SID = p_category_sid
                AND UPPER(OWNER) = UPPER(p_owner);

           o_res := SQL%ROWCOUNT;
      END IF;
   END deleteCategory;

END AUXTOOLS_HICP;
/
