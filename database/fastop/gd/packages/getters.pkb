CREATE OR REPLACE PACKAGE BODY GD_GETTERS
AS
   /******************************************************************************
      NAME:       GD_GETTERS
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        06/03/2019  rokosra          1. Created this package.
   ******************************************************************************/

   ----------------------------------------------------------------------------
   -- @name getCtyDefaultLevels gets country default levels for specific country grid
   ----------------------------------------------------------------------------
   PROCEDURE getCtyDefaultLevels(p_cty_grid_sid IN     NUMBER
                               , o_cur          OUT    SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
         SELECT L.LINE_SID
              , C.COL_SID
              , core_commons.listGetAt(ameco.vector, G.YEAR + C.YEAR_VALUE - AMECO.START_YEAR, ',') as value
              , s.SCALE_ID
           FROM VW_GD_CTY_GRIDS  G
           JOIN VW_GD_ROUND_GRID_LINES L ON L.ROUND_GRID_SID = G.ROUND_GRID_SID
           JOIN VW_GD_ROUND_GRID_COLS C ON C.ROUND_GRID_SID = G.ROUND_GRID_SID
           JOIN GD_LINE_INDICATOR li ON li.LINE_SID = l.LINE_SID AND C.DATA_TYPE_SID = li.DATA_TYPE_SID
           JOIN INDICATORS i ON i.INDICATOR_SID = li.INDICATOR_SID
           LEFT JOIN SCALES s ON s.SCALE_SID = i.SCALE_SID
           JOIN VW_AMECO_INDIC_DATA AMECO ON AMECO.COUNTRY_ID = G.COUNTRY_ID
               AND AMECO.ROUND_SID = G.ROUND_SID
               AND AMECO.INDICATOR_SID = li.INDICATOR_SID
          WHERE C.COL_TYPE_ID = 'YEAR'
            AND C.IS_ABSOLUTE = 0
            AND G.YEAR + C.YEAR_VALUE - AMECO.START_YEAR > 0
            AND G.CTY_GRID_SID = p_cty_grid_sid;

   END getCtyDefaultLevels;

   ----------------------------------------------------------------------------
   -- @name getCtyGrid gets grid information for a country
   ----------------------------------------------------------------------------
   PROCEDURE getCtyGrid(p_round_sid  IN     NUMBER
                      , p_grid_id    IN     VARCHAR2
                      , p_country_id IN     VARCHAR2
                      , p_version    IN     NUMBER
                      , o_cur           OUT SYS_REFCURSOR)
   IS
      l_version NUMBER(4);
   BEGIN
      IF p_version IS NULL THEN
         l_version := getCountryVersion(p_country_id, p_round_sid);
      ELSE
         l_version := p_version;
      END IF;

      OPEN o_cur FOR
         SELECT CG.CTY_GRID_SID
              , CG.ROUND_GRID_SID
              , CG.GRID_ID
              , CG.DESCR
              , CG.GRID_TYPE_ID
              , CG.CONSISTENCY_STATUS_CD_SID
              , CG.CONSISTENCY_STATUS_MS_SID
              , CG.YEAR
              , CG.VERSION
           FROM VW_GD_CTY_GRIDS CG
          WHERE CG.ROUND_SID = p_round_sid
            AND CG.GRID_ID = p_grid_id
            AND CG.COUNTRY_ID = p_country_id
            AND CG.VERSION = l_version;
   END getCtyGrid;

   ----------------------------------------------------------------------------
   -- @name getCtyGridRoundSid
   ----------------------------------------------------------------------------
   FUNCTION getCtyGridRoundSid(p_cty_grid_sid IN NUMBER)
      RETURN NUMBER
   IS
      l_round_sid ROUNDS.ROUND_SID%TYPE;
   BEGIN
      BEGIN
         SELECT CG.ROUND_SID
           INTO l_round_sid
           FROM vw_gd_cty_grids CG
          WHERE CG.CTY_GRID_SID = p_cty_grid_sid;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_round_sid := NULL;
      END;

      RETURN l_round_sid;
   END getCtyGridRoundSid;

   ----------------------------------------------------------------------------
   -- @name getCtyVersions
   ----------------------------------------------------------------------------
   PROCEDURE getCtyVersions(p_country_id IN     VARCHAR2
                          , p_round_sid  IN     NUMBER
                          , o_cur           OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR   SELECT DISTINCT CG.VERSION
                         FROM VW_GD_CTY_GRIDS CG
                        WHERE CG.COUNTRY_ID = p_country_id AND CG.ROUND_SID = p_round_sid
                     ORDER BY VERSION;
   END getCtyVersions;

   ----------------------------------------------------------------------------
   -- @name getCountryVersion
   ----------------------------------------------------------------------------
   FUNCTION getCountryVersion(p_country_id IN VARCHAR2, p_round_sid IN NUMBER)
      RETURN NUMBER
   IS
      l_version GD_CTY_VERSIONS.VERSION%TYPE;
   BEGIN
      BEGIN
         SELECT COALESCE(MAX(CG.VERSION), 0)
           INTO l_version
           FROM VW_GD_CTY_GRIDS CG
          WHERE CG.COUNTRY_ID = p_country_id AND CG.ROUND_SID = p_round_sid;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_version := NULL;
      END;

      RETURN l_version;
   END getCountryVersion;

   ----------------------------------------------------------------------------
   -- @name getCurrentCtyVersion
   ----------------------------------------------------------------------------
   PROCEDURE getCurrentCtyVersion(p_country_id IN VARCHAR2, p_app_id IN VARCHAR2, o_res OUT NUMBER)
   IS
   BEGIN
      o_res := getCountryVersion(p_country_id, CORE_GETTERS.getCurrentRoundSid(p_app_id));
   END getCurrentCtyVersion;

   ----------------------------------------------------------------------------
   -- @name getCountryVersionSid
   ----------------------------------------------------------------------------
   FUNCTION getCountryVersionSid(p_country_id IN VARCHAR2, p_round_sid IN NUMBER)
      RETURN NUMBER
   IS
      l_version         GD_CTY_VERSIONS.VERSION%TYPE;
      l_cty_version_sid NUMBER := 0;
   BEGIN
      l_version := getCountryVersion(p_country_id, p_round_sid);

      BEGIN
         SELECT CTY_VERSION_SID
           INTO l_cty_version_sid
           FROM GD_CTY_VERSIONS
          WHERE COUNTRY_ID = p_country_id AND VERSION = l_version;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_cty_version_sid := NULL;
      END;

      RETURN l_cty_version_sid;
   END getCountryVersionSid;

   ----------------------------------------------------------------------------
   -- @name getGridCols
   ----------------------------------------------------------------------------
   PROCEDURE getGridCols(p_round_grid_sid IN NUMBER, o_cur OUT SYS_REFCURSOR)
   IS
      l_sids CORE_COMMONS.SIDSARRAY;
   BEGIN
      l_sids(1) := p_round_grid_sid;
      getGridsCols(l_sids, o_cur);
   END getGridCols;

   ----------------------------------------------------------------------------
   -- @name getGridLineByRatsId
   ----------------------------------------------------------------------------
   PROCEDURE getGridLineByRatsId(p_rats_id   IN     VARCHAR2
                               , p_round_sid IN     NUMBER
                               , o_cur          OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR SELECT L.LINE_ID, L.DESCR, L.INDICATOR_ID
                       FROM VW_GD_ROUND_GRID_LINES L
                      WHERE L.RATS_ID = p_rats_id AND L.ROUND_SID = p_round_sid;
   END getGridLineByRatsId;

   ----------------------------------------------------------------------------
   -- @name getGridLines
   ----------------------------------------------------------------------------
   PROCEDURE getGridLines(p_round_grid_sid IN NUMBER, o_cur OUT SYS_REFCURSOR)
   IS
      l_sids CORE_COMMONS.SIDSARRAY;
   BEGIN
      l_sids(1) := p_round_grid_sid;
      getGridsLines(l_sids, o_cur);
   END getGridLines;

   ----------------------------------------------------------------------------
   -- @name getGrids gets grids for specific round
   ----------------------------------------------------------------------------
   PROCEDURE getGrids(p_round_sid IN NUMBER, o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR   SELECT G.GRID_SID
                            , G.GRID_ID
                            , G.DESCR
                            , G.ROUTE
                            , G.GRID_TYPE_ID
                         FROM VW_GD_GRIDS G
                        WHERE G.ROUND_SID = p_round_sid
                     ORDER BY G.ORDER_BY;
   END getGrids;

   ----------------------------------------------------------------------------
   -- @name getGridsCols
   ----------------------------------------------------------------------------
   PROCEDURE getGridsCols(p_round_grid_sids IN CORE_COMMONS.SIDSARRAY, o_cur OUT SYS_REFCURSOR)
   IS
      l_round_grid_sids SIDSLIST := CORE_COMMONS.arrayToSidsList(p_round_grid_sids);
   BEGIN
      OPEN o_cur FOR   SELECT c.round_grid_sid "roundGridSid"
                            , c.col_sid       "colSid"
                            , c.descr         "description"
                            , c.data_type_id  "dataTypeId"
                            , c.data_type_descr "dataTypeDesc"
                            , c.col_type_id   "colTypeId"
                            , c.is_mandatory  "isMandatory"
                            , c.year_value    "yearValue"
                            , c.is_absolute   "isAbsolute"
                            , c.mess          "helpMessage"
                            , c.width         "width"
                         FROM VW_GD_ROUND_GRID_COLS C
                        WHERE c.round_grid_sid IN (SELECT * FROM TABLE(l_round_grid_sids))
                     ORDER BY c.order_by ASC;
   END getGridsCols;

   ----------------------------------------------------------------------------
   -- @name getGridsLines
   ----------------------------------------------------------------------------
   PROCEDURE getGridsLines(p_round_grid_sids IN CORE_COMMONS.SIDSARRAY, o_cur OUT SYS_REFCURSOR)
   IS
      l_round_grid_sids SIDSLIST := CORE_COMMONS.arrayToSidsList(p_round_grid_sids);
   BEGIN
      OPEN o_cur FOR   SELECT l.round_grid_sid          AS "roundGridSid"
                            , l.line_sid                AS "lineSid"
                            , l.line_id                 AS "lineId"
                            , l.descr                   AS "description"
                            , l.esa_code                AS "esaCode"
                            , l.is_mandatory            AS "isMandatory"
                            , l.mandatory_cty_grp_cty_ids AS "mandatoryCtyIds"
                            , l.line_type_id            AS "lineTypeId"
                            , l.calc_rule               AS "calcRule"
                            , l.copy_line_rule          AS "copyLineRule"
                            , l.mess                    AS "helpMessage"
                         FROM VW_GD_ROUND_GRID_LINES L
                        WHERE l.round_grid_sid IN (SELECT * FROM TABLE(l_round_grid_sids))
                     ORDER BY l.order_by ASC;
   END getGridsLines;

   ----------------------------------------------------------------------------
   -- @name getGridTypeInfo gets type of the grid
   ----------------------------------------------------------------------------
   PROCEDURE getGridTypeInfo(p_cty_grid_sid IN NUMBER, o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR SELECT GRID_TYPE_ID   AS "gridTypeId"
                          , GRID_ID        AS "gridId"
                          , ROUND_GRID_SID AS "roundGridSid"
                          , ROUND_SID      AS "roundSid"
                          , COUNTRY_ID     AS "countryId"
                       FROM VW_GD_CTY_GRIDS
                      WHERE CTY_GRID_SID = p_cty_grid_sid;
   END getGridTypeInfo;

   ----------------------------------------------------------------------------
   -- @name getOptionalCells gets optional cells
   ----------------------------------------------------------------------------
   PROCEDURE getOptionalCells(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR SELECT C.LINE_SID AS "lineSid", C.COL_SID AS "colSid"
                       FROM GD_OPT_CELLS C;
   END getOptionalCells;

   ----------------------------------------------------------------------------
   -- @name getRoundsLines gets all lines
   ----------------------------------------------------------------------------
   PROCEDURE getRoundsLines(p_round_sids  IN     CORE_COMMONS.SIDSARRAY
                          , o_cur            OUT SYS_REFCURSOR
                          , p_all_columns IN     NUMBER DEFAULT NULL)
   IS
      l_round_sids SIDSLIST := CORE_COMMONS.arrayToSidsList(p_round_sids);
   BEGIN
      IF p_all_columns IS NULL THEN
         OPEN o_cur FOR   SELECT DISTINCT L.LINE_ID, L.DESCR
                            FROM VW_GD_ROUND_GRID_LINES L
                           WHERE L.ROUND_SID IN (SELECT * FROM TABLE(l_round_sids))
                        ORDER BY L.LINE_ID;
      ELSE
         OPEN o_cur FOR   SELECT L.*
                            FROM VW_GD_ROUND_GRID_LINES L
                           WHERE L.ROUND_SID IN (SELECT * FROM TABLE(l_round_sids))
                        ORDER BY L.LINE_ID;
      END IF;
   END getRoundsLines;

   ----------------------------------------------------------------------------
   -- @name getDataTypes gets all datatypes
   ----------------------------------------------------------------------------
   PROCEDURE getDataTypes(o_cur     OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR SELECT DATA_TYPE_SID, DATA_TYPE_ID, DESCR, LINE_INDICATOR_DISPLAY
                       FROM GD_DATA_TYPES;

   END getDataTypes;

   ----------------------------------------------------------------------------
   -- @name getCtyRoundScale gets the scale for the country (+version) and round
   ----------------------------------------------------------------------------
   PROCEDURE getCtyRoundScale(p_cty_id       IN VARCHAR2,
                              p_round_sid    IN NUMBER,
                              p_cty_version  IN NUMBER,
                              o_cur          OUT   SYS_REFCURSOR)
   IS
      l_cty_version_sid NUMBER;
   BEGIN
      IF p_cty_version > 0 THEN
         SELECT cty_version_sid INTO l_cty_version_sid
           FROM GD_CTY_VERSIONS
          WHERE COUNTRY_ID = p_cty_id 
            AND version = p_cty_version;
      ELSE
         l_cty_version_sid := getCountryVersionSid(p_cty_id, p_round_sid);
      END IF;

      OPEN o_cur FOR
        SELECT s.SCALE_SID AS "sid", s.DESCR AS "description", s.SCALE_ID AS "id"
          FROM GD_CTY_ROUND_SCALES crs
          LEFT JOIN SCALES s ON s.SCALE_SID = crs.SCALE_SID
         WHERE crs.CTY_VERSION_SID = l_cty_version_sid
           AND crs.ROUND_SID = p_round_sid; 
   END getCtyRoundScale;

   ----------------------------------------------------------------------------
   -- @name getCtyRoundScaleByCtyGrid gets the scale for the cty_grid_sid
   ----------------------------------------------------------------------------
   PROCEDURE getCtyRoundScaleByCtyGrid(p_cty_grid_sid IN NUMBER,
                              o_cur          OUT   SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
        SELECT s.SCALE_SID AS "sid", s.DESCR AS "description", s.SCALE_ID AS "id"
          FROM GD_CTY_ROUND_SCALES crs
          LEFT JOIN SCALES s ON s.SCALE_SID = crs.SCALE_SID
          JOIN GD_ROUND_GRIDS rg ON rg.ROUND_SID = crs.ROUND_SID
          JOIN GD_CTY_GRIDS cg
                ON cg.ROUND_GRID_SID = rg.ROUND_GRID_SID
               AND cg.CTY_VERSION_SID = crs.CTY_VERSION_SID
         WHERE cg.CTY_GRID_SID = p_cty_grid_sid; 
   END getCtyRoundScaleByCtyGrid;
     
END GD_GETTERS;
/
