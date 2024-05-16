/* Formatted on 02/03/2020 11:57:09 (QP5 v5.313) */
DECLARE
    TYPE T_MIGR_GRID IS RECORD(GRID_SID GD_GRIDS.GRID_SID%TYPE
                             , GRID_ID GD_GRIDS.GRID_ID%TYPE
                             , DESCR GD_GRIDS.DESCR%TYPE
                             , ROUND_SID GD_ROUND_GRIDS.ROUND_SID%TYPE
                             , ORDER_BY GD_ROUND_GRIDS.ORDER_BY%TYPE);

    l_grid_sid        GD_GRIDS.GRID_SID%TYPE;
    l_round_grid_sid  GD_ROUND_GRIDS.ROUND_GRID_SID%TYPE;
    l_line_sid        GD_LINES.LINE_SID%TYPE;
    l_col_sid         GD_COLS.COL_SID%TYPE;
    l_cty_version_sid GD_CTY_VERSIONS.CTY_VERSION_SID%TYPE;
    l_cty_grid_sid    GD_CTY_GRIDS.CTY_GRID_SID%TYPE;

    CURSOR dbpGrids
    IS
        SELECT MG.GRID_SID
             , MG.GRID_ID
             , MG.DESCR
             , MG.ROUND_SID
             , MG.ORDER_BY
          FROM GRIDS@SCOPAX MG JOIN VW_ROUNDS R ON R.ROUND_SID = MG.ROUND_SID
         WHERE R.PERIOD_ID = 'AUT' AND R.ROUND_SID != 18;

    CURSOR scpGrids
    IS
        SELECT MG.GRID_SID
             , MG.GRID_ID
             , MG.DESCR
             , MG.ROUND_SID
             , MG.ORDER_BY
          FROM GRIDS@SCOPAX MG JOIN VW_ROUNDS R ON R.ROUND_SID = MG.ROUND_SID
         WHERE R.PERIOD_ID = 'SPR' OR R.ROUND_SID = 18;

    FUNCTION getDbpGridTypeSid(p_grid_id IN VARCHAR2)
        RETURN NUMBER
    IS
    BEGIN
        RETURN CASE p_grid_id WHEN '5' THEN 2 WHEN '5a' THEN 3 WHEN '7' THEN 4 ELSE 1 END;
    END;

    PROCEDURE migrateGrid(p_grid IN T_MIGR_GRID, p_grid_type_sid IN NUMBER)
    IS
    BEGIN
        -- GD_GRIDS
        BEGIN
            SELECT GRID_SID
              INTO l_grid_sid
              FROM GD_GRIDS
             WHERE GRID_ID = p_grid.GRID_ID AND DESCR = p_grid.DESCR;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                INSERT INTO GD_GRIDS(GRID_ID, DESCR, GRID_TYPE_SID, ROUTE)
                     VALUES (p_grid.GRID_ID, p_grid.DESCR, p_grid_type_sid, 'grid')
                  RETURNING GRID_SID
                       INTO l_grid_sid;
        END;

        -- GD_ROUND_GRIDS
        BEGIN
            SELECT RG.ROUND_GRID_SID
              INTO l_round_grid_sid
              FROM GD_ROUND_GRIDS RG
             WHERE RG.ROUND_SID = p_grid.ROUND_SID AND RG.GRID_SID = l_grid_sid;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                INSERT INTO GD_ROUND_GRIDS(ROUND_SID, GRID_SID, ORDER_BY)
                     VALUES (p_grid.ROUND_SID, l_grid_sid, p_grid.ORDER_BY)
                  RETURNING ROUND_GRID_SID
                       INTO l_round_grid_sid;
        END;

        -- GRID LINES section
        FOR migrLine IN (SELECT *
                           FROM MIGR_LINES
                          WHERE GRID_SID = p_grid.GRID_SID) LOOP
            -- GD_LINES
            BEGIN
                SELECT L.LINE_SID
                  INTO l_line_sid
                  FROM GD_LINES L
                 WHERE L.LINE_TYPE_SID = migrLine.LINE_TYPE_SID
                   AND ((L.DESCR IS NULL AND migrLine.DESCR IS NULL)
                     OR L.DESCR = migrLine.DESCR)
                   AND ((L.ESA_CODE IS NULL AND migrLine.ESA_CODE IS NULL)
                     OR L.ESA_CODE = migrLine.ESA_CODE)
                   AND ((L.RATS_ID IS NULL AND migrLine.RATS_ID IS NULL)
                     OR L.RATS_ID = migrLine.RATS_ID)
                   AND ((L.LINE_ID IS NULL AND migrLine.LINE_ID IS NULL)
                     OR L.LINE_ID = migrLine.LINE_ID)
                   AND ((L.EB_ID IS NULL AND migrLine.EB_ID IS NULL)
                     OR L.EB_ID = migrLine.EB_ID)
                   AND ((L.IN_AGG IS NULL AND migrLine.IN_AGG IS NULL)
                     OR L.IN_AGG = migrLine.IN_AGG)
                   AND ((L.IN_LT IS NULL AND migrLine.IN_LT IS NULL)
                     OR L.IN_LT = migrLine.IN_LT)
                   AND NVL(L.IS_MANDATORY, 0) = 2 - NVL(migrLine.MANDATORY, 2)
                   AND ((L.INDICATOR_ID IS NULL AND migrLine.INDICATOR_ID IS NULL)
                     OR L.INDICATOR_ID = migrLine.INDICATOR_ID)
                   AND ((L.WEIGHT IS NULL AND migrLine.WEIGHT IS NULL)
                     OR L.WEIGHT = migrLine.WEIGHT)
                   AND ((L.WEIGHT_YEAR IS NULL AND migrLine.WEIGHT_YEAR IS NULL)
                     OR L.WEIGHT_YEAR = migrLine.WEIGHT_YEAR)
                   AND ((L.IN_DD IS NULL AND migrLine.IN_DD IS NULL)
                     OR L.IN_DD = migrLine.IN_DD)
                   AND ((L.AGG_DESCR IS NULL AND migrLine.AGG_DESCR IS NULL)
                     OR L.AGG_DESCR = migrLine.AGG_DESCR);
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    INSERT INTO GD_LINES(LINE_TYPE_SID
                                       , DESCR
                                       , ESA_CODE
                                       , RATS_ID
                                       , LINE_ID
                                       , EB_ID
                                       , IN_AGG
                                       , IN_LT
                                       , IS_MANDATORY
                                       , MANDATORY_CTY_GROUP_ID
                                       , INDICATOR_ID
                                       , WEIGHT
                                       , WEIGHT_YEAR
                                       , IN_DD
                                       , AGG_DESCR
                                       , CALC_RULE
                                       , COPY_LINE_RULE)
                         VALUES (migrLine.LINE_TYPE_SID
                               , migrLine.DESCR
                               , migrLine.ESA_CODE
                               , migrLine.RATS_ID
                               , migrLine.LINE_ID
                               , migrLine.EB_ID
                               , migrLine.IN_AGG
                               , migrLine.IN_LT
                               , CASE migrLine.MANDATORY WHEN 1 THEN 1 ELSE 0 END
                               , CASE migrLine.LINE_ID WHEN 'T00aL01' THEN 'NEURO' END
                               , migrLine.INDICATOR_ID
                               , migrLine.WEIGHT
                               , migrLine.WEIGHT_YEAR
                               , migrLine.IN_DD
                               , migrLine.AGG_DESCR
                               , migrLine.CALC_RULE
                               , migrLine.COPY_LINE_ID)
                      RETURNING LINE_SID
                           INTO l_line_sid;
            END;

            UPDATE MIGR_LINES
               SET NEW_LINE_SID = l_line_sid
             WHERE LINE_SID = migrLine.LINE_SID;

            -- GD_ROUND_GRID_LINES
            BEGIN
                INSERT INTO GD_ROUND_GRID_LINES(ROUND_GRID_SID, LINE_SID, ORDER_BY)
                     VALUES (l_round_grid_sid, l_line_sid, migrLine.ORDER_BY);
            EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                    NULL;
            END;
        END LOOP;

        -- GRID COLS section
        FOR migrCol IN (SELECT *
                          FROM MIGR_COLS
                         WHERE GRID_SID = p_grid.GRID_SID) LOOP
            -- GD_COLS
            BEGIN
                SELECT C.COL_SID
                  INTO l_col_sid
                  FROM GD_COLS C
                 WHERE ROWNUM = 1
                   AND C.COL_TYPE_SID = migrCol.COL_TYPE_SID
                   AND ((C.DESCR IS NULL AND migrCol.DESCR IS NULL)
                     OR C.DESCR = migrCol.DESCR)
                   AND ((C.DATA_TYPE_SID IS NULL AND migrCol.DATA_TYPE_SID IS NULL)
                     OR C.DATA_TYPE_SID = migrCol.DATA_TYPE_SID)
                   AND ((C.YEAR_VALUE IS NULL AND migrCol.YEAR_VALUE IS NULL)
                     OR C.YEAR_VALUE = migrCol.YEAR_VALUE)
                   AND NVL(C.IS_ABSOLUTE, 0) = NVL(migrCol.ABSOLUTE, 1) - 1
                   AND NVL(C.IS_MANDATORY, 0) =
                       CASE migrCol.COL_TYPE_SID
                           WHEN 2 THEN 0
                           ELSE 2 - NVL(migrCol.MANDATORY, 2)
                       END;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    INSERT INTO GD_COLS(COL_TYPE_SID
                                      , DESCR
                                      , DATA_TYPE_SID
                                      , YEAR_VALUE
                                      , IS_ABSOLUTE
                                      , IS_MANDATORY
                                      , WIDTH)
                         VALUES (
                                    migrCol.COL_TYPE_SID
                                  , migrCol.DESCR
                                  , migrCol.DATA_TYPE_SID
                                  , migrCol.YEAR_VALUE
                                  , NVL(migrCol.ABSOLUTE, 1) - 1
                                  , CASE migrCol.COL_TYPE_SID
                                        WHEN 2 THEN 0
                                        ELSE 2 - NVL(migrCol.MANDATORY, 2)
                                    END
                                  , CASE migrCol.COL_TYPE_SID
                                        WHEN 2 THEN
                                            12
                                        ELSE
                                            CASE migrCol.DATA_TYPE_SID
                                                WHEN 1 THEN 13
                                                WHEN 2 THEN 20
                                                WHEN 4 THEN 16
                                                ELSE 12
                                            END
                                    END
                                )
                      RETURNING COL_SID
                           INTO l_col_sid;
            END;

            UPDATE MIGR_COLS
               SET NEW_COL_SID = l_col_sid
             WHERE COL_SID = migrCol.COL_SID;

            -- GD_ROUND_GRID_COLS
            BEGIN
                INSERT INTO GD_ROUND_GRID_COLS(ROUND_GRID_SID, COL_SID, ORDER_BY)
                     VALUES (l_round_grid_sid, l_col_sid, migrCol.ORDER_BY);
            EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                    NULL;
            END;
        END LOOP;

        -- CTY_GRIDS section
        FOR migrCtyGrid IN (SELECT *
                              FROM CTY_GRIDS@SCOPAX
                             WHERE GRID_SID = p_grid.GRID_SID) LOOP
            -- GD_CTY_VERSIONS
            BEGIN
                SELECT V.CTY_VERSION_SID
                  INTO l_cty_version_sid
                  FROM GD_CTY_VERSIONS V
                 WHERE V.COUNTRY_ID = migrCtyGrid.COUNTRY_ID
                   AND V.VERSION = migrCtyGrid.VERSION;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    INSERT INTO GD_CTY_VERSIONS(COUNTRY_ID, VERSION)
                         VALUES (migrCtyGrid.COUNTRY_ID, migrCtyGrid.VERSION)
                      RETURNING CTY_VERSION_SID
                           INTO l_cty_version_sid;
            END;

            -- GD_CTY_GRIDS
            BEGIN
                INSERT INTO GD_CTY_GRIDS(CTY_VERSION_SID
                                       , ROUND_GRID_SID
                                       , CONSISTENCY_STATUS_MS_SID
                                       , CONSISTENCY_STATUS_CD_SID)
                     VALUES (
                                l_cty_version_sid
                              , l_round_grid_sid
                              , CASE migrCtyGrid.CONSISTENCY_STATUS_MS
                                    WHEN 'YES' THEN 1
                                    WHEN 'NO' THEN 2
                                END
                              , CASE migrCtyGrid.CONSISTENCY_STATUS_CD
                                    WHEN 'YES' THEN 1
                                    WHEN 'NO' THEN 2
                                END
                            )
                  RETURNING CTY_GRID_SID
                       INTO l_cty_grid_sid;

                -- GD_CELLS section
                FOR migrCell IN (SELECT CL.*, L.NEW_LINE_SID, C.NEW_COL_SID
                                   FROM CELLS@SCOPAX  CL
                                        JOIN MIGR_LINES L ON L.LINE_SID = CL.LINE_SID
                                        JOIN MIGR_COLS C ON C.COL_SID = CL.COL_SID
                                  WHERE CTY_GRID_SID = migrCtyGrid.CTY_GRID_SID) LOOP
                    BEGIN
                        INSERT INTO GD_CELLS(CTY_GRID_SID
                                           , LINE_SID
                                           , COL_SID
                                           , VALUE_N
                                           , VALUE_P
                                           , VALUE_CD)
                             VALUES (l_cty_grid_sid
                                   , migrCell.NEW_LINE_SID
                                   , migrCell.NEW_COL_SID
                                   , migrCell.VALUE_N
                                   , migrCell.VALUE_P
                                   , migrCell.VALUE_CD);
                    EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                            NULL;
                    END;
                END LOOP;
            EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                    NULL;
            END;
        END LOOP;
    END;

    PROCEDURE addTable5
    IS
    BEGIN
        INSERT INTO GD_GRIDS(DESCR, GRID_ID, GRID_TYPE_SID, ROUTE)
             VALUES ('Table 5. Discretionary measures', '5', 2, 'measures')
          RETURNING GRID_SID
               INTO l_grid_sid;


        INSERT INTO GD_ROUND_GRIDS(ROUND_SID, GRID_SID, ORDER_BY)
            SELECT G.ROUND_SID, l_grid_sid, G.ORDER_BY
              FROM VW_GD_GRIDS G
             WHERE GRID_ID = '5a';

        UPDATE GD_ROUND_GRIDS
           SET ORDER_BY = ORDER_BY + 1
         WHERE GRID_SID IN (SELECT GRID_SID
                              FROM GD_GRIDS
                             WHERE GRID_ID IN ('5a', '7'));
    END;

    PROCEDURE renameTable5a
    IS
    BEGIN
        UPDATE GD_GRIDS
           SET DESCR =
                   'Table 5a. Discretionary measures taken by Central Government (aggregated)'
         WHERE GRID_ID = '5a' AND DESCR = 'Table 5. Discretionary measures';
    END;
BEGIN
    FOR grid IN dbpGrids LOOP
        migrateGrid(grid, getDbpGridTypeSid(grid.GRID_ID));
    END LOOP;

    addTable5;
    renameTable5a;

    FOR grid IN scpGrids LOOP
        migrateGrid(grid, 1);
    END LOOP;
END;