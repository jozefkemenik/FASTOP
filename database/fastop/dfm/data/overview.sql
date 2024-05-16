/* Formatted on 12/4/2019 11:54:07 (QP5 v5.252.13127.32847) */
SET DEFINE OFF;

INSERT INTO DFM_OVERVIEW (OVERVIEW_SID
,                         DESCR
,                         CODES
,                         ORDER_BY
,                         OPERATOR
,                         IS_FILTER)
     VALUES (1
,            'GG ONE-OFF MEASURES (REVENUE SIDE)'
,            'UOOMSR,UOOMDR'
,            1
,            '+'
,            0);

INSERT INTO DFM_OVERVIEW (OVERVIEW_SID
,                         DESCR
,                         CODES
,                         ORDER_BY
,                         OPERATOR
,                         IS_FILTER)
     VALUES (2
,            'GG ONE-OFF MEASURES (EXPENDITURE SIDE)'
,            'UOOMSE,UOOMDE'
,            2
,            '-'
,            0);

INSERT INTO DFM_OVERVIEW (OVERVIEW_SID
,                         DESCR
,                         CODES
,                         ORDER_BY
,                         OPERATOR
,                         IS_FILTER)
     VALUES (3
,            'DISCRETIONARY MEASURES CURRENT EXPENDITURE'
,            'UDMGCE,UDMDCE'
,            6
,            'SUM'
,            1);

INSERT INTO DFM_OVERVIEW (OVERVIEW_SID
,                         DESCR
,                         CODES
,                         ORDER_BY
,                         OPERATOR
,                         IS_FILTER)
     VALUES (4
,            'DISCRETIONARY MEASURES CURRENT REVENUE'
,            'UDMGCR,UDMDCR'
,            7
,            'SUM'
,            1);

INSERT INTO DFM_OVERVIEW (OVERVIEW_SID
,                         DESCR
,                         CODES
,                         ORDER_BY
,                         OPERATOR
,                         IS_FILTER)
     VALUES (5
,            'DISCRETIONARY MEASURES CAPITAL EXPENDITURE'
,            'UDMGKE,UDMDKE'
,            8
,            'SUM'
,            1);

INSERT INTO DFM_OVERVIEW (OVERVIEW_SID
,                         DESCR
,                         CODES
,                         ORDER_BY
,                         OPERATOR
,                         IS_FILTER)
     VALUES (6
,            'DISCRETIONARY MEASURES CAPITAL TRANSFERS RECEIVED'
,            'UDMGKTR,UDMDKTR'
,            9
,            'SUM'
,            1);

INSERT INTO DFM_OVERVIEW (OVERVIEW_SID
,                         DESCR
,                         CODES
,                         ORDER_BY
,                         OPERATOR
,                         IS_FILTER)
     VALUES (7
,            'GG ONE-OFF MEASURES (CURRENT EXPENDITURE)'
,            'UOOMSCE,UOOMDCE'
,            3
,            'SUM-'
,            0);

INSERT INTO DFM_OVERVIEW (OVERVIEW_SID
,                         DESCR
,                         CODES
,                         ORDER_BY
,                         OPERATOR
,                         IS_FILTER)
     VALUES (8
,            'GG ONE-OFF MEASURES (GROSS FIXED CAPITAL FORMATION)'
,            'UOOMSIE,UOOMDIE'
,            4
,            'SUM-'
,            0);

INSERT INTO DFM_OVERVIEW (OVERVIEW_SID
,                         DESCR
,                         CODES
,                         ORDER_BY
,                         OPERATOR
,                         IS_FILTER)
     VALUES (9
,            'GG ONE-OFF MEASURES (OTHER CAPITAL EXPENDITURE)'
,            'UOOMSKE,UOOMDKE'
,            5
,            'SUM-'
,            0);

INSERT INTO DFM_OVERVIEW_ESA (OVERVIEW_SID, ESA2010_SID)
   SELECT 7, ESA2010_SID
     FROM DFM_ESA2010 
    WHERE ESA2010_ID IN ('P.2', 'D.1', 'D.29', 'D.2', 'D.31', 'D.39', 'D.3', 'D.4-D.41', 'D.41', 'D.5', 'D.62', 'D.632', 'D.7', 'D.8')
      AND REV_EXP_SID = 1;

INSERT INTO DFM_OVERVIEW_ESA (OVERVIEW_SID, ESA2010_SID)
   SELECT 8, ESA2010_SID 
     FROM DFM_ESA2010 
    WHERE ESA2010_ID IN ('P.51g')
      AND REV_EXP_SID = 1;


INSERT INTO DFM_OVERVIEW_ESA (OVERVIEW_SID, ESA2010_SID)
   SELECT 9, ESA2010_SID 
     FROM DFM_ESA2010 
    WHERE ESA2010_ID IN ('D.9', 'P.52/53', 'NP')
      AND REV_EXP_SID = 1;


COMMIT;