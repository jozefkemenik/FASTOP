SET DEFINE OFF;
Insert into PERIODS
   (PERIOD_SID, PERIOD_ID, DESCR, ORDER_PERIOD, ROUND_TYPE, IS_FULL,
    START_DATE, END_DATE)
 Values
   (1, 'SPR', 'Spring', 1, 'N', 'Y',
    '03/21', '06/20');
Insert into PERIODS
   (PERIOD_SID, PERIOD_ID, DESCR, ORDER_PERIOD, ROUND_TYPE, 
    START_DATE, END_DATE)
 Values
   (2, 'SUM', 'Summer', 2, 'N', 
    '06/21', '09/20');
Insert into PERIODS
   (PERIOD_SID, PERIOD_ID, DESCR, ORDER_PERIOD, ROUND_TYPE, IS_FULL,
    START_DATE, END_DATE)
 Values
   (3, 'AUT', 'Autumn', 3, 'N', 'Y',
    '09/21', '12/20');
Insert into PERIODS
   (PERIOD_SID, PERIOD_ID, DESCR, ORDER_PERIOD, ROUND_TYPE, 
    START_DATE, END_DATE)
 Values
   (4, 'WIN', 'Winter', 4, 'N', 
    '12/21', '03/20');
Insert into PERIODS
   (PERIOD_SID, PERIOD_ID, DESCR, ORDER_PERIOD, ROUND_TYPE, 
    START_DATE, END_DATE)
 Values
   (5, 'CUS', 'Custom period', 5, 'C', 
    '01/01', '12/31');
Insert into PERIODS
   (PERIOD_SID, PERIOD_ID, DESCR, ORDER_PERIOD, ROUND_TYPE, 
    START_DATE, END_DATE)
 Values
   (6, 'ANN', 'Annual', 6, 'C', 
    '01/01', '12/31');
COMMIT;
