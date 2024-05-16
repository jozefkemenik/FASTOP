/* Formatted on 12/4/2019 14:10:57 (QP5 v5.252.13127.32847) */
SET DEFINE OFF;
--SQL Statement which produced this data:
--
--  SELECT * FROM DBP_ADOPT_STATUS;
--

INSERT INTO DBP_ADOPT_STATUS (ADOPT_STATUS_SID, DESCR, ORDER_BY)
     VALUES (1, 'Already adopted', 1);

INSERT INTO DBP_ADOPT_STATUS (ADOPT_STATUS_SID, DESCR, ORDER_BY)
     VALUES (2, 'Not yet adopted but credibly planned', 2);

INSERT INTO DBP_ADOPT_STATUS (ADOPT_STATUS_SID, DESCR, ORDER_BY)
        VALUES (
                  3
,                 'Included in revenue projections but not known with sufficient details'
,                 3);

COMMIT;