CREATE OR REPLACE PACKAGE AMECO_INDICATOR
AS
   PROCEDURE getIndicators(o_cur               OUT SYS_REFCURSOR
                         , p_provider_id    IN     VARCHAR2 DEFAULT NULL
                         , p_periodicity_id IN     VARCHAR2 DEFAULT NULL);

    PROCEDURE setIndicatorData(o_res                    OUT  NUMBER
                            ,  p_provider_id        IN       VARCHAR2
                            ,  p_indicator_id       IN       VARCHAR2
                            ,  p_periodicity_id     IN       VARCHAR2
                            ,  p_start_year         IN       NUMBER
                            ,  p_country_ids        IN       CORE_COMMONS.VARCHARARRAY
                            ,  p_time_series        IN       CORE_COMMONS.VARCHARARRAY
                            ,  p_hst_time_series    IN       CORE_COMMONS.VARCHARARRAY
                            ,  p_src_time_series    IN       CORE_COMMONS.VARCHARARRAY
                            ,  p_level_time_series  IN       CORE_COMMONS.VARCHARARRAY
                            ,  p_user               IN       VARCHAR2);

    PROCEDURE getIndicatorData(o_cur                OUT  SYS_REFCURSOR
                            ,  p_provider_id    IN       VARCHAR2
                            ,  p_periodicity_id IN       VARCHAR2
                            ,  p_indicator_ids  IN       CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               ));

    PROCEDURE getIndicatorMetadata(o_cur                OUT  SYS_REFCURSOR
                                ,  p_provider_id    IN       VARCHAR2
                                ,  p_periodicity_id IN       VARCHAR2
                                ,  p_indicator_ids  IN       CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               ));

    PROCEDURE setIndicatorInputSource(o_res              OUT  NUMBER
                                    , p_source_ids   IN       CORE_COMMONS.SIDSARRAY
                                    , p_source_codes IN       CORE_COMMONS.VARCHARARRAY);


    PROCEDURE getInputSources(o_cur  OUT  SYS_REFCURSOR);
END AMECO_INDICATOR;
