CREATE OR REPLACE PACKAGE BODY FPADMIN_LOG
AS
   ----------------------------------------------------------------------------
   -- @name getAccessLogs
   ----------------------------------------------------------------------------
   PROCEDURE getAccessLogs(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
        SELECT USER_ID
             , APP
             , URI
             , INTRAGATE
             , LATEST_IP
             , LATEST_ACCESS_DATE
         FROM ACCESS_INFO;
   END getAccessLogs;

END FPADMIN_LOG;
/
