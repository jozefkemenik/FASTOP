
SET DEFINE OFF;
-- ROOT
Insert into FASTOP.ADDIN_TREE (DASHBOARD_SID,TITLE,TREE_SID,PARENT_TREE_SID,JSON_DATA) 
values (null,'Public databases',1,null,'{"color":"#121b63","icon":"pi pi-home"}');

Insert into FASTOP.ADDIN_TREE (DASHBOARD_SID,TITLE,TREE_SID,PARENT_TREE_SID,JSON_DATA) 
values (null,'Restricted databases',2,null,'{"color":"#910f41","icon":"pi pi-home"}');
-- LEVEL 1
Insert into FASTOP.ADDIN_TREE (DASHBOARD_SID,TITLE,TREE_SID,PARENT_TREE_SID,JSON_DATA) 
values (null,'ECFIN sources',3,1,'{"color":"#126312","icon":"pi pi-database"}');

Insert into FASTOP.ADDIN_TREE (DASHBOARD_SID,TITLE,TREE_SID,PARENT_TREE_SID,JSON_DATA) 
values (null,'National sources',4,1,'{"color":"#631258","icon":"pi pi-database"}');

Insert into FASTOP.ADDIN_TREE (DASHBOARD_SID,TITLE,TREE_SID,PARENT_TREE_SID,JSON_DATA)
values (null,'International/European sources',5,1,'{"color":"#8f8518","icon":"pi pi-database"}');

Insert into FASTOP.ADDIN_TREE (DASHBOARD_SID,TITLE,TREE_SID,PARENT_TREE_SID,JSON_DATA) 
values (null,'AMECO',6,2,'{"color":"#0f1391","icon":"pi pi-database"}');

Insert into FASTOP.ADDIN_TREE (DASHBOARD_SID,TITLE,TREE_SID,PARENT_TREE_SID,JSON_DATA) 
values (null,'FORECAST/TCE',7,2,'{"color":"#540f91","icon":"pi pi-database"}');

Insert into FASTOP.ADDIN_TREE (DASHBOARD_SID,TITLE,TREE_SID,PARENT_TREE_SID,JSON_DATA) 
values (null,'Output Gaps',8,2,'{"color":"#0a6924","icon":"pi pi-database"}');

Insert into FASTOP.ADDIN_TREE (DASHBOARD_SID,TITLE,TREE_SID,PARENT_TREE_SID,JSON_DATA) 
values (null,'Exchange rates',9,2,'{"color":"#70430c","icon":"pi pi-database"}');
-- LEVEL 2
Insert into FASTOP.ADDIN_TREE (DASHBOARD_SID,TITLE,TREE_SID,PARENT_TREE_SID,JSON_DATA) 
values ((Select DASHBOARD_SID From ADDIN_DASHBOARD Where DASHBOARD_ID = 'bcs'),'BCS (Business and consumerSurveys)',10,3,'{"color":"#126312","icon":"pi pi-list"}');

Insert into FASTOP.ADDIN_TREE (DASHBOARD_SID,TITLE,TREE_SID,PARENT_TREE_SID,JSON_DATA) 
values ((Select DASHBOARD_SID From ADDIN_DASHBOARD Where DASHBOARD_ID = 'ameco_internal_annex'),'Ameco Internal - Annex',11,3,'{"color":"#126312","icon":"pi pi-list"}');

Insert into FASTOP.ADDIN_TREE (DASHBOARD_SID,TITLE,TREE_SID,PARENT_TREE_SID,JSON_DATA) 
values ((Select DASHBOARD_SID From ADDIN_DASHBOARD Where DASHBOARD_ID = 'ameco_internal_current'),'Ameco Internal - Current',12,3,'{"color":"#126312","icon":"pi pi-list"}');

Insert into FASTOP.ADDIN_TREE (DASHBOARD_SID,TITLE,TREE_SID,PARENT_TREE_SID,JSON_DATA) 
values ((Select DASHBOARD_SID From ADDIN_DASHBOARD Where DASHBOARD_ID = 'forecast_archived'),'Forecast - Archived',13,3,'{"color":"#126312","icon":"pi pi-list"}');

Insert into FASTOP.ADDIN_TREE (DASHBOARD_SID,TITLE,TREE_SID,PARENT_TREE_SID,JSON_DATA) 
values ((Select DASHBOARD_SID From ADDIN_DASHBOARD Where DASHBOARD_ID = 'output_gap_archived'),'Output-gap - Aarchived',14,3,'{"color":"#126312","icon":"pi pi-list"}');

Insert into FASTOP.ADDIN_TREE (DASHBOARD_SID,TITLE,TREE_SID,PARENT_TREE_SID,JSON_DATA) 
values ((Select DASHBOARD_SID From ADDIN_DASHBOARD Where DASHBOARD_ID = 'tce_archived'),'TCE - archived',15,3,'{"color":"#126312","icon":"pi pi-list"}');

