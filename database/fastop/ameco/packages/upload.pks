CREATE OR REPLACE PACKAGE AMECO_UPLOAD
AS
    PROCEDURE uploadIndicatorData(o_res                    OUT  NUMBER
                               ,  p_country_id         IN       VARCHAR2
                               ,  p_start_year         IN       NUMBER
                               ,  p_indicator_sids     IN       CORE_COMMONS.SIDSARRAY
                               ,  p_time_series        IN       CORE_COMMONS.VARCHARARRAY
                               ,  p_user               IN       VARCHAR2);

END AMECO_UPLOAD;
/
