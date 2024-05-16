CREATE OR REPLACE PACKAGE BODY DBP_GRID_DATA
AS
    /******************************************************************************
       NAME:       DBP_GRID_DATA
       PURPOSE:

       REVISIONS:
       Ver        Date        Author           Description
       ---------  ----------  ---------------  ------------------------------------
       1.0        12/07/2019  lubiesz          1. Created this package.
    ******************************************************************************/

    PROCEDURE calculateTable5ACells(p_country_id      IN   VARCHAR2
,                                   p_cty_grid_sid    IN   NUMBER
,                                   p_version         IN   NUMBER    
,                                   p_round_grid_sid  IN   NUMBER
,                                   p_round_sid       IN   NUMBER
,                                   o_res             OUT  NUMBER)
    IS
        l_value      NUMBER;
        l_round_year NUMBER;
    BEGIN
        BEGIN
            SELECT YEAR INTO l_round_year FROM VW_ROUNDS WHERE ROUND_SID = p_round_sid;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN l_round_year := NULL;
        END;

        FOR l_cur_lines IN (SELECT * FROM VW_GD_ROUND_GRID_LINES WHERE ROUND_GRID_SID = p_round_grid_sid AND LINE_TYPE_SID = 1 ORDER BY ORDER_BY)
        LOOP
            FOR l_cur_measures IN (SELECT * FROM VW_DBP_MEASURES M JOIN DBP_ESA E ON M.ESA_SID = E.ESA_SID WHERE ROUND_SID = p_round_sid AND COUNTRY_ID = p_country_id AND E.ESA_ID = l_cur_lines.ESA_CODE AND M.VERSION = p_version)
            LOOP
                FOR l_cur_cols IN (SELECT * FROM VW_GD_ROUND_GRID_COLS WHERE ROUND_GRID_SID = p_round_grid_sid AND COL_TYPE_SID = 1 ORDER BY ORDER_BY)
                LOOP
                    BEGIN
                        SELECT vector_value INTO l_value
                        FROM (
                            SELECT vector_value FROM
                                 (
                                      SELECT NVL(val, 0) AS vector_value, (l_cur_measures.START_YEAR + num - 1) AS vector_year
                                      FROM TABLE(GD_GRID_DATA.convertToVarcharObjectList(l_cur_measures.DATA, ','))
                                  )
                            WHERE vector_year = (l_round_year + l_cur_cols.YEAR_VALUE)
                        );
                     EXCEPTION WHEN NO_DATA_FOUND
                     THEN
                            l_value := NULL;
                     END;


                    UPDATE GD_CELLS
                    SET VALUE_N = VALUE_N + l_value
                    ,   VALUE_P = VALUE_P + l_value
                    ,   VALUE_CD = VALUE_CD + l_value
                    WHERE CTY_GRID_SID = p_cty_grid_sid
                      AND LINE_SID = l_cur_lines.LINE_SID
                      AND COL_SID = l_cur_cols.COL_SID;

                    IF SQL%ROWCOUNT = 0 THEN
                        INSERT INTO GD_CELLS(
                            CTY_GRID_SID
                        ,   LINE_SID
                        ,   COL_SID
                        ,   VALUE_N
                        ,   VALUE_P
                        ,   VALUE_CD)
                        VALUES (
                            p_cty_grid_sid
                        ,   l_cur_lines.LINE_SID
                        ,   l_cur_cols.COL_SID
                        ,   l_value
                        ,   l_value
                        ,   l_value );
                    END IF;

                    o_res := o_res + SQL%ROWCOUNT;
                END LOOP;
            END LOOP;
        END LOOP;

        -- format and round calculated values
        UPDATE GD_CELLS
        SET VALUE_N = GD_GRID_DATA.formatValue(VALUE_N)
        ,   VALUE_P = GD_GRID_DATA.publicValue(VALUE_P)
        ,   VALUE_CD = GD_GRID_DATA.formatValue(VALUE_CD)
        WHERE CTY_GRID_SID = p_cty_grid_sid
          AND LINE_SID IN (SELECT LINE_SID FROM VW_GD_ROUND_GRID_LINES WHERE ROUND_GRID_SID = p_round_grid_sid AND LINE_TYPE_SID = 1)
          AND COL_SID IN (SELECT COL_SID FROM VW_GD_ROUND_GRID_COLS WHERE ROUND_GRID_SID = p_round_grid_sid AND COL_TYPE_SID = 1);
    END calculateTable5ACells;

    PROCEDURE calculateTable5ARuleCells(p_cty_grid_sid    IN NUMBER
,                                       p_round_grid_sid  IN   NUMBER
,                                       o_res             OUT  NUMBER)
    IS
        l_calc_rule VARCHAR2(500 BYTE);
        l_tmp       NUMBER;
        l_sign      NUMBER := 1;
        l_val_n     NUMBER := 0;
        l_val_p     NUMBER := 0;
        l_val_cd    NUMBER := 0;
        l_flag_n    NUMBER := 0;
        l_flag_p    NUMBER := 0;
        l_flag_cd   NUMBER := 0;                
    BEGIN
        FOR l_cur_lines IN (SELECT * FROM VW_GD_ROUND_GRID_LINES WHERE ROUND_GRID_SID = p_round_grid_sid AND LINE_TYPE_SID = 3 ORDER BY ORDER_BY)
        LOOP
            FOR l_cur_cols IN (SELECT * FROM VW_GD_ROUND_GRID_COLS WHERE ROUND_GRID_SID = p_round_grid_sid AND COL_TYPE_SID = 1 ORDER BY ORDER_BY)
                LOOP
                    l_calc_rule := l_cur_lines.CALC_RULE;
                    FOR l_cur_calc IN (SELECT l.* FROM VW_GD_ROUND_GRID_LINES l
                                                  INNER JOIN
                                                        (SELECT ROWNUM AS num, REGEXP_SUBSTR(l_cur_lines.CALC_RULE,'[^\+-]+', 1, level) AS line_id FROM DUAL
                                                         CONNECT BY REGEXP_SUBSTR(l_cur_lines.CALC_RULE, '[^\+-]+', 1, level) IS NOT NULL
                                                        ) li
                                                  ON l.LINE_ID = li.line_id WHERE l.ROUND_GRID_SID = p_round_grid_sid ORDER BY li.num
                                      )
                        LOOP                            
                            l_tmp := INSTR(l_calc_rule, l_cur_calc.LINE_ID);
                            l_sign := 1;
                            IF l_tmp > 1 THEN
                                IF SUBSTR(l_calc_rule, l_tmp - 1, 1) = '-' THEN
                                    l_sign := -1;
                                END IF;
                            END IF;

                            -- in  case we can have the same lineId used multiple times in one rule
                            l_calc_rule := REPLACE(l_calc_rule, l_cur_calc.LINE_ID);

                            FOR l_cur_cells IN (SELECT * FROM GD_CELLS WHERE CTY_GRID_SID = p_cty_grid_sid AND line_sid = l_cur_calc.LINE_SID AND col_sid = l_cur_cols.COL_SID)
                                LOOP
                                    IF l_cur_cells.VALUE_N IS NOT NULL OR l_cur_cells.VALUE_N != '' THEN
                                        l_val_n := l_val_n + l_sign * l_cur_cells.VALUE_N;
                                        l_flag_n := 1;
                                    END IF;
                                    IF l_cur_cells.VALUE_P IS NOT NULL OR l_cur_cells.VALUE_P != '' THEN
                                        l_val_p := l_val_p + l_sign * l_cur_cells.VALUE_P;
                                        l_flag_p := 1;
                                    END IF;
                                    IF l_cur_cells.VALUE_CD IS NOT NULL OR l_cur_cells.VALUE_CD != '' THEN
                                        l_val_cd := l_val_cd + l_sign * l_cur_cells.VALUE_CD;
                                        l_flag_cd := 1;
                                    END IF;
                                END LOOP;
                        END LOOP;

                    IF l_flag_n = 0 THEN
                        l_val_n := NULL;
                    END IF;
                    IF l_flag_p = 0 THEN
                        l_val_p := NULL;
                    END IF;
                    IF l_flag_cd = 0 THEN
                        l_val_cd := NULL;
                    END IF;

                    UPDATE GD_CELLS
                    SET VALUE_N = GD_GRID_DATA.formatValue(l_val_n)
                    ,   VALUE_P = GD_GRID_DATA.publicValue(l_val_p)
                    ,   VALUE_CD = GD_GRID_DATA.formatValue(l_val_cd)
                    WHERE CTY_GRID_SID = p_cty_grid_sid
                      AND LINE_SID = l_cur_lines.line_sid
                      AND COL_SID = l_cur_cols.col_sid;

                    IF SQL%ROWCOUNT = 0 THEN
                        INSERT INTO GD_CELLS(
                            CTY_GRID_SID
                        ,   LINE_SID
                        ,   COL_SID
                        ,   VALUE_N
                        ,   VALUE_P
                        ,   VALUE_CD)
                        VALUES (
                            p_cty_grid_sid
                        ,   l_cur_lines.LINE_SID
                        ,   l_cur_cols.COL_SID
                        ,   GD_GRID_DATA.formatValue(l_val_n)
                        ,   GD_GRID_DATA.publicValue(l_val_p)
                        ,   GD_GRID_DATA.formatValue(l_val_cd) );
                    END IF;

                    o_res := o_res + SQL%ROWCOUNT;

                    l_val_n := 0;
                    l_val_p := 0;
                    l_val_cd := 0;
                    l_flag_n := 0;
                    l_flag_p := 0;
                    l_flag_cd := 0;
                END LOOP;
            END LOOP;
    END calculateTable5ARuleCells;

    PROCEDURE calculateTable5AMeasures(p_country_id   IN     VARCHAR2
,                                      p_round_sid    IN     NUMBER
,                                      p_version      IN     NUMBER
,                                      o_res          OUT    NUMBER)
   IS
        l_round_sid           NUMBER := p_round_sid;
        l_version             NUMBER := p_version;
        l_cty_grid_sid        NUMBER;
        l_round_grid_sid      NUMBER;
        l_res                 NUMBER;
   BEGIN
       o_res := 0;
       
       IF l_round_sid <= 0 OR l_round_sid IS NULL THEN
           l_round_sid := CORE_GETTERS.getCurrentRoundSid (DBP_GETTERS.APP_ID);           
       END IF;

       IF l_version <= 0 OR l_version IS NULL THEN
           l_version := GD_GETTERS.getCountryVersion (p_country_id, l_round_sid);
       END IF;

       BEGIN
           SELECT CTY_GRID_SID INTO l_cty_grid_sid
           FROM VW_GD_CTY_GRIDS
           WHERE GRID_ID = '5a'
                 AND ROUND_SID = l_round_sid
                 AND VERSION = l_version
                 AND COUNTRY_ID = p_country_id;
       EXCEPTION
           WHEN NO_DATA_FOUND
           THEN l_cty_grid_sid := NULL;
       END;

       IF l_cty_grid_sid IS NOT NULL THEN
           -- remove all cells data
           DELETE FROM GD_CELLS WHERE CTY_GRID_SID = l_cty_grid_sid;

           SELECT ROUND_GRID_SID INTO l_round_grid_sid
           FROM VW_GD_GRIDS
           WHERE GRID_ID = '5a'
             AND ROUND_SID = l_round_sid;

           calculateTable5ACells(p_country_id, l_cty_grid_sid, l_version, l_round_grid_sid, l_round_sid, l_res);
           if l_res IS NOT NULL
           THEN
               o_res := o_res + l_res;
           END IF;
           calculateTable5ARuleCells(l_cty_grid_sid, l_round_grid_sid, l_res);
           if l_res IS NOT NULL
           THEN
               o_res := o_res + l_res;
           END IF;
       END IF;

   END calculateTable5AMeasures;

END DBP_GRID_DATA;
/
