SET DEFINE OFF;
--SQL Statement which produced this data:
--
--  SELECT * FROM DFM_PARAMS;
--
Insert into DFM_PARAMS
   (PARAM_ID, DESCR, VALUE)
 Values
   ('START_YEAR', 'Release year', '2008');
Insert into DFM_PARAMS
   (PARAM_ID, DESCR, VALUE)
 Values
   ('MEASURE_DEFAULT_YEAR', 'Default year for a new measure', '2012');
Insert into DFM_PARAMS
   (PARAM_ID, DESCR, VALUE)
 Values
   ('CURRENT_FC', 'Current forecast', '3');
Insert into DFM_PARAMS
   (PARAM_ID, DESCR, VALUE)
 Values
   ('ESA2010_ROUND', 'Round from which esa2010 are used', '76');
Insert into DFM_PARAMS
   (PARAM_ID, DESCR, VALUE)
 Values
   ('ONE_OFF_TYPES_ENABLED_ROUND', 'Round from which new one_off_types are used', '76');
Insert into DFM_PARAMS
   (PARAM_ID, DESCR, VALUE)
 Values
   ('CURRENT_CUST_STORAGE', 'current custom storage text', '1');
COMMIT;
