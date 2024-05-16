/* Formatted on 23/03/2021 11:19:19 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY IDR_GETTERS
AS
   /**************************************************************************
    *********************** PRIVATE SECTION **********************************
    **************************************************************************/


   /**************************************************************************
    *********************** PUBLIC SECTION ***********************************
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name getIndicatorById
   ----------------------------------------------------------------------------
   PROCEDURE getIndicatorById(o_cur             OUT SYS_REFCURSOR
                            , p_indicator_id IN     indicators.indicator_id%TYPE)
   IS
   BEGIN
      OPEN o_cur FOR SELECT *
                       FROM INDICATORS I
                      WHERE I.INDICATOR_ID = p_indicator_id;
   END getIndicatorById;

   ----------------------------------------------------------------------------
   -- @name getIndicatorListBySource
   ----------------------------------------------------------------------------
   PROCEDURE getIndicatorListBySource(o_cur       OUT SYS_REFCURSOR
                                    , p_source IN     indicators.source%TYPE DEFAULT NULL)
   IS
   BEGIN
      OPEN o_cur FOR   SELECT I.INDICATOR_SID, I.INDICATOR_ID, I.DESCR
                         FROM INDICATORS I
                        WHERE p_source IS NULL OR I.SOURCE = p_source
                     ORDER BY I.INDICATOR_ID;
   END getIndicatorListBySource;

   ----------------------------------------------------------------------------
   -- @name getAmecoIndForLinkedTables
   ----------------------------------------------------------------------------
   PROCEDURE getAmecoIndForLinkedTables(o_cur OUT SYS_REFCURSOR, p_workbook_id IN VARCHAR2)
   IS
   BEGIN
      OPEN o_cur FOR SELECT I.INDICATOR_ID
                       FROM INDICATORS  I
                            JOIN INDICATOR_LISTS L ON L.INDICATOR_SID = I.INDICATOR_SID
                            JOIN WORKBOOK_GROUPS W ON L.WORKBOOK_GROUP_SID = W.WORKBOOK_GROUP_SID
                      WHERE W.WORKBOOK_GROUP_ID = p_workbook_id AND LOWER(I.SOURCE) = 'ameco';
   END getAmecoIndForLinkedTables;

   ----------------------------------------------------------------------------
   -- @name getLastAmecoUpload
   ----------------------------------------------------------------------------
   FUNCTION getLastAmecoUpload(p_round_sid IN NUMBER)
      RETURN DATE
   IS
      l_ameco_upload_date DATE;
   BEGIN
      SELECT MAX(D.LAST_CHANGE_DATE)
        INTO l_ameco_upload_date
        FROM AMECO_INDIC_DATA D
       WHERE D.ROUND_SID = p_round_sid;

      RETURN l_ameco_upload_date;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
   END getLastAmecoUpload;

   ----------------------------------------------------------------------------
   -- @name getLastFiscalParamsUpload
   ----------------------------------------------------------------------------
   FUNCTION getLastFiscalParamsUpload(p_round_sid IN NUMBER)
      RETURN DATE
   IS
      l_fp_upload_date DATE;
   BEGIN
      SELECT MAX(D.LAST_CHANGE_DATE)
        INTO l_fp_upload_date
        FROM CALCULATED_INDIC_DATA D JOIN FP_TPL_INDICATORS I ON I.INDICATOR_SID = D.INDICATOR_SID
       WHERE D.ROUND_SID = p_round_sid;

      RETURN l_fp_upload_date;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
   END getLastFiscalParamsUpload;

   ----------------------------------------------------------------------------
   -- @name getCurrentGDP
   -- @purpose = retrieve latest GDP indicator value in order to transform values in level into values in % of GDP
   -- the cursor gets either one country as a parameter or no countries which means that it selects GDP for all countries.
   ----------------------------------------------------------------------------
   PROCEDURE getCurrentGDP(p_country_id    IN     VARCHAR2
                         , o_cur              OUT SYS_REFCURSOR
                         , p_with_forecast IN     NUMBER DEFAULT NULL)
   IS
      l_gdp VARCHAR2(40)
               := CASE p_with_forecast WHEN 1 THEN '1.0.0.0.UVGDOG' ELSE '1.2.0.0.UVGD' END;
   BEGIN
      OPEN o_cur FOR SELECT A.ROUND_SID
                          , A.PERIOD_ID
                          , A.YEAR
                          , A.COUNTRY_ID
                          , A.START_YEAR
                          , A.VECTOR
                       FROM VW_AMECO_INDIC_DATA  A
                            JOIN (
                                      SELECT MAX(YEAR) MAX_YEAR, COUNTRY_ID, INDICATOR_SID
                                        FROM VW_AMECO_INDIC_DATA
                                       WHERE INDICATOR_ID = l_gdp AND ROUND_TYPE = 'N'
                                    GROUP BY COUNTRY_ID, INDICATOR_SID
                                 ) B
                               ON B.COUNTRY_ID = A.COUNTRY_ID
                              AND B.MAX_YEAR = A.YEAR
                              AND B.INDICATOR_SID = A.INDICATOR_SID
                            JOIN
                            (  SELECT MAX(ORDER_PERIOD) MAX_ORDER_PERIOD
                                    , COUNTRY_ID
                                    , YEAR
                                    , INDICATOR_SID
                                 FROM VW_AMECO_INDIC_DATA
                                WHERE INDICATOR_ID = l_gdp AND ROUND_TYPE = 'N'
                             GROUP BY COUNTRY_ID, YEAR, INDICATOR_SID) C
                               ON C.COUNTRY_ID = B.COUNTRY_ID
                              AND C.YEAR = B.MAX_YEAR
                              AND C.INDICATOR_SID = B.INDICATOR_SID
                              AND C.MAX_ORDER_PERIOD = A.ORDER_PERIOD
                      WHERE p_country_id IS NULL OR A.COUNTRY_ID = p_country_id;
   END;

   ----------------------------------------------------------------------------
   -- @name getHelpMessages
   ----------------------------------------------------------------------------
   PROCEDURE getHelpMessages(p_help_msg_type_id IN VARCHAR2 DEFAULT NULL, o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR   SELECT HELP_MSG_SID, DESCR, MESS
                         FROM HELP_MSGS
                        WHERE p_help_msg_type_id IS NULL OR HELP_MSG_TYPE_ID = p_help_msg_type_id
                     ORDER BY HELP_MSG_SID ASC;
   END getHelpMessages;

   ----------------------------------------------------------------------------
   -- @name getCyclicalAdjustments
   ----------------------------------------------------------------------------
   PROCEDURE getCyclicalAdjustments(
      o_cur            OUT SYS_REFCURSOR
    , p_country_ids IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                NULL AS CORE_COMMONS.VARCHARARRAY
                                                             )
    , p_round_sid   IN     NUMBER DEFAULT NULL
   )
   IS
      l_round_sid     ROUNDS.ROUND_SID%TYPE := CORE_GETTERS.currentOrPassedRound(p_round_sid);
      l_country_ids   VARCHARLIST := CORE_COMMONS.arrayToList(p_country_ids);
      l_country_count NUMBER(3) := l_country_ids.COUNT;
   BEGIN
      OPEN o_cur FOR
         SELECT CA.COUNTRY_ID
              , CA.DESCR
              , 'UNIT' SCALE_ID
              , CA.START_YEAR
              , CA.VECTOR
           FROM VW_CYCLICAL_ADJUSTMENTS CA
          WHERE CA.ROUND_SID = (SELECT MAX(ROUND_SID)
                                  FROM CYCLICAL_ADJUSTMENTS
                                 WHERE ROUND_SID <= l_round_sid)
            AND (l_country_count = 0 OR CA.COUNTRY_ID IN (SELECT * FROM TABLE(l_country_ids)));
   END getCyclicalAdjustments;
END IDR_GETTERS;