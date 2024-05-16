SET DEFINE OFF;
Insert into ST_STATUS_REPO
   (STATUS_SID, STATUS_ID, DESCR, APP_DESCR, TR_DESCR)
 Values
   (1, 'ACTIVE', 'Active', 'Active', 'N/A');
Insert into ST_STATUS_REPO
   (STATUS_SID, STATUS_ID, DESCR, APP_DESCR, TR_DESCR)
 Values
   (2, 'SUBMIT', 'Submitted', 'Submitted', 'N/A');
Insert into ST_STATUS_REPO
   (STATUS_SID, STATUS_ID, DESCR, APP_DESCR, TR_DESCR)
 Values
   (3, 'ARCHIVE', 'Archived', 'Archived', 'N/A');
Insert into ST_STATUS_REPO
   (STATUS_SID, STATUS_ID, DESCR, APP_DESCR, TR_DESCR)
 Values
   (4, 'PUBLISH', 'Published', 'Archived', 'N/A');
Insert into ST_STATUS_REPO
   (STATUS_SID, STATUS_ID, DESCR, APP_DESCR, TR_DESCR)
 Values
   (5, 'TR_OPEN', 'Transparency Report Open', 'Archived', 'Open');
Insert into ST_STATUS_REPO
   (STATUS_SID, STATUS_ID, DESCR, APP_DESCR, TR_DESCR)
 Values
   (6, 'TR_SUBMIT', 'Transparency Report Submitted', 'Archived', 'Submitted');
Insert into ST_STATUS_REPO
   (STATUS_SID, STATUS_ID, DESCR, APP_DESCR, TR_DESCR)
 Values
   (7, 'TR_PUBLISH', 'Transparency Report Published', 'Archived', 'Published');
Insert into ST_STATUS_REPO
   (STATUS_SID, STATUS_ID, DESCR, APP_DESCR, TR_DESCR)
 Values
   (8, 'OPEN', 'Open', 'Open', 'N/A');
Insert into ST_STATUS_REPO
   (STATUS_SID, STATUS_ID, DESCR, APP_DESCR, TR_DESCR)
 Values
   (9, 'CLOSED', 'Closed', 'Closed', 'N/A');
Insert into ST_STATUS_REPO
   (STATUS_SID, STATUS_ID, DESCR, APP_DESCR, TR_DESCR)
 Values
   (10, 'VALIDATE', 'Validated', 'Validated', 'N/A');
Insert into ST_STATUS_REPO
   (STATUS_SID, STATUS_ID, DESCR, APP_DESCR, TR_DESCR)
 Values
   (11, 'ACCEPTED', 'Accepted', 'Accepted', NULL);
Insert into ST_STATUS_REPO
   (STATUS_SID, STATUS_ID, DESCR, APP_DESCR, TR_DESCR)
 Values
   (12, 'REJECTED', 'Rejected', 'Rejected', NULL);
Insert into ST_STATUS_REPO
   (STATUS_SID, STATUS_ID, DESCR, APP_DESCR, TR_DESCR)
 Values
   (13, 'ST_CLOSED', 'Final storage closed', 'Final storage closed', NULL);
COMMIT;
