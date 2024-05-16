/* Formatted on 19-10-2020 13:45:54 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY GD_GRID_DATA
AS
   /***************************************************************************
   NAME:       GD_GRID_DATA
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        24/06/2019  muccilu          1. Created this package.
   ***************************************************************************/

   /**************************************************************************
    *********************** PRIVATE SECTION **********************************
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name checkCountry checks if country_id corresponds to cty_grid_sid
   -- return 0 if check fails, >0 if succeeds
   ----------------------------------------------------------------------------
   FUNCTION checkCountry(p_country_id IN VARCHAR2, p_cty_grid_sid IN NUMBER)
      RETURN NUMBER
   AS
      l_count NUMBER(4);
   BEGIN
      BEGIN
         SELECT COUNT(*)
           INTO l_count
           FROM vw_GD_cty_grids G
          WHERE G.CTY_GRID_SID = p_cty_grid_sid AND G.COUNTRY_ID = p_country_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_count := 0;
      END;

      RETURN l_count;
   END checkCountry;

   ----------------------------------------------------------------------------
   -- @name publicValue converts to public value
   ----------------------------------------------------------------------------
   FUNCTION publicValue(p_value IN VARCHAR2)
      RETURN VARCHAR2
   AS
      l_value GD_CELLS.VALUE_N%TYPE := p_value;
   BEGIN
      IF REGEXP_INSTR(LOWER(p_value), 'n.a.| to |½|¼|¾') = 0 THEN
         l_value := formatValue(TO_CHAR(ROUND(TO_NUMBER(p_value), 1)));
      END IF;

      RETURN l_value;
   END publicValue;

   ----------------------------------------------------------------------------
   -- @name formatValue adds leasing zero
   ----------------------------------------------------------------------------
   FUNCTION formatValue(p_value IN VARCHAR2)
      RETURN VARCHAR2
   AS
      l_value GD_CELLS.VALUE_N%TYPE := p_value;
   BEGIN
      IF TO_NUMBER(l_value) < 1 AND TO_NUMBER(l_value) > 0 THEN
         l_value := '0' || l_value;
      ELSIF TO_NUMBER(l_value) < 0 AND TO_NUMBER(l_value) > -1 THEN
         l_value := '-0' || SUBSTR(l_value, 2, LENGTH(l_value));
      END IF;

      RETURN l_value;
   END formatValue;

   ----------------------------------------------------------------------------
   -- @name setupNextCtyVersion returns next cty_version_id and creates it if necessary
   ----------------------------------------------------------------------------
   FUNCTION setupNextCtyVersion(p_country_id IN VARCHAR2, p_round_sid IN NUMBER)
      RETURN NUMBER
   IS
      l_version     GD_CTY_VERSIONS.VERSION%TYPE
                       := GD_GETTERS.getCountryVersion(p_country_id, p_round_sid) + 1;
      l_version_sid GD_CTY_VERSIONS.CTY_VERSION_SID%TYPE;
   BEGIN
      SELECT V.CTY_VERSION_SID
        INTO l_version_sid
        FROM GD_CTY_VERSIONS V
       WHERE V.COUNTRY_ID = p_country_id AND V.VERSION = l_version;

      RETURN l_version_sid;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         INSERT INTO GD_CTY_VERSIONS(COUNTRY_ID, VERSION)
              VALUES (p_country_id, l_version)
           RETURNING CTY_VERSION_SID
                INTO l_version_sid;

         RETURN l_version_sid;
   END setupNextCtyVersion;

   /**************************************************************************
    *********************** PUBLIC SECTION ***********************************
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name convertGridVersionType
   ----------------------------------------------------------------------------
   FUNCTION convertGridVersionType(p_value        IN VARCHAR2
                                 , p_version_from IN VARCHAR2
                                 , p_version_to   IN VARCHAR2)
      RETURN VARCHAR2
   IS
      l_value_n GD_CELLS.VALUE_N%TYPE;
   BEGIN
      IF p_version_from = p_version_to THEN
         RETURN p_value;
      ELSIF LOWER(p_value) = 'n.a.' THEN
         RETURN 'n.a.';
      ELSIF INSTR(LOWER(p_value), ' to ') != 0 THEN
         FOR l_interval
            IN (SELECT val, num
                  FROM TABLE(GD_GRID_DATA.convertToVarcharObjectList(LOWER(p_value), ' to '))) LOOP
            IF l_interval.num = 1 THEN
               l_value_n := convertGridVersionType(l_interval.val, p_version_from, p_version_to);
            ELSIF l_interval.num = 2 THEN
               l_value_n :=
                  TO_NUMBER(
                       (  l_value_n
                        + convertGridVersionType(l_interval.val, p_version_from, p_version_to))
                     / 2
                  );
            ELSE
               RETURN NULL;
            END IF;
         END LOOP;
      ELSE
         l_value_n := REPLACE(REPLACE(p_value, ' ', ''), ',', '.');

         IF INSTR(l_value_n, '½') != 0 THEN
            l_value_n := TO_NUMBER(REPLACE(l_value_n, '½') || '.5');
         ELSIF INSTR(l_value_n, '¼') != 0 THEN
            l_value_n := TO_NUMBER(REPLACE(l_value_n, '¼') || '.25');
         ELSIF INSTR(l_value_n, '¾') != 0 THEN
            l_value_n := TO_NUMBER(REPLACE(l_value_n, '¾') || '.75');
         ELSIF UPPER(p_version_to) = 'P' THEN
            l_value_n := TO_CHAR(ROUND(TO_NUMBER(l_value_n), 1));
         ELSE
            RETURN l_value_n;
         END IF;
      END IF;

      BEGIN
         IF TO_NUMBER(l_value_n) < 1 AND TO_NUMBER(l_value_n) > 0 THEN
            l_value_n := '0' || l_value_n;
         ELSIF TO_NUMBER(l_value_n) < 0 AND TO_NUMBER(l_value_n) > -1 THEN
            l_value_n := '-0' || SUBSTR(l_value_n, 2, LENGTH(l_value_n));
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      RETURN l_value_n;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END convertGridVersionType;

   ----------------------------------------------------------------------------
   -- @name convertToVarcharObjectList
   ----------------------------------------------------------------------------
   FUNCTION convertToVarcharObjectList(p_list IN CLOB, p_delimiter IN VARCHAR2 DEFAULT ',')
      RETURN VARCHAROBJECT_LIST
      PIPELINED
   AS
      l_string      CLOB := p_list || p_delimiter;
      l_comma_index PLS_INTEGER;
      l_index       PLS_INTEGER := 1;

      l_out         varcharObject := VARCHAROBJECT(NULL, NULL);
      l_num         PLS_INTEGER := 0;
   BEGIN
      LOOP
         l_num         := l_num + 1;
         l_comma_index := INSTR(l_string, p_delimiter, l_index);
         EXIT WHEN l_comma_index = 0;
         l_out.val     := SUBSTR(l_string, l_index, l_comma_index - l_index);
         l_out.num     := l_num;
         PIPE ROW (l_out);
         l_index       := l_comma_index + LENGTH(p_delimiter);
      END LOOP;

      RETURN;
   END convertToVarcharObjectList;

   ----------------------------------------------------------------------------
   -- @name copyAllGridsFromVersion copies country all grids data from one version to another
   ----------------------------------------------------------------------------
   PROCEDURE copyAllGridsFromVersion(p_app_id       IN     VARCHAR2
                                   , p_country_id   IN     VARCHAR2
                                   , p_version_from IN     VARCHAR2
                                   , p_version_to   IN     VARCHAR2
                                   , o_res             OUT NUMBER)
   IS
      l_round_sid NUMBER := CORE_GETTERS.getCurrentRoundSid(p_app_id);
      l_version   NUMBER := GD_GETTERS.getCountryVersion(p_country_id, l_round_sid);
      l_stmt      VARCHAR2(1024);
      l_col_to    VARCHAR2(32) := 'VALUE_' || p_version_to;
      l_col_from  VARCHAR2(32) := 'VALUE_' || p_version_from;
   BEGIN
      l_stmt :=
            'BEGIN UPDATE GD_cells SET '
         || l_col_to
         || ' = GD_GRID_DATA.convertGridVersionType( '
         || l_col_from
         || ', :versionFrom, :versionTo) '
         || ' WHERE cty_grid_sid IN '
         || ' (SELECT cty_grid_sid FROM vw_GD_cty_grids '
         || '  WHERE GRID_TYPE_ID = ''NORMAL'' '
         || '    AND round_sid = :roundSid '
         || '    AND country_id = :countryId '
         || '    AND version = :version); '
         || ':res := SQL%ROWCOUNT; END;';

      EXECUTE IMMEDIATE l_stmt
         USING IN p_version_from
             , IN p_version_to
             , IN l_round_sid
             , IN p_country_id
             , IN l_version
             , OUT o_res;
   END copyAllGridsFromVersion;

   ----------------------------------------------------------------------------
   -- @name copyCtyGridVersion copies country grid data from one version to another
   ----------------------------------------------------------------------------
   PROCEDURE copyCtyGridVersion(p_app_id       IN     VARCHAR2
                              , p_country_id   IN     VARCHAR2
                              , p_cty_grid_sid IN     NUMBER
                              , p_version_from IN     VARCHAR2
                              , p_version_to   IN     VARCHAR2
                              , o_res             OUT NUMBER)
   IS
      l_stmt     VARCHAR2(1024);
      l_col_to   VARCHAR2(32) := 'VALUE_' || p_version_to;
      l_col_from VARCHAR2(32) := 'VALUE_' || p_version_from;
   BEGIN
      IF checkCountry(p_country_id, p_cty_grid_sid) > 0 THEN
         l_stmt :=
               'BEGIN UPDATE GD_cells SET '
            || l_col_to
            || ' = GD_GRID_DATA.convertGridVersionType( '
            || l_col_from
            || ', :versionFrom, :versionTo) '
            || ' WHERE cty_grid_sid = :cgs; :res := SQL%ROWCOUNT; END;';

         EXECUTE IMMEDIATE l_stmt
            USING IN p_version_from, IN p_version_to, IN p_cty_grid_sid, OUT o_res;
      ELSE
         o_res := -1;
      END IF;
   END copyCtyGridVersion;

   ----------------------------------------------------------------------------
   -- @name deleteCtyVersion deletes country version
   ----------------------------------------------------------------------------
   PROCEDURE deleteCtyVersion(p_country_id IN     VARCHAR2
                            , p_round_sid  IN     NUMBER
                            , p_version    IN     NUMBER
                            , o_res           OUT NUMBER)
   IS
   BEGIN
      DELETE FROM GD_CTY_GRIDS G
            WHERE G.CTY_VERSION_SID =
                  (SELECT V.CTY_VERSION_SID
                     FROM GD_CTY_VERSIONS V
                    WHERE V.COUNTRY_ID = p_country_id AND V.VERSION = p_version)
              AND G.ROUND_GRID_SID IN (SELECT RG.ROUND_GRID_SID
                                         FROM GD_ROUND_GRIDS RG
                                        WHERE RG.ROUND_SID = p_round_sid);

      o_res := SQL%ROWCOUNT;
   END deleteCtyVersion;

   ----------------------------------------------------------------------------
   -- @name getApplicationCtyGridCells
   ----------------------------------------------------------------------------
   PROCEDURE getApplicationCtyGridCells(p_app_id            IN     VARCHAR2
                                      , p_round_sid         IN     NUMBER
                                      , p_grid_id           IN     VARCHAR2
                                      , p_country_id        IN     VARCHAR2
                                      , p_version           IN     NUMBER
                                      , p_grid_version_type IN     VARCHAR2
                                      , o_cur                  OUT SYS_REFCURSOR)
   IS
      l_current_app_round NUMBER(4)
                             := CORE_GETTERS.getLatestApplicationRound(p_app_id, p_round_sid);
   BEGIN
      getCtyGridCells(l_current_app_round
                    , p_grid_id
                    , p_country_id
                    , p_version
                    , p_grid_version_type
                    , o_cur);
   END getApplicationCtyGridCells;

   ----------------------------------------------------------------------------
   -- @name getCtyGridCells get country grid cell values
   ----------------------------------------------------------------------------
   PROCEDURE getCtyGridCells(p_round_sid         IN     NUMBER
                           , p_grid_id           IN     VARCHAR2
                           , p_country_id        IN     VARCHAR2
                           , p_version           IN     NUMBER
                           , p_grid_version_type IN     VARCHAR2
                           , o_cur                  OUT SYS_REFCURSOR)
   IS
      l_version NUMBER(4);
   BEGIN
      IF p_version = 0 THEN
         l_version := GD_GETTERS.getCountryVersion(p_country_id, p_round_sid);
      ELSE
         l_version := p_version;
      END IF;

      OPEN o_cur FOR
         SELECT GRID_ID
                   AS "gridId"
              , LINE_ID
                   AS "lineId"
              , YEAR_VALUE
                   AS "yearValue"
              , COL_SID
                   AS "colSid"
              , LINE_SID
                   AS "lineSid"
              , CASE UPPER(p_grid_version_type)
                   WHEN 'P' THEN VALUE_P
                   WHEN 'N' THEN VALUE_N
                   WHEN 'CD' THEN VALUE_CD
                END
                   AS "cellValue"
              , CASE
                   WHEN UPPER(p_grid_version_type) IN ('P', 'N', 'CD') THEN p_grid_version_type
                END
                   AS "gridVersionType"
              , CASE UPPER(p_grid_version_type)
                   WHEN 'P' THEN P_FOOTNOTE
                   WHEN 'N' THEN N_FOOTNOTE
                   WHEN 'CD' THEN CD_FOOTNOTE
                END
                   AS "footnote"
           FROM VW_GD_CELLS
          WHERE ROUND_SID = p_round_sid
            AND COUNTRY_ID = p_country_id
            AND LINE_TYPE_ID IN ('LINE', 'CALCULATION')
            AND VERSION = l_version
            AND GRID_TYPE_ID IN ('NORMAL', 'AGGREGATE')
            AND (p_grid_id IS NULL OR grid_id = p_grid_id);
   END getCtyGridCells;

   ----------------------------------------------------------------------------
   -- @name getCtyGridData gets country grid data
   ----------------------------------------------------------------------------
   PROCEDURE getCtyGridData(p_country_id        IN     VARCHAR2
                          , p_cty_grid_sid      IN     NUMBER
                          , p_grid_version_type IN     VARCHAR2
                          , o_cur                  OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
         SELECT LINE_SID
              , COL_SID
              , CASE UPPER(p_grid_version_type)
                   WHEN 'P' THEN VALUE_P
                   WHEN 'N' THEN VALUE_N
                   WHEN 'CD' THEN VALUE_CD
                END
                   AS "cellValue"
              , CASE UPPER(p_grid_version_type)
                   WHEN 'P' THEN P_FTN_SID
                   WHEN 'N' THEN N_FTN_SID
                   WHEN 'CD' THEN CD_FTN_SID
                END
                   AS "footnoteSid"
           FROM vw_GD_cells
          WHERE CTY_GRID_SID = p_cty_grid_sid AND COUNTRY_ID = p_country_id;
   END getCtyGridData;

   ----------------------------------------------------------------------------
   -- @name getLineDataNoLevel
   ----------------------------------------------------------------------------
   PROCEDURE getLineDataNoLevel(o_cur           OUT SYS_REFCURSOR
                              , p_app_id     IN     VARCHAR2
                              , p_line_id    IN     VARCHAR2
                              , p_country_id IN     VARCHAR2
                              , p_round_sid  IN     NUMBER DEFAULT NULL
                              , p_version    IN     NUMBER DEFAULT NULL)
   IS
      l_round_sid ROUNDS.ROUND_SID%TYPE := CORE_GETTERS.CURRENTORPASSEDROUND(p_round_sid, p_app_id);
      l_version   GD_CTY_VERSIONS.VERSION%TYPE
         := CASE
               WHEN p_version IS NULL THEN GD_GETTERS.getCountryVersion(p_country_id, l_round_sid)
               ELSE p_version
            END;
   BEGIN
      OPEN o_cur FOR
           SELECT YEAR
                , YEAR_VALUE
                , VALUE_N
                , VALUE_P
                , VALUE_CD
             FROM VW_GD_CELLS
            WHERE LINE_ID = p_line_id
              AND ROUND_SID = l_round_sid
              AND COUNTRY_ID = p_country_id
              AND VERSION = l_version
              AND (DATA_TYPE_ID IS NULL OR DATA_TYPE_ID NOT IN ('LEVELS', 'TEXT'))
         ORDER BY YEAR_VALUE;
   END getLineDataNoLevel;

   ----------------------------------------------------------------------------
   -- @name getLinesData
   ----------------------------------------------------------------------------
   PROCEDURE getLinesData(o_cur            OUT SYS_REFCURSOR
                        , p_round_sids  IN     CORE_COMMONS.SIDSARRAY
                        , p_country_ids IN     CORE_COMMONS.VARCHARARRAY
                        , p_line_ids    IN     CORE_COMMONS.VARCHARARRAY)
   IS
      l_round_sids  SIDSLIST := CORE_COMMONS.arrayToSidsList(p_round_sids);
      l_country_ids VARCHARLIST := CORE_COMMONS.arrayToList(p_country_ids);
      l_line_ids    VARCHARLIST := CORE_COMMONS.arrayToList(p_line_ids);
   BEGIN
      OPEN o_cur FOR
           SELECT G.YEAR
                , G.COUNTRY_ID
                , C.LINE_ID
                , G.VERSION
                , CASE C.IS_ABSOLUTE WHEN 1 THEN C.YEAR_VALUE ELSE C.YEAR + C.YEAR_VALUE END
                     YEAR_VALUE
                , COALESCE(C.DATA_TYPE_ID, 'DATA')
                     DATA_TYPE
                , C.VALUE_CD
             FROM VW_GD_CELLS C
                  JOIN VW_GD_CTY_GRIDS G ON G.CTY_GRID_SID = C.CTY_GRID_SID
                  JOIN GD_ROUND_GRID_LINES RGL
                     ON RGL.ROUND_GRID_SID = G.ROUND_GRID_SID AND RGL.LINE_SID = C.LINE_SID
                  JOIN VW_GD_ROUND_GRID_COLS RGC
                     ON RGC.ROUND_GRID_SID = G.ROUND_GRID_SID AND RGC.COL_SID = C.COL_SID
            WHERE G.ROUND_SID IN (SELECT * FROM TABLE(l_round_sids))
              AND G.COUNTRY_ID IN (SELECT * FROM TABLE(l_country_ids))
              AND C.LINE_ID IN (SELECT * FROM TABLE(l_line_ids))
              AND C.LINE_TYPE_ID IN ('LINE', 'CALCULATION')
         ORDER BY G.YEAR
                , G.COUNTRY_ID
                , G.VERSION
                , G.ORDER_BY
                , RGL.ORDER_BY
                , RGC.ORDER_BY;
   END getLinesData;

   ----------------------------------------------------------------------------
   -- @name newCtyVersion creates new country version and returns it
   ----------------------------------------------------------------------------
   PROCEDURE newCtyVersion(p_country_id IN VARCHAR2, p_app_id IN VARCHAR2, o_res OUT NUMBER)
   IS
      l_round_sid   ROUNDS.ROUND_SID%TYPE := CORE_GETTERS.getCurrentRoundSid(p_app_id);
      l_version_sid GD_CTY_VERSIONS.CTY_VERSION_SID%TYPE
                       := setupNextCtyVersion(p_country_id, l_round_sid);
   BEGIN
      INSERT INTO GD_CTY_GRIDS(CTY_VERSION_SID, ROUND_GRID_SID)
         SELECT l_version_sid, RG.ROUND_GRID_SID
           FROM GD_ROUND_GRIDS RG
          WHERE RG.ROUND_SID = l_round_sid;

      o_res := l_version_sid;
   END newCtyVersion;

   ----------------------------------------------------------------------------
   -- @name patchCtyGridData updates country grid data
   ----------------------------------------------------------------------------
   PROCEDURE patchCtyGridData(p_app_id            IN     VARCHAR2
                            , p_country_id        IN     VARCHAR2
                            , p_cty_grid_sid      IN     NUMBER
                            , p_grid_version_type IN     VARCHAR2
                            , p_lines             IN     CORE_COMMONS.SIDSARRAY
                            , p_cols              IN     CORE_COMMONS.SIDSARRAY
                            , p_data              IN     CORE_COMMONS.VARCHARARRAY
                            , o_res                  OUT NUMBER)
   IS
      l_cnt          NUMBER(4);
      l_public_value GD_CELLS.VALUE_P%TYPE;
   BEGIN
      o_res := 0;

      IF checkCountry(p_country_id, p_cty_grid_sid) > 0 THEN
         FOR i IN 1 .. p_data.COUNT LOOP
            l_public_value := publicValue(p_data(i));

            -- Update existing record
            UPDATE GD_CELLS
               SET VALUE_N =
                      CASE UPPER(p_grid_version_type) WHEN 'N' THEN p_data(i) ELSE VALUE_N END
                 , VALUE_P =
                      CASE UPPER(p_grid_version_type) WHEN 'P' THEN l_public_value ELSE VALUE_P END
                 , VALUE_CD =
                      CASE UPPER(p_grid_version_type) WHEN 'CD' THEN p_data(i) ELSE VALUE_CD END
             WHERE CTY_GRID_SID = p_cty_grid_sid AND LINE_SID = p_lines(i) AND COL_SID = p_cols(i);

            -- If there was no record yet try to insert a new one
            IF SQL%ROWCOUNT = 0 THEN
               -- Check if line and column types are correct
               SELECT COUNT(*)
                 INTO l_cnt
                 FROM (SELECT L.LINE_SID SID
                         FROM VW_GD_LINES L
                        WHERE L.LINE_SID = p_lines(i) AND L.LINE_TYPE_ID IN ('LINE', 'CALCULATION')
                       UNION ALL
                       SELECT C.COL_SID SID
                         FROM VW_GD_COLS C
                        WHERE C.COL_SID = p_cols(i) AND C.COL_TYPE_ID = 'YEAR');

               IF l_cnt = 2                           -- Line and column types ok, insert new record
                            THEN
                  INSERT INTO GD_CELLS(CTY_GRID_SID
                                     , LINE_SID
                                     , COL_SID
                                     , VALUE_N
                                     , VALUE_P
                                     , VALUE_CD)
                       VALUES (p_cty_grid_sid
                             , p_lines(i)
                             , p_cols(i)
                             , CASE UPPER(p_grid_version_type) WHEN 'N' THEN p_data(i) END
                             , CASE UPPER(p_grid_version_type) WHEN 'P' THEN l_public_value END
                             , CASE UPPER(p_grid_version_type) WHEN 'CD' THEN p_data(i) END);
               END IF;
            END IF;

            o_res          := o_res + SQL%ROWCOUNT;
         END LOOP;
      ELSE
         o_res := -1;
      END IF;
   END patchCtyGridData;

   ----------------------------------------------------------------------------
   -- @name saveCtyRoundScale updates GD_CTY_ROUND_SCALES with new scale value
   ----------------------------------------------------------------------------
   PROCEDURE saveCtyRoundScale (
      p_cty_id             IN      VARCHAR2,
      p_round_sid          IN      NUMBER,
      p_scale_id           IN      VARCHAR2,
      o_res                   OUT  NUMBER)
   IS
      l_scale_sid          NUMBER;
      l_cty_version_sid    NUMBER;
   BEGIN
      o_res := 0;
      -- Check if Scale exists (else, -1)
      SELECT SCALE_SID INTO l_scale_sid
        FROM SCALES 
       WHERE SCALE_ID = p_scale_id;
      
      -- Get cty_version_sid
      l_cty_version_sid := GD_GETTERS.getCountryVersionSid(p_cty_id, p_round_sid);
      
      IF l_cty_version_sid IS NULL THEN
         o_res := -2;
      ELSE
         -- Update or Insert if not exists
         UPDATE GD_CTY_ROUND_SCALES
            SET SCALE_SID = l_scale_sid
            WHERE CTY_VERSION_SID = l_cty_version_sid
            AND ROUND_SID = p_round_sid;
         o_res := SQL%ROWCOUNT;
         IF o_res = 0 THEN
            INSERT INTO GD_CTY_ROUND_SCALES (CTY_VERSION_SID, ROUND_SID, SCALE_SID)
            VALUES (l_cty_version_sid, p_round_sid, l_scale_sid);
            o_res := SQL%ROWCOUNT;
         END IF;
      END IF;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         o_res := -1;

   END saveCtyRoundScale;

END GD_GRID_DATA;
/