/* Formatted on 04-02-2020 12:38:17 (QP5 v5.313) */
CREATE OR REPLACE FORCE VIEW VW_TASK_RUNS
AS
    SELECT R.*, S.TASK_STATUS_ID
      FROM TASK_RUNS  R
           JOIN TASK_STATUSES S ON S.TASK_STATUS_SID = R.TASK_STATUS_SID;