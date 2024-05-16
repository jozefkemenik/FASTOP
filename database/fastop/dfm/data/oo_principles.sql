/* Formatted on 12/4/2019 11:55:47 (QP5 v5.252.13127.32847) */
SET DEFINE OFF;

INSERT INTO DFM_OO_PRINCIPLES (OO_PRINCIPLE_SID
,                              OO_PRINCIPLE_ID
,                              DESCR
,                              ORDER_BY)
        VALUES (
                  1
,                 '1a'
,                 'Measures creating short-term benefits accompanied by a significant reduction in government assets or a build-up of future liabilities'
,                 1);

INSERT INTO DFM_OO_PRINCIPLES (OO_PRINCIPLE_SID
,                              OO_PRINCIPLE_ID
,                              DESCR
,                              ORDER_BY)
        VALUES (
                  2
,                 '1b'
,                 'Measures entailing short-term lump-sum benefits at the expense of a recurrent future cost'
,                 2);

INSERT INTO DFM_OO_PRINCIPLES (OO_PRINCIPLE_SID
,                              OO_PRINCIPLE_ID
,                              DESCR
,                              ORDER_BY)
        VALUES (
                  3
,                 '1c'
,                 'Measures implying a change in the timing of revenue or expenditure that create a temporary peak in revenue or expenditure patterns'
,                 3);

INSERT INTO DFM_OO_PRINCIPLES (OO_PRINCIPLE_SID
,                              OO_PRINCIPLE_ID
,                              DESCR
,                              ORDER_BY)
        VALUES (
                  4
,                 '1d'
,                 'Measures introduced in direct response to "exceptional events" and that have a very short-term impact'
,                 4);

-- TODO: This option is to be either deleted or hidden (FASTOP-357)
INSERT INTO DFM_OO_PRINCIPLES (OO_PRINCIPLE_SID
,                              OO_PRINCIPLE_ID
,                              DESCR
,                              ORDER_BY)
        VALUES (
                  5
,                 '5'
,                 'Only measures having a significant impact on the general government balance should be considered one-offs'
,                 5);

INSERT INTO DFM_OO_PRINCIPLES (OO_PRINCIPLE_SID
,                              OO_PRINCIPLE_ID
,                              DESCR
,                              ORDER_BY)
     VALUES (6
,            '0'
,            'Other - See "Comments on One-offs" field for explaination'
,            6);

COMMIT;