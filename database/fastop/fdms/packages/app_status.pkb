CREATE OR REPLACE PACKAGE BODY FDMS_APP_STATUS
AS
   PROCEDURE setApplicationClosed (o_res OUT NUMBER)
   IS
   BEGIN
        CORE_APP_STATUS.setApplicationStatus(FDMS_GETTERS.APP_ID, 'ST_CLOSED', 'CLOSED', o_res);
   END setApplicationClosed;
END FDMS_APP_STATUS;
/
