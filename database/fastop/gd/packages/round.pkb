/* Formatted on 24/01/2020 11:26:48 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY GD_ROUND
AS
    FUNCTION prepareNextRound(p_previous_round_sid  IN  NUMBER
,                             p_new_round_sid       IN  NUMBER)
        RETURN NUMBER
    IS
        l_round_grid_row        GD_ROUND_GRIDS%ROWTYPE;
        l_new_round_grid_sid    GD_ROUND_GRIDS.ROUND_GRID_SID%TYPE;

        CURSOR round_grid_cur
        IS
            SELECT *
            FROM GD_ROUND_GRIDS
            WHERE ROUND_SID = p_previous_round_sid;
    BEGIN
        OPEN round_grid_cur;

        LOOP
            FETCH round_grid_cur INTO l_round_grid_row;
            EXIT WHEN round_grid_cur%NOTFOUND;

            -- new round grid
            INSERT INTO GD_ROUND_GRIDS (ROUND_SID, GRID_SID, ORDER_BY)
            VALUES (p_new_round_sid, l_round_grid_row.GRID_SID, l_round_grid_row.ORDER_BY)
            RETURNING ROUND_GRID_SID INTO l_new_round_grid_sid;

            -- copy lines
            INSERT INTO GD_ROUND_GRID_LINES (ROUND_GRID_SID, LINE_SID, ORDER_BY)
            SELECT l_new_round_grid_sid, LINE_SID, ORDER_BY
            FROM GD_ROUND_GRID_LINES
            WHERE ROUND_GRID_SID = l_round_grid_row.ROUND_GRID_SID;

            -- copy columns
            INSERT INTO GD_ROUND_GRID_COLS (ROUND_GRID_SID, COL_SID, ORDER_BY)
            SELECT l_new_round_grid_sid, COL_SID, ORDER_BY
            FROM GD_ROUND_GRID_COLS
            WHERE ROUND_GRID_SID = l_round_grid_row.ROUND_GRID_SID;

            -- assign countries
            INSERT INTO GD_CTY_GRIDS (ROUND_GRID_SID, CTY_VERSION_SID)
            SELECT l_new_round_grid_sid, CTY_VERSION_SID
            FROM GD_CTY_VERSIONS
            WHERE VERSION = 1;

        END LOOP;

        CLOSE round_grid_cur;

        RETURN 1;
        EXCEPTION
            WHEN OTHERS
                THEN RETURN 0;
    END prepareNextRound;

END GD_ROUND;