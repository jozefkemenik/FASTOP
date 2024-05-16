/* Formatted on 30-03-2021 11:08:41 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY IDR_CALCULATED
AS
   /**************************************************************************
    *********************** PRIVATE SECTION **********************************
    **************************************************************************/

   /**************************************************************************
    *********************** PUBLIC SECTION ***********************************
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name getAmecoIndicators
   ----------------------------------------------------------------------------
   PROCEDURE getAmecoIndicators(o_cur           OUT SYS_REFCURSOR
                              , p_country_id IN     VARCHAR2
                              , p_indicators IN     CORE_COMMONS.VARCHARARRAY
                              , p_round_sid  IN     NUMBER)
   IS
      l_indicators VARCHARLIST := CORE_COMMONS.arrayToList(p_indicators);
   BEGIN
      OPEN o_cur FOR
           SELECT I.INDICATOR_ID, I.DESCR, D.VECTOR, D.START_YEAR
             FROM INDICATORS I
                  LEFT JOIN AMECO_INDIC_DATA D
                     ON (D.INDICATOR_SID = I.INDICATOR_SID
                     AND D.COUNTRY_ID = p_country_id
                     AND D.ROUND_SID = p_round_sid)
            WHERE I.INDICATOR_ID IN (SELECT * FROM TABLE(l_indicators))
         ORDER BY I.INDICATOR_ID ASC;
   END getAmecoIndicators;

   ----------------------------------------------------------------------------
   -- @name getAmecoIndicatorsForCSV
   ----------------------------------------------------------------------------
   PROCEDURE getAmecoIndicatorsForCSV(o_cur              OUT SYS_REFCURSOR
                                    , p_round_sids    IN     CORE_COMMONS.SIDSARRAY
                                    , p_country_ids   IN     CORE_COMMONS.VARCHARARRAY
                                    , p_indicator_ids IN     CORE_COMMONS.VARCHARARRAY)
   IS
      l_round_sids    SIDSLIST := CORE_COMMONS.arrayToSidsList(p_round_sids);
      l_country_ids   VARCHARLIST := CORE_COMMONS.arrayToList(p_country_ids);
      l_indicator_ids VARCHARLIST := CORE_COMMONS.arrayToList(p_indicator_ids);
   BEGIN
      OPEN o_cur FOR
           SELECT D.YEAR
                , D.COUNTRY_ID
                , D.INDICATOR_ID
                , D.START_YEAR
                , D.VECTOR
             FROM VW_AMECO_INDIC_DATA D
            WHERE D.ROUND_SID IN (SELECT * FROM TABLE(l_round_sids))
              AND D.COUNTRY_ID IN (SELECT * FROM TABLE(l_country_ids))
              AND D.INDICATOR_ID IN (SELECT * FROM TABLE(l_indicator_ids))
         ORDER BY D.YEAR, D.COUNTRY_ID, D.INDICATOR_ID;
   END getAmecoIndicatorsForCSV;

   ----------------------------------------------------------------------------
   -- @name getCalculatedIndicators
   ----------------------------------------------------------------------------
   PROCEDURE getCalculatedIndicators(o_cur           OUT SYS_REFCURSOR
                                   , p_country_id IN     VARCHAR2
                                   , p_sources    IN     CORE_COMMONS.VARCHARARRAY
                                   , p_indicators IN     CORE_COMMONS.VARCHARARRAY
                                   , p_round_sid  IN     NUMBER)
   IS
      l_sources    VARCHARLIST := CORE_COMMONS.arrayToList(p_sources);
      l_indicators VARCHARLIST := CORE_COMMONS.arrayToList(p_indicators);
   BEGIN
      OPEN o_cur FOR
           SELECT D.INDICATOR_ID
                , D.DESCR
                , D.INDICATOR_SOURCE SOURCE
                , D.VECTOR
                , D.START_YEAR
                , O.ORDER_BY
             FROM VW_CALCULATED_INDIC_DATA D
                  LEFT JOIN OG_INDIC_ORDER O ON D.INDICATOR_SID = O.INDICATOR_SID
            WHERE D.COUNTRY_ID = p_country_id
              AND D.ROUND_SID = p_round_sid
              AND D.INDICATOR_SOURCE IN (SELECT * FROM TABLE(l_sources))
              AND D.INDICATOR_ID IN (SELECT * FROM TABLE(l_indicators))
         ORDER BY O.ORDER_BY;
   END getCalculatedIndicators;

   ----------------------------------------------------------------------------
   -- @name getCalculatedIndicatorsForCSV
   ----------------------------------------------------------------------------
   PROCEDURE getCalculatedIndicatorsForCSV(o_cur              OUT SYS_REFCURSOR
                                         , p_round_sids    IN     CORE_COMMONS.SIDSARRAY
                                         , p_country_ids   IN     CORE_COMMONS.VARCHARARRAY
                                         , p_indicator_ids IN     CORE_COMMONS.VARCHARARRAY)
   IS
      l_round_sids    SIDSLIST := CORE_COMMONS.arrayToSidsList(p_round_sids);
      l_country_ids   VARCHARLIST := CORE_COMMONS.arrayToList(p_country_ids);
      l_indicator_ids VARCHARLIST := CORE_COMMONS.arrayToList(p_indicator_ids);
   BEGIN
      OPEN o_cur FOR
           SELECT D.YEAR
                , D.COUNTRY_ID
                , D.INDICATOR_ID
                , D.START_YEAR
                , D.VECTOR
             FROM VW_CALCULATED_INDIC_DATA D
            WHERE D.ROUND_SID IN (SELECT * FROM TABLE(l_round_sids))
              AND D.COUNTRY_ID IN (SELECT * FROM TABLE(l_country_ids))
              AND D.INDICATOR_ID IN (SELECT * FROM TABLE(l_indicator_ids))
         ORDER BY D.YEAR, D.COUNTRY_ID, D.INDICATOR_ID;
   END getCalculatedIndicatorsForCSV;

   ----------------------------------------------------------------------------
   -- @name getSemiElasticityInfo
   ----------------------------------------------------------------------------
   PROCEDURE getSemiElasticityInfo(o_cur OUT SYS_REFCURSOR, p_country_id IN VARCHAR2, p_round_sid IN NUMBER)
   IS
   BEGIN
      OPEN o_cur FOR 
      -- Get the latest available value
         SELECT t.VALUE, t.ROUND_SID, t.YEAR, t.DESCR, t.PERIOD_DESCR
            FROM ( SELECT SE.VALUE
                        , R.ROUND_SID
                        , R.YEAR
                        , R.DESCR
                        , R.PERIOD_DESCR
                        , ROW_NUMBER() OVER (ORDER BY R.YEAR DESC, R.ORDER_PERIOD DESC) AS row_num
                     FROM SEMI_ELASTICS SE 
                     JOIN VW_ROUNDS R ON se.ROUND_SID = R.ROUND_SID
                  WHERE se.country_id = p_country_id
                     AND (R.YEAR || R.ORDER_PERIOD <= (SELECT r2.year || r2.order_period FROM VW_ROUNDS r2 WHERE r2.round_sid = p_round_sid))
                 ) t
            WHERE t.row_num = 1;

   END getSemiElasticityInfo;  

   ----------------------------------------------------------------------------
   -- @name getAmecoLastChangeDate
   ----------------------------------------------------------------------------
   PROCEDURE getAmecoLastChangeDate(o_res           OUT DATE
                                  , p_country_id IN     VARCHAR2
                                  , p_round_sid  IN     NUMBER)
   IS
   BEGIN
      SELECT last_change_date
        INTO o_res
        FROM (SELECT MAX(D.LAST_CHANGE_DATE) AS last_change_date
                FROM INDICATORS  I
                     INNER JOIN AMECO_INDIC_DATA D ON I.INDICATOR_SID = D.INDICATOR_SID
               WHERE LOWER(I.SOURCE) = 'ameco'
                 AND D.COUNTRY_ID = p_country_id
                 AND D.ROUND_SID = p_round_sid);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         o_res := NULL;
   END getAmecoLastChangeDate;

   ----------------------------------------------------------------------------
   -- @name getCalculatedLastChangeDate
   ----------------------------------------------------------------------------
   PROCEDURE getCalculatedLastChangeDate(o_res             OUT DATE
                                       , p_indicator_id IN     VARCHAR2
                                       , p_country_id   IN     VARCHAR2
                                       , p_round_sid    IN     NUMBER)
   IS
   BEGIN
      SELECT last_change_date
        INTO o_res
        FROM (SELECT MAX(D.LAST_CHANGE_DATE) AS last_change_date
                FROM INDICATORS  I
                     INNER JOIN CALCULATED_INDIC_DATA D ON I.INDICATOR_SID = D.INDICATOR_SID
               WHERE LOWER(I.INDICATOR_ID) = LOWER(p_indicator_id)
                 AND D.COUNTRY_ID = p_country_id
                 AND D.ROUND_SID = p_round_sid);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         o_res := NULL;
   END getCalculatedLastChangeDate;

   ----------------------------------------------------------------------------
   -- @name scaleTimeSerie
   ----------------------------------------------------------------------------
   FUNCTION scaleTimeSerie(p_time_serie IN VARCHAR2, p_scale_id IN VARCHAR2)
      RETURN VARCHAR2
   IS
      l_time_serie  VARCHAR2(4000) := p_time_serie;
      l_comma_index NUMBER(8);
      l_index       NUMBER(8) := 1;
      l_token       VARCHAR2(100);
      l_length      NUMBER(8) := LENGTH(p_time_serie);
   BEGIN
      IF p_time_serie IS NOT NULL AND p_scale_id IS NOT NULL THEN
         l_time_serie := NULL;

         LOOP
            l_comma_index := INSTR(p_time_serie, ',', l_index);

            IF l_comma_index = 0 THEN
               l_comma_index := l_length + 1;
            END IF;

            l_token       := SUBSTR(p_time_serie, l_index, l_comma_index - l_index);

            BEGIN
               l_token :=
                  TO_CHAR(
                       TO_NUMBER(l_token)
                     / CASE p_scale_id
                          WHEN 'Billions' THEN 1000000000
                          WHEN 'Millions' THEN 1000000
                          ELSE 1
                       END
                  );
            EXCEPTION
               WHEN VALUE_ERROR THEN
                  l_token := NULL;
            END;

            l_time_serie  := l_time_serie || ',' || l_token;
            l_index       := l_comma_index + 1;
            EXIT WHEN l_index > l_length AND l_comma_index > l_length;
         END LOOP;

         l_time_serie := SUBSTR(l_time_serie, 2);
      END IF;

      RETURN l_time_serie;
   END scaleTimeSerie;

   ----------------------------------------------------------------------------
   -- @name uploadCalculatedIndicatorData
   ----------------------------------------------------------------------------
   PROCEDURE uploadCalculatedIndicatorData(
      p_round_sid        IN     calculated_indic_data.round_sid%TYPE
    , p_indicator_sid    IN     calculated_indic_data.indicator_sid%TYPE
    , p_country_id       IN     calculated_indic_data.country_id%TYPE
    , p_start_year       IN     calculated_indic_data.start_year%TYPE
    , p_vector           IN     calculated_indic_data.vector%TYPE
    , p_last_change_user IN     calculated_indic_data.last_change_user%TYPE
    , p_source           IN     calculated_indic_data.source%TYPE
    , o_res                 OUT NUMBER
   )
   IS
   BEGIN
      UPDATE calculated_indic_data
         SET start_year       = p_start_year
           , vector           = p_vector
           , last_change_user = p_last_change_user
           , last_change_date = SYSDATE
           , source           = p_source
       WHERE indicator_sid = p_indicator_sid
         AND country_id = p_country_id
         AND round_sid = p_round_sid;

      IF SQL%ROWCOUNT = 0 THEN
         INSERT INTO calculated_indic_data(round_sid
                                         , indicator_sid
                                         , country_id
                                         , start_year
                                         , vector
                                         , source
                                         , last_change_user
                                         , last_change_date)
              VALUES (p_round_sid
                    , p_indicator_sid
                    , p_country_id
                    , p_start_year
                    , p_vector
                    , p_source
                    , p_last_change_user
                    , SYSDATE);
      END IF;

      o_res := SQL%ROWCOUNT;
   END uploadCalculatedIndicatorData;
END IDR_CALCULATED;