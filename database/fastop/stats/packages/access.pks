CREATE OR REPLACE PACKAGE STATS_ACCESS
AS
   PROCEDURE logAccess(p_user_id   IN      VARCHAR2
                     , p_app       IN      VARCHAR2
                     , p_uri       IN      CLOB
                     , p_ip        IN      VARCHAR2
                     , p_intragate IN      NUMBER
                     , o_res          OUT  NUMBER);

END STATS_ACCESS;
/
