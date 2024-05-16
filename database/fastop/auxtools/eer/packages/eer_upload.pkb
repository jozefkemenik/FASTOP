CREATE OR REPLACE PACKAGE BODY AUXTOOLS_EER_UPLOAD
AS
   /**************************************************************************
    *********************** PRIVATE SECTION **********************************
    **************************************************************************/

   /**************************************************************************
    *********************** PUBLIC SECTION ***********************************
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name setDataUpload
   ----------------------------------------------------------------------------
    PROCEDURE setDataUpload(p_provider_id  IN      VARCHAR2
                          , p_user         IN      VARCHAR2
                          , o_res             OUT  NUMBER)
    IS
      l_provider_sid EER_PROVIDERS.PROVIDER_SID%TYPE := AUXTOOLS_EER_GETTERS.getProviderSid(p_provider_id);
    BEGIN
        o_res := -1;

        UPDATE EER_DATA_UPLOADS
           SET UPDATE_DATE = SYSTIMESTAMP
             , UPDATE_USER = p_user
         WHERE PROVIDER_SID = l_provider_sid;

         o_res := SQL%ROWCOUNT;

        IF SQL%NOTFOUND THEN
            INSERT INTO EER_DATA_UPLOADS(PROVIDER_SID, UPDATE_DATE, UPDATE_USER)
                 VALUES (l_provider_sid, SYSTIMESTAMP, p_user);
            o_res := SQL%ROWCOUNT;
        END IF;

    END setDataUpload;

   ----------------------------------------------------------------------------
   -- @name getUploads
   ----------------------------------------------------------------------------
   PROCEDURE getUploads(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT P.DESCR       AS "providerDescr"
                , P.PROVIDER_ID AS "providerId"
                , U.UPDATE_DATE AS "lastUpdated"
                , U.UPDATE_USER AS "updatedBy"
             FROM EER_PROVIDERS P
        LEFT JOIN EER_DATA_UPLOADS U
               ON U.PROVIDER_SID = P.PROVIDER_SID
            WHERE P.IS_INPUT_DATA_UPLOAD = 1
         ORDER BY P.ORDER_BY, P.DESCR;
   END getUploads;

   ----------------------------------------------------------------------------
   -- @name getProviderUpload
   ----------------------------------------------------------------------------
   PROCEDURE getProviderUpload(p_provider_id IN       VARCHAR2
                             , o_cur            OUT   SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT P.DESCR       AS "providerDescr"
                , P.PROVIDER_ID AS "providerId"
                , U.UPDATE_DATE AS "lastUpdated"
                , U.UPDATE_USER AS "updatedBy"
             FROM EER_PROVIDERS P
        LEFT JOIN EER_DATA_UPLOADS U
               ON U.PROVIDER_SID = P.PROVIDER_SID
            WHERE P.IS_INPUT_DATA_UPLOAD = 1
              AND P.PROVIDER_ID = p_provider_id;
   END getProviderUpload;

   ----------------------------------------------------------------------------
   -- @name setIndicatorData
   ----------------------------------------------------------------------------
   PROCEDURE setIndicatorData(p_provider_id     IN       VARCHAR2
                            , p_indicator_id    IN       VARCHAR2
                            , p_periodicity_id  IN       VARCHAR2
                            , p_start_year      IN       NUMBER
                            , p_country_ids     IN       CORE_COMMONS.VARCHARARRAY
                            , p_time_series     IN       CLOBLIST
                            , p_geo_grp_id      IN       VARCHAR2
                            , p_user            IN       VARCHAR2
                            , o_res                 OUT  NUMBER)
   IS
      l_indicator_sid EER_INDICATORS.INDICATOR_SID%TYPE := AUXTOOLS_EER_GETTERS.getIndicatorSid(p_indicator_id
                                                                                              , p_provider_id
                                                                                              , p_periodicity_id);
      l_geo_grp_sid   EER_GEO_GROUP.GEO_GROUP_SID%TYPE := AUXTOOLS_EER_GETTERS.getGeoGroupSid(p_geo_grp_id);
   BEGIN

      o_res := 0;

      FOR i IN 1 .. p_country_ids.COUNT LOOP
         UPDATE EER_INDICATOR_DATA
            SET START_YEAR     = p_start_year
              , TIMESERIE_DATA = p_time_series(i)
              , UPDATE_DATE    = SYSTIMESTAMP
              , UPDATE_USER    = p_user
          WHERE INDICATOR_SID = l_indicator_sid
            AND COUNTRY_ID = p_country_ids(i)
            AND (l_geo_grp_sid IS NULL OR GEO_GRP_SID = l_geo_grp_sid);

         o_res := o_res + SQL%ROWCOUNT;

         IF SQL%NOTFOUND THEN
            INSERT INTO EER_INDICATOR_DATA(INDICATOR_SID
                                         , GEO_GRP_SID
                                         , COUNTRY_ID
                                         , START_YEAR
                                         , TIMESERIE_DATA
                                         , UPDATE_USER)
                 VALUES (l_indicator_sid
                       , l_geo_grp_sid
                       , p_country_ids(i)
                       , p_start_year
                       , p_time_series(i)
                       , p_user);

            o_res := o_res + SQL%ROWCOUNT;
         END IF;
      END LOOP;
   END setIndicatorData;

   ----------------------------------------------------------------------------
   -- @name setMatrixData
   ----------------------------------------------------------------------------
   PROCEDURE setMatrixData(p_provider_id        IN       VARCHAR2
                         , p_year               IN       NUMBER
                         , p_importers          IN       CORE_COMMONS.VARCHARARRAY
                         , p_exporters          IN       CORE_COMMONS.VARCHARARRAY
                         , p_values             IN       CORE_COMMONS.VARCHARARRAY
                         , p_geo_grp_id         IN       VARCHAR2
                         , p_user               IN       VARCHAR2
                         , o_res                   OUT   NUMBER)
   IS
      l_provider_sid EER_PROVIDERS.PROVIDER_SID%TYPE := AUXTOOLS_EER_GETTERS.getProviderSid(p_provider_id);
      l_geo_grp_sid  EER_GEO_GROUP.GEO_GROUP_SID%TYPE := AUXTOOLS_EER_GETTERS.getGeoGroupSid(p_geo_grp_id);
      l_value        EER_MATRIX_DATA.VALUE%TYPE;
   BEGIN

      o_res := 0;

      FOR e IN 1 .. p_exporters.COUNT LOOP
         FOR i IN 1 .. p_importers.COUNT LOOP
             l_value := p_values((e - 1) * p_importers.COUNT + i);

             UPDATE EER_MATRIX_DATA
                SET VALUE = l_value
                  , UPDATE_DATE    = SYSTIMESTAMP
                  , UPDATE_USER    = p_user
              WHERE PROVIDER_SID = l_provider_sid
                AND YEAR = p_year
                AND IMPORTER_CTY_ID = p_importers(i)
                AND EXPORTER_CTY_ID = p_exporters(e)
                AND (l_geo_grp_sid IS NULL OR GEO_GRP_SID = l_geo_grp_sid);

             o_res := o_res + SQL%ROWCOUNT;

             IF SQL%NOTFOUND THEN
                INSERT INTO EER_MATRIX_DATA(PROVIDER_SID
                                          , GEO_GRP_SID
                                          , YEAR
                                          , EXPORTER_CTY_ID
                                          , IMPORTER_CTY_ID
                                          , VALUE
                                          , UPDATE_USER)
                     VALUES (l_provider_sid
                           , l_geo_grp_sid
                           , p_year
                           , p_exporters(e)
                           , p_importers(i)
                           , l_value
                           , p_user);

                o_res := o_res + SQL%ROWCOUNT;
             END IF;
         END LOOP;
      END LOOP;

   END setMatrixData;

END AUXTOOLS_EER_UPLOAD;
/
