/* Formatted on 13-10-2020 18:35:24 (QP5 v5.313) */
SET DEFINE OFF;

DECLARE
   l_table_sid              FDMS_DT_TABLES.TABLE_SID%TYPE;
   l_table_order            NUMBER(4) := 1;
   l_line_sid               FDMS_DT_LINES.LINE_SID%TYPE;
   l_table_line_sid         FDMS_DT_TABLE_LINES.TABLE_LINE_SID%TYPE;
   l_order                  NUMBER(4);

   l_col_type_data          FDMS_DT_COL_TYPES.COL_TYPE_SID%TYPE;
   l_col_type_alt_data      FDMS_DT_COL_TYPES.COL_TYPE_SID%TYPE;
   l_col_type_alt2_data     FDMS_DT_COL_TYPES.COL_TYPE_SID%TYPE;

   l_line_type_year         FDMS_DT_LINE_TYPES.LINE_TYPE_SID%TYPE;
   l_line_type_quarter      FDMS_DT_LINE_TYPES.LINE_TYPE_SID%TYPE;
   l_line_type_header       FDMS_DT_LINE_TYPES.LINE_TYPE_SID%TYPE;
   l_line_type_data         FDMS_DT_LINE_TYPES.LINE_TYPE_SID%TYPE;

   l_line_empty             FDMS_DT_LINES.LINE_SID%TYPE;
   l_line_years             FDMS_DT_LINES.LINE_SID%TYPE;
   l_line_perc_change_level FDMS_DT_LINES.LINE_SID%TYPE;
   l_line_perc_gdp_level    FDMS_DT_LINES.LINE_SID%TYPE;
BEGIN
   SELECT COL_TYPE_SID
     INTO l_col_type_data
     FROM FDMS_DT_COL_TYPES
    WHERE COL_TYPE_ID = 'DATA';

   SELECT COL_TYPE_SID
     INTO l_col_type_alt_data
     FROM FDMS_DT_COL_TYPES
    WHERE COL_TYPE_ID = 'ALT_DATA';

   SELECT COL_TYPE_SID
     INTO l_col_type_alt2_data
     FROM FDMS_DT_COL_TYPES
    WHERE COL_TYPE_ID = 'ALT2_DATA';


--    SELECT COL_TYPE_SID
--      INTO l_col_type_code_descr
--      FROM FDMS_DT_COL_TYPES
--     WHERE COL_TYPE_ID = 'DESCR_IND';


   SELECT LINE_TYPE_SID
     INTO l_line_type_year
     FROM FDMS_DT_LINE_TYPES
    WHERE LINE_TYPE_ID = 'YEAR';

   SELECT LINE_TYPE_SID
     INTO l_line_type_quarter
     FROM FDMS_DT_LINE_TYPES
    WHERE LINE_TYPE_ID = 'QUARTER';

   SELECT LINE_TYPE_SID
     INTO l_line_type_header
     FROM FDMS_DT_LINE_TYPES
    WHERE LINE_TYPE_ID = 'HEADER';

   SELECT LINE_TYPE_SID
     INTO l_line_type_data
     FROM FDMS_DT_LINE_TYPES
    WHERE LINE_TYPE_ID = 'DATA';

   -- common lines
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID)
        VALUES (l_line_type_year)
     RETURNING LINE_SID
          INTO l_line_years;

   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID)
        VALUES (l_line_type_header)
     RETURNING LINE_SID
          INTO l_line_empty;


   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID)
        VALUES (l_line_type_header)
     RETURNING LINE_SID
          INTO l_line_perc_change_level;

   INSERT INTO FDMS_DT_LINE_HEADERS(LINE_SID, COL_TYPE_SID, HEADER)
        VALUES (l_line_perc_change_level, l_col_type_data, '% change');

   INSERT INTO FDMS_DT_LINE_HEADERS(LINE_SID, COL_TYPE_SID, HEADER)
        VALUES (l_line_perc_change_level, l_col_type_alt_data, 'Level');

   INSERT INTO FDMS_DT_LINE_HEADERS(LINE_SID, COL_TYPE_SID, HEADER)
        VALUES (l_line_perc_change_level, l_col_type_alt2_data, '% trade');








   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID)
        VALUES (l_line_type_header)
     RETURNING LINE_SID
          INTO l_line_perc_gdp_level;

   INSERT INTO FDMS_DT_LINE_HEADERS(LINE_SID, COL_TYPE_SID, HEADER)
        VALUES (l_line_perc_gdp_level, l_col_type_data, '% of GDP');

   INSERT INTO FDMS_DT_LINE_HEADERS(LINE_SID, COL_TYPE_SID, HEADER)
        VALUES (l_line_perc_gdp_level, l_col_type_alt_data, 'Level');

   -----------------------------------------------------------------------------
   -- Table 0
   -----------------------------------------------------------------------------
   INSERT INTO FDMS_DT_TABLES(TABLE_ID, DESCR, ORDER_BY)
        VALUES ('0', 'KEY POINTS OF THE FORECAST', l_table_order)
     RETURNING TABLE_SID
          INTO l_table_sid;

   l_table_order := l_table_order + 1;

   -- Table 0 cols
   l_order       := 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-1Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y0Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y1Q1';

   l_order       := l_order + 1;

   -- Table 0 lines
   l_order       := 1;

   ------------------------------- new line ------------------------------------
   -- line years
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_years, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID)
        VALUES (l_line_type_header)
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_HEADERS(LINE_SID, COL_TYPE_SID, HEADER)
        VALUES (l_line_sid, l_col_type_data, 'Level');

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_header, 'Exchange rates, annual average')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY, STYLES)
        VALUES (l_table_sid, l_line_sid, l_order, 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Effective (% change)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '1', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'XUNNQ.6.0.30.442'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'US dollar (1 USD=)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '2', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'XNU.1.0.30.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Euro (1 EUR=)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '3', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'XNE.1.0.99.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_header, 'Interest rates, annual average')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY, STYLES)
        VALUES (l_table_sid, l_line_sid, l_order, 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Short-term interest rate')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '4', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ISN.1.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Long-term interest rate')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '5', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ILN.1.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID)
        VALUES (l_line_type_header)
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_HEADERS(LINE_SID, COL_TYPE_SID, HEADER)
        VALUES (l_line_sid, l_col_type_data, '% change on previous year');

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_header, 'Macroeconomic environment')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY, STYLES)
        VALUES (l_table_sid, l_line_sid, l_order, 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Export of goods and services')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '6', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OXGS.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Import prices of goods')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '7', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'PMGN.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Final demand')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '8', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OUTT.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'GDP')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '9', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OVGD.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Output gap')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '10', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'AVGDGP.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Employment (persons)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '11', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'FETD9.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Unemployment rate (level)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '12', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZUTN.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'GDP per person employed')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '13', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'RVGDE.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Nominal compensation of employees per head')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '14', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'HWCDW.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Unit labour costs')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '15', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'PLCD.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Relative unit labour costs in common currency')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '16', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'PLCDQ.6.0.0.437'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'HICP')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '17', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZCPIH.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'National CPI')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '18', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZCPIN.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID)
        VALUES (l_line_type_header)
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_HEADERS(LINE_SID, COL_TYPE_SID, HEADER)
        VALUES (l_line_sid, l_col_type_data, 'Level as % of GDP');

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Current external balance')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '19', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBCA.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Private sector net lending')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '20', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBLP.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_header, 'General Government')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY, STYLES)
        VALUES (l_table_sid, l_line_sid, l_order, 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Net lending')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '21', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBLGE.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Cyclically-adjusted primary balance')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '22', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBLGBP.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Gross debt')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '23', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UDGG.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   -----------------------------------------------------------------------------
   -- Table 1
   -----------------------------------------------------------------------------
   INSERT INTO FDMS_DT_TABLES(TABLE_ID, DESCR, ORDER_BY)
        VALUES ('1', 'USE AND SUPPLY OF GOODS AND SERVICES, VOLUMES', l_table_order)
     RETURNING TABLE_SID
          INTO l_table_sid;

   l_table_order := l_table_order + 1;

   -- Table 1 cols
   l_order       := 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'CODE';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-1Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y0Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y1Q1';

   l_order       := l_order + 1;

   -- Table 1 lines
   l_order       := 1;

   ------------------------------- new line ------------------------------------
   -- line years
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_years, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line perc change and level
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_perc_change_level, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Private consumption expenditure', 'P3')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '1'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OCPH.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OCPH.1.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Government consumption expenditure', 'P3')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '2'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OCTG.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OCTG.1.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Gross fixed capital formation', 'P51g')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '3'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OIGT.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OIGT.1.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Domestic demand (excl. inventories)(1+2+3)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '4'
              , 1
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OUNF.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OUNF.1.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data
              , 'Change in inventories + net acquisition of valuable as % of GDP'
              , 'P52+P53')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '5'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OIST.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OIST.1.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Domestic demand (incl. inventories)(4+5)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '6'
              , 1
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OUNT.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OUNT.1.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Exports of goods and services', 'P6')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '7'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OXGS.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OXGS.1.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, '- of which, goods', 'P61')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '7.a'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OXGN.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OXGN.1.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, '- of which, services', 'P62')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '7.b'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OXSN.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OXSN.1.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Final demand (6+7)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '8'
              , 1
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OUTT.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OUTT.1.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Imports of goods and services', 'P7')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '9'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OMGS.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OMGS.1.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, '- of which, goods', 'P71')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '9.a'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OMGN.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OMGN.1.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, '- of which, services', 'P72')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '9.b'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OMSN.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OMSN.1.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Gross domestic product at market prices (8-9)', 'B1*g')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '10'
              , 1
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OVGD.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OVGD.1.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID)
        VALUES (l_line_type_header)
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_HEADERS(LINE_SID, COL_TYPE_SID, HEADER)
        VALUES (l_line_sid, l_col_type_data, 'Contribution to change in GDP');

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Domestic demand (excl. inventories)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '11'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'CUNF.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Change in inventories + net acq. of valuables', 'P52+P53')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '12'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'CIST.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'External balance of goods and services', 'B11')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '13'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'CBGS.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   -----------------------------------------------------------------------------
   -- Table 2
   -----------------------------------------------------------------------------
   INSERT INTO FDMS_DT_TABLES(TABLE_ID, DESCR, ORDER_BY)
        VALUES ('2', 'QUARTERLY PROFILES', l_table_order)
     RETURNING TABLE_SID
          INTO l_table_sid;

   l_table_order := l_table_order + 1;

   -- Table 2 cols
   l_order       := 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-1Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-1Q2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-1Q3';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-1Q4';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y0Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y0Q2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y0Q3';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y0Q4';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y1Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y1Q2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y1Q3';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y1Q4';

   l_order       := l_order + 1;

   -- Table 2 lines
   l_order       := 1;

   ------------------------------- new line ------------------------------------
   -- line years
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY, LINE_SPAN)
        VALUES (l_table_sid, l_line_years, l_order, 2)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID)
        VALUES (l_line_type_quarter)
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY, LINE_SPAN)
        VALUES (l_table_sid, l_line_sid, l_order, 0)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID)
        VALUES (l_line_type_header)
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_HEADERS(LINE_SID, COL_TYPE_SID, HEADER)
        VALUES (l_line_sid, l_col_type_data, 'USE AND SUPPLY OF GOODS AND SERVICES, VOLUMES');

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID)
        VALUES (l_line_type_header)
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_HEADERS(LINE_SID, COL_TYPE_SID, HEADER)
        VALUES (l_line_sid, l_col_type_data, 'Percentage change from previous quarter');

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Private consumption expenditure'
      AND ESA_CODE = 'P3';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '1', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OCPH.12.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'Q';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Government consumption expenditure'
      AND ESA_CODE = 'P3';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '2', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OCTG.12.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'Q';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Gross fixed capital formation'
      AND ESA_CODE = 'P51g';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '3', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OIGT.12.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'Q';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data AND DESCR = 'Domestic demand (excl. inventories)';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '4'
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OUNF.12.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'Q';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Change in inventories + net acquisition of valuable as % of GDP'
      AND ESA_CODE = 'P52+P53';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '5', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OIST.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'Q';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Domestic demand (incl. inventories)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '6'
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OUNT.12.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'Q';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Exports of goods and services'
      AND ESA_CODE = 'P6';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '7', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OXGS.12.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'Q';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data AND DESCR = 'Final demand';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '8'
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OUTT.12.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'Q';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Imports of goods and services'
      AND ESA_CODE = 'P7';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '9', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OMGS.12.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'Q';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Gross domestic product at market prices', 'B1*g')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '10'
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OVGD.12.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'Q';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID)
        VALUES (l_line_type_header)
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_HEADERS(LINE_SID, COL_TYPE_SID, HEADER)
        VALUES (l_line_sid, l_col_type_data, 'HARMONIZED INDEX OF CONSUMER PRICES');

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID)
        VALUES (l_line_type_header)
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_HEADERS(LINE_SID, COL_TYPE_SID, HEADER)
        VALUES (l_line_sid, l_col_type_data, 'Percentage change from four quarters earlier');

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data AND DESCR = 'HICP';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '11'
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZCPIH.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'Q';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Non-energy industrial goods')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '11.a'
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZCPINEG.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'Q';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Energy')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '11.b'
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZCPIENG.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'Q';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Processed food (incl. alcohol and tobacco)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '11.c'
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZCPIFOO.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'Q';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Unprocessed food')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '11.d'
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZCPIUNF.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'Q';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Services')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '11.e'
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZCPISER.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'Q';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Additional aggregates')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '12.'
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'EMPTY_LINE'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Food (11c+11d)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '12.a', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZCPIFUP.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'Q';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Goods (11a+11b+11c+11d)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '12.b', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZCPIGDS.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'Q';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Measures of underlying inflation')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '13.'
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'EMPTY_LINE'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'HICP excl. energy')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '13.a', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZCPIXE.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'Q';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'HICP excl. energy and unprocessed food')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '13.b', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZCPIXEF.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'Q';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'HICP excl. energy and food, alcohol and tobacco')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '13.c', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZCPIX.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'Q';

   l_order       := l_order + 1;

   -----------------------------------------------------------------------------
   -- Table 3
   -----------------------------------------------------------------------------
   INSERT INTO FDMS_DT_TABLES(TABLE_ID, DESCR, ORDER_BY)
        VALUES ('3', 'FURTHER ANALYSIS OF FIXED INVESTMENT, VOLUMES', l_table_order)
     RETURNING TABLE_SID
          INTO l_table_sid;

   l_table_order := l_table_order + 1;

   -- Table 3 cols
   l_order       := 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'CODE';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-1Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y0Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y1Q1';

   l_order       := l_order + 1;

   -- Table 3 lines
   l_order       := 1;

   ------------------------------- new line ------------------------------------
   -- line years
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_years, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line perc change and level
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_perc_change_level, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

