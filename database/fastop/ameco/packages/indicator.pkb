CREATE OR REPLACE PACKAGE BODY AMECO_INDICATOR
AS
    ----------------------------------------------------------------------------
    ------------------------------- Private methods ----------------------------
    ----------------------------------------------------------------------------

    ----------------------------------------------------------------------------
    -- @name getIndicatorDataSid
    ----------------------------------------------------------------------------
    FUNCTION getIndicatorDataSid(p_indicator_sid IN NUMBER, p_country_id IN VARCHAR2)
       RETURN NUMBER
    IS
       l_indicator_data_sid AMECO_INDICATOR_DATA.INDICATOR_DATA_SID%TYPE;
    BEGIN
       BEGIN
          SELECT INDICATOR_DATA_SID
            INTO l_indicator_data_sid
            FROM AMECO_INDICATOR_DATA
           WHERE INDICATOR_SID = p_indicator_sid
             AND COUNTRY_ID = p_country_id;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_indicator_data_sid := -1;
       END;

       RETURN l_indicator_data_sid;
    END getIndicatorDataSid;

    ----------------------------------------------------------------------------
    -------------------------------- Public methods ----------------------------
    ----------------------------------------------------------------------------

   ----------------------------------------------------------------------------
   -- @name getIndicators
   ----------------------------------------------------------------------------
   PROCEDURE getIndicators(o_cur               OUT SYS_REFCURSOR
                         , p_provider_id    IN     VARCHAR2 DEFAULT NULL
                         , p_periodicity_id IN     VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      OPEN o_cur FOR
         SELECT I.INDICATOR_SID  AS "indicatorSid"
              , I.INDICATOR_ID   AS "indicatorId"
              , I.PERIODICITY_ID AS "periodicityId"
              , I.DESCR          AS "indicatorDescr"
           FROM VW_AMECO_INDICATORS I
          WHERE (p_provider_id IS NULL OR I.PROVIDER_ID = p_provider_id)
            AND (p_periodicity_id IS NULL OR I.PERIODICITY_ID = p_periodicity_id);
   END getIndicators;

    ----------------------------------------------------------------------------
    -- @name setIndicatorData
    ----------------------------------------------------------------------------
    PROCEDURE setIndicatorData(o_res                    OUT  NUMBER
                            ,  p_provider_id        IN       VARCHAR2
                            ,  p_indicator_id       IN       VARCHAR2
                            ,  p_periodicity_id     IN       VARCHAR2
                            ,  p_start_year         IN       NUMBER
                            ,  p_country_ids        IN       CORE_COMMONS.VARCHARARRAY
                            ,  p_time_series        IN       CORE_COMMONS.VARCHARARRAY
                            ,  p_hst_time_series    IN       CORE_COMMONS.VARCHARARRAY
                            ,  p_src_time_series    IN       CORE_COMMONS.VARCHARARRAY
                            ,  p_level_time_series  IN       CORE_COMMONS.VARCHARARRAY
                            ,  p_user               IN       VARCHAR2)
   IS
      l_indicator_sid NUMBER := AMECO_GETTERS.getIndicatorSid(p_indicator_id, p_provider_id, p_periodicity_id);
      l_indicator_data_sid AMECO_INDICATOR_DATA.INDICATOR_DATA_SID%TYPE;
   BEGIN
      o_res := p_country_ids.COUNT;

      FOR i IN 1 .. p_country_ids.COUNT LOOP
         l_indicator_data_sid := getIndicatorDataSid(l_indicator_sid, p_country_ids(i));
         IF l_indicator_data_sid > 0 THEN
             UPDATE AMECO_INDICATOR_DATA
                SET START_YEAR         = p_start_year
                  , TIMESERIE_DATA     = p_time_series(i)
                  , UPDATE_DATE        = SYSDATE
                  , UPDATE_USER        = p_user
              WHERE COUNTRY_ID = p_country_ids(i)
                AND INDICATOR_SID = l_indicator_sid;

             DELETE FROM AMECO_INDICATOR_METADATA WHERE INDICATOR_DATA_SID = l_indicator_data_sid;
         ELSE
            INSERT INTO AMECO_INDICATOR_DATA( INDICATOR_SID
                                            , COUNTRY_ID
                                            , START_YEAR
                                            , TIMESERIE_DATA
                                            , UPDATE_USER)
                 VALUES (l_indicator_sid
                       , p_country_ids(i)
                       , p_start_year
                       , p_time_series(i)
                       , p_user)
              RETURNING INDICATOR_DATA_SID INTO l_indicator_data_sid;
         END IF;

         -- insert metadata
         INSERT INTO AMECO_INDICATOR_METADATA( INDICATOR_DATA_SID
                                             , HST_TIMESERIE_DATA
                                             , SRC_TIMESERIE_DATA
                                             , LEVEL_TIMESERIE_DATA)
              VALUES ( l_indicator_data_sid
                     , p_hst_time_series(i)
                     , p_src_time_series(i)
                     , p_level_time_series(i));

      END LOOP;
   END setIndicatorData;

   ----------------------------------------------------------------------------
   -- @name getIndicatorData
   ----------------------------------------------------------------------------
   PROCEDURE getIndicatorData(o_cur               OUT    SYS_REFCURSOR
                            ,  p_provider_id    IN       VARCHAR2
                            ,  p_periodicity_id IN       VARCHAR2
                            ,  p_indicator_ids  IN       CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               ))
   IS
      l_indicator_ids   VARCHARLIST := CORE_COMMONS.arrayToList(p_indicator_ids);
      l_indicator_count NUMBER(3)   := l_indicator_ids.COUNT;
   BEGIN
     OPEN o_cur FOR
           SELECT COUNTRY_ID
                , INDICATOR_ID
                , 'UNIT' AS SCALE_ID
                , START_YEAR
                , TIMESERIE_DATA
                , PERIODICITY_ID
                , COUNTRY_DESCR
                , 'UNIT' AS SCALE_DESCR
                , UPDATE_DATE
                , DATA_SOURCE
             FROM VW_AMECO_INDICATOR_DATA
            WHERE PROVIDER_ID = p_provider_id
              AND PERIODICITY_ID = p_periodicity_id
              AND (l_indicator_count = 0 OR INDICATOR_ID IN (SELECT * FROM TABLE(l_indicator_ids)))
         ORDER BY INDICATOR_ID, COUNTRY_ID;
   END getIndicatorData;

   ----------------------------------------------------------------------------
   -- @name getIndicatorMetadata
   ----------------------------------------------------------------------------
   PROCEDURE getIndicatorMetadata(o_cur               OUT    SYS_REFCURSOR
                               ,  p_provider_id    IN       VARCHAR2
                               ,  p_periodicity_id IN       VARCHAR2
                               ,  p_indicator_ids  IN       CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               ))
   IS
      l_indicator_ids   VARCHARLIST := CORE_COMMONS.arrayToList(p_indicator_ids);
      l_indicator_count NUMBER(3)   := l_indicator_ids.COUNT;
   BEGIN
     OPEN o_cur FOR
           SELECT COUNTRY_ID
                , INDICATOR_ID
                , 'UNIT' AS SCALE_ID
                , START_YEAR
                , TIMESERIE_DATA
                , PERIODICITY_ID
                , COUNTRY_DESCR
                , 'UNIT' AS SCALE_DESCR
                , UPDATE_DATE
                , DATA_SOURCE
                , HST_TIMESERIE_DATA
                , SRC_TIMESERIE_DATA
                , LEVEL_TIMESERIE_DATA
             FROM VW_AMECO_INDICATOR_DATA
            WHERE PROVIDER_ID = p_provider_id
              AND PERIODICITY_ID = p_periodicity_id
              AND (l_indicator_count = 0 OR INDICATOR_ID IN (SELECT * FROM TABLE(l_indicator_ids)))
         ORDER BY INDICATOR_ID, COUNTRY_ID;
   END getIndicatorMetadata;

   ----------------------------------------------------------------------------
   -- @name setIndicatorInputSource
   ----------------------------------------------------------------------------
   PROCEDURE setIndicatorInputSource(o_res              OUT  NUMBER
                                   , p_source_ids   IN       CORE_COMMONS.SIDSARRAY
                                   , p_source_codes IN       CORE_COMMONS.VARCHARARRAY)
   IS
   BEGIN
      o_res := p_source_ids.COUNT;
      DELETE FROM AMECO_INDICATOR_INPUT_SOURCE;

      FOR i IN 1 .. p_source_ids.COUNT LOOP
         INSERT INTO AMECO_INDICATOR_INPUT_SOURCE(SOURCE_SID, CODE)
         VALUES (p_source_ids(i), p_source_codes(i));
      END LOOP;
   END setIndicatorInputSource;

   ----------------------------------------------------------------------------
   -- @name getInputSources
   ----------------------------------------------------------------------------
   PROCEDURE getInputSources(o_cur  OUT  SYS_REFCURSOR)
   IS
   BEGIN
     OPEN o_cur FOR
           SELECT SOURCE_SID AS "sid"
                , CODE       AS "code"
             FROM AMECO_INDICATOR_INPUT_SOURCE;
   END getInputSources;

END AMECO_INDICATOR;
