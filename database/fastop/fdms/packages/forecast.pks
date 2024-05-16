CREATE OR REPLACE PACKAGE FDMS_FORECAST
AS

    PROCEDURE getRoundAndStorage(p_forecast_id IN     VARCHAR2
                               , o_round          OUT NUMBER
                               , o_storage        OUT NUMBER);

    PROCEDURE setRoundAndStorage(p_forecast_id IN     VARCHAR2
                               , p_user        IN     VARCHAR2
                               , o_res            OUT NUMBER);

END FDMS_FORECAST;
/
