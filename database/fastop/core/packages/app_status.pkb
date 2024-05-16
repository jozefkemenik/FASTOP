/* Formatted on 11/29/2019 13:47:36 (QP5 v5.252.13127.32847) */
CREATE OR REPLACE PACKAGE BODY CORE_APP_STATUS
AS
   /**************************************************************************
    * NAME:      CORE_APP_STATUS
    * PURPOSE:   Common application status setting functionality
    **************************************************************************/

   PROCEDURE setApplicationStatus (p_app_id             IN    VARCHAR2
,                                  p_current_status_id  IN    VARCHAR2
,                                  p_new_status_id      IN    VARCHAR2
,                                  o_res                OUT   NUMBER)
   IS
      l_app_sid              NUMBER := CORE_GETTERS.getApplicationSid (p_app_id);
      l_current_status_sid   NUMBER := CORE_GETTERS.getStatusSid (p_current_status_id);
      l_new_status_sid       NUMBER := CORE_GETTERS.getStatusSid (p_new_status_id);
   BEGIN
      UPDATE APPLICATIONS
         SET STATUS_SID = l_new_status_sid
,            STATUS_DATE = SYSTIMESTAMP
       WHERE   APP_SID = l_app_sid
           AND STATUS_SID = l_current_status_sid;

      o_res := SQL%ROWCOUNT;
   END setApplicationStatus;

   PROCEDURE setApplicationOpen (p_app_id IN VARCHAR2, o_res OUT NUMBER)
   IS
   BEGIN
      setApplicationStatus(p_app_id, 'CLOSED', 'OPEN', o_res);
   END setApplicationOpen;

   PROCEDURE setApplicationClosed (p_app_id IN VARCHAR2, o_res OUT NUMBER)
   IS
   BEGIN
      setApplicationStatus(p_app_id, 'OPEN', 'CLOSED', o_res);
   END setApplicationClosed;
END CORE_APP_STATUS;
/