/* Formatted on 28-Sep-22 17:22:18 (QP5 v5.313) */
DECLARE
   l_round_sid              ROUNDS.ROUND_SID%TYPE;
   l_grants_round_grid_sid  GD_ROUND_GRIDS.ROUND_GRID_SID%TYPE;
   l_loans_round_grid_sid   GD_ROUND_GRIDS.ROUND_GRID_SID%TYPE;
   l_line_sid               GD_LINES.LINE_SID%TYPE;
   l_col_sid                GD_COLS.COL_SID%TYPE;
   l_help_msg_sid           HELP_MSGS.HELP_MSG_SID%TYPE;
   l_order                  NUMBER(4);

   PROCEDURE addGrid(p_descr IN VARCHAR2, p_grid_id IN VARCHAR2, p_round_sid IN NUMBER, o_round_grid_sid OUT NUMBER)
   IS
      l_grid_sid  GD_GRIDS.GRID_SID%TYPE;
   BEGIN
      BEGIN
         SELECT G.GRID_SID
           INTO l_grid_sid
           FROM GD_GRIDS G JOIN GD_GRID_TYPES GT ON GT.GRID_TYPE_SID = G.GRID_TYPE_SID
          WHERE G.DESCR = p_descr AND G.GRID_ID = p_grid_id AND GT.GRID_TYPE_ID = 'NORMAL';
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            INSERT INTO GD_GRIDS(DESCR, GRID_ID, GRID_TYPE_SID)
                 VALUES (p_descr
                       , p_grid_id
                       , (SELECT GRID_TYPE_SID
                            FROM GD_GRID_TYPES
                           WHERE GRID_TYPE_ID = 'NORMAL'))
              RETURNING GRID_SID
                   INTO l_grid_sid;
      END;

      INSERT INTO GD_ROUND_GRIDS(ROUND_SID, GRID_SID, ORDER_BY)
           VALUES (l_round_sid
                 , l_grid_sid
                 , (SELECT MAX(ORDER_BY) + 1
                      FROM GD_ROUND_GRIDS
                     WHERE ROUND_SID = p_round_sid))
        RETURNING ROUND_GRID_SID
             INTO o_round_grid_sid;
   END;

   PROCEDURE addLine(o_line_sid           OUT NUMBER
                   , p_line_id         IN     VARCHAR2
                   , p_descr           IN     VARCHAR2
                   , p_line_type_id    IN     VARCHAR2
                   , p_mandatory       IN     NUMBER
                   , p_round_grid_sid  IN     NUMBER
                   , p_order           IN     NUMBER
                   , p_esa_code        IN     VARCHAR2 DEFAULT NULL
                   , p_line_sid        IN     NUMBER DEFAULT NULL
                   , p_help_msg_sid    IN     NUMBER DEFAULT NULL)
   IS
   BEGIN
      IF p_line_sid IS NULL THEN
         BEGIN
            SELECT LINE_SID
              INTO o_line_sid
              FROM VW_GD_LINES
             WHERE LINE_ID = p_line_id;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               INSERT INTO GD_LINES(DESCR, LINE_TYPE_SID, LINE_ID, IS_MANDATORY, ESA_CODE, HELP_MSG_SID)
                    VALUES (p_descr
                          , (SELECT line_type_sid
                               FROM GD_LINE_TYPES
                              WHERE line_type_id = p_line_type_id)
                          , p_line_id
                          , p_mandatory
                          , p_esa_code
                          , p_help_msg_sid)
                 RETURNING LINE_SID
                      INTO o_line_sid;
         END;
      ELSE
         o_line_sid := p_line_sid;
      END IF;

      INSERT INTO GD_ROUND_GRID_LINES(ROUND_GRID_SID, LINE_SID, ORDER_BY)
           VALUES (p_round_grid_sid, o_line_sid, p_order);
   END;
