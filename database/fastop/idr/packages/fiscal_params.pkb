/* Formatted on 31-Oct-22 15:40:26 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY IDR_FISCAL_PARAMS
AS
   /**************************************************************************
    *********************** PRIVATE SECTION **********************************
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name getEmptyVector
   ----------------------------------------------------------------------------
   FUNCTION getEmptyVector(p_start_year IN NUMBER, p_end_year IN NUMBER)
      RETURN VARCHAR2
   IS
      l_vector  CALCULATED_INDIC_DATA.VECTOR%TYPE := '';
   BEGIN
      FOR year IN p_start_year .. p_end_year LOOP
         IF year < p_end_year THEN
            l_vector := l_vector || 'n.a.,';
         ELSE
            l_vector := l_vector || 'n.a.';
         END IF;
      END LOOP;

      RETURN l_vector;
   END getEmptyVector;

   /**************************************************************************
    *********************** PUBLIC SECTION ***********************************
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name getTemplateDefinitions
   ----------------------------------------------------------------------------
   PROCEDURE getTemplateDefinitions(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR   SELECT *
                         FROM VW_FP_TPL_DEFINITIONS
                        WHERE WORKSHEET_ORDER > 0
                     ORDER BY WORKSHEET_ORDER, INDICATOR_ORDER ASC;
   END getTemplateDefinitions;

   ----------------------------------------------------------------------------
   -- @name getWorksheets
   ----------------------------------------------------------------------------
   PROCEDURE getWorksheets(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT WORKSHEET_SID AS "worksheetSid"
                , NAME        AS "name"
                , TITLE       AS "title"
                , START_YEAR  AS "startYear"
                , END_YEAR    AS "endYear"
                , ORDER_BY    AS "orderBy"
             FROM FP_TPL_WORKSHEET
            WHERE ORDER_BY > 0
         ORDER BY ORDER_BY ASC;
   END getWorksheets;

   ----------------------------------------------------------------------------
   -- @name getWorksheetIndicatorData
   ----------------------------------------------------------------------------
   PROCEDURE getWorksheetIndicatorData(o_cur               OUT SYS_REFCURSOR
                                     , p_worksheet_sid  IN     NUMBER
                                     , p_round_sid      IN     NUMBER DEFAULT NULL
                                     , p_app_id         IN     VARCHAR2 DEFAULT NULL)
   IS
      l_round_sid  ROUNDS.ROUND_SID%TYPE := CORE_GETTERS.currentOrPassedRound(p_round_sid, p_app_id);
   BEGIN
      OPEN o_cur FOR
           SELECT CID.COUNTRY_ID AS "countryId"
                , CID.START_YEAR AS "startYear"
                , CID.VECTOR    AS "vector"
                , I.INDICATOR_ID AS "indicatorId"
                , I.INDICATOR_SID AS "indicatorSid"
             FROM CALCULATED_INDIC_DATA CID
                  INNER JOIN FP_TPL_INDICATORS FPI ON FPI.INDICATOR_SID = CID.INDICATOR_SID
                  INNER JOIN INDICATORS I ON I.INDICATOR_SID = CID.INDICATOR_SID
                  INNER JOIN GEO_AREAS G ON G.GEO_AREA_ID = CID.COUNTRY_ID
            WHERE FPI.WORKSHEET_SID = p_worksheet_sid AND CID.ROUND_SID = l_round_sid
         ORDER BY G.ORDER_BY ASC, FPI.ORDER_BY ASC;
   END getWorksheetIndicatorData;

   ----------------------------------------------------------------------------
   -- @name storeIndicators
   ----------------------------------------------------------------------------
   PROCEDURE storeIndicators(o_res                  OUT NUMBER
                           , p_round_sid         IN     NUMBER
                           , p_last_change_user  IN     VARCHAR2
                           , p_indicator_sids    IN     CORE_COMMONS.SIDSARRAY
                           , p_country_ids       IN     CORE_COMMONS.VARCHARARRAY
                           , p_start_years       IN     CORE_COMMONS.SIDSARRAY
                           , p_vectors           IN     CORE_COMMONS.VARCHARARRAY)
   IS
      l_res              NUMBER;
      l_prev_start_year  NUMBER := 0;
      l_prev_end_year    NUMBER := 0;
      l_vector           CALCULATED_INDIC_DATA.VECTOR%TYPE;
      l_source           CALCULATED_INDIC_DATA.SOURCE%TYPE := 'EXCEL_C1';

      CURSOR c_ind_cur
      IS
         SELECT D.INDICATOR_SID, D.START_YEAR, D.END_YEAR, C.COUNTRY_ID
           FROM VW_FP_TPL_DEFINITIONS D CROSS JOIN VW_EU27_COUNTRIES C;
   BEGIN
      l_res := 0;

      FOR tpl_record IN c_ind_cur LOOP
         IF l_prev_start_year != tpl_record.START_YEAR OR l_prev_end_year != tpl_record.END_YEAR THEN
            l_vector := getEmptyVector(tpl_record.START_YEAR, tpl_record.END_YEAR);
            l_prev_start_year := tpl_record.START_YEAR;
            l_prev_end_year := tpl_record.END_YEAR;
         END IF;

         IDR_CALCULATED.uploadCalculatedIndicatorData(p_round_sid
                                                    , tpl_record.INDICATOR_SID
                                                    , tpl_record.COUNTRY_ID
                                                    , tpl_record.START_YEAR
                                                    , l_vector
                                                    , p_last_change_user
                                                    , l_source
                                                    , l_res);
         o_res := o_res + l_res;
      END LOOP;

      l_res := 0;

      FOR i IN 1 .. p_vectors.COUNT LOOP
         IDR_CALCULATED.uploadCalculatedIndicatorData(p_round_sid
                                                    , p_indicator_sids(i)
                                                    , p_country_ids(i)
                                                    , p_start_years(i)
                                                    , p_vectors(i)
                                                    , p_last_change_user
                                                    , l_source
                                                    , o_res);
         o_res := o_res + l_res;
      END LOOP;
   END storeIndicators;
END IDR_FISCAL_PARAMS;
/