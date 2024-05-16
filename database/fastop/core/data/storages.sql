/* Formatted on 11/29/2019 13:21:09 (QP5 v5.252.13127.32847) */
SET DEFINE OFF;

ALTER TABLE STORAGES DISABLE CONSTRAINT STORAGES_NEXT_FK;

INSERT INTO STORAGES (STORAGE_SID
,                     STORAGE_ID
,                     DESCR
,                     IS_PERMANENT
,                     ORDER_BY
,                     NEXT_STORAGE_SID)
     VALUES (1
,            'TCE1'
,            'TCE1'
,            'N'
,            1
,            2);


INSERT INTO STORAGES (STORAGE_SID
,                     STORAGE_ID
,                     DESCR
,                     ALT_DESCR
,                     IS_PERMANENT
,                     ORDER_BY
,                     NEXT_STORAGE_SID
,                     IS_FULL)
     VALUES (2
,            'FIRST'
,            'First Storage'
,            '/TCE2'
,            'N'
,            2
,            3
,            'Y');

INSERT INTO STORAGES (STORAGE_SID
,                     STORAGE_ID
,                     DESCR
,                     IS_PERMANENT
,                     ORDER_BY
,                     NEXT_STORAGE_SID)
     VALUES (3
,            'TCE3'
,            'TCE3'
,            'N'
,            3
,            4);

INSERT INTO STORAGES (STORAGE_SID
,                     STORAGE_ID
,                     DESCR
,                     ALT_DESCR
,                     IS_PERMANENT
,                     ORDER_BY
,                     NEXT_STORAGE_SID
,                     IS_FULL)
     VALUES (4
,            'SECOND'
,            'Second Storage'
,            '/TCE4'
,            'N'
,            4
,            5
,            'Y');

INSERT INTO STORAGES (STORAGE_SID
,                     STORAGE_ID
,                     DESCR
,                     IS_PERMANENT
,                     ORDER_BY
,                     NEXT_STORAGE_SID)
     VALUES (5
,            'TCE5'
,            'TCE5'
,            'N'
,            5
,            6);

INSERT INTO STORAGES (STORAGE_SID
,                     STORAGE_ID
,                     DESCR
,                     ALT_DESCR
,                     IS_PERMANENT
,                     ORDER_BY
,                     IS_FULL)
     VALUES (6
,            'FINAL'
,            'Final Storage'
,            '/TCE6'
,            'Y'
,            6
,            'Y');

INSERT INTO STORAGES (STORAGE_SID
,                     STORAGE_ID
,                     DESCR
,                     IS_PERMANENT
,                     ORDER_BY
,                     IS_CUSTOM)
     VALUES (7
,            'CUST'
,            'Custom Storage'
,            'Y'
,            -1
,            'Y');

INSERT INTO STORAGES (STORAGE_SID
,                     STORAGE_ID
,                     DESCR
,                     IS_PERMANENT
,                     ORDER_BY
,                     IS_CUSTOM)
     VALUES (8
,            'IEA'
,            'International Environment Assumptions'
,            'N'
,            7
,            'N');

ALTER TABLE STORAGES ENABLE CONSTRAINT STORAGES_NEXT_FK;

COMMIT;