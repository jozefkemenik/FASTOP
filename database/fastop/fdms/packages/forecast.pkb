CREATE OR REPLACE PACKAGE BODY FDMS_FORECAST
AS
    ----------------------------------------------------------------------------
    -- @name getRoundAndStorage
    ----------------------------------------------------------------------------
    PROCEDURE getRoundAndStorage(p_forecast_id IN     VARCHAR2
                               , o_round          OUT NUMBER
                               , o_storage        OUT NUMBER)
    IS
    BEGIN
        SELECT ROUND_SID, STORAGE_SID
          INTO o_round, o_storage
          FROM FDMS_FORECASTS
         WHERE FORECAST_ID = UPPER(p_forecast_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;

    END getRoundAndStorage;

    ----------------------------------------------------------------------------
    -- @name setRoundAndStorage
    ----------------------------------------------------------------------------
    PROCEDURE setRoundAndStorage(p_forecast_id IN     VARCHAR2
                               , p_user        IN     VARCHAR2
                               , o_res            OUT NUMBER)
    IS
    BEGIN
      UPDATE FDMS_FORECASTS
         SET ROUND_SID = CORE_GETTERS.getCurrentRoundSid(FDMS_GETTERS.APP_ID)
           , STORAGE_SID = CORE_GETTERS.getCurrentStorageSid(FDMS_GETTERS.APP_ID)
           , LAST_CHANGE_USER = p_user
           , LAST_CHANGE_DATE = CURRENT_TIMESTAMP
       WHERE FORECAST_ID = UPPER(p_forecast_id);

       o_res := SQL%ROWCOUNT;

    END setRoundAndStorage;

END FDMS_FORECAST;
