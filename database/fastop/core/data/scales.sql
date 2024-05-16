SET DEFINE OFF;
--SQL Statement which produced this data:
--
--  SELECT * FROM SCALES;
--
Insert into SCALES
   (SCALE_SID, SCALE_ID, DESCR, ORDER_BY)
 Values
   (1, 'Millions', 'Millions of national currency', 1);
Insert into SCALES
   (SCALE_SID, SCALE_ID, DESCR, ORDER_BY)
 Values
   (4, 'Billions', 'Billions of national currency', 2);
Insert into SCALES
   (SCALE_SID, SCALE_ID, DESCR, ORDER_BY)
 Values
   (5, 'GDP', '% GDP', 3);
COMMIT;
