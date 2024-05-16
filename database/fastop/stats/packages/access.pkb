CREATE OR REPLACE PACKAGE BODY STATS_ACCESS
AS

   ----------------------------------------------------------------------------
   -- @name logAccess
   ----------------------------------------------------------------------------
   PROCEDURE logAccess(p_user_id   IN      VARCHAR2
                     , p_app       IN      VARCHAR2
                     , p_uri       IN      CLOB
                     , p_ip        IN      VARCHAR2
                     , p_intragate IN      NUMBER
                     , o_res          OUT  NUMBER)
   IS
      l_ip    ACCESS_INFO.LATEST_IP%TYPE := COALESCE(p_ip, '0.0.0.0');
   BEGIN
      o_res := -1;
      UPDATE ACCESS_INFO
         SET URI                = p_uri
           , INTRAGATE          = p_intragate
           , LATEST_IP          = p_ip
           , LATEST_ACCESS_DATE = CURRENT_TIMESTAMP
       WHERE USER_ID = UPPER(p_user_id)
         AND APP = UPPER(p_app)
         AND LATEST_IP = l_ip
         AND TO_DATE(LATEST_ACCESS_DATE, 'YYYY-MM-DD') = TO_DATE(CURRENT_DATE, 'YYYY-MM-DD');

      IF SQL%ROWCOUNT = 0 THEN
         INSERT INTO ACCESS_INFO(USER_ID
                               , APP
                               , URI
                               , INTRAGATE
                               , LATEST_IP)
              VALUES (UPPER(p_user_id)
                    , UPPER(p_app)
                    , p_uri
                    , p_intragate
                    , l_ip);
      END IF;
      o_res := SQL%ROWCOUNT;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;

   END logAccess;

END STATS_ACCESS;
/