BEGIN
   SELECT ROUND_SID
     INTO l_round_sid
     FROM ROUNDS
    WHERE DESCR = 'SPR 2021';

   addGrid('Table 9a. RRF impact on programme''s projections - GRANTS', '9a', l_round_sid, l_grants_round_grid_sid);
   addGrid('Table 9b. RRF impact on programme''s projections - LOANS', '9b', l_round_sid, l_loans_round_grid_sid);
   l_order := 1;

   addLine(l_line_sid, 'T09aH01', 'Revenue from RRF grants', 'HEADER', 1, l_grants_round_grid_sid, l_order);
   addLine(l_line_sid
         , 'T09bH01'
         , 'Cash flow from RRF loans projected in the programme'
         , 'HEADER'
         , 1
         , l_loans_round_grid_sid
         , l_order);
   l_order := l_order + 1;

   addLine(l_line_sid
         , 'T09aL01'
         , '1. RRF GRANTS as included in the revenue projections'
         , 'LINE'
         , 1
         , l_grants_round_grid_sid
         , l_order);
   addLine(l_line_sid, 'T09bL01', '1. Disbursements of RRF LOANS from EU', 'LINE', 1, l_loans_round_grid_sid, l_order);
   l_order := l_order + 1;

   addLine(l_line_sid
         , 'T09aL02'
         , '2. Cash disbursements of RRF GRANTS from EU'
         , 'LINE'
         , 1
         , l_grants_round_grid_sid
         , l_order);
   addLine(l_line_sid, 'T09bL02', '2. Repayments of RRF LOANS to EU', 'LINE', 1, l_loans_round_grid_sid, l_order);
   l_order := l_order + 1;

   addLine(l_line_sid, 'T09aH02', 'Expenditure financed by RRF grants', 'HEADER', 1, l_grants_round_grid_sid, l_order);
   addLine(l_line_sid, 'T09bH02', 'Expenditure financed by RRF loans', 'HEADER', 1, l_loans_round_grid_sid, l_order);
   l_order := l_order + 1;

   addLine(l_line_sid, 'T09aL03', '3.TOTAL CURRENT EXPENDITURE', 'LINE', 1, l_grants_round_grid_sid, l_order);
   addLine(l_line_sid, 'T09bL03', '3.TOTAL CURRENT EXPENDITURE', 'LINE', 1, l_loans_round_grid_sid, l_order);
   l_order := l_order + 1;

   SELECT LINE_SID
     INTO l_line_sid
     FROM GD_LINES
    WHERE DESCR = 'of which:' AND LINE_ID = 'T02bH02';

   addLine(l_line_sid, NULL, NULL, NULL, NULL, l_grants_round_grid_sid, l_order, NULL, l_line_sid);
   addLine(l_line_sid, NULL, NULL, NULL, NULL, l_loans_round_grid_sid, l_order, NULL, l_line_sid);
   l_order := l_order + 1;

   addLine(l_line_sid, 'T09aL04', '- Compensation of employees', 'LINE', 0, l_grants_round_grid_sid, l_order, 'D.1');
   addLine(l_line_sid, 'T09bL04', '- Compensation of employees', 'LINE', 0, l_loans_round_grid_sid, l_order, 'D.1');
   l_order := l_order + 1;

   addLine(l_line_sid, 'T09aL05', '- Intermediate consumption', 'LINE', 0, l_grants_round_grid_sid, l_order, 'P.2');
   addLine(l_line_sid, 'T09bL05', '- Intermediate consumption', 'LINE', 0, l_loans_round_grid_sid, l_order, 'P.2');
   l_order := l_order + 1;

   addLine(l_line_sid, 'T09aL06', '- Social Payments', 'LINE', 0, l_grants_round_grid_sid, l_order, 'D.62+D.632');
   addLine(l_line_sid, 'T09bL06', '- Social Payments', 'LINE', 0, l_loans_round_grid_sid, l_order, 'D.62+D.632');
   l_order := l_order + 1;

   addLine(l_line_sid, 'T09aL07', '- Interest expenditure', 'LINE', 0, l_grants_round_grid_sid, l_order, 'D.41');
   addLine(l_line_sid, 'T09bL07', '- Interest expenditure', 'LINE', 0, l_loans_round_grid_sid, l_order, 'D.41');
   l_order := l_order + 1;

   addLine(l_line_sid, 'T09aL08', '- Subsidies, payable', 'LINE', 0, l_grants_round_grid_sid, l_order, 'D.3');
   addLine(l_line_sid, 'T09bL08', '- Subsidies, payable', 'LINE', 0, l_loans_round_grid_sid, l_order, 'D.3');
   l_order := l_order + 1;

   addLine(l_line_sid, 'T09aL09', '- Current transfers', 'LINE', 0, l_grants_round_grid_sid, l_order, 'D.7');
   addLine(l_line_sid, 'T09bL09', '- Current transfers', 'LINE', 0, l_loans_round_grid_sid, l_order, 'D.7');
   l_order := l_order + 1;

   addLine(l_line_sid, 'T09aL10', '4. TOTAL CAPITAL EXPENDITURE', 'LINE', 1, l_grants_round_grid_sid, l_order);
   addLine(l_line_sid, 'T09bL10', '4. TOTAL CAPITAL EXPENDITURE', 'LINE', 1, l_loans_round_grid_sid, l_order);
   l_order := l_order + 1;

   SELECT LINE_SID
     INTO l_line_sid
     FROM GD_LINES
    WHERE DESCR = 'of which:' AND LINE_ID = 'T02bH03';

   addLine(l_line_sid, NULL, NULL, NULL, NULL, l_grants_round_grid_sid, l_order, NULL, l_line_sid);
   addLine(l_line_sid, NULL, NULL, NULL, NULL, l_loans_round_grid_sid, l_order, NULL, l_line_sid);
   l_order := l_order + 1;

   addLine(l_line_sid
         , 'T09aL11'
         , '- Gross fixed capital formation'
         , 'LINE'
         , 1
         , l_grants_round_grid_sid
         , l_order
         , 'P.51g');
   addLine(l_line_sid
         , 'T09bL11'
         , '- Gross fixed capital formation'
         , 'LINE'
         , 1
         , l_loans_round_grid_sid
         , l_order
         , 'P.51g');
   l_order := l_order + 1;

   addLine(l_line_sid, 'T09aL12', '- Capital transfers', 'LINE', 1, l_grants_round_grid_sid, l_order, 'D.9');
   addLine(l_line_sid, 'T09bL12', '- Capital transfers', 'LINE', 1, l_loans_round_grid_sid, l_order, 'D.9');
   l_order := l_order + 1;

   BEGIN
      SELECT HELP_MSG_SID
        INTO l_help_msg_sid
        FROM HELP_MSGS
       WHERE DESCR = 'Tab9a/bH03';
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         INSERT INTO HELP_MSGS(DESCR, MESS)
              VALUES ('Tab9a/bH03', 'This covers costs that are not recorded as expenditure in national accounts')
           RETURNING HELP_MSG_SID
                INTO l_help_msg_sid;
   END;

   addLine(l_line_sid
         , 'T09aH03'
         , 'Other costs financed by RRF grants'
         , 'HEADER'
         , 1
         , l_grants_round_grid_sid
         , l_order
         , NULL
         , NULL
         , l_help_msg_sid);
   addLine(l_line_sid
         , 'T09bH03'
         , 'Other costs financed by RRF loans'
         , 'HEADER'
         , 1
         , l_loans_round_grid_sid
         , l_order
         , NULL
         , NULL
         , l_help_msg_sid);
   l_order := l_order + 1;

   addLine(l_line_sid, 'T09aL13', '5. Reduction in tax revenue', 'LINE', 1, l_grants_round_grid_sid, l_order);
   addLine(l_line_sid, 'T09bL13', '5. Reduction in tax revenue', 'LINE', 1, l_loans_round_grid_sid, l_order);
   l_order := l_order + 1;

   addLine(l_line_sid, 'T09aL14', '6. Other costs with impact on revenue', 'LINE', 1, l_grants_round_grid_sid, l_order);
   addLine(l_line_sid, 'T09bL14', '6. Other costs with impact on revenue', 'LINE', 1, l_loans_round_grid_sid, l_order);
   l_order := l_order + 1;

   addLine(l_line_sid, 'T09aL15', '7. Financial transactions', 'LINE', 1, l_grants_round_grid_sid, l_order);
   addLine(l_line_sid, 'T09bL15', '7. Financial transactions', 'LINE', 1, l_loans_round_grid_sid, l_order);
   l_order := l_order + 1;


   l_order := 1;

   SELECT COL_SID
     INTO l_col_sid
     FROM VW_GD_COLS
    WHERE COL_TYPE_ID = 'CODE' AND DATA_TYPE_ID = 'TEXT' AND DESCR = 'ESA Code';

   INSERT INTO GD_ROUND_GRID_COLS(ROUND_GRID_SID, COL_SID, ORDER_BY)
        VALUES (l_grants_round_grid_sid, l_col_sid, l_order);

   INSERT INTO GD_ROUND_GRID_COLS(ROUND_GRID_SID, COL_SID, ORDER_BY)
        VALUES (l_loans_round_grid_sid, l_col_sid, l_order);

   l_order := l_order + 1;

   FOR i IN -1 .. 5 LOOP
      SELECT COL_SID
        INTO l_col_sid
        FROM VW_GD_COLS
       WHERE COL_TYPE_ID = 'YEAR'
         AND DATA_TYPE_ID = 'GDP'
         AND IS_ABSOLUTE = 0
         AND IS_MANDATORY = 1
         AND YEAR_VALUE = i
         AND DESCR IS NULL;

      INSERT INTO GD_ROUND_GRID_COLS(ROUND_GRID_SID, COL_SID, ORDER_BY)
           VALUES (l_grants_round_grid_sid, l_col_sid, l_order);

      INSERT INTO GD_ROUND_GRID_COLS(ROUND_GRID_SID, COL_SID, ORDER_BY)
           VALUES (l_loans_round_grid_sid, l_col_sid, l_order);

      l_order := l_order + 1;
   END LOOP;

   INSERT INTO GD_CTY_GRIDS(ROUND_GRID_SID, CTY_VERSION_SID)
      SELECT l_grants_round_grid_sid, CTY_VERSION_SID
        FROM GD_CTY_VERSIONS
       WHERE VERSION = 1;

   INSERT INTO GD_CTY_GRIDS(ROUND_GRID_SID, CTY_VERSION_SID)
      SELECT l_loans_round_grid_sid, CTY_VERSION_SID
        FROM GD_CTY_VERSIONS
       WHERE VERSION = 1;
