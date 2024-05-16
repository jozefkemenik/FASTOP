/* Formatted on 12/2/2019 17:30:07 (QP5 v5.252.13127.32847) */
CREATE OR REPLACE PACKAGE BODY IDR_SEMI_ELASTICITY
AS
   PROCEDURE storeSemiElasticity (
      o_res            OUT NUMBER
,     p_app_id      IN     VARCHAR2
,     p_round_sid   IN     NUMBER
,     p_countries   IN     CORE_COMMONS.VARCHARARRAY
,     p_values      IN     CORE_COMMONS.SIDSARRAY)
   IS
   BEGIN
      o_res := 0;

      IF CORE_GETTERS.getApplicationStatus (p_app_id) != 'ARCHIVE'
      THEN
         FOR i IN 1 .. p_values.COUNT
         LOOP
            -- Update existing record
            UPDATE SEMI_ELASTICS
               SET VALUE = p_values (i)
             WHERE ROUND_SID = p_round_sid AND COUNTRY_ID = p_countries (i);

            -- If there was no record yet try to insert a new one
            IF SQL%ROWCOUNT = 0
            THEN
               INSERT INTO SEMI_ELASTICS (ROUND_SID, COUNTRY_ID, VALUE)
                    VALUES (p_round_sid, p_countries (i), p_values (i));
            END IF;

            o_res := o_res + SQL%ROWCOUNT;
         END LOOP;
      ELSE
         o_res := -1;
      END IF;
   END storeSemiElasticity;
   
   ----------------------------------------------------------------------------
   -- @name getLastSemiElasticityRound
   ----------------------------------------------------------------------------
   FUNCTION getLastSemiElasticityRound RETURN NUMBER
   IS
      o_round_sid NUMBER;
   BEGIN
      SELECT ROUND_SID 
         INTO o_round_sid
         FROM ( SELECT R.ROUND_SID
                     , ROW_NUMBER() OVER (ORDER BY R.YEAR DESC, R.ORDER_PERIOD DESC) AS row_num
                  FROM SEMI_ELASTICS SE 
                  JOIN VW_ROUNDS R ON se.ROUND_SID = R.ROUND_SID
               ) t
      WHERE t.row_num = 1;

      RETURN o_round_sid;

   END getLastSemiElasticityRound;

   ----------------------------------------------------------------------------
   -- @name getLatestSemiElasticity
   ----------------------------------------------------------------------------
   PROCEDURE getLatestSemiElasticity (
      o_cur       OUT SYS_REFCURSOR)
   IS
      last_round_sid NUMBER := getLastSemiElasticityRound();
   BEGIN
      
      OPEN o_cur FOR
         SELECT se.ROUND_SID
               , se.VALUE
               , r.YEAR
               , r.DESCR as ROUND_DESCR
               , r.PERIOD_DESCR
               , se.COUNTRY_ID
               , c.DESCR as COUNTRY_DESCR
            FROM SEMI_ELASTICS se
            JOIN VW_ROUNDS r ON se.ROUND_SID = r.ROUND_SID
            JOIN GEO_AREAS c ON c.GEO_AREA_ID = se.COUNTRY_ID
            WHERE se.ROUND_SID = last_round_sid
            ORDER BY c.ORDER_BY;

   END getLatestSemiElasticity;
    
END IDR_SEMI_ELASTICITY;