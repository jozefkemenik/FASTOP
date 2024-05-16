/* Formatted on 24-Oct-22 16:44:41 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY AGG_GETTERS
AS
   /******************************************************************************
      NAME:       AGG_GETTERS
   ******************************************************************************/

   ----------------------------------------------------------------------------
   -- @name getVariables
   ----------------------------------------------------------------------------
   PROCEDURE getVariables(p_round_sid     IN     NUMBER
                        , p_area_id       IN     VARCHAR2
                        , p_variable_ids  IN     CORE_COMMONS.VARCHARARRAY
                        , o_cur              OUT SYS_REFCURSOR)
   IS
      l_variable_ids  VARCHARLIST := NULL;
   BEGIN
      IF p_variable_ids.COUNT > 0 THEN
         l_variable_ids := CORE_COMMONS.arrayToList(p_variable_ids);
      END IF;

      OPEN o_cur FOR
           SELECT DISTINCT
                  AGG_DATA_SID
                , AGG_TYPE_ID
                , DESCR
                , LAST_CHANGE_USER
                , LAST_CHANGE_DATE
                , WEIGHT_INDICATOR
                , WEIGHTING_YEAR
                , AGG_TYPE
                , GR_DESCR
                , COMPARABLE_VARIABLE_ID
             FROM (SELECT VW.AGG_DATA_SID
                        , VW.AGG_TYPE_ID
                        , NVL(LI.AGG_DESCR, LI.DESCR) AS DESCR
                        , VW.LAST_CHANGE_USER
                        , VW.LAST_CHANGE_DATE
                        , LI.WEIGHT                 AS WEIGHT_INDICATOR
                        , LI.WEIGHT_YEAR            AS WEIGHTING_YEAR
                        , VW.AGG_TYPE
                        , VW.GR_DESCR
                        , VW.COMPARABLE_VARIABLE_ID
                     FROM VW_AGG_DATA VW
                          JOIN VW_GD_ROUND_GRID_LINES LI ON (LI.LINE_ID = VW.AGG_TYPE_ID AND LI.ROUND_SID = VW.ROUND_SID)
                    WHERE VW.ROUND_SID = p_round_sid AND VW.COUNTRY_ID = p_area_id
                   UNION ALL
                   SELECT NULL                      AS AGG_DATA_SID
                        , LI.LINE_ID                AS AGG_TYPE_ID
                        , NVL(LI.AGG_DESCR, LI.DESCR) AS DESCR
                        , ''                        AS LAST_CHANGE_USER
                        , NULL                      AS LAST_CHANGE_DATE
                        , LI.WEIGHT                 AS WEIGHT_INDICATOR
                        , LI.WEIGHT_YEAR            AS WEIGHTING_YEAR
                        , 'LINE'                    AS AGG_TYPE
                        , GR.DESCR                  AS GR_DESCR
                        , LI.INDICATOR_ID           AS COMPARABLE_VARIABLE_ID
                     FROM VW_GD_ROUND_GRID_LINES LI JOIN GD_GRIDS GR ON GR.GRID_SID = LI.GRID_SID
                    WHERE LI.IN_AGG = 'Y'
                      AND LI.ROUND_SID = p_round_sid
                      AND LI.LINE_ID NOT IN
                             (SELECT AGG_TYPE_ID
                                FROM VW_AGG_DATA
                               WHERE COUNTRY_ID = p_area_id AND ROUND_SID = p_round_sid AND AGG_TYPE = 'LINE')
                   UNION ALL
                   SELECT VW.AGG_DATA_SID
                        , VW.AGG_TYPE_ID
                        , IND.DESCR
                        , VW.LAST_CHANGE_USER
                        , VW.LAST_CHANGE_DATE
                        , 'GDP' AS WEIGHT_INDICATOR
                        , 0   AS WEIGHTING_YEAR
                        , VW.AGG_TYPE
                        , VW.GR_DESCR
                        , VW.COMPARABLE_VARIABLE_ID
                     FROM VW_AGG_DATA VW JOIN INDICATORS IND ON IND.INDICATOR_ID = VW.AGG_TYPE_ID
                    WHERE VW.ROUND_SID = p_round_sid AND VW.COUNTRY_ID = p_area_id AND VW.AGG_TYPE <> 'LINE'
                   UNION ALL
                   SELECT NULL                 AS AGG_DATA_SID
                        , I.INDICATOR_ID       AS AGG_TYPE_ID
                        , I.DESCR
                        , ''                   AS LAST_CHANGE_USER
                        , NULL                 AS LAST_CHANGE_DATE
                        , 'GDP'                AS WEIGHT_INDICATOR
                        , 0                    AS WEIGHTING_YEAR
                        , 'INDICATOR'          AS AGG_TYPE
                        , 'Calculated variables' AS GR_DESCR
                        , ''                   AS COMPARABLE_VARIABLE_ID
                     FROM INDICATORS I
                          JOIN INDICATOR_LISTS IL ON IL.INDICATOR_SID = I.INDICATOR_SID
                          JOIN WORKBOOK_GROUPS WB ON WB.WORKBOOK_GROUP_SID = IL.WORKBOOK_GROUP_SID
                    WHERE UPPER(WB.WORKBOOK_GROUP_ID) = 'AGGREGATES_INDICATOR'
                      AND I.INDICATOR_ID NOT IN
                             (SELECT AGG_TYPE_ID
                                FROM VW_AGG_DATA
                               WHERE COUNTRY_ID = p_area_id AND ROUND_SID = p_round_sid AND AGG_TYPE = 'INDICATOR'))
            WHERE (l_variable_ids IS NULL OR AGG_TYPE_ID IN (SELECT * FROM TABLE(l_variable_ids)))
         ORDER BY AGG_TYPE, AGG_TYPE_ID;
   END getVariables;

   ----------------------------------------------------------------------------
   -- @name getGridCells
   ----------------------------------------------------------------------------
   PROCEDURE getGridCells(p_round_sid IN NUMBER, p_line_ids IN CORE_COMMONS.VARCHARARRAY, o_cur OUT SYS_REFCURSOR)
   IS
      l_line_ids  VARCHARLIST := CORE_COMMONS.arrayToList(p_line_ids);
   BEGIN
      OPEN o_cur FOR
           SELECT LINE_ID
                , COUNTRY_ID
                , VALUE_CD
                , VALUE_P
                , CASE IS_ABSOLUTE WHEN 0 THEN YEAR ELSE 0 END      AS START_YEAR
                , YEAR_VALUE
                , CASE WHEN DATA_TYPE_ID = 'LEVELS' THEN 1 ELSE 0 END AS IS_LEVEL
             FROM VW_GD_CELLS
            WHERE ROUND_SID = p_round_sid
              AND LINE_TYPE_ID IN ('LINE', 'CALCULATION')
              AND COL_TYPE_ID = 'YEAR'
              AND IN_AGG = 'Y'
              AND LINE_ID IN (SELECT * FROM TABLE(l_line_ids))
              AND VERSION = GD_GETTERS.getCountryVersion(COUNTRY_ID, ROUND_SID)
         ORDER BY COUNTRY_ID, LINE_ID, YEAR_VALUE;
   END getGridCells;

   ----------------------------------------------------------------------------
   -- @name getIndicatorVectors
   ----------------------------------------------------------------------------
   PROCEDURE getIndicatorVectors(p_round_sid      IN     NUMBER
                               , p_area           IN     VARCHAR2
                               , p_indicator_ids  IN     CORE_COMMONS.VARCHARARRAY
                               , o_cur               OUT SYS_REFCURSOR)
   IS
      l_indicator_ids  VARCHARLIST := CORE_COMMONS.arrayToList(p_indicator_ids);
   BEGIN
      OPEN o_cur FOR   SELECT IJ.INDICATOR_ID AS VARIABLE_ID, CG.COUNTRY_ID, IJ.START_YEAR, IJ.VECTOR
                         FROM COUNTRY_GROUPS CG
                              JOIN GEO_AREAS GA ON (GA.GEO_AREA_ID = CG.COUNTRY_ID AND CG.COUNTRY_GROUP_ID = p_area)
                              LEFT OUTER JOIN
                              (SELECT CID.COUNTRY_ID, I.INDICATOR_ID, CID.START_YEAR, CID.VECTOR
                                 FROM CALCULATED_INDIC_DATA CID JOIN INDICATORS I ON CID.INDICATOR_SID = I.INDICATOR_SID
                                WHERE CID.ROUND_SID = p_round_sid
                                  AND I.INDICATOR_ID IN (SELECT * FROM TABLE(l_indicator_ids))
                                  AND NOT EXISTS
                                         (SELECT *
                                            FROM AMECO_INDIC_DATA AID
                                           WHERE AID.INDICATOR_SID = I.INDICATOR_SID)
                               UNION ALL
                               SELECT AID.COUNTRY_ID, I.INDICATOR_ID, AID.START_YEAR, AID.VECTOR
                                 FROM AMECO_INDIC_DATA AID JOIN INDICATORS I ON AID.INDICATOR_SID = I.INDICATOR_SID
                                WHERE AID.ROUND_SID = p_round_sid
                                  AND I.INDICATOR_ID IN (SELECT * FROM TABLE(l_indicator_ids))
                                  AND EXISTS
                                         (SELECT *
                                            FROM AMECO_INDIC_DATA AID
                                           WHERE AID.INDICATOR_SID = I.INDICATOR_SID)) IJ
                                 ON IJ.COUNTRY_ID = GA.GEO_AREA_ID
                     ORDER BY IJ.INDICATOR_ID, GA.AMECO_ORDER;
   END getIndicatorVectors;

   ----------------------------------------------------------------------------
   -- @name getAggregatedVectors
   ----------------------------------------------------------------------------
   PROCEDURE getAggregatedVectors(p_round_sid     IN     NUMBER
                                , p_variable_ids  IN     CORE_COMMONS.VARCHARARRAY
                                , o_cur              OUT SYS_REFCURSOR)
   IS
      l_variable_ids  VARCHARLIST := CORE_COMMONS.arrayToList(p_variable_ids);
   BEGIN
      OPEN o_cur FOR SELECT COUNTRY_ID, AGG_TYPE_ID AS VARIABLE_ID, START_YEAR, VECTOR
                       FROM VW_AGG_DATA
                      WHERE ROUND_SID = p_round_sid AND AGG_TYPE_ID IN (SELECT * FROM TABLE(l_variable_ids));
   END getAggregatedVectors;

   ----------------------------------------------------------------------------
   -- @name getLevels
   ----------------------------------------------------------------------------
   PROCEDURE getLevels(p_round_sid IN NUMBER, p_line_id IN VARCHAR2, o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT COUNTRY_ID, VALUE_CD
             FROM VW_GD_CELLS
            WHERE ROUND_SID = p_round_sid
              AND LINE_TYPE_ID IN ('LINE', 'CALCULATION')
              AND DATA_TYPE_ID = 'LEVELS'
              AND LINE_ID = p_line_id
              AND VERSION = GD_GETTERS.getCountryVersion(COUNTRY_ID, ROUND_SID)
         ORDER BY COUNTRY_ID;
   END getLevels;
END AGG_GETTERS;