END;

--------------------------------------------------------------------------------
-- Correction for fixed years columns, FASTOP-569
--------------------------------------------------------------------------------

DECLARE
BEGIN
   -- add required columns
   FOR i IN 2021 .. 2026 LOOP
      INSERT INTO GD_COLS(COL_TYPE_SID, DATA_TYPE_SID, YEAR_VALUE, IS_ABSOLUTE, IS_MANDATORY, WIDTH)
         SELECT CT.COL_TYPE_SID, DT.DATA_TYPE_SID, i, 1, 1, 16
           FROM GD_COL_TYPES CT, GD_DATA_TYPES DT
          WHERE CT.COL_TYPE_ID = 'YEAR' AND DT.DATA_TYPE_ID = 'GDP';
   END LOOP;

   FOR i IN 2024 .. 2026 LOOP
      INSERT INTO GD_COLS(COL_TYPE_SID, DATA_TYPE_SID, YEAR_VALUE, IS_ABSOLUTE, IS_MANDATORY, WIDTH)
         SELECT CT.COL_TYPE_SID, DT.DATA_TYPE_SID, i, 1, 0, 16
           FROM GD_COL_TYPES CT, GD_DATA_TYPES DT
          WHERE CT.COL_TYPE_ID = 'YEAR' AND DT.DATA_TYPE_ID = 'GDP';
   END LOOP;
