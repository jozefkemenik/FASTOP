/* Formatted on 04-02-2020 12:40:33 (QP5 v5.313) */
CREATE OR REPLACE FORCE VIEW VW_TASK_LOGS
AS
    SELECT L.*, S.TASK_STATUS_ID STEP_STATUS_ID
      FROM TASK_LOGS  L
           JOIN TASK_STATUSES S ON S.TASK_STATUS_SID = L.STEP_STATUS_SID;