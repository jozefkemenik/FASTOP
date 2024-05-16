/* Formatted on 27-01-2021 14:45:16 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE FDMS_DETAILED_TABLE
AS
   PROCEDURE getBaseYear(p_round_sid IN NUMBER, o_year OUT NUMBER);

   PROCEDURE getTableCols(p_table_sid IN NUMBER, o_cur OUT SYS_REFCURSOR);

   PROCEDURE getTableIndicatorIds(o_cur               OUT SYS_REFCURSOR
                                , p_periodicity_id IN     VARCHAR2 DEFAULT NULL
                                , p_table_sid      IN     NUMBER DEFAULT NULL);

   PROCEDURE getTableIndicators(p_table_sid IN NUMBER, o_cur OUT SYS_REFCURSOR);

   PROCEDURE getTableLines(p_table_sid IN NUMBER, o_cur OUT SYS_REFCURSOR);

   PROCEDURE getTables(o_cur OUT SYS_REFCURSOR);
END FDMS_DETAILED_TABLE;