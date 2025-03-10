/* Formatted on 17-08-2020 17:05:58 (QP5 v5.313) */
SET DEFINE OFF;

INSERT INTO ST_ACTIONS(ACTION_ID, RESULT_STATUS_SID, DESCR)
   SELECT 'submit', STATUS_SID, 'Country submits'
     FROM ST_STATUS_REPO
    WHERE STATUS_ID = 'SUBMIT';

INSERT INTO ST_ACTIONS(ACTION_ID, RESULT_STATUS_SID, DESCR)
   SELECT 'unsubmit', STATUS_SID, 'Country submission revoked'
     FROM ST_STATUS_REPO
    WHERE STATUS_ID = 'ACTIVE';

INSERT INTO ST_ACTIONS(ACTION_ID, RESULT_STATUS_SID, DESCR)
   SELECT 'validate', STATUS_SID, 'Country data is validated'
     FROM ST_STATUS_REPO
    WHERE STATUS_ID = 'VALIDATE';

INSERT INTO ST_ACTIONS(ACTION_ID, RESULT_STATUS_SID, DESCR)
   SELECT 'unvalidate', STATUS_SID, 'Country validation revoked'
     FROM ST_STATUS_REPO
    WHERE STATUS_ID = 'SUBMIT';

INSERT INTO ST_ACTIONS(ACTION_ID, RESULT_STATUS_SID, DESCR)
   SELECT 'accept', STATUS_SID, 'Country data is accepted'
     FROM ST_STATUS_REPO
    WHERE STATUS_ID = 'ACCEPTED';

INSERT INTO ST_ACTIONS(ACTION_ID, RESULT_STATUS_SID, DESCR)
   SELECT 'unaccept', STATUS_SID, 'Country transfer reopened'
     FROM ST_STATUS_REPO
    WHERE STATUS_ID = 'ACTIVE';

INSERT INTO ST_ACTIONS(ACTION_ID, RESULT_STATUS_SID, DESCR)
   SELECT 'reject', STATUS_SID, 'Country data is rejected'
     FROM ST_STATUS_REPO
    WHERE STATUS_ID = 'REJECTED';

INSERT INTO ST_ACTIONS(ACTION_ID, RESULT_STATUS_SID, DESCR)
   SELECT 'archive', STATUS_SID, 'Country data is archived'
     FROM ST_STATUS_REPO
    WHERE STATUS_ID = 'ARCHIVE';

INSERT INTO ST_ACTIONS(ACTION_ID, RESULT_STATUS_SID, DESCR)
   SELECT 'trSubmit', STATUS_SID, 'Country submits TR'
     FROM ST_STATUS_REPO
    WHERE STATUS_ID = 'TR_SUBMIT';

INSERT INTO ST_ACTIONS(ACTION_ID, RESULT_STATUS_SID, DESCR)
   SELECT 'trUnsubmit', STATUS_SID, 'Country TR submission revoked'
     FROM ST_STATUS_REPO
    WHERE STATUS_ID = 'TR_OPEN';

COMMIT;