--    ------------------------------- new line ------------------------------------
--    INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
--         VALUES (l_line_type_header, 'By sector')
--      RETURNING LINE_SID
--           INTO l_line_sid;

--    INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY, STYLES)
--         VALUES (l_table_sid, l_line_sid, l_order, 'italic')
--      RETURNING TABLE_LINE_SID
--           INTO l_table_line_sid;

--    l_order       := l_order + 1;

--    ------------------------------- new line ------------------------------------
--    INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
--         VALUES (l_line_type_data, 'General Government', 'S3')
--      RETURNING LINE_SID
--           INTO l_line_sid;

--    INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
--                                  , LINE_SID
--                                  , LINE_ID
--                                  , USE_CTY_SCALE
--                                  , ORDER_BY)
--         VALUES (l_table_sid
--               , l_line_sid
--               , '1'
--               , 1
--               , l_order)
--      RETURNING TABLE_LINE_SID
--           INTO l_table_line_sid;

--    INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
--       SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
--         FROM VW_FDMS_INDICATORS I
--        WHERE I.INDICATOR_ID = 'OIGG.6.1.0.0'
--          AND I.PROVIDER_ID = 'PRE_PROD'
--          AND I.PERIODICITY_ID = 'A';

--    INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
--       SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
--         FROM VW_FDMS_INDICATORS I
--        WHERE I.INDICATOR_ID = 'UIGG0.1.0.0.0'
--          AND I.PROVIDER_ID = 'PRE_PROD'
--          AND I.PERIODICITY_ID = 'A';

--    l_order       := l_order + 1;

--    ------------------------------- new line ------------------------------------
--    INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
--         VALUES (l_line_type_data, 'Other domestic sectors', 'S1-S13')
--      RETURNING LINE_SID
--           INTO l_line_sid;

--    INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
--                                  , LINE_SID
--                                  , LINE_ID
--                                  , USE_CTY_SCALE
--                                  , ORDER_BY)
--         VALUES (l_table_sid
--               , l_line_sid
--               , '2'
--               , 1
--               , l_order)
--      RETURNING TABLE_LINE_SID
--           INTO l_table_line_sid;

--    INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
--       SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
--         FROM VW_FDMS_INDICATORS I
--        WHERE I.INDICATOR_ID = 'OIGP.6.1.0.0'
--          AND I.PROVIDER_ID = 'PRE_PROD'
--          AND I.PERIODICITY_ID = 'A';

--    INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
--       SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
--         FROM VW_FDMS_INDICATORS I
--        WHERE I.INDICATOR_ID = 'UIGP.1.0.0.0'
--          AND I.PROVIDER_ID = 'PRE_PROD'
--          AND I.PERIODICITY_ID = 'A';

--    l_order       := l_order + 1;

--    ------------------------------- new line ------------------------------------
--    INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
--         VALUES (l_line_type_header, 'By type of asset')
--      RETURNING LINE_SID
--           INTO l_line_sid;

--    INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY, STYLES)
--         VALUES (l_table_sid, l_line_sid, l_order, 'italic')
--      RETURNING TABLE_LINE_SID
--           INTO l_table_line_sid;

