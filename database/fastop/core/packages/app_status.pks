/* Formatted on 11/29/2019 13:47:25 (QP5 v5.252.13127.32847) */
CREATE OR REPLACE PACKAGE CORE_APP_STATUS
AS
   /**************************************************************************
    * NAME:      CORE_APP_STATUS
    * PURPOSE:   Common application status setting functionality
    **************************************************************************/

   PROCEDURE setApplicationOpen (p_app_id IN VARCHAR2, o_res OUT NUMBER);

   PROCEDURE setApplicationClosed (p_app_id IN VARCHAR2, o_res OUT NUMBER);

   PROCEDURE setApplicationStatus (p_app_id             IN    VARCHAR2
,                                  p_current_status_id  IN    VARCHAR2
,                                  p_new_status_id      IN    VARCHAR2
,                                  o_res                OUT   NUMBER);

END CORE_APP_STATUS;