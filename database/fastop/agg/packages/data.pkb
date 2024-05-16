CREATE OR REPLACE PACKAGE BODY AGG_DATA
AS
   /******************************************************************************
      NAME:       AGG_DATA
   ******************************************************************************/

   ----------------------------------------------------------------------------
   -- @name saveAggLines
   ----------------------------------------------------------------------------
    PROCEDURE saveAggLines ( p_round_sid   IN     NUMBER
,                            p_area        IN     VARCHAR2
,                            p_variables   IN     VECTORARRAY
,                            p_user        IN     VARCHAR2
,                            o_res         OUT    NUMBER)
    IS
      l_vector      VECTOROBJECT;
    BEGIN
      o_res := 0;

      FOR i IN 1 .. p_variables.COUNT LOOP
         l_vector   := p_variables(i);

         UPDATE AGG_LINE_DATA
            SET       START_YEAR = l_vector.START_YEAR
              ,           VECTOR = l_vector.VECTOR
              , LAST_CHANGE_USER = p_user
              , LAST_CHANGE_DATE = CURRENT_TIMESTAMP
          WHERE ROUND_SID  = p_round_sid
            AND   LINE_ID  = l_vector.VARIABLE_ID
            AND COUNTRY_ID = p_area;

         IF SQL%ROWCOUNT <= 0 THEN
            INSERT INTO AGG_LINE_DATA (ROUND_SID
            ,                          LINE_ID
            ,                          COUNTRY_ID
            ,                          START_YEAR
            ,                          VECTOR
            ,                          LAST_CHANGE_USER
            ,                          LAST_CHANGE_DATE)
            VALUES (p_round_sid
            ,       l_vector.VARIABLE_ID
            ,       p_area
            ,       l_vector.START_YEAR
            ,       l_vector.VECTOR
            ,       p_user
            ,       CURRENT_TIMESTAMP);
         END IF;

         o_res := o_res + 1;
      END LOOP;
    END saveAggLines;

   ----------------------------------------------------------------------------
   -- @name saveAggIndicators
   ----------------------------------------------------------------------------
   PROCEDURE saveAggIndicators ( p_round_sid   IN     NUMBER
,                                p_area        IN     VARCHAR2
,                                p_variables   IN     VECTORARRAY
,                                p_user        IN     VARCHAR2
,                                o_res         OUT    NUMBER)
    IS
      l_vector      VECTOROBJECT;
    BEGIN
      o_res := 0;

      FOR i IN 1 .. p_variables.COUNT LOOP
         l_vector   := p_variables(i);

         UPDATE AGG_INDICATOR_DATA
            SET       START_YEAR = l_vector.START_YEAR
              ,           VECTOR = l_vector.VECTOR
              , LAST_CHANGE_USER = p_user
              , LAST_CHANGE_DATE = CURRENT_TIMESTAMP
          WHERE     ROUND_SID = p_round_sid
            AND INDICATOR_SID = (SELECT INDICATOR_SID FROM INDICATORS WHERE INDICATOR_ID = l_vector.VARIABLE_ID)
            AND    COUNTRY_ID = p_area;

         IF SQL%ROWCOUNT <= 0 THEN
            INSERT INTO AGG_INDICATOR_DATA (ROUND_SID
            ,                               INDICATOR_SID
            ,                               COUNTRY_ID
            ,                               START_YEAR
            ,                               VECTOR
            ,                               LAST_CHANGE_USER
            ,                               LAST_CHANGE_DATE)
            SELECT p_round_sid
            ,      INDICATOR_SID
            ,      p_area
            ,      l_vector.START_YEAR
            ,      l_vector.VECTOR
            ,      p_user
            ,      CURRENT_TIMESTAMP
              FROM INDICATORS
             WHERE INDICATOR_ID = l_vector.VARIABLE_ID;
         END IF;

         o_res := o_res + 1;
      END LOOP;
    END saveAggIndicators;

END AGG_DATA;
