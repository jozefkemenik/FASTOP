SET DEFINE OFF;

Insert into ADDIN_PERMISSIONS (DASHBOARD_SID, ROLE_SID)
  Select
    (Select DASHBOARD_SID From ADDIN_DASHBOARD Where DASHBOARD_ID = 'ameco_internal_restricted') as DASHBOARD_SID,
    ROLE_SID From SECUNDA_ROLES Where ROLE_ID IN ('ADMIN', 'FORECAST');

Insert into ADDIN_PERMISSIONS (DASHBOARD_SID, ROLE_SID)
  Select
    (Select DASHBOARD_SID From ADDIN_DASHBOARD Where DASHBOARD_ID = 'ameco_historical') as DASHBOARD_SID,
    ROLE_SID From SECUNDA_ROLES Where ROLE_ID IN ('ADMIN', 'CTY_DESK', 'FORECAST');

Insert into ADDIN_PERMISSIONS (DASHBOARD_SID, ROLE_SID)
  Select
    (Select DASHBOARD_SID From ADDIN_DASHBOARD Where DASHBOARD_ID = 'forecast_current') as DASHBOARD_SID,
    ROLE_SID From SECUNDA_ROLES Where ROLE_ID IN ('ADMIN', 'CTY_DESK', 'FORECAST');

Insert into ADDIN_PERMISSIONS (DASHBOARD_SID, ROLE_SID)
  Select
    (Select DASHBOARD_SID From ADDIN_DASHBOARD Where DASHBOARD_ID = 'output_gap_current') as DASHBOARD_SID,
    ROLE_SID From SECUNDA_ROLES Where ROLE_ID IN ('ADMIN', 'CTY_DESK', 'FORECAST');

Insert into ADDIN_PERMISSIONS (DASHBOARD_SID, ROLE_SID)
  Select
    (Select DASHBOARD_SID From ADDIN_DASHBOARD Where DASHBOARD_ID = 'output_gap_t10_current') as DASHBOARD_SID,
    ROLE_SID From SECUNDA_ROLES Where ROLE_ID IN ('ADMIN', 'CTY_DESK', 'FORECAST');

Insert into ADDIN_PERMISSIONS (DASHBOARD_SID, ROLE_SID)
  Select
    (Select DASHBOARD_SID From ADDIN_DASHBOARD Where DASHBOARD_ID = 'eer_neer') as DASHBOARD_SID,
    ROLE_SID From SECUNDA_ROLES Where ROLE_ID IN ('ADMIN', 'CTY_DESK', 'FORECAST', 'PUBLIC');

Insert into ADDIN_PERMISSIONS (DASHBOARD_SID, ROLE_SID)
  Select
    (Select DASHBOARD_SID From ADDIN_DASHBOARD Where DASHBOARD_ID = 'eer_reer') as DASHBOARD_SID,
    ROLE_SID From SECUNDA_ROLES Where ROLE_ID IN ('ADMIN', 'CTY_DESK', 'FORECAST', 'PUBLIC');

Insert into ADDIN_PERMISSIONS (DASHBOARD_SID, ROLE_SID)
  Select
    (Select DASHBOARD_SID From ADDIN_DASHBOARD Where DASHBOARD_ID = 'tce_current') as DASHBOARD_SID,
    ROLE_SID From SECUNDA_ROLES Where ROLE_ID IN ('ADMIN', 'CTY_DESK', 'FORECAST');

COMMIT;
