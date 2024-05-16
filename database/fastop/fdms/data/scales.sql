/* Formatted on 15-09-2020 13:50:29 (QP5 v5.313) */
REM INSERTING into FASTOP.FDMS_SCALES
SET DEFINE OFF;

INSERT INTO FASTOP.FDMS_SCALES(SCALE_SID
                             , SCALE_ID
                             , DESCR
                             , ORDER_BY
                             , EXPONENT)
     VALUES (1
           , 'UNIT'
           , 'Units'
           , 1
           , 0);

INSERT INTO FASTOP.FDMS_SCALES(SCALE_SID
                             , SCALE_ID
                             , DESCR
                             , ORDER_BY
                             , EXPONENT)
     VALUES (2
           , 'THOUSAND'
           , 'Thousands'
           , 2
           , 3);

INSERT INTO FASTOP.FDMS_SCALES(SCALE_SID
                             , SCALE_ID
                             , DESCR
                             , ORDER_BY
                             , EXPONENT)
     VALUES (3
           , 'MILLION'
           , 'Millions of National Currency'
           , 3
           , 6);

INSERT INTO FASTOP.FDMS_SCALES(SCALE_SID
                             , SCALE_ID
                             , DESCR
                             , ORDER_BY
                             , EXPONENT)
     VALUES (4
           , 'BILLION'
           , 'Billions Of national Currency'
           , 4
           , 9);

INSERT INTO FASTOP.FDMS_SCALES(SCALE_SID, SCALE_ID, DESCR, ORDER_BY)
     VALUES (5, 'GDP', '% GDP', 5);

INSERT INTO FASTOP.FDMS_SCALES(SCALE_SID
                             , SCALE_ID
                             , DESCR
                             , ORDER_BY
                             , EXPONENT)
     VALUES (6
           , 'BILLION_D'
           , 'Billions of dollars'
           , 6
           , 9);

INSERT INTO FASTOP.FDMS_SCALES(SCALE_SID, SCALE_ID, DESCR, ORDER_BY)
     VALUES (7, 'RATE', 'Rate', 7);

INSERT INTO FASTOP.FDMS_SCALES(SCALE_ID, DESCR, ORDER_BY, EXPONENT)
     VALUES ('THOUSAND_NC', 'Thousands Of National Currency', 8, 3);

INSERT INTO FASTOP.FDMS_SCALES(SCALE_ID, DESCR, ORDER_BY, EXPONENT)
     VALUES ('THOUSAND_E', 'Thousands Of EUR', 9, 3);

INSERT INTO FASTOP.FDMS_SCALES(SCALE_ID, DESCR, ORDER_BY, EXPONENT)
     VALUES ('THOUSAND_PPS', 'Thousands of purchasing parity standard units', 10, 3);

INSERT INTO FASTOP.FDMS_SCALES(SCALE_ID, DESCR, ORDER_BY, EXPONENT)
     VALUES ('BILLION_E', 'Billions Of EUR', 11, 9);
/
COMMIT;
