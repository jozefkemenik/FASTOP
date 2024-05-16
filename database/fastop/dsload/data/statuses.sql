SET DEFINE OFF;
Insert into DSLOAD_STATUSES
   (ORDER_BY, STATUS_ID, DESCR)
 Values
   (1, 'DATASET', 'Start process');
Insert into DSLOAD_STATUSES
   (ORDER_BY, STATUS_ID, DESCR, STATE_CHANGE)
 Values
   (2, 'UPLOADING', 'Start uploading', 1);
Insert into DSLOAD_STATUSES
   (ORDER_BY, STATUS_ID, DESCR, STATE_CHANGE)
 Values
   (3, 'UPLOADED', 'End uploading', 1);
Insert into DSLOAD_STATUSES
   (ORDER_BY, STATUS_ID, DESCR, STATE_CHANGE)
 Values
   (4, 'VALIDATING', 'Start validating', 1);
Insert into DSLOAD_STATUSES
   (ORDER_BY, STATUS_ID, DESCR, STATE_CHANGE)
 Values
   (5, 'VALIDATED', 'End validating', 1);
Insert into DSLOAD_STATUSES
   (ORDER_BY, STATUS_ID, DESCR, STATE_CHANGE)
 Values
   (6, 'PUBLISHING', 'Start publishing', 1);
Insert into DSLOAD_STATUSES
   (ORDER_BY, STATUS_ID, DESCR, STATE_CHANGE)
 Values
   (7, 'PUBLISHED', 'Finished - keep record', 1);
Insert into DSLOAD_STATUSES
   (ORDER_BY, STATUS_ID, DESCR)
 Values
   (8, 'FINISHED', 'Finished - keep record');
Insert into DSLOAD_STATUSES
   (ORDER_BY, STATUS_ID, DESCR)
 Values
   (100, 'CANCELLED', 'Clean up process');
COMMIT;