--    l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Construction', 'AN(111+112)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '1'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OIGCO.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UIGCO.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, '- of which, housing', 'AN(111)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '1.a'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OIGDW.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UIGDW.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, '- of which, other construction', 'AN(112)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '1.b'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OIGNR.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UIGNR.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Equipment', 'AN(113)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '2'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OIGEQ.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UIGEQ.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Other', 'AN(114+115+117)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '3'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OIGOT.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UIGOT.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data
              , 'Gross fixed capital formation (whole economy) (=1+2=3+4+5)'
              , 'P51g')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '4'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OIGT.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UIGT.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   -----------------------------------------------------------------------------
   -- Table 4
   -----------------------------------------------------------------------------
   INSERT INTO FDMS_DT_TABLES(TABLE_ID, DESCR, ORDER_BY)
        VALUES ('4'
              , 'USE AND SUPPLY OF GOODS AND SERVICES, VALUES AT CURRENT PRICES'
              , l_table_order)
     RETURNING TABLE_SID
          INTO l_table_sid;

   l_table_order := l_table_order + 1;

   -- Table 4 cols
   l_order       := 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'CODE';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY-1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-1Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY0';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y0Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y1Q1';

   l_order       := l_order + 1;

   -- Table 4 lines
   l_order       := 1;

   ------------------------------- new line ------------------------------------
   -- line years
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_years, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line perc change and level
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_perc_change_level, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Private consumption expenditure'
      AND ESA_CODE = 'P3';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '1'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UCPH.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UCPH.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Government consumption expenditure'
      AND ESA_CODE = 'P3';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '2'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UCTG.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UCTG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Gross fixed capital formation'
      AND ESA_CODE = 'P51g';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '3'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UIGT.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UIGT.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data AND DESCR = 'Domestic demand (excl. inventories)(1+2+3)';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '4'
              , 1
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UUNF.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UUNF.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Change in inventories + net acquisition of valuable as % of GDP'
      AND ESA_CODE = 'P52+P53';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '5', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UIST.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data AND DESCR = 'Domestic demand (incl. inventories)(4+5)';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '6'
              , 1
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UUNT.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UUNT.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Exports of goods and services'
      AND ESA_CODE = 'P6';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '7'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UXGS.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UXGS.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data AND DESCR = '- of which, goods' AND ESA_CODE = 'P61';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '7.a'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UXGN.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UXGN.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data AND DESCR = '- of which, services' AND ESA_CODE = 'P62';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '7.b'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UXSN.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UXSN.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data AND DESCR = 'Final demand (6+7)';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '8'
              , 1
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UUTT.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UUTT.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Imports of goods and services'
      AND ESA_CODE = 'P7';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '9'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UMGS.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UMGS.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data AND DESCR = '- of which, goods' AND ESA_CODE = 'P71';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '9.a'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UMGN.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UMGN.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data AND DESCR = '- of which, services' AND ESA_CODE = 'P72';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '9.b'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UMSN.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UMSN.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Gross domestic product at market prices (8-9)'
      AND ESA_CODE = 'B1*g';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '10'
              , 1
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UVGD.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UVGD.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'of which, external balance of g&s', 'B11')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '11'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBGS.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBGS.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, '- of which, goods')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '11.a'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBGN.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBGN.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, '- of which, services')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '11.b'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBSN.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBSN.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Balance of primary income with the RoW', 'B5')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '12'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBRA.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBRA.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Gross National Income (10+12)', 'B5*g')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '13'
              , 1
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UVGN.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UVGN.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Compensation of employees', 'D1')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '14'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UWCD.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UWCD.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Gross operating surplus and mixed income', 'B2g+B3g')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '15'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UOGD.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UOGD.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Gross value added at basic prices', 'B1g')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '16'
              , 1
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UVGE.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UVGE.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, '- of which, labour costs, incl.of self-employed')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '16.a'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UWCDA.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UWCDA.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Taxes net of subsidies (18+19)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '17'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTVNBP.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTVNBP.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, '- taxes on products', 'D21')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '18'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTVTBP.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTVTBP.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, '- subsidies on products', 'D31')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '19'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UYVTBP.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UYVTBP.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'GDP market prices (16+17)', 'B1*g')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '20'
              , 1
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UVGD.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UVGD.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   -----------------------------------------------------------------------------
   -- Table 5
   -----------------------------------------------------------------------------
   INSERT INTO FDMS_DT_TABLES(TABLE_ID, DESCR, ORDER_BY)
        VALUES ('5', 'COSTS AND PRICES', l_table_order)
     RETURNING TABLE_SID
          INTO l_table_sid;

   l_table_order := l_table_order + 1;

   -- Table 5 cols
   l_order       := 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-1Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y0Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y1Q1';

   l_order       := l_order + 1;

   -- Table 5 lines
   l_order       := 1;

   ------------------------------- new line ------------------------------------
   -- line years
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_years, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID)
        VALUES (l_line_type_header)
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_HEADERS(LINE_SID, COL_TYPE_SID, HEADER)
        VALUES (l_line_sid, l_col_type_data, '% change in implicit price deflator');

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Private consumption expenditure'
      AND ESA_CODE = 'P3';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '1', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'PCPH.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Government consumption expenditure'
      AND ESA_CODE = 'P3';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '2', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'PCTG.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Gross fixed capital formation'
      AND ESA_CODE = 'P51g';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '3', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'PIGT.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, '- of which, construction')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '3.a'
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'PIGCO.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, '- of which, equipment')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '3.b'
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'PIGEQ.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data AND DESCR = 'Domestic demand (excl. inventories)';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '4'
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'PUNF.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Change in inventories')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '5', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'PIST.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data AND DESCR = 'Domestic demand (incl. inventories)';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '6'
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'PUNT.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Exports of good and services')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '7', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'PXGS.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data AND DESCR = '- of which, goods' AND ESA_CODE IS NULL;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '7.a'
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'PXGN.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data AND DESCR = '- of which, services' AND ESA_CODE IS NULL;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '7.b'
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'PXSN.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data AND DESCR = 'Final demand';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '8'
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'PUTT.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Imports of good and services')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '9', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'PMGS.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data AND DESCR = '- of which, goods' AND ESA_CODE IS NULL;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '9.a'
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'PMGN.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data AND DESCR = '- of which, services' AND ESA_CODE IS NULL;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '9.b'
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'PMSN.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Gross domestic product at market prices'
      AND ESA_CODE = 'B1*g';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '10'
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'PVGD.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Terms of trade of goods and services')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '11', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'APGS.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, '- of which, terms of trade of goods')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '11.a'
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'APGN.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, '- of which, terms of trade of services')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '11.b'
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'APSN.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line perc change and level
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_perc_change_level, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data AND DESCR = 'HICP';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '12'
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZCPIH.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data AND DESCR = 'Non-energy industrial goods';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '12.a'
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZCPINEG.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data AND DESCR = 'Energy';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '12.b'
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZCPIENG.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data AND DESCR = 'Processed food (incl. alcohol and tobacco)';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '12.c'
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZCPIFOO.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data AND DESCR = 'Unprocessed food';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '12.d'
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZCPIUNF.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data AND DESCR = 'Services';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '12.e'
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZCPISER.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Additional aggregations')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '13.'
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'EMPTY_LINE'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Food (12c+12d)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '13.a', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZCPIFUP.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Goods (12a+12b+12c+12d)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '13.b', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZCPIGDS.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Measures of underlying inflation')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '14.'
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'EMPTY_LINE'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'HICP excl. energy')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '14.a', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZCPIXE.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'HICP excl. energy and unprocessed food')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '14b.', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZCPIXEF.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'HICP excl. energy, food, alcohol and tobacco')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '14c.', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZCPIX.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Consumer prices (national index)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '14bis. ', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZCPIN.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID)
        VALUES (l_line_type_header)
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_HEADERS(LINE_SID, COL_TYPE_SID, HEADER)
           VALUES (l_line_sid
                 , l_col_type_data
                 , 'Contribution to % change in cost per unit of real GDP at market prices');

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Compensation of employees'
      AND ESA_CODE = 'D1';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '15', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'CCWCD.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, '- of which, gross wages and salaries', 'D11')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '15.a'
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'CCWWD.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, '- of which, employers'' social contributions')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '15.b'
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'CCWSC.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Gross operating surplus / mixed income')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '16', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'CCOGD.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Gross value added at basic prices'
      AND ESA_CODE = 'B1g';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '17'
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'CCVGE.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Taxes net of subsidies')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '18', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'CCTVNBP.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Gross domestic product at market prices'
      AND ESA_CODE = 'B1*g';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '19'
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'CCVGD.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   -----------------------------------------------------------------------------
   -- Table 6
   -----------------------------------------------------------------------------
   INSERT INTO FDMS_DT_TABLES(TABLE_ID, DESCR, FOOTER, ORDER_BY)
        VALUES ('6', 'PRODUCTIVITY AND UNIT LABOUR COSTS',
                '*In thousands per person per year,
**Levels of the unit labour costs are expressed in indices, where the base year value is 100.',
                l_table_order)
     RETURNING TABLE_SID
          INTO l_table_sid;

   l_table_order := l_table_order + 1;

   -- Table 6 cols
   l_order       := 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'CODE';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY-1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-1Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY0';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y0Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y1Q1';

   l_order       := l_order + 1;

   -- Table 6 lines
   l_order       := 1;

   ------------------------------- new line ------------------------------------
   -- line years
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_years, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line perc change and level
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_perc_change_level, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID)
        VALUES (l_line_type_header)
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_HEADERS(LINE_SID, COL_TYPE_SID, HEADER)
        VALUES (l_line_sid, l_col_type_data, 'Based on exclusively on national accounts data ');

   INSERT INTO FDMS_DT_LINE_HEADERS(LINE_SID, COL_TYPE_SID, HEADER)
        VALUES (l_line_sid, l_col_type_alt_data, 'Based on exclusively on national accounts data ');

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Total employment, domestic concept', 'B1g')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '1'
              , NULL
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NETD.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NETD.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, '- of which, employees ')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '1.a'
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NWTD.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NWTD.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, '- of which, self-employed')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '1.b'
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NSTD.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NSTD.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Nominal compensation of employees (Country Scale)', ' ')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '2'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UWCD.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UWCD.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;




   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Nominal compensation per employee*', ' ')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '3'
              , NULL
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'HWCDW.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'HWCDW.1.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, '- of which, wages and salaries per head')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '3.a'
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'HWWDW.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'HWWDW.1.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, '- of which, employers'' contributions per head')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '3.b'
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'HWSCW.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'HWSCW.1.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;





   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Hours worked per person employed')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '4', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NLHA.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NLHA.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;




  ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_header, 'Supplemental/derived indicators')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY, STYLES)
        VALUES (l_table_sid, l_line_sid, l_order, 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Total employment, national concept')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 )
        VALUES (l_table_sid
              , l_line_sid
              , '5'
              , l_order
              )
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NETN.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NETN.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;





   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'GDP in volumes (Country Scale)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 )
        VALUES (l_table_sid
              , l_line_sid
              , '6'
              , 1
              , l_order
              )
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OVGD.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OVGD.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Labour productivity (6:1)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 )
        VALUES (l_table_sid
              , l_line_sid
              , '7'
              , l_order
              )
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'RVGDE.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'RVGDE.1.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Unit labour costs (GDP based)**')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 )
        VALUES (l_table_sid
              , l_line_sid
              , '8'
              , l_order
              )
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'PLCD.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'PLCD.3.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   -----------------------------------------------------------------------------
   -- Table 7
   -----------------------------------------------------------------------------

   INSERT INTO FDMS_DT_TABLES(TABLE_ID, DESCR, FOOTER, ORDER_BY)
        VALUES ('7', 'EMPLOYMENT AND UNEMPLOYMENT',
                '*Population data are annual averages. Please note that Eurostat databases differ in that they provide 1st of January data',
                l_table_order)
     RETURNING TABLE_SID
          INTO l_table_sid;

   l_table_order := l_table_order + 1;



   -- Table 7 cols
   l_order       := 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY-1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-1Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY0';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y0Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y1Q1';

   l_order       := l_order + 1;

   -- Table 7 lines
   l_order       := 1;

   ------------------------------- new line ------------------------------------
   -- line years
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_years, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line perc change and level
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_perc_change_level, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Total population (National accounts)*')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '1', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NPTD.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NPTD.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Population of working age (15-74 years)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '2', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NPAN1.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NPAN1.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Total labour force (LFS)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '3', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NLLN.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NLLN.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;





   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Total employment (LFS)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '4'
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NELN.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NELN.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Unemployment (3 - 4) (LFS)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '5'
              , l_order
              , '')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NUTN.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NUTN.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_header, 'Net inflows from Ukraine - labour market assumptions')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY, STYLES)
        VALUES (l_table_sid, l_line_sid, l_order, 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Population in working age')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '6'
              , l_order
              , '')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NPAN18.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NPAN18.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, ' Number of employed')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '7'
              , l_order
              , '')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NETD8.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NETD8.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;




   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Number of unemployed')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '8'
              , l_order
              , '')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NUTN8.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NUTN8.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'p.m. Active population in working age (%)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , ''
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NETD8.6.0.414.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NETD8.1.0.414.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



