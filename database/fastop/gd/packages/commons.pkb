/* Formatted on 02-03-2022 14:37:36 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY GD_COMMONS
AS
   /**************************************************************************
      NAME:       GD_COMMONS
      PURPOSE:
    **************************************************************************/

   PROCEDURE hasAnyGridData(p_app_id     IN     VARCHAR2
                          , p_country_id IN     VARCHAR2
                          , p_round_sid  IN     NUMBER DEFAULT NULL
                          , o_res           OUT NUMBER)
   IS
      l_round_sid NUMBER := p_round_sid;
   BEGIN
      IF l_round_sid IS NULL THEN
         l_round_sid := CORE_GETTERS.getCurrentRoundSid(p_app_id);
      END IF;

      SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
        INTO o_res
        FROM VW_GD_CELLS
       WHERE COUNTRY_ID = p_country_id
         AND ROUND_SID = l_round_sid
         AND (VALUE_P IS NOT NULL OR VALUE_N IS NOT NULL OR VALUE_CD IS NOT NULL);
   END hasAnyGridData;

   ----------------------------------------------------------------------------
   -- @name hasMissingData - returns number of empty cells in normal grids
   ----------------------------------------------------------------------------
   PROCEDURE hasMissingData(p_country_id IN VARCHAR2, p_round_sid IN NUMBER, o_res OUT NUMBER)
   IS
      l_version NUMBER(4) := GD_GETTERS.getCountryVersion(p_country_id, p_round_sid);
   BEGIN
      SELECT COUNT(*)
        INTO o_res
        FROM VW_GD_CTY_GRIDS  VCG
             JOIN VW_GD_ROUND_GRID_LINES VL ON VCG.ROUND_GRID_SID = VL.ROUND_GRID_SID
             JOIN VW_GD_ROUND_GRID_COLS VC ON VCG.ROUND_GRID_SID = VC.ROUND_GRID_SID
             LEFT JOIN GD_CELLS C
                ON C.CTY_GRID_SID = VCG.CTY_GRID_SID
               AND C.LINE_SID = VL.LINE_SID
               AND C.COL_SID = VC.COL_SID
       WHERE VCG.COUNTRY_ID = p_country_id
         AND VCG.ROUND_SID = p_round_sid
         AND VCG.VERSION = l_version
         AND VCG.GRID_TYPE_ID = 'NORMAL'
         AND VL.LINE_TYPE_ID = 'LINE'
         AND VC.COL_TYPE_ID = 'YEAR'
         AND (C.VALUE_CD IS NULL OR C.VALUE_N IS NULL OR C.VALUE_P IS NULL);
   END hasMissingData;
END GD_COMMONS;