Insert into FASTOP.ADDIN_TREE (DASHBOARD_SID,TITLE,TREE_SID,PARENT_TREE_SID,JSON_DATA) 
values ((Select DASHBOARD_SID From ADDIN_DASHBOARD Where DASHBOARD_ID = 'bos'),'Bank of Spain',16,4,'{"color":"#631258","icon":"pi pi-list"}');

Insert into FASTOP.ADDIN_TREE (DASHBOARD_SID,TITLE,TREE_SID,PARENT_TREE_SID,JSON_DATA) 
values ((Select DASHBOARD_SID From ADDIN_DASHBOARD Where DASHBOARD_ID = 'ecb'),'ECB (European Central Bank',17,5,'{"color":"#8f8518","icon":"pi pi-list"}');

Insert into FASTOP.ADDIN_TREE (DASHBOARD_SID,TITLE,TREE_SID,PARENT_TREE_SID,JSON_DATA) 
values ((Select DASHBOARD_SID From ADDIN_DASHBOARD Where DASHBOARD_ID = 'eurostat'),'Eurostat',18,5,'{"color":"#8f8518","icon":"pi pi-list"}');

Insert into FASTOP.ADDIN_TREE (DASHBOARD_SID,TITLE,TREE_SID,PARENT_TREE_SID,JSON_DATA) 
values ((Select DASHBOARD_SID From ADDIN_DASHBOARD Where DASHBOARD_ID = 'dbnomics'),'DB.Nomics',19,5,'{"color":"#8f8518","icon":"pi pi-list"}');

Insert into FASTOP.ADDIN_TREE (DASHBOARD_SID,TITLE,TREE_SID,PARENT_TREE_SID,JSON_DATA) 
values ((Select DASHBOARD_SID From ADDIN_DASHBOARD Where DASHBOARD_ID = 'ameco_internal_restricted'),'Ameco Internal - Restricted',20,6,'{"color":"#0f1391","icon":"pi pi-list"}');

Insert into FASTOP.ADDIN_TREE (DASHBOARD_SID,TITLE,TREE_SID,PARENT_TREE_SID,JSON_DATA) 
values ((Select DASHBOARD_SID From ADDIN_DASHBOARD Where DASHBOARD_ID = 'ameco_historical'),'Ameco historical',21,6,'{"color":"#0f1391","icon":"pi pi-list"}');

Insert into FASTOP.ADDIN_TREE (DASHBOARD_SID,TITLE,TREE_SID,PARENT_TREE_SID,JSON_DATA) 
values ((Select DASHBOARD_SID From ADDIN_DASHBOARD Where DASHBOARD_ID = 'forecast_current'),'Forecast - current',22,7,'{"color":"#540f91","icon":"pi pi-list"}');

Insert into FASTOP.ADDIN_TREE (DASHBOARD_SID,TITLE,TREE_SID,PARENT_TREE_SID,JSON_DATA) 
values ((Select DASHBOARD_SID From ADDIN_DASHBOARD Where DASHBOARD_ID = 'tce_current'),'TCE - current',23,7,'{"color":"#540f91","icon":"pi pi-list"}');

Insert into FASTOP.ADDIN_TREE (DASHBOARD_SID,TITLE,TREE_SID,PARENT_TREE_SID,JSON_DATA) 
values ((Select DASHBOARD_SID From ADDIN_DASHBOARD Where DASHBOARD_ID = 'output_gap_current'),'Output-gap:current',24,8,'{"color":"#0a6924","icon":"pi pi-list"}');

Insert into FASTOP.ADDIN_TREE (DASHBOARD_SID,TITLE,TREE_SID,PARENT_TREE_SID,JSON_DATA) 
values ((Select DASHBOARD_SID From ADDIN_DASHBOARD Where DASHBOARD_ID = 'output_gap_t10_current'),'Output Gap T+10',25,8,'{"color":"#0a6924","icon":"pi pi-list"}');

Insert into FASTOP.ADDIN_TREE (DASHBOARD_SID,TITLE,TREE_SID,PARENT_TREE_SID,JSON_DATA) 
values ((Select DASHBOARD_SID From ADDIN_DASHBOARD Where DASHBOARD_ID = 'eer_neer'),'Nominal Effective Exchange Rates (NEER)',26,9,'{"color":"#70430c","icon":"pi pi-list"}');

Insert into FASTOP.ADDIN_TREE (DASHBOARD_SID,TITLE,TREE_SID,PARENT_TREE_SID,JSON_DATA) 
values ((Select DASHBOARD_SID From ADDIN_DASHBOARD Where DASHBOARD_ID = 'eer_reer'),'Nominal Effective Exchange Rates (REER)',27,9,'{"color":"#70430c","icon":"pi pi-list"}');

COMMIT;

