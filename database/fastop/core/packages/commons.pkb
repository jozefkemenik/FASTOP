/* Formatted on 26-Sep-22 17:52:52 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY CORE_COMMONS
AS
   ----------------------------------------------------------------------------
   -- @name arrayToList
   ----------------------------------------------------------------------------
   FUNCTION arrayToList(p_array IN VARCHARARRAY)
      RETURN VARCHARLIST
   AS
      l_list  VARCHARLIST := VARCHARLIST();
   BEGIN
      IF p_array IS NOT NULL THEN
         l_list.EXTEND(p_array.COUNT);

         FOR i IN 1 .. p_array.COUNT LOOP
            l_list(i) := p_array(i);
         END LOOP;
      END IF;

      RETURN l_list;
   END arrayToList;

   ----------------------------------------------------------------------------
   -- @name arrayToSidsList
   ----------------------------------------------------------------------------
   FUNCTION arrayToSidsList(p_array IN SIDSARRAY)
      RETURN SIDSLIST
   AS
      l_list  SIDSLIST := SIDSLIST();
   BEGIN
      IF p_array IS NOT NULL THEN
         l_list.EXTEND(p_array.COUNT);

         FOR i IN 1 .. p_array.COUNT LOOP
            l_list(i) := p_array(i);
         END LOOP;
      END IF;

      RETURN l_list;
   END arrayToSidsList;

   ----------------------------------------------------------------------------
   -- @name getEmptyCursor
   ----------------------------------------------------------------------------
   PROCEDURE getEmptyCursor(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR SELECT *
                       FROM DUAL
                      WHERE 1 = 2;
   END getEmptyCursor;

   ----------------------------------------------------------------------------
   -- @name isCurrentRound - function used to verify if passed in
   --    parameter corresponds to the current round
   -- @return 1 if ok, 0 if failed
   ----------------------------------------------------------------------------
   FUNCTION isCurrentRound(p_round_sid IN NUMBER, p_app_id IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
   BEGIN
      RETURN CASE CORE_GETTERS.getCurrentRoundSid(p_app_id) WHEN p_round_sid THEN 1 ELSE 0 END;
   END isCurrentRound;

   FUNCTION isApplicationInRound(p_app_id IN VARCHAR2, p_round_sid IN NUMBER)
      RETURN NUMBER
   IS
      l_res  NUMBER;
   BEGIN
      SELECT COUNT(*)
        INTO l_res
        FROM ROUND_APPLICATIONS R JOIN APPLICATIONS A ON R.APP_SID = A.APP_SID
       WHERE R.ROUND_SID = p_round_sid AND UPPER(A.APP_ID) = UPPER(p_app_id);

      RETURN l_res;
   END isApplicationInRound;

   PROCEDURE isApplicationInRound(p_app_id IN VARCHAR2, p_round_sid IN NUMBER, o_res OUT NUMBER)
   IS
   BEGIN
      o_res := isApplicationInRound(p_app_id, p_round_sid);
   END isApplicationInRound;

   ----------------------------------------------------------------------------
   -- @name listGetAt
   --    p_list : the list to search on
   --    p_index : the index of returned element (start at 0)
   --    delimiter : delimiter of the list
   -- @return the element (varchar2) at the index of the list or null if error/invalid
   ----------------------------------------------------------------------------
   FUNCTION listGetAt(p_list IN VARCHAR2, p_index IN NUMBER, delimiter IN VARCHAR2)
      RETURN VARCHAR2
   IS
      start_pos  NUMBER;
      nb_char    NUMBER;
   BEGIN
      -- if index < 0  or p_list empty or if out of range => return null
      IF p_index < 0 OR LENGTH(p_list) = 0 OR INSTR(p_list || delimiter, delimiter, p_index + 1) = 0 THEN
         RETURN NULL;
      END IF;

      -- get start position
      IF p_index = 0 THEN
         start_pos := 1;
      ELSE
         start_pos := INSTR(p_list, delimiter, 1, p_index) + 1;
      END IF;

      -- get the length of the element (add delimiter to end of list to avoid problem with last)
      nb_char := INSTR(p_list || delimiter, delimiter, 1, p_index + 1) - start_pos;

      RETURN SUBSTR(p_list, start_pos, nb_char);
   END listGetAt;

   ----------------------------------------------------------------------------
   -- @name listApplyExchangeRate
   --    p_list : the list (delimitered string), to apply the exchange rate on
   --    p_rate : exchange rate to apply
   --    p_delimiter : delimiter of the list
   --    p_precision : number of decimal places in the result list
   -- @return the list with applied exchange rate
   ----------------------------------------------------------------------------
   FUNCTION listApplyExchangeRate(p_list       IN VARCHAR2
                                , p_rate       IN NUMBER
                                , p_delimiter  IN VARCHAR2
                                , p_precision  IN NUMBER DEFAULT 8)
      RETURN VARCHAR2
   IS
      l_input     VARCHAR2(4000) := p_list;
      l_result    VARCHAR2(4000);
      l_last_dem  NUMBER(4);
      l_value     NUMBER;
   BEGIN
      WHILE LENGTH(l_input) > 0 LOOP
         l_last_dem := INSTR(l_input, p_delimiter, -1);
         l_value := TO_NUMBER(SUBSTR(l_input, l_last_dem + 1));

         l_result := p_delimiter || TO_CHAR(ROUND(l_value * p_rate, p_precision)) || l_result;

         IF l_last_dem = 1 THEN
            l_result := p_delimiter || l_result;
         END IF;

         l_input := SUBSTR(l_input, 1, l_last_dem - 1);
      END LOOP;

      RETURN SUBSTR(l_result, 2);
   END listApplyExchangeRate;
END CORE_COMMONS;