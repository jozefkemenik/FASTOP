/* Formatted on 26-Sep-22 17:54:55 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE CORE_COMMONS
AS
   /******************************************************************************
         NAME:       CORE_COMMONS
         PURPOSE: Common global functionality
    ******************************************************************************/
   TYPE SIDSARRAY IS TABLE OF NUMBER(12)
      INDEX BY BINARY_INTEGER;

   TYPE VARCHARARRAY IS TABLE OF VARCHAR2(4000 BYTE)
      INDEX BY PLS_INTEGER;

   FUNCTION arrayToList(p_array IN VARCHARARRAY)
      RETURN VARCHARLIST;

   FUNCTION arrayToSidsList(p_array IN SIDSARRAY)
      RETURN SIDSLIST;

   PROCEDURE getEmptyCursor(o_cur OUT SYS_REFCURSOR);

   FUNCTION isCurrentRound(p_round_sid IN NUMBER, p_app_id IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION isApplicationInRound(p_app_id IN VARCHAR2, p_round_sid IN NUMBER)
      RETURN NUMBER;

   PROCEDURE isApplicationInRound(p_app_id IN VARCHAR2, p_round_sid IN NUMBER, o_res OUT NUMBER);

   FUNCTION listGetAt(p_list IN VARCHAR2, p_index IN NUMBER, delimiter IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION listApplyExchangeRate(p_list       IN VARCHAR2
                                , p_rate       IN NUMBER
                                , p_delimiter  IN VARCHAR2
                                , p_precision  IN NUMBER DEFAULT 8)
      RETURN VARCHAR2;
END CORE_COMMONS;