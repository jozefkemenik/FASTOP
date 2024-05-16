/* Formatted on 27/08/2020 12:13:31 (QP5 v5.313) */
SET DEFINE OFF;

INSERT INTO FDMS_DT_COLS(COL_ID, COL_TYPE_SID)
     VALUES ('CODE', 1);

INSERT INTO FDMS_DT_COLS(COL_ID, COL_TYPE_SID, YEAR_VALUE)
     VALUES ('Y-3', 2, -3);

INSERT INTO FDMS_DT_COLS(COL_ID, COL_TYPE_SID, YEAR_VALUE)
     VALUES ('Y-2', 2, -2);

INSERT INTO FDMS_DT_COLS(COL_ID
                       , COL_TYPE_SID
                       , DESCR
                       , YEAR_VALUE
                       , QUARTER)
     VALUES ('Y-1Q1'
           , 2
           , 'I'
           , -1
           , 1);

INSERT INTO FDMS_DT_COLS(COL_ID
                       , COL_TYPE_SID
                       , DESCR
                       , YEAR_VALUE
                       , QUARTER)
     VALUES ('Y-1Q2'
           , 2
           , 'II'
           , -1
           , 2);

INSERT INTO FDMS_DT_COLS(COL_ID
                       , COL_TYPE_SID
                       , DESCR
                       , YEAR_VALUE
                       , QUARTER)
     VALUES ('Y-1Q3'
           , 2
           , 'III'
           , -1
           , 3);

INSERT INTO FDMS_DT_COLS(COL_ID
                       , COL_TYPE_SID
                       , DESCR
                       , YEAR_VALUE
                       , QUARTER)
     VALUES ('Y-1Q4'
           , 2
           , 'IV'
           , -1
           , 4);

INSERT INTO FDMS_DT_COLS(COL_ID
                       , COL_TYPE_SID
                       , DESCR
                       , YEAR_VALUE
                       , QUARTER)
     VALUES ('Y0Q1'
           , 2
           , 'I'
           , 0
           , 1);

INSERT INTO FDMS_DT_COLS(COL_ID
                       , COL_TYPE_SID
                       , DESCR
                       , YEAR_VALUE
                       , QUARTER)
     VALUES ('Y0Q2'
           , 2
           , 'II'
           , 0
           , 2);

INSERT INTO FDMS_DT_COLS(COL_ID
                       , COL_TYPE_SID
                       , DESCR
                       , YEAR_VALUE
                       , QUARTER)
     VALUES ('Y0Q3'
           , 2
           , 'III'
           , 0
           , 3);

INSERT INTO FDMS_DT_COLS(COL_ID
                       , COL_TYPE_SID
                       , DESCR
                       , YEAR_VALUE
                       , QUARTER)
     VALUES ('Y0Q4'
           , 2
           , 'IV'
           , 0
           , 4);

INSERT INTO FDMS_DT_COLS(COL_ID
                       , COL_TYPE_SID
                       , DESCR
                       , YEAR_VALUE
                       , QUARTER)
     VALUES ('Y1Q1'
           , 2
           , 'I'
           , 1
           , 1);

INSERT INTO FDMS_DT_COLS(COL_ID
                       , COL_TYPE_SID
                       , DESCR
                       , YEAR_VALUE
                       , QUARTER)
     VALUES ('Y1Q2'
           , 2
           , 'II'
           , 1
           , 2);

INSERT INTO FDMS_DT_COLS(COL_ID
                       , COL_TYPE_SID
                       , DESCR
                       , YEAR_VALUE
                       , QUARTER)
     VALUES ('Y1Q3'
           , 2
           , 'III'
           , 1
           , 3);

INSERT INTO FDMS_DT_COLS(COL_ID
                       , COL_TYPE_SID
                       , DESCR
                       , YEAR_VALUE
                       , QUARTER)
     VALUES ('Y1Q4'
           , 2
           , 'IV'
           , 1
           , 4);

INSERT INTO FDMS_DT_COLS(COL_ID, COL_TYPE_SID, YEAR_VALUE)
     VALUES ('AY-3', 3, -3);

INSERT INTO FDMS_DT_COLS(COL_ID, COL_TYPE_SID, YEAR_VALUE)
     VALUES ('AY-2', 3, -2);

INSERT INTO FDMS_DT_COLS(COL_ID, COL_TYPE_SID, YEAR_VALUE)
     VALUES ('AY-1', 3, -1);

INSERT INTO FDMS_DT_COLS(COL_ID, COL_TYPE_SID, YEAR_VALUE)
     VALUES ('AY0', 3, 0);

INSERT INTO FDMS_DT_COLS(COL_ID, COL_TYPE_SID, YEAR_VALUE)
     VALUES ('AY1', 3, 1);

INSERT INTO FDMS_DT_COLS(COL_ID, COL_TYPE_SID, YEAR_VALUE)
     VALUES ('BY-3', 4, -3);

INSERT INTO FDMS_DT_COLS(COL_ID, COL_TYPE_SID, YEAR_VALUE)
     VALUES ('BY-2', 4, -2);

INSERT INTO FDMS_DT_COLS(COL_ID, COL_TYPE_SID, YEAR_VALUE)
     VALUES ('BY-1', 4, -1);

INSERT INTO FDMS_DT_COLS(COL_ID, COL_TYPE_SID, YEAR_VALUE)
     VALUES ('BY0', 4, 0);

INSERT INTO FDMS_DT_COLS(COL_ID, COL_TYPE_SID, YEAR_VALUE)
     VALUES ('BY1', 4, 1);


INSERT INTO FDMS_DT_COLS(COL_ID, COL_TYPE_SID , DESCR)
     VALUES ('CODE_DESCR', 1 , 'Description' );


COMMIT;