-- DEACTIVATE PERC CHANGE FOR ALL BELOW

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'p.m. Unemployment rate (%)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , ''
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZUTN8.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZUTN8.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;




   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_header, 'Structural Indicators definitions (15-74 years)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY, STYLES)
        VALUES (l_table_sid, l_line_sid, l_order, 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Working age population ratio (demographic data)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '9'
              , l_order
              , '')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'WPOPR.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'WPOPR.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, '  p.m. excluding net inflows from Ukraine (approximative)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , ''
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'WPOPX18R.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'WPOPX18R.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;




   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Activity rate (%) (LFS)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '10'
              , l_order
              , '')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ACTR.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ACTR.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Employment rate (%) (LFS)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '11'
              , l_order
              , '')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'EMPR.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'EMPR.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;




   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Unemployment rate, Eurostat definition (%) (LFS)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '12'
              , l_order
              , '')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZUTN.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZUTN.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;


--    -----------------------------------------------------------------------------
--    -- Table 7a
--    -----------------------------------------------------------------------------
--    INSERT INTO FDMS_DT_TABLES(TABLE_ID, DESCR, ORDER_BY)
--         VALUES ('7a', 'REFUGEE LABOUR MARKET OVERVIEW', l_table_order)
--      RETURNING TABLE_SID
--           INTO l_table_sid;

--    l_table_order := l_table_order + 1;

--    -- Table 7a cols
--    l_order       := 1;

--    INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
--       SELECT l_table_sid, C.COL_SID, l_order
--         FROM FDMS_DT_COLS C
--        WHERE C.COL_ID = 'Y-2';

--    l_order       := l_order + 1;

--    INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
--       SELECT l_table_sid, C.COL_SID, l_order
--         FROM FDMS_DT_COLS C
--        WHERE C.COL_ID = 'Y-1Q1';

--    l_order       := l_order + 1;

--    INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
--       SELECT l_table_sid, C.COL_SID, l_order
--         FROM FDMS_DT_COLS C
--        WHERE C.COL_ID = 'Y0Q1';

--    l_order       := l_order + 1;

--    INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
--       SELECT l_table_sid, C.COL_SID, l_order
--         FROM FDMS_DT_COLS C
--        WHERE C.COL_ID = 'Y1Q1';

--    l_order       := l_order + 1;

--    -- Table 7a lines
--    l_order       := 1;

--    ------------------------------- new line ------------------------------------
--    -- line years
--    INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
--         VALUES (l_table_sid, l_line_years, l_order)
--      RETURNING TABLE_LINE_SID
--           INTO l_table_line_sid;

--    l_order       := l_order + 1;

--    ------------------------------- new line ------------------------------------
--    INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
--         VALUES (l_line_type_data, 'Population of refugees in working age (15-74 years)')
--      RETURNING LINE_SID
--           INTO l_line_sid;

--    INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
--         VALUES (l_table_sid, l_line_sid, '1', l_order)
--      RETURNING TABLE_LINE_SID
--           INTO l_table_line_sid;

--    INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
--       SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
--         FROM VW_FDMS_INDICATORS I
--        WHERE I.INDICATOR_ID = 'NPAN18.1.0.0.0'
--          AND I.PROVIDER_ID = 'PRE_PROD'
--          AND I.PERIODICITY_ID = 'A';

--    l_order       := l_order + 1;

--    ------------------------------- new line ------------------------------------

--    INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
--         VALUES (l_line_type_data, 'Number of employed refugees')
--      RETURNING LINE_SID
--           INTO l_line_sid;

--    INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
--         VALUES (l_table_sid, l_line_sid, '2', l_order)
--      RETURNING TABLE_LINE_SID
--           INTO l_table_line_sid;

--    INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
--       SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
--         FROM VW_FDMS_INDICATORS I
--        WHERE I.INDICATOR_ID = 'NETD8.1.0.0.0'
--          AND I.PROVIDER_ID = 'PRE_PROD'
--          AND I.PERIODICITY_ID = 'A';

--    l_order       := l_order + 1;

--    ------------------------------- new line ------------------------------------
--    INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
--         VALUES (l_line_type_data, 'Number of unemployed refugees')
--      RETURNING LINE_SID
--           INTO l_line_sid;

--    INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
--         VALUES (l_table_sid, l_line_sid, '3', l_order)
--      RETURNING TABLE_LINE_SID
--           INTO l_table_line_sid;

--    INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
--       SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
--         FROM VW_FDMS_INDICATORS I
--        WHERE I.INDICATOR_ID = 'NUTN8.1.0.0.0'
--          AND I.PROVIDER_ID = 'PRE_PROD'
--          AND I.PERIODICITY_ID = 'A';

--    l_order       := l_order + 1;

--    ------------------------------- new line ------------------------------------
--    INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
--         VALUES (l_line_type_data, 'Active population of total refugees in working age (%)')
--      RETURNING LINE_SID
--           INTO l_line_sid;

--    INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
--         VALUES (l_table_sid, l_line_sid, '4', l_order)
--      RETURNING TABLE_LINE_SID
--           INTO l_table_line_sid;

--    INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
--       SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
--         FROM VW_FDMS_INDICATORS I
--        WHERE I.INDICATOR_ID = 'NETD8.1.0.414.0'
--          AND I.PROVIDER_ID = 'PRE_PROD'
--          AND I.PERIODICITY_ID = 'A';

--    l_order       := l_order + 1;

--    ------------------------------- new line ------------------------------------
--    INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
--         VALUES (l_line_type_data, 'Unemployment rate among refugees (%)')
--      RETURNING LINE_SID
--           INTO l_line_sid;

--    INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
--         VALUES (l_table_sid, l_line_sid, '5', l_order)
--      RETURNING TABLE_LINE_SID
--           INTO l_table_line_sid;

--    INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
--       SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
--         FROM VW_FDMS_INDICATORS I
--        WHERE I.INDICATOR_ID = 'ZUTN8.1.0.0.0'
--          AND I.PROVIDER_ID = 'PRE_PROD'
--          AND I.PERIODICITY_ID = 'A';

--    l_order       := l_order + 1;

   -----------------------------------------------------------------------------
   -- Table 8
   -----------------------------------------------------------------------------
   INSERT INTO FDMS_DT_TABLES(TABLE_ID, DESCR, ORDER_BY)
        VALUES (
                  '8'
                , 'INCOME AND EXPENDITURE OF HOUSEHOLDS AND NON-PROFIT INSTITUTIONS, SERVING HOUSEHOLDS (S14+S15)'
                , l_table_order
               )
     RETURNING TABLE_SID
          INTO l_table_sid;

   l_table_order := l_table_order + 1;

   -- Table 8 cols
   l_order       := 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'CODE';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY-1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-1Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY0';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y0Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y1Q1';

   l_order       := l_order + 1;

   -- Table 8 lines
   l_order       := 1;

   ------------------------------- new line ------------------------------------
   -- line years
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_years, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line perc change and level
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_perc_change_level, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Compensation of employees'
      AND ESA_CODE = 'D1';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '1'
              , 1
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UWCH.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UWCH.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = '- of which, gross wages and salaries'
      AND ESA_CODE = 'D11';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '1.a'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UWSH.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UWSH.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Non-labour income, net', 'B2g+B3g+D4')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '2'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UYOH.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UYOH.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Current transfers received', 'D62+D7')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '3'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UCTRH.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UCTRH.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Current taxes on income and wealth', 'D5')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '4'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTYH.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTYH.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Current transfers paid', 'D61+D7')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '5'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UCTPH.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UCTPH.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Gross disposable income (1+2+3-4-5)', 'B6g')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '6'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UVGH.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UVGH.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Change in net equity in pension fund res.', 'D8')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '7'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UEHH.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UEHH.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Adjusted gross disposable income (6+7)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '8'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UVGHA.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UVGHA.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Real adjusted gross disposable income')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '9'
              , l_order
              , 'bold italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OVGHA.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Final consumption expenditure', 'P3')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '10'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UCPH0.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UCPH0.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Gross saving (8-10)', 'B8g')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '11'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'USGH.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'USGH.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Saving rate (%) (11:8)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES
                                 , COL_TYPE_SID_SPAN)
        VALUES (l_table_sid
              , l_line_sid
              , '12'
              , l_order
              , 'bold italic'
              , l_col_type_alt_data)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ASGH.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Gross capital formation', 'P5g')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '13'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UITH.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UITH.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Other capital expenditure, net', 'D9+K2')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '14'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UKOH.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UKOH.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Net lending (+) or net borrowing (-) (11-13-14)', 'B9')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '15'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBLH.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'p.m. 15 as % of GDP')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES
                                 , COL_TYPE_SID_SPAN)
        VALUES (l_table_sid
              , l_line_sid
              , '15.a'
              , l_order
              , 'bold italic'
              , l_col_type_alt_data)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBLH.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   -----------------------------------------------------------------------------
   -- Table 9
   -----------------------------------------------------------------------------
   INSERT INTO FDMS_DT_TABLES(TABLE_ID, DESCR, ORDER_BY)
        VALUES ('9', 'INCOME AND EXPENDITURE OF CORPORATIONS (S11+S12)', l_table_order)
     RETURNING TABLE_SID
          INTO l_table_sid;

   l_table_order := l_table_order + 1;

   -- Table 9 cols
   l_order       := 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'CODE';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY-1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-1Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY0';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y0Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y1Q1';

   l_order       := l_order + 1;

   -- Table 9 lines
   l_order       := 1;

   ------------------------------- new line ------------------------------------
   -- line years
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_years, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line perc change and level
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_perc_change_level, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Gross value added at basic prices'
      AND ESA_CODE = 'B1g';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '1'
              , 1
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UGVAC.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UGVAC.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Other subsidies on production', 'D39')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '2'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UYVC.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UYVC.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Other taxes on production', 'D29')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '3'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTVC.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTVC.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Compensation of employees'
      AND ESA_CODE = 'D1';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '4'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UWCC.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UWCC.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Gross operating surplus (1+2-3-4)', 'B2g')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '5'
              , 1
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UOGC.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UOGC.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Property income, net', 'D4')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '6'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UYNC.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UYNC.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Current transfers, net receipts', 'D61+D62+D7')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '7'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UCTRC.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UCTRC.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Current taxes on income and wealth'
      AND ESA_CODE = 'D5';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '8'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTYC.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTYC.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Change in net equity in pension fund res.'
      AND ESA_CODE = 'D8';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '9'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UEHC.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UEHC.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Gross savings (5+6+7-8-9)', 'B8g')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '10'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'USGC.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'USGC.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'p.m. 10 as % of GDP')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES
                                 , COL_TYPE_SID_SPAN)
        VALUES (l_table_sid
              , l_line_sid
              , '10.a'
              , l_order
              , 'bold italic'
              , l_col_type_alt_data)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'USGC.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Gross capital formation'
      AND ESA_CODE = 'P5g';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '11'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UITC.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UITC.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Other capital expenditure, net'
      AND ESA_CODE = 'D9+K2';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '12'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UKOC.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UKOC.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Net lending (+) or net borrowing (-) (10-11-12)', 'B9')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '13'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBLC.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'p.m. 13 as % of GDP')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES
                                 , COL_TYPE_SID_SPAN)
        VALUES (l_table_sid
              , l_line_sid
              , '13.a'
              , l_order
              , 'bold italic'
              , l_col_type_alt_data)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBLC.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;










 -----------------------------------------------------------------------------
   -- Table 10
   -----------------------------------------------------------------------------
   INSERT INTO FDMS_DT_TABLES(TABLE_ID, DESCR, ORDER_BY)
        VALUES ('10', 'REVENUE AND EXPENDITURE OF GENERAL GOVERNMENT (S13)', l_table_order)
     RETURNING TABLE_SID
          INTO l_table_sid;

   l_table_order := l_table_order + 1;

   -- Table 10 cols
   l_order       := 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'CODE';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY-1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-1Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY0';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y0Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y1Q1';

   l_order       := l_order + 1;

   -- Table 10 lines
   l_order       := 1;

   ------------------------------- new line ------------------------------------
   -- line years
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_years, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line perc change and level
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_perc_change_level, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;




   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Taxes on production and imports', 'D2')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '1'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTVG.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTVG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Current taxes on income and wealth', 'D5')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '2'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTYG.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTYG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, '- of which, paid by households and NPISH')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '2.a'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTYH.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTYH.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, '- of which, paid by corporations')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '2.b'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTYC.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTYC.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Social contributions', 'D61')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '3'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTSG.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTSG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, '- of which, actual social contributions', 'D611+D613')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '3.a'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTAG.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTAG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;




   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Sales', 'P11+P12+P131')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '4'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UPOMN.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UPOMN.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Other current revenue', 'D39r+D4r+D7r')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '5'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UROG.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UROG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;




   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, '- of which other current transfers', 'D7r')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '5.a'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UCTRG.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UCTRG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;





   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, '  - of which from EU institutions (including RRF grants)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '5.a1'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UCTREU.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UCTREU.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Total current revenue (1+2+3+4+5)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '6'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'URCG.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'URCG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;





  INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Capital transfers, received', 'D9r')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '7'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UKTTG.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UKTTG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, '- of which from EU institutions')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '7.a'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UKTGEU.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UKTGEU.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Total government revenue (6+7)', 'TR')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '8'
              , 1
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'URTG.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'URTG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;




   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'p.m. as % of GDP')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES
                                 , COL_TYPE_SID_SPAN)
        VALUES (l_table_sid
              , l_line_sid
              , '8.a'
              , l_order
              , 'bold'
              , l_col_type_alt_data)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'URTG.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;





   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Intermediate consumption', 'P2')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '9'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UCTGI.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UCTGI.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Compensation of employees'
      AND ESA_CODE = 'D1';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '10'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UWCG.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UWCG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Interest', 'D41p')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '11'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UYIG.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UYIG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Social transfers in other than in kind', 'D62')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '12'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UYTGH.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UYTGH.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR , ESA_CODE)
        VALUES (l_line_type_data, 'Social transfers in kind supplied via market producer' , 'D632')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '13'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UYTGM.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UYTGM.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Subsidies', 'D3')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '14'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UYVG.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UYVG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Other current expenditure', 'D29p+(D4P-D41p)+D5p+D7p+D8')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '15'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UUOG.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UUOG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, '- of which VAT and GNI contribution to the EU budget', 'D76')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '15.a'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UYTGEU.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UYTGEU.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;




   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Total current expenditure (9+10+11+12+13+14+15)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '16'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UUCG.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UUCG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Gross fixed capital formation'
      AND ESA_CODE = 'P51g';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '17'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UIGG0.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UIGG0.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Other capital expenditure', 'P52+P53+NP+D92p+D99p')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '18'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UKOG.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UKOG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Total government expenditure (16+17+18)', 'TE')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '19'
              , 1
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UUTG.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UUTG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'p.m. as % of GDP')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES
                                 , COL_TYPE_SID_SPAN)
        VALUES (l_table_sid
              , l_line_sid
              , '19.a'
              , l_order
              , 'bold'
              , l_col_type_alt_data)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UUTG.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'p.m. Primary expenditure (19-11)', '')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '20'
              , 1
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UUTGI.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UUTGI.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'p.m. as % of GDP')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES
                                 , COL_TYPE_SID_SPAN)
        VALUES (l_table_sid
              , l_line_sid
              , '20.a'
              , l_order
              , 'bold'
              , l_col_type_alt_data)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UUTGI.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   -- line perc gdp and level
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_perc_gdp_level, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Net lending(+) / net borrowing(-) (8-19)', 'B9')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '21'
              , 1
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBLG.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBLG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'primary balance (20+11)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '21.a'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBLGI.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBLGI.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'General government consolidated gross debt')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '22'
              , 1
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UDGG.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UDGG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Tax burden = D2 (incl. paid to EU)+D5+D611+D91')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES
                                 , COL_TYPE_SID_SPAN)
        VALUES (l_table_sid
              , l_line_sid
              , '23'
              , l_order
              , 'bold'
              , l_col_type_alt_data)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTAT.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;







   -----------------------------------------------------------------------------
   -- Table 10a
   -----------------------------------------------------------------------------
   INSERT INTO FDMS_DT_TABLES(TABLE_ID, DESCR, ORDER_BY)
        VALUES ('10a', 'GOVERNMENT CONSUMPTION EXPENDITURE', l_table_order)
     RETURNING TABLE_SID
          INTO l_table_sid;

   l_table_order := l_table_order + 1;

   -- Table 10a cols
   l_order       := 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'CODE';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY-1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-1Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY0';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y0Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y1Q1';

   l_order       := l_order + 1;

   -- Table 10a lines
   l_order       := 1;

   ------------------------------- new line ------------------------------------
   -- line years
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_years, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line perc change and level
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_perc_change_level, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Compensation of employees'
      AND ESA_CODE = 'D1';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '1'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UWCG.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UWCG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Intermediate consumption'
      AND ESA_CODE = 'P2';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '2'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UCTGI.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UCTGI.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Social transfers in kind supplied via market producer';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '3'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UYTGM.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UYTGM.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Consumption of fixed capital', 'P51c')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '4'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UKCG0.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UKCG0.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Other')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '5'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UCRG.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UCRG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Sales')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '6'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UPOMN.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UPOMN.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Government consumption (1+2+3+4+5-6)', 'P3')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '7'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UCTG.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UCTG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'individual consumption = social transfers in kind', 'P31=D63')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '7.a'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UCIG0.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UCIG0.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'collective consumption', 'P32')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '7.b'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UCCG0.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UCCG0.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;





