SET DEFINE OFF;

-- public
Insert into ADDIN_DASHBOARD
    (TITLE, DASHBOARD_ID, LINK, OWNER_APP_ID, IS_ACTIVE, ORDER_BY)
  Values
    ('Ameco-online', 'ameco_online', '/ameco/online', 'AMECO', 0, 1);

Insert into ADDIN_DASHBOARD
    (TITLE, DASHBOARD_ID, LINK, OWNER_APP_ID, IS_ACTIVE, ORDER_BY)
  Values
    ('Ameco-internal:current', 'ameco_internal_current', '/ameco/current', 'AMECO', 1, 2);

Insert into ADDIN_DASHBOARD
    (TITLE, DASHBOARD_ID, LINK, OWNER_APP_ID, IS_ACTIVE, ORDER_BY)
  Values
    ('Ameco-internal:annex', 'ameco_internal_annex', '/ameco/annex', 'AMECO', 1, 3);

Insert into ADDIN_DASHBOARD
    (TITLE, DASHBOARD_ID, LINK, IS_ACTIVE, ORDER_BY)
  Values
    ('Bank of Spain', 'bos', '/bos', 1, 20);

Insert into ADDIN_DASHBOARD
    (TITLE, DASHBOARD_ID, LINK, OWNER_APP_ID, IS_ACTIVE, ORDER_BY)
  Values
    ('BCS', 'bcs', '/bcs', 'BCS', 0, 21);

Insert into ADDIN_DASHBOARD
    (TITLE, DASHBOARD_ID, LINK, IS_ACTIVE, ORDER_BY)
  Values
    ('DB.Nomics', 'dbnomics', '/dbnomics', 1, 60);

Insert into ADDIN_DASHBOARD
    (TITLE, DASHBOARD_ID, LINK, IS_ACTIVE, ORDER_BY)
  Values
    ('Ecfin', 'ecfin', '/ecfin', 0, 80);

Insert into ADDIN_DASHBOARD
    (TITLE, DASHBOARD_ID, LINK, IS_ACTIVE, ORDER_BY)
  Values
    ('European Central Bank', 'ecb', '/ecb', 1, 81);

Insert into ADDIN_DASHBOARD
    (TITLE, DASHBOARD_ID, LINK, IS_ACTIVE, ORDER_BY)
  Values
    ('Eurostat', 'eurostat', '/estat', 1, 82);

Insert into ADDIN_DASHBOARD
    (TITLE, DASHBOARD_ID, LINK, OWNER_APP_ID, IS_ACTIVE, ORDER_BY)
  Values
    ('Forecast:archived', 'forecast_archived', '/forecast/archived', 'FDMS', 1, 100);

Insert into ADDIN_DASHBOARD
    (TITLE, DASHBOARD_ID, LINK, OWNER_APP_ID, IS_ACTIVE, ORDER_BY)
  Values
    ('Output-gap:archived', 'output_gap_archived', '/output_gap/archived', 'FDMS', 1, 280);

Insert into ADDIN_DASHBOARD
    (TITLE, DASHBOARD_ID, LINK, OWNER_APP_ID, IS_ACTIVE, ORDER_BY)
  Values
    ('TCE:archived', 'tce_archived', '/tce/archived', 'FDMS', 1, 380);

-- restricted
Insert into ADDIN_DASHBOARD
    (TITLE, DASHBOARD_ID, LINK, OWNER_APP_ID, IS_ACTIVE, ORDER_BY)
  Values
    ('Ameco-internal:restricted', 'ameco_internal_restricted', '/ameco/restricted', 'AMECO', 1, 1);

Insert into ADDIN_DASHBOARD
    (TITLE, DASHBOARD_ID, LINK, OWNER_APP_ID, IS_ACTIVE, ORDER_BY)
  Values
    ('Ameco historical', 'ameco_historical', '/ameco_h', 'FDMS', 1, 2);

Insert into ADDIN_DASHBOARD
    (TITLE, DASHBOARD_ID, LINK, OWNER_APP_ID, IS_ACTIVE, ORDER_BY)
  Values
    ('Effective Exchange Rates - NEER', 'eer_neer', '/eer/neer', 'AUXTOOLS', 1, 80);
Insert into ADDIN_DASHBOARD
    (TITLE, DASHBOARD_ID, LINK, OWNER_APP_ID, IS_ACTIVE, ORDER_BY)
  Values
    ('Effective Exchange Rates - REER', 'eer_reer', '/eer/reer', 'AUXTOOLS', 1, 81);

Insert into ADDIN_DASHBOARD
    (TITLE, DASHBOARD_ID, LINK, OWNER_APP_ID, IS_ACTIVE, ORDER_BY)
  Values
    ('Forecast:current', 'forecast_current', '/forecast/current', 'FDMS', 1, 100);

Insert into ADDIN_DASHBOARD
    (TITLE, DASHBOARD_ID, LINK, OWNER_APP_ID, IS_ACTIVE, ORDER_BY)
  Values
    ('Output-gap:current', 'output_gap_current', '/output_gap/current', 'FDMS', 1, 280);

Insert into ADDIN_DASHBOARD
    (TITLE, DASHBOARD_ID, LINK, OWNER_APP_ID, IS_ACTIVE, ORDER_BY)
  Values
    ('Output Gap T+10', 'output_gap_t10_current', '/output_gap_t10/current', 'AMECO', 1, 281);

Insert into ADDIN_DASHBOARD
    (TITLE, DASHBOARD_ID, LINK, OWNER_APP_ID, IS_ACTIVE, ORDER_BY)
  Values
    ('TCE:current', 'tce_current', '/tce/current', 'FDMS', 1, 380);

COMMIT;
