SET DEFINE OFF;

INSERT INTO FDMS_FORECASTS(FORECAST_ID, DESCR)
     VALUES ('LATEST_FULLY_FLEDGED', 'Latest fdms round and storage when full output gap calculation was done');

INSERT INTO FDMS_FORECASTS(FORECAST_ID, DESCR)
     VALUES ('LATEST_AGGREGATES', 'Latest fdms round and storage when aggregates were accepted');

COMMIT;