-----------------------------------------------------------------------------
   -- Table 10b
   -----------------------------------------------------------------------------
   INSERT INTO FDMS_DT_TABLES(TABLE_ID, DESCR, ORDER_BY)
        VALUES ('10b', 'CONSISTENCY ANALYSIS OF REVENUE FORECASTS', l_table_order)
     RETURNING TABLE_SID
          INTO l_table_sid;

   l_table_order := l_table_order + 1;

   -- Table 10b cols
   l_order       := 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-1Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y0Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y1Q1';

   l_order       := l_order + 1;

   -- Table 10a lines
   l_order       := 1;

   ------------------------------- new line ------------------------------------
   -- line years
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_years, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_header, 'Taxes on production and imports (indirect taxes)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY, STYLES)
        VALUES (l_table_sid, l_line_sid, l_order, 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Ex ante elasticity with respect to private consumption')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , SPAN_YEARS_OFFSET
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '1'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'EATTG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Apparent elasticity of forecast')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '2', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ETTG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Past average tax rate ({YEARS-5-2} in percent)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , SPAN_YEARS_OFFSET
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '3'
              , -1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'TRIT.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Average tax rate of forecast (in percent)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '4', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'RTTG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data
              , 'Other factors including discretionary measures implied by forecast (% of GDP)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '5', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'FTTG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_header, 'Taxes on income and wealth (direct taxes)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY, STYLES)
        VALUES (l_table_sid, l_line_sid, l_order, 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Ex ante elasticity with respect to nominal GDP')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , SPAN_YEARS_OFFSET
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '1'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'EATYG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data AND DESCR = 'Apparent elasticity of forecast';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '2', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ETYG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Past average tax rate ({YEARS-5-2} in percent)';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , SPAN_YEARS_OFFSET
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '3'
              , -1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'TRDT.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data AND DESCR = 'Average tax rate of forecast (in percent)';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '4', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'RTYG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Other factors including discretionary measures implied by forecast (% of GDP)';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '5', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'FTYG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_header, 'Social contributions')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY, STYLES)
        VALUES (l_table_sid, l_line_sid, l_order, 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Ex ante elasticity with respect to compensation of employees')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , SPAN_YEARS_OFFSET
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '1'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'EATSG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data AND DESCR = 'Apparent elasticity of forecast';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '2', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ETSG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Past average tax rate ({YEARS-5-2} in percent)';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , SPAN_YEARS_OFFSET
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '3'
              , -1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'TRSC.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data AND DESCR = 'Average tax rate of forecast (in percent)';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '4', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'RTSG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data
      AND DESCR = 'Other factors including discretionary measures implied by forecast (% of GDP)';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '5', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'FTSG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;




-------------------------------------------------------------
   -- Table 10c
   -----------------------------------------------------------------------------
   INSERT INTO FDMS_DT_TABLES(TABLE_ID, DESCR, ORDER_BY)
        VALUES ('10c', 'FURTHER ANALYSIS OF DEBT DEVELOPMENTS', l_table_order)
     RETURNING TABLE_SID
          INTO l_table_sid;

   l_table_order := l_table_order + 1;

   -- Table 10c cols
   l_order       := 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-1Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y0Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y1Q1';

   l_order       := l_order + 1;

   -- Table 10c lines
   l_order       := 1;

   ------------------------------- new line ------------------------------------
   -- line years
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_years, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID)
        VALUES (l_line_type_header)
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_HEADERS(LINE_SID, COL_TYPE_SID, HEADER)
        VALUES (l_line_sid, l_col_type_data, '% of GDP');

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Gross debt')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '1', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UDGG.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Change in the debt ratio')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '2', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UDGGD.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_header, 'Contributions')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY, STYLES)
        VALUES (l_table_sid, l_line_sid, l_order, 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Primary balance')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '2.a', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = '-UBLGI.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, '"Snowball" effect ')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '2.b', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ADGGI.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

      ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_header, 'of which :')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY, STYLES)
        VALUES (l_table_sid, l_line_sid, l_order, 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Interest expenditure')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, ' ', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ADGGIY.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Real GDP growth')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, ' ', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ADGGIO.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Inflation (GDP deflator)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, ' ', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ADGGIP.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, '"Stock-flow" adjustment')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '2.c', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UDGGS.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'p.m. Net lending / borrowing (B.9)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, ' ', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBLGE.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'p.m. Primary balance (B.9 - D.41)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, ' ', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBLGI.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'p.m. Interest expenditure (D.41)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, ' ', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UYIGE.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Implicit interest rate on debt level')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, '3', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'IUDGG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Long-term interest assumption')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, LINE_ID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, ' ', l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ILN.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;






  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------



   -----------------------------------------------------------------------------
   -- Table 10d
   -----------------------------------------------------------------------------
   INSERT INTO FDMS_DT_TABLES(TABLE_ID, DESCR, ORDER_BY)
        VALUES (
                  '10d'
               , 'Fiscal surveillance indicators'
               , l_table_order
               )
     RETURNING TABLE_SID
          INTO l_table_sid;

   l_table_order := l_table_order + 1;

   -- Table 10d cols
   l_order       := 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'CODE';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY-1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-1Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY0';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y0Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y1Q1';

   l_order       := l_order + 1;

   -- Table 10d lines
   l_order       := 1;

   ------------------------------- new line ------------------------------------
   -- line years
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_years, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line perc change and level
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_perc_change_level, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_header, 'Macro variables')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY, STYLES)
        VALUES (l_table_sid, l_line_sid, l_order, 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data
              , 'GDP at current market prices - Reference level for excessive deficit procedure'
              , 'EDP B1*g')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '1'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UVGDH.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UVGDH.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data
              , 'Potential GDP (approximative)'
              , '')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '2'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OVGDP.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OVGDP.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Output gap (% of potential GDP)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , COL_TYPE_SID_SPAN)
        VALUES (l_table_sid
              , l_line_sid
              , '3'
              , l_order
              , l_col_type_alt_data)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'AVGDGP.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Medium term potential growth (approximative)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , COL_TYPE_SID_SPAN)
        VALUES (l_table_sid
              , l_line_sid
              , '4'
              , l_order
              , l_col_type_alt_data)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OVGDPM.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;





   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'GDP deflator')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , COL_TYPE_SID_SPAN)
        VALUES (l_table_sid
              , l_line_sid
              , '5'
              , l_order
              , l_col_type_alt_data)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'PVGD.6.1.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line perc gdp and level
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_perc_gdp_level, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;




   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_header, 'Structural budget balance')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY, STYLES)
        VALUES (l_table_sid, l_line_sid, l_order, 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data
              , 'General government net lending / net borrowing for EDP purposes'
              , 'EDP B9')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '6'
              , 1
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBLGE.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBLGE.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

--    ------------------------------- new line ------------------------------------
--    INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
--         VALUES (l_line_type_data
--               , 'Cyclical component of general government revenue (µr - 1) * R/Y * OG')
--      RETURNING LINE_SID
--           INTO l_line_sid;

--    INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
--                                  , LINE_SID
--                                  , LINE_ID
--                                  , USE_CTY_SCALE
--                                  , ORDER_BY)
--         VALUES (l_table_sid
--               , l_line_sid
--               , '7'
--               , 1
--               , l_order)
--      RETURNING TABLE_LINE_SID
--           INTO l_table_line_sid;

--    INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
--       SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
--         FROM VW_FDMS_INDICATORS I
--        WHERE I.INDICATOR_ID = 'UTCGCP.1.0.319.0'
--          AND I.PROVIDER_ID = 'PRE_PROD'
--          AND I.PERIODICITY_ID = 'A';

--    l_order       := l_order + 1;

--    ------------------------------- new line ------------------------------------
--    INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
--         VALUES (l_line_type_data, 'p.m. Elasticity of revenue (µr)')
--      RETURNING LINE_SID
--           INTO l_line_sid;

--    INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
--                                  , LINE_SID
--                                  , LINE_ID
--                                  , ORDER_BY
--                                  , STYLES)
--         VALUES (l_table_sid
--               , l_line_sid
--               , '7.a'
--               , l_order
--               , 'italic')
--      RETURNING TABLE_LINE_SID
--           INTO l_table_line_sid;

--    INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
--       SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
--         FROM VW_FDMS_INDICATORS I
--        WHERE I.INDICATOR_ID = 'EREV.1.0.319.0'
--          AND I.PROVIDER_ID = 'PRE_PROD'
--          AND I.PERIODICITY_ID = 'A';

--    l_order       := l_order + 1;

--    ------------------------------- new line ------------------------------------
--    INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
--         VALUES (l_line_type_data, 'Cyclical component of general government expenditure')
--      RETURNING LINE_SID
--           INTO l_line_sid;

--    INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
--                                  , LINE_SID
--                                  , LINE_ID
--                                  , USE_CTY_SCALE
--                                  , ORDER_BY)
--         VALUES (l_table_sid
--               , l_line_sid
--               , '8'
--               , 1
--               , l_order)
--      RETURNING TABLE_LINE_SID
--           INTO l_table_line_sid;

--    INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
--       SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
--         FROM VW_FDMS_INDICATORS I
--        WHERE I.INDICATOR_ID = 'UUCGCP.1.0.319.0'
--          AND I.PROVIDER_ID = 'PRE_PROD'
--          AND I.PERIODICITY_ID = 'A';

--    l_order       := l_order + 1;

--    ------------------------------- new line ------------------------------------
--    INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
--         VALUES (l_line_type_data, 'p.m. Elasticity of expenditure (µg)')
--      RETURNING LINE_SID
--           INTO l_line_sid;

--    INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
--                                  , LINE_SID
--                                  , LINE_ID
--                                  , ORDER_BY
--                                  , STYLES)
--         VALUES (l_table_sid
--               , l_line_sid
--               , '8.a'
--               , l_order
--               , 'italic')
--      RETURNING TABLE_LINE_SID
--           INTO l_table_line_sid;

--    INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
--       SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
--         FROM VW_FDMS_INDICATORS I
--        WHERE I.INDICATOR_ID = 'EEXP.1.0.319.0'
--          AND I.PROVIDER_ID = 'PRE_PROD'
--          AND I.PERIODICITY_ID = 'A';

--    l_order       := l_order + 1;

--    ------------------------------- new line ------------------------------------
--    INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
--         VALUES (l_line_type_data
--               , 'Cyclical component of general government net lending/net borrowing (7+8)')
--      RETURNING LINE_SID
--           INTO l_line_sid;

--    INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
--                                  , LINE_SID
--                                  , LINE_ID
--                                  , USE_CTY_SCALE
--                                  , ORDER_BY
--                                  , STYLES)
--         VALUES (l_table_sid
--               , l_line_sid
--               , '9'
--               , 1
--               , l_order
--               , 'bold')
--      RETURNING TABLE_LINE_SID
--           INTO l_table_line_sid;

--    INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
--       SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
--         FROM VW_FDMS_INDICATORS I
--        WHERE I.INDICATOR_ID = 'UBLGCP.1.0.319.0'
--          AND I.PROVIDER_ID = 'PRE_PROD'
--          AND I.PERIODICITY_ID = 'A';

--    l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Cyclically-adjusted general government net lending/net borrowing')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , COL_TYPE_SID_SPAN)
        VALUES (l_table_sid
              , l_line_sid
              , '7'
              , l_order
              , l_col_type_alt_data)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBLGAP.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'One-off measures (revenue side)*')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '8'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UOOMSR.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UOOMSR.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'One-off measures (expenditure side)*')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '9'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UOOMSE.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UOOMSE.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Structural budget balance (10-11-12)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , COL_TYPE_SID_SPAN)
        VALUES (l_table_sid
              , l_line_sid
              , '10'
              , l_order
              , l_col_type_alt_data)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBLGAPS.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Change in structural budget balance')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , COL_TYPE_SID_SPAN)
        VALUES (l_table_sid
              , l_line_sid
              , '10.a'
              , l_order
              , l_col_type_alt_data)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBLGAPSDIFF.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;



  ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_header, 'Fiscal stance indicators')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY, STYLES)
        VALUES (l_table_sid, l_line_sid, l_order, 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;



  ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_header, 'Overall fiscal stance')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY, STYLES)
        VALUES (l_table_sid, l_line_sid, l_order, 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Fiscal impulse from the national budget')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '1'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'FSN.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'FSN.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, '- of which nationally financed net primary expenditure')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '1.a'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'FSNF.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'FSNF.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, '- of which gfcf')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '1.b'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'FSGFCF.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'FSGFCF.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, '- of which other capital expenditure')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '1.c'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'FSOE.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'FSOE.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Fiscal impulse from EU funded expenditure')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '2'
              , 1
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'FSEU.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'FSEU.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;






   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Overall fiscal stance (1+2)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY,
                                 STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '3'
              , 1
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'AGFS.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'AGFS.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;





   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;





   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_header, 'Measures')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY, STYLES)
        VALUES (l_table_sid, l_line_sid, l_order, 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;





   ------------------------------- new line ------------------------------------
--    INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID)
--         VALUES (l_line_type_header)
--      RETURNING LINE_SID
--           INTO l_line_sid;

--    INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
--         VALUES (l_table_sid, l_line_sid, l_order)
--      RETURNING TABLE_LINE_SID
--           INTO l_table_line_sid;

--    INSERT INTO FDMS_DT_LINE_HEADERS(LINE_SID, COL_TYPE_SID, HEADER)
--         VALUES (l_line_sid, l_col_type_data, 'Measures');

--    INSERT INTO FDMS_DT_LINE_HEADERS(LINE_SID, COL_TYPE_SID, HEADER)
--         VALUES (l_line_sid, l_col_type_alt_data, 'Measures');

--    l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'One-Offs')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES
                                 , COL_TYPE_SID_SPAN)
        VALUES (l_table_sid
              , l_line_sid
              , '1'
              , l_order
              , 'bold'
              , l_col_type_alt_data)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'EMPTY_LINE'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_header, 'Excluding EU financed')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY, STYLES)
        VALUES (l_table_sid, l_line_sid, l_order, 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;


 -- Rewrite wihtout capital letters

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Revenue side')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UOOMSR.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UOOMSR.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Expenditure side')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UOOMSE.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UOOMSE.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Current expenditure')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UOOMSCE.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UOOMSCE.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Gross fixed capital formation')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UOOMSIE.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UOOMSIE.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Other capital expenditure')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UOOMSKE.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UOOMSKE.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_header, 'Including EU financed')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY, STYLES)
        VALUES (l_table_sid, l_line_sid, l_order, 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Revenue side')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UOOMDR.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UOOMDR.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;




   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Expenditure side')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UOOMDE.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UOOMDE.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Current expenditure')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UOOMDCE.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UOOMDCE.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;





   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Gross fixed capital formation')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UOOMDIE.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UOOMDIE.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Other capital expenditure')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UOOMDKE.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UOOMDKE.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Discretionary measures')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES
                                 , COL_TYPE_SID_SPAN)
        VALUES (l_table_sid
              , l_line_sid
              , '2'
              , l_order
              , 'bold'
              , l_col_type_alt_data)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'EMPTY_LINE'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_header, 'Excluding EU financed')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY, STYLES)
        VALUES (l_table_sid, l_line_sid, l_order, 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;




   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Current expenditure')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UDMGCE.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UDMGCE.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Current revenue')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UDMGCR.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UDMGCR.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Capital expenditure')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UDMGKE.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UDMGKE.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Capital transfers received')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UDMGKTR.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UDMGKTR.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;





   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_header, 'Including EU financed')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY, STYLES)
        VALUES (l_table_sid, l_line_sid, l_order, 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Current expenditure')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UDMDCE.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UDMDCE.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Current revenue')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UDMDCR.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UDMDCR.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Capital expenditure')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UDMDKE.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UDMDKE.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Capital transfers received')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UDMDKTR.1.0.319.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UDMDKTR.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------








   -----------------------------------------------------------------------------
   -- Table 10f RRF OVERVIEW
   -----------------------------------------------------------------------------
   INSERT INTO FDMS_DT_TABLES(TABLE_ID, DESCR, ORDER_BY)
        VALUES ('10e', 'RRF OVERVIEW', l_table_order)
     RETURNING TABLE_SID
          INTO l_table_sid;

   l_table_order := l_table_order + 1;

   -- Table 10f cols
   l_order       := 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY-3';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 2, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-3';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 2, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY-1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 2, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-1Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY0';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 2, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y0Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 2, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y1Q1';

   l_order       := l_order + 1;

   -- table 10f lines
   l_order       := 1;

   ------------------------------- new line ------------------------------------
   -- line years
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_years, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID)
        VALUES (l_line_type_header)
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_HEADERS(LINE_SID, COL_TYPE_SID, HEADER)
        VALUES (l_line_sid, l_col_type_data, 'Level (mn)');

   INSERT INTO FDMS_DT_LINE_HEADERS(LINE_SID, COL_TYPE_SID, HEADER)
        VALUES (l_line_sid, l_col_type_alt_data, '% of GDP');

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------

   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Expenditure financed by RRF grants')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '1'
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Total current expenditure financed by RRF grants')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '1.a'
              , 2
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UUCGR.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UUCGR.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Total capital expenditure financed by RRF grants (1.c + 1.d)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '1.b'
              , 2
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'TAB10D1B.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'TAB10D1B.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

      ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_header, 'of which :')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY, STYLES)
        VALUES (l_table_sid, l_line_sid, l_order, 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Gross fixed capital formation')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '1.c'
              , 2
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UIGG0R.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UIGG0R.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Capital transfers')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '1.d'
              , 2
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UKTGR.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UKTGR.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;


      ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_header, 'Which is :')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY, STYLES)
        VALUES (l_table_sid, l_line_sid, l_order, 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, '= Total expenditure financed by RRF grants (1.a + 1.b)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '1.e'
              , 2
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'TAB10D1G.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'TAB10D1G.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------

   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Other costs financed by RRF grants')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '2'
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Reduction in tax revenue compensated by RRF grants')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '2.a'
              , 2
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTGCR.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTGCR.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, '+ Other costs with impact on revenue compensated by RRF grants')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '2.b'
              , 2
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UROGR.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UROGR.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, '= Total reduction in revenue compensated by RRF grants (2.a + 2.b)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '2.c'
              , 2
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'TAB10D2C.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'TAB10D2C.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'p.m.: Financial transactions making use of RRF grants')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '2.d'
              , 2
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTAFGGR.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTAFGGR.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------

   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, '(Accrual) Revenues from RRF grants')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '3'
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Current revenues from RRF grants')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '3.a'
              , 2
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'URCGR.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'URCGR.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, '+ Capital revenues from RRF grants')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '3.b'
              , 2
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UKTTR.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UKTTR.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, '= Total revenues from RRF grants (3.a + 3.b)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '3.c'
              , 2
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'TAB10D3E.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'TAB10D3E.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Cash disbursements of RRF grants from the EU:- ESA2010')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '4'
              , 2
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTAF2GR.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTAF2GR.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;












   -----------------------------------------------------------------------------
   -- Table 11
   -----------------------------------------------------------------------------
   INSERT INTO FDMS_DT_TABLES(TABLE_ID, DESCR, ORDER_BY)
        VALUES ('11', 'EXTERNAL TRANSACTIONS ACCOUNT OF THE NATION (S2)', l_table_order)
     RETURNING TABLE_SID
          INTO l_table_sid;

   l_table_order := l_table_order + 1;

   -- Table 11 cols
   l_order       := 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'CODE';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY-1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-1Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY0';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y0Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y1Q1';

   l_order       := l_order + 1;

   -- Table 11 lines
   l_order       := 1;

   ------------------------------- new line ------------------------------------
   -- line years
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_years, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line perc change and level
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_perc_change_level, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Exports of goods (fob)', 'P61')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '1'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UXGN.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UXGN.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Imports of gooods (fob)', 'P71')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '2'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UMGN.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UMGN.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Trade balance (goods, fob/cif) (1-2)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '3'
              , 1
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBGN.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBGN.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'p.m. 3 as % of GDP')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '3.a'
              , l_order
              , 'bold italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBGN.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Exports of services', 'P62')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '4'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UXSN.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UXSN.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Imports of services', 'P72')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '5'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UMSN.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UMSN.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Services balance (4-5)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '6'
              , 1
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBSN.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBSN.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'p.m. 6 as % of GDP')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '6.a'
              , l_order
              , 'bold italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBSN.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'External balance of goods and services (3+6)', 'B11')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '7'
              , 1
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBGS.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'p.m. 7 as % of GDP')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '7.a'
              , l_order
              , 'bold italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBGS.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Balance of primary incomes and current transfers')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '8'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBYA.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, '- of which, balance of primary income', 'B5g')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '8.a'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBRA.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, '- of which, net current transfers')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '8.b'
              , 1
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBTA.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, '- p.m. 8 as % of GDP')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '8.c'
              , l_order
              , 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBYA.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Current external balance (7+8)', 'B12')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '9'
              , 1
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBCA.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'p.m. 9 as % of GDP')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '9.a'
              , l_order
              , 'bold italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBCA.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Net capital transactions')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '10'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBKA.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data, 'Net lending (+)/ net borrowing (-) (9+10)', 'B9')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '11'
              , 1
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBLA.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'p.m. 11 as % of GDP')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '11.a'
              , l_order
              , 'bold italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBLA.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   -----------------------------------------------------------------------------
   -- Table 12
   -----------------------------------------------------------------------------
   INSERT INTO FDMS_DT_TABLES(TABLE_ID, DESCR, ORDER_BY)
        VALUES ('12', 'TRADE IN GOODS BY REGION (CUSTOMS BASIS)', l_table_order)
     RETURNING TABLE_SID
          INTO l_table_sid;

   l_table_order := l_table_order + 1;

   -- Table 12 cols
   l_order       := 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'BY-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY-1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-1Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY0';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y0Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y1Q1';

   l_order       := l_order + 1;

   -- Table 12 lines
   l_order       := 1;

   ------------------------------- new line ------------------------------------
   -- line years
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_years, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line perc change and level
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_perc_change_level, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_header, 'Exports of goods (fob)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY, STYLES)
        VALUES (l_table_sid, l_line_sid, l_order, 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Intra-EU')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '1'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'DXGI.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'DXGI.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt2_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'DXGIT.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Extra-EU')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '2'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'DXGE.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'DXGE.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt2_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'DXGET.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Total exports (1+2)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '3'
              , 1
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'DXGT.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'DXGT.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt2_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'DXGTT.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_header, 'Imports of goods (cif)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY, STYLES)
        VALUES (l_table_sid, l_line_sid, l_order, 'italic')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data AND DESCR = 'Intra-EU';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '4'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'DMGI.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'DMGI.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt2_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'DMGIT.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   SELECT LINE_SID
     INTO l_line_sid
     FROM FDMS_DT_LINES
    WHERE LINE_TYPE_SID = l_line_type_data AND DESCR = 'Extra-EU';

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '5'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'DMGE.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'DMGE.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt2_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'DMGET.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Total imports (4+5)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '6'
              , 1
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'DMGT.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'DMGT.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt2_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'DMGTT.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Trade balance (fob/cif) (3-6)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '7'
              , 1
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'DBGT.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'DBGT.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   -----------------------------------------------------------------------------
   -- Table 13
   -----------------------------------------------------------------------------
   INSERT INTO FDMS_DT_TABLES(TABLE_ID, DESCR, ORDER_BY)
        VALUES ('13', 'FINANCING SIDE OVERVIEW', l_table_order)
     RETURNING TABLE_SID
          INTO l_table_sid;

   l_table_order := l_table_order + 1;

   -- Table 13 cols
   l_order       := 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-1Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y0Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y1Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY-1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY0';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'BY-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'BY-1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'BY0';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'BY1';

   l_order       := l_order + 1;

   -- Table 13 lines
   l_order       := 1;

   ------------------------------- new line ------------------------------------
   -- line years
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_years, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID)
        VALUES (l_line_type_header)
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_HEADERS(LINE_SID, COL_TYPE_SID, HEADER)
        VALUES (l_line_sid, l_col_type_data, 'y-o-y% change');

   INSERT INTO FDMS_DT_LINE_HEADERS(LINE_SID, COL_TYPE_SID, HEADER)
        VALUES (l_line_sid, l_col_type_alt_data, '% of GDP');

   INSERT INTO FDMS_DT_LINE_HEADERS(LINE_SID, COL_TYPE_SID, HEADER)
        VALUES (l_line_sid, l_col_type_alt2_data, 'Level');

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------

   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Net International Investment Position (NIIP)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '1'
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Country desk forecast')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '1.a'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBIKBOP.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBIKBOP.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt2_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBIKBOP.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'B1 forecast')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '1.b'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBIKBOPB1.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBIKBOPB1.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt2_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UBIKBOPB1.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Household Lending (Flow)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '2'
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Country desk forecast')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '2.a'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTLDIHN.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTLDIHN.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt2_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTLDIHN.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'B1 forecast')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '2.b'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTLDIHNB1.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTLDIHNB1.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt2_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTLDIHNB1.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Corporate Lending (Flow)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '3'
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Country desk forecast')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '3.a'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTLDINF.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTLDINF.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt2_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTLDINF.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'B1 forecast')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '3.b'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTLDINFB1.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTLDINFB1.1.0.310.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt2_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'UTLDINFB1.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID)
        VALUES (l_line_type_header)
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_HEADERS(LINE_SID, COL_TYPE_SID, HEADER)
        VALUES (l_line_sid, l_col_type_data, 'y-o-y% change');

   INSERT INTO FDMS_DT_LINE_HEADERS(LINE_SID, COL_TYPE_SID, HEADER)
        VALUES (l_line_sid, l_col_type_alt_data, 'Index');

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'House Prices')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES)
        VALUES (l_table_sid
              , l_line_sid
              , '4'
              , l_order
              , 'bold')
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Country desk forecast')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '4.a'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZHPI.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZHPI.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'B1 forecast')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , '4.b'
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZHPIB1.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZHPIB1.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;





   -----------------------------------------------------------------------------
   -- Table 14
   -----------------------------------------------------------------------------

   INSERT INTO FDMS_DT_TABLES(TABLE_ID, DESCR, FOOTER, ORDER_BY )
        VALUES ('14', 'EMPLOYMENT AND UNEMPLOYMENT',
                '*These variables are calculated using a mix of LFS and national accounts data and differ from the LFS based series and the FDMS* calculations',
                l_table_order)
     RETURNING TABLE_SID
          INTO l_table_sid;

   l_table_order := l_table_order + 1;


   l_order       := 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY )
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'CODE_DESCR';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, USE_CTY_SCALE, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, 1, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'AY-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-2';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y-1Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y0Q1';

   l_order       := l_order + 1;

   INSERT INTO FDMS_DT_TABLE_COLS(TABLE_SID, COL_SID, ORDER_BY)
      SELECT l_table_sid, C.COL_SID, l_order
        FROM FDMS_DT_COLS C
       WHERE C.COL_ID = 'Y1Q1';

   l_order       := l_order + 1;

   -- Table 14 lines
   l_order       := 1;




   ------------------------------- new line ------------------------------------
   -- line years
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_years, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   -- line perc change and level
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_perc_change_level, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Demographics')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES
                                 , COL_TYPE_SID_SPAN)
        VALUES (l_table_sid
              , l_line_sid
              , '1'
              , l_order
              , 'bold'
              , l_col_type_alt_data)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'EMPTY_LINE'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data
              , 'Total population'
              , 'NPTD: National accounts source,annual average')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , NULL
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NPTD.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NPTD.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;




   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data
              , 'Working age population (15-74)'
              , 'NPAN1: Population 15-74 years (Population statistics), annual average')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , NULL
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NPAN1.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NPAN1.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data
              , ' - Excluding refugees'
              , 'NPAN1 minus Ukrainian refugee population (15-74 years)')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , NULL
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NPAN1X8.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NPAN1X8.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;




   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'Labour market')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES
                                 , COL_TYPE_SID_SPAN)
        VALUES (l_table_sid
              , l_line_sid
              , '2'
              , l_order
              , 'bold'
              , l_col_type_alt_data)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'EMPTY_LINE'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;







   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data
              , 'Hours worked per employee'
              , 'NLHA: Average annual hours worked per person employed')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , NULL
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NLHA.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NLHA.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data
              , 'Employment Domestic'
              , 'NETD: Employment in persons, domestic concept')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , NULL
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NETD.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NETD.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;





   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data
              , ' - Excluding refugees'
              , 'NETD minus employed Ukrainian refugees')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , NULL
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NETDX8.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NETDX8.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;




   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data
              , 'Unemployed*'
              , 'Number of unemployed persons calculated using domestic employment and the unemployment rate.')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , NULL
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NUTNOG.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NUTNOG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;




   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data
              , ' - Excluding refugees*'
              , 'Number of unemployed persons as calculated for EUCAM minus unemployed Ukrainian refugees')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , NULL
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NUTNOGX8.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'NUTNOGX8.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID)
        VALUES (l_line_type_header)
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_HEADERS(LINE_SID, COL_TYPE_SID, HEADER)
        VALUES (l_line_sid, l_col_type_data, '% of relevant population');

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data
              , 'Harmonised unemployment rate'
              , 'ZUTN: Unemployed persons as a share of total active population, eurostat definition')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , NULL
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;


   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'ZUTN.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data
              , 'Participation rate*'
              , 'Employment divided by 1-Unemployment rate/100 as percent of working age population')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , NULL
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;


   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'PARTOGR.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data
              , ' - Excluding refugees*'
              , 'Same as above, excluding Ukrainian refugee population for each variable')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , NULL
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;


   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'PARTOGX8R.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   -- line empty
   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_empty, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID)
        VALUES (l_line_type_header)
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID, LINE_SID, ORDER_BY)
        VALUES (l_table_sid, l_line_sid, l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_HEADERS(LINE_SID, COL_TYPE_SID, HEADER)
        VALUES (l_line_sid, l_col_type_data, '% change');

   l_order       := l_order + 1;


   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR)
        VALUES (l_line_type_data, 'GDP and capital stock')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , ORDER_BY
                                 , STYLES
                                 , COL_TYPE_SID_SPAN)
        VALUES (l_table_sid
              , l_line_sid
              , '3'
              , l_order
              , 'bold'
              , l_col_type_alt_data)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'EMPTY_LINE'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;




   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data
              , 'Real GDP'
              , 'OVGD: Gross domestic product at constant prices')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OVGD.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OVGD.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;




   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data
              , 'Real gross fixed capital formation'
              , 'OIGT: Gross fixed capital formation at constant prices')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , 1
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OIGT.6.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_alt_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'OIGT.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;



   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data
              , 'Labour productivity'
              , 'Real GDP per person employed, change in log')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , NULL
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;


   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'RVGDEA3.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;

   ------------------------------- new line ------------------------------------
   INSERT INTO FDMS_DT_LINES(LINE_TYPE_SID, DESCR, ESA_CODE)
        VALUES (l_line_type_data
              , 'Capital + TFP contribution to GDP growth'
              , 'GDP growth - labour contribution: Growth rate(OVGD) - 0.65*(growth rate(NLHA* Participation rate  * NPAN1 * (1-ZUTN)))')
     RETURNING LINE_SID
          INTO l_line_sid;

   INSERT INTO FDMS_DT_TABLE_LINES(TABLE_SID
                                 , LINE_SID
                                 , LINE_ID
                                 , USE_CTY_SCALE
                                 , ORDER_BY)
        VALUES (l_table_sid
              , l_line_sid
              , ' '
              , NULL
              , l_order)
     RETURNING TABLE_LINE_SID
          INTO l_table_line_sid;


   INSERT INTO FDMS_DT_LINE_INDICATORS(TABLE_LINE_SID, COL_TYPE_SID, INDICATOR_SID)
      SELECT l_table_line_sid, l_col_type_data, I.INDICATOR_SID
        FROM VW_FDMS_INDICATORS I
       WHERE I.INDICATOR_ID = 'CCTFPOG.1.0.0.0'
         AND I.PROVIDER_ID = 'PRE_PROD'
         AND I.PERIODICITY_ID = 'A';

   l_order       := l_order + 1;


   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------



COMMIT;
END;
