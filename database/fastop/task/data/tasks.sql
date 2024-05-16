SET DEFINE OFF;
Insert into TASKS
   (TASK_SID, TASK_ID, DESCR)
 Values
   (1, 'CALCULATION', 'Forecast calculation');
Insert into TASKS
   (TASK_SID, TASK_ID, DESCR)
 Values
   (2, 'VALIDATION', 'Forecast validation');
Insert into TASKS
   (TASK_SID, TASK_ID, DESCR)
 Values
   (3, 'AGGREGATION', 'Forecast aggregates');
Insert into TASKS
   (TASK_SID, TASK_ID, DESCR)
 Values
   (4, 'TCE', 'Forecast TCE');
Insert into TASKS
   (TASK_SID, TASK_ID, DESCR)
 Values
   (5, 'CYCLICAL-ADJUSTMENTS', 'Cyclical adjustments calculation');
Insert into TASKS
   (TASK_SID, TASK_ID, DESCR)
 Values
   (6, 'IEA-CALCULATION', 'International environment assumptions forecast calculation');
Insert into TASKS
   (TASK_SID, TASK_ID, DESCR)
 Values
   (7, 'IEA-AGGREGATION', 'International environment assumptions forecast aggregates');
Insert into TASKS
   (TASK_SID, TASK_ID, DESCR)
Values
   (8, 'OIL-PRICE', 'Oil price calculation');
Insert into TASKS
   (TASK_SID, TASK_ID, DESCR)
Values
   (9, 'KNP', 'Forecast KNP calculation chain');
Insert into TASKS
   (TASK_SID, TASK_ID, DESCR)
Values
   (10, 'WORLD-AGGREGATION', 'Forecast world aggregates');
Insert into TASKS
   (TASK_SID, TASK_ID, DESCR)
Values
   (11, 'ESTAT-Q-LOAD', 'Load Eurostat quarterly data');
Insert into TASKS
   (TASK_SID, TASK_ID, DESCR)
Values
   (12, 'ESTAT-M-LOAD', 'Load Eurostat monthly data');
Insert into TASKS
   (TASK_SID, TASK_ID, DESCR)
Values
   (13, 'ESTAT-A-LOAD', 'Load Eurostat annual data');
Insert into TASKS
   (TASK_SID, TASK_ID, DESCR)
 Values
   (14, 'HICP-DATA-REFRESH', 'HICP Data Refresh');
Insert into TASKS
   (TASK_SID, TASK_ID, DESCR)
 Values
   (15, 'OG-AGGREGATION', 'Output Gap Aggregation');
Insert into TASKS
   (TASK_SID, TASK_ID, DESCR)
 Values
   (16, 'AMECO-UNEMPLOYMENT', 'Ameco unemployment calculation');
Insert into TASKS
   (TASK_SID, TASK_ID, DESCR)
 Values
   (17, 'AMECO-NSI', 'Ameco NSI calculation');
-- EER tasks
Insert into TASKS
   (TASK_SID, TASK_ID, DESCR)
 Values
   (18, 'EER-WEIGHTS', 'EER weights calculation');
Insert into TASKS
   (TASK_SID, TASK_ID, DESCR)
 Values
   (19, 'NEER', 'Neer calculation');
Insert into TASKS
   (TASK_SID, TASK_ID, DESCR)
 Values
   (20, 'REER', 'Reer calculation');
COMMIT;
