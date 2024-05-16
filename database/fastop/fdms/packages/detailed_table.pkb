/* Formatted on 27-01-2021 14:45:39 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY FDMS_DETAILED_TABLE
AS
   /**************************************************************************
    *********************** PRIVATE SECTION **********************************
    **************************************************************************/

   /**************************************************************************
    *********************** PUBLIC SECTION ***********************************
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name getBaseYear
   ----------------------------------------------------------------------------
   PROCEDURE getBaseYear(p_round_sid IN NUMBER, o_year OUT NUMBER)
   IS
      l_round_sid ROUNDS.ROUND_SID%TYPE;
      l_round     ROUNDS.DESCR%TYPE;
      l_version   ROUNDS.VERSION%TYPE;
      l_period    PERIODS.DESCR%TYPE;
      l_period_id PERIODS.PERIOD_ID%TYPE;
   BEGIN
      CORE_GETTERS.GETROUNDINFO(l_round_sid
                              , o_year
                              , l_round
                              , l_period
                              , l_period_id
                              , l_version
                              , FDMS_GETTERS.APP_ID
                              , p_round_sid);

      IF l_period_id = 'AUT' THEN
         o_year := o_year + 1;
      END IF;
   END getBaseYear;

   ----------------------------------------------------------------------------
   -- @name getTableCols
   ----------------------------------------------------------------------------
   PROCEDURE getTableCols(p_table_sid IN NUMBER, o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR   SELECT TC.*
                         FROM VW_FDMS_DT_TABLE_COLS TC
                        WHERE TC.TABLE_SID = p_table_sid
                     ORDER BY TC.ORDER_BY;
   END getTableCols;

   ----------------------------------------------------------------------------
   -- @name getTableIndicatorIds
   ----------------------------------------------------------------------------
   PROCEDURE getTableIndicatorIds(o_cur               OUT SYS_REFCURSOR
                                , p_periodicity_id IN     VARCHAR2 DEFAULT NULL
                                , p_table_sid      IN     NUMBER DEFAULT NULL)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT DISTINCT I.INDICATOR_ID
             FROM FDMS_DT_TABLE_LINES TL
                  JOIN FDMS_DT_LINE_INDICATORS LI ON LI.TABLE_LINE_SID = TL.TABLE_LINE_SID
                  JOIN VW_FDMS_INDICATORS I ON I.INDICATOR_SID = LI.INDICATOR_SID
            WHERE (p_table_sid IS NULL OR TL.TABLE_SID = p_table_sid)
              AND (p_periodicity_id IS NULL OR I.PERIODICITY_ID = p_periodicity_id);
   END getTableIndicatorIds;

   ----------------------------------------------------------------------------
   -- @name getTableIndicators
   ----------------------------------------------------------------------------
   PROCEDURE getTableIndicators(p_table_sid IN NUMBER, o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT DISTINCT I.PERIODICITY_ID, I.INDICATOR_ID
             FROM FDMS_DT_TABLE_LINES TL
                  JOIN FDMS_DT_LINE_INDICATORS LI ON LI.TABLE_LINE_SID = TL.TABLE_LINE_SID
                  JOIN VW_FDMS_INDICATORS I ON I.INDICATOR_SID = LI.INDICATOR_SID
            WHERE TL.TABLE_SID = p_table_sid
         ORDER BY I.PERIODICITY_ID;
   END getTableIndicators;

   ----------------------------------------------------------------------------
   -- @name getTableLines
   ----------------------------------------------------------------------------
   PROCEDURE getTableLines(p_table_sid IN NUMBER, o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR   SELECT TL.*
                         FROM VW_FDMS_DT_TABLE_LINES TL
                        WHERE TL.TABLE_SID = p_table_sid
                     ORDER BY TL.ORDER_BY;
   END getTableLines;

   ----------------------------------------------------------------------------
   -- @name getTables
   ----------------------------------------------------------------------------
   PROCEDURE getTables(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR   SELECT T.TABLE_SID, T.TABLE_ID, T.DESCR, T.FOOTER
                         FROM FDMS_DT_TABLES T
                     ORDER BY T.ORDER_BY;
   END getTables;
END FDMS_DETAILED_TABLE;
