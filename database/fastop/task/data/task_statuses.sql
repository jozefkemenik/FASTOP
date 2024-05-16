SET DEFINE OFF;
Insert into TASK_STATUSES
   (TASK_STATUS_SID, TASK_STATUS_ID, DESCR)
 Values
   (1, 'READY', 'Ready to run');
Insert into TASK_STATUSES
   (TASK_STATUS_SID, TASK_STATUS_ID, DESCR)
 Values
   (2, 'RUNNING', 'Running');
Insert into TASK_STATUSES
   (TASK_STATUS_SID, TASK_STATUS_ID, DESCR)
 Values
   (3, 'SAVING', 'Saving results');
Insert into TASK_STATUSES
   (TASK_STATUS_SID, TASK_STATUS_ID, DESCR)
 Values
   (4, 'DONE', 'Done');
Insert into TASK_STATUSES
   (TASK_STATUS_SID, TASK_STATUS_ID, DESCR)
 Values
   (5, 'ERROR', 'Finished with error');
Insert into TASK_STATUSES
   (TASK_STATUS_SID, TASK_STATUS_ID, DESCR)
 Values
   (6, 'WARNING', 'Finished with warning');
Insert into TASK_STATUSES
   (TASK_STATUS_SID, TASK_STATUS_ID, DESCR)
 Values
   (7, 'ABORT', 'Aborted by user');
COMMIT;
