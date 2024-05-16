CREATE OR REPLACE PACKAGE BODY FPLAKE_GETTERS
AS

   ----------------------------------------------------------------------------
   -- @name getLakes
   ----------------------------------------------------------------------------
   PROCEDURE getLakes(o_cur         OUT SYS_REFCURSOR
                    , p_provider IN     VARCHAR2 DEFAULT NULL
                    , p_dataflow IN     VARCHAR2 DEFAULT NULL
   )
   IS
   BEGIN
        OPEN o_cur FOR
            SELECT
                   S.SERVICE_ID
                 , S.URL
                 , L.PROVIDER
                 , L.DATAFLOW
              FROM FPLAKES L
              JOIN FPLAKE_SERVICES S
                ON L.SERVICE_SID = S.SERVICE_SID
             WHERE (p_provider IS NULL OR UPPER(p_provider) = UPPER(L.PROVIDER))
               AND (p_dataflow IS NULL OR UPPER(p_dataflow) = UPPER(L.DATAFLOW));
   END getLakes;


END FPLAKE_GETTERS;
/