END;

-- copy the data in GD_CELLS into the new columns (absolute year)

INSERT INTO GD_CELLS(CTY_GRID_SID, LINE_SID, COL_SID, VALUE_P, VALUE_N, VALUE_CD)
   SELECT C.CTY_GRID_SID, C.LINE_SID, COL.COL_SID, C.VALUE_P, C.VALUE_N, C.VALUE_CD
     FROM VW_GD_CELLS  C
          JOIN VW_ROUNDS R ON R.ROUND_SID = C.ROUND_SID
          JOIN VW_GD_COLS COL
             ON COL.COL_TYPE_ID = 'YEAR'
            AND COL.DATA_TYPE_ID = 'GDP'
            AND COL.IS_ABSOLUTE = 1
            AND COL.YEAR_VALUE = C.YEAR + C.YEAR_VALUE
            AND (((C.YEAR <= 2023 OR R.PERIOD_ID = 'SPR') AND COL.IS_MANDATORY = 1)
              OR (C.YEAR > 2023 AND R.PERIOD_ID = 'AUT' AND COL.IS_MANDATORY = 0))
    WHERE C.GRID_ID LIKE '9%' AND C.COL_TYPE_ID = 'YEAR' AND C.DATA_TYPE_ID = 'GDP' AND C.IS_ABSOLUTE = 0;

-- backup old grid 9 columns configuration

CREATE TABLE GD_ROUND_GRID9_COLS_BCK
AS
   SELECT C.*
     FROM GD_ROUND_GRID_COLS C JOIN VW_GD_GRIDS G ON G.ROUND_GRID_SID = C.ROUND_GRID_SID
    WHERE G.GRID_ID LIKE '9%';

-- reconfigure grid 9 columns

DELETE FROM GD_ROUND_GRID_COLS C
      WHERE C.ROUND_GRID_SID IN (SELECT ROUND_GRID_SID
                                   FROM VW_GD_GRIDS
                                  WHERE GRID_ID LIKE '9%')
        AND C.COL_SID IN (SELECT COL_SID
                            FROM VW_GD_COLS
                           WHERE COL_TYPE_ID = 'YEAR' AND DATA_TYPE_ID = 'GDP' AND IS_ABSOLUTE = 0);

INSERT INTO GD_ROUND_GRID_COLS(ROUND_GRID_SID, COL_SID, ORDER_BY)
   SELECT G.ROUND_GRID_SID, C.COL_SID, Y.YEAR_VALUE - 2009
     FROM VW_GD_GRIDS  G
          JOIN VW_ROUNDS R ON R.ROUND_SID = G.ROUND_SID
          JOIN (SELECT COLUMN_VALUE YEAR_VALUE FROM TABLE(SIDSLIST(2020, 2021, 2022, 2023, 2024, 2025, 2026))) Y
             ON 1 = 1
          JOIN VW_GD_COLS C
             ON C.COL_TYPE_ID = 'YEAR'
            AND C.DATA_TYPE_ID = 'GDP'
            AND C.IS_ABSOLUTE = 1
            AND C.YEAR_VALUE = Y.YEAR_VALUE
            AND (((C.YEAR_VALUE <= 2023 OR R.PERIOD_ID = 'SPR') AND C.IS_MANDATORY = 1)
              OR (C.YEAR_VALUE > 2023 AND R.PERIOD_ID = 'AUT' AND C.IS_MANDATORY = 0))
    WHERE G.GRID_ID LIKE '9%';