/* Formatted on 25-08-2020 22:08:14 (QP5 v5.313) */
SET DEFINE OFF;

INSERT INTO FDMS_DT_LINE_TYPES(LINE_TYPE_SID, LINE_TYPE_ID, DESCR)
     VALUES (1, 'YEAR', 'Header year');

INSERT INTO FDMS_DT_LINE_TYPES(LINE_TYPE_SID, LINE_TYPE_ID, DESCR)
     VALUES (2, 'QUARTER', 'Header quarter');

INSERT INTO FDMS_DT_LINE_TYPES(LINE_TYPE_SID, LINE_TYPE_ID, DESCR)
     VALUES (3, 'HEADER', 'Custom header');

INSERT INTO FDMS_DT_LINE_TYPES(LINE_TYPE_SID, LINE_TYPE_ID, DESCR)
     VALUES (4, 'DATA', 'Data line');

COMMIT;