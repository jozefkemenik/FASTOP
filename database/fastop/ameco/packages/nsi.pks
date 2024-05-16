CREATE OR REPLACE PACKAGE AMECO_NSI
AS
    PROCEDURE getNSIData(o_cur               OUT SYS_REFCURSOR
                       , p_country_id     IN     VARCHAR2 DEFAULT NULL
                       , p_periodicity_id IN     VARCHAR2 DEFAULT 'A');

    PROCEDURE setNSIData(o_res                    OUT  NUMBER
                      ,  p_nsi_indicator_id   IN       VARCHAR2
                      ,  p_country_id         IN       VARCHAR2
                      ,  p_type               IN       VARCHAR2
                      ,  p_periodicity_id     IN       VARCHAR2
                      ,  p_start_year         IN       NUMBER
                      ,  p_time_series        IN       CORE_COMMONS.VARCHARARRAY
                      ,  p_orders             IN       CORE_COMMONS.SIDSARRAY
                      ,  p_user               IN       VARCHAR2);

END AMECO_NSI;
