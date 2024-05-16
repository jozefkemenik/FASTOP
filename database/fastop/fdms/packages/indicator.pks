/* Formatted on 20-05-2021 17:34:52 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE FDMS_INDICATOR
AS
   PROCEDURE addIndicator(p_indicator_id   IN     VARCHAR2
                        , p_provider_id    IN     VARCHAR2
                        , p_periodicity_id IN     VARCHAR2
                        , o_res               OUT NUMBER);

   PROCEDURE copyFromFDMSStorage(
      o_res              OUT NUMBER
    , p_app_id        IN     VARCHAR2
    , p_country_ids   IN     CORE_COMMONS.VARCHARARRAY
    , p_provider_ids  IN     CORE_COMMONS.VARCHARARRAY
    , p_round_sid     IN     NUMBER
    , p_storage_sid   IN     NUMBER
    , p_indicator_ids IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
   );

   PROCEDURE getAmecoPhData(
      o_cur              OUT SYS_REFCURSOR
    , p_country_ids   IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_indicator_ids IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_round_sid     IN     NUMBER DEFAULT NULL
   );

   PROCEDURE getCountryTableData(
      o_cur              OUT SYS_REFCURSOR
    , p_country_ids   IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_og_full       IN     NUMBER DEFAULT NULL
    , p_round_sid     IN     NUMBER DEFAULT NULL
    , p_storage_sid   IN     NUMBER DEFAULT NULL
    , p_cust_text_sid IN     NUMBER DEFAULT NULL
   );

   PROCEDURE getDetailedTablesData(
      o_cur               OUT SYS_REFCURSOR
    , p_country_ids    IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                   NULL AS CORE_COMMONS.VARCHARARRAY
                                                                )
    , p_og_full        IN     NUMBER DEFAULT NULL
    , p_periodicity_id IN     VARCHAR2 DEFAULT 'A'
    , p_round_sid      IN     NUMBER DEFAULT NULL
    , p_storage_sid    IN     NUMBER DEFAULT NULL
    , p_cust_text_sid  IN     NUMBER DEFAULT NULL
   );

   PROCEDURE getProvidersIndicatorData(
      o_cur               OUT SYS_REFCURSOR
    , p_provider_ids   IN     CORE_COMMONS.VARCHARARRAY
    , p_country_ids    IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                   NULL AS CORE_COMMONS.VARCHARARRAY
                                                                )
    , p_indicator_ids  IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                   NULL AS CORE_COMMONS.VARCHARARRAY
                                                                )
    , p_og_full        IN     NUMBER DEFAULT NULL
    , p_periodicity_id IN     VARCHAR2 DEFAULT 'A'
    , p_round_sid      IN     NUMBER DEFAULT NULL
    , p_storage_sid    IN     NUMBER DEFAULT NULL
    , p_cust_text_sid  IN     NUMBER DEFAULT NULL
    , p_codes          IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(NULL AS CORE_COMMONS.VARCHARARRAY)                            
    , p_trns           IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(NULL AS CORE_COMMONS.VARCHARARRAY) 
    , p_aggs           IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(NULL AS CORE_COMMONS.VARCHARARRAY) 
    , p_units          IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(NULL AS CORE_COMMONS.VARCHARARRAY)
    , p_refs           IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(NULL AS CORE_COMMONS.VARCHARARRAY)
   );

   PROCEDURE getProvidersIndicatorData(
      o_cur               OUT SYS_REFCURSOR
    , p_app_id         IN     VARCHAR2
    , p_provider_ids   IN     CORE_COMMONS.VARCHARARRAY
    , p_country_ids    IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                   NULL AS CORE_COMMONS.VARCHARARRAY
                                                                )
    , p_indicator_ids  IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                   NULL AS CORE_COMMONS.VARCHARARRAY
                                                                )
    , p_og_full        IN     NUMBER DEFAULT NULL
    , p_periodicity_id IN     VARCHAR2 DEFAULT 'A'
   );

   PROCEDURE getProvidersLatestData(
      o_cur               OUT SYS_REFCURSOR
    , p_provider_ids   IN     CORE_COMMONS.VARCHARARRAY
    , p_country_ids    IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                   NULL AS CORE_COMMONS.VARCHARARRAY
                                                                )
    , p_indicator_ids  IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                   NULL AS CORE_COMMONS.VARCHARARRAY
                                                                )
    , p_og_full        IN     NUMBER DEFAULT NULL
    , p_periodicity_id IN     VARCHAR2 DEFAULT 'A'
   );

   PROCEDURE getProvidersForecastData(
      o_cur               OUT SYS_REFCURSOR
    , p_forecast_id    IN     VARCHAR2
    , p_provider_ids   IN     CORE_COMMONS.VARCHARARRAY
    , p_country_ids    IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                   NULL AS CORE_COMMONS.VARCHARARRAY
                                                                )
    , p_indicator_ids  IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                   NULL AS CORE_COMMONS.VARCHARARRAY
                                                                )
    , p_og_full        IN     NUMBER DEFAULT NULL
    , p_periodicity_id IN     VARCHAR2 DEFAULT 'A'
   );

   PROCEDURE getIndicatorCodes(o_cur OUT SYS_REFCURSOR);

   PROCEDURE getForecastIndicatorCodes(o_cur OUT SYS_REFCURSOR);

   PROCEDURE getIndicatorNames(p_indicator_ids IN     CORE_COMMONS.VARCHARARRAY
                             , o_cur              OUT SYS_REFCURSOR);

   PROCEDURE getReportIndicators(o_cur OUT SYS_REFCURSOR, p_report_id IN VARCHAR2);

   PROCEDURE getIndicators(o_cur               OUT SYS_REFCURSOR
                         , p_provider_id    IN     VARCHAR2 DEFAULT NULL
                         , p_periodicity_id IN     VARCHAR2 DEFAULT NULL);

   PROCEDURE isOgFull(o_res            OUT NUMBER
                    , p_country_id  IN     VARCHAR2
                    , p_round_sid   IN     NUMBER
                    , p_storage_sid IN     NUMBER);

   PROCEDURE setIndicatorData(p_app_id         IN     VARCHAR2
                            , p_country_id     IN     VARCHAR2
                            , p_indicator_id   IN     VARCHAR2
                            , p_provider_id    IN     VARCHAR2
                            , p_periodicity_id IN     VARCHAR2
                            , p_scale_id       IN     VARCHAR2
                            , p_start_year     IN     NUMBER
                            , p_time_serie     IN     VARCHAR2
                            , p_user           IN     VARCHAR
                            , o_res               OUT NUMBER
                            , p_round_sid      IN     NUMBER DEFAULT NULL
                            , p_storage_sid    IN     NUMBER DEFAULT NULL
                            , p_archive_data   IN     NUMBER DEFAULT NULL);

   PROCEDURE setIndicatorData(o_res               OUT NUMBER
                            , p_app_id         IN     VARCHAR2
                            , p_country_id     IN     VARCHAR2
                            , p_indicator_sids IN OUT CORE_COMMONS.SIDSARRAY
                            , p_scale_sids     IN     CORE_COMMONS.SIDSARRAY
                            , p_start_years    IN     CORE_COMMONS.SIDSARRAY
                            , p_time_series    IN     CORE_COMMONS.VARCHARARRAY
                            , p_user           IN     VARCHAR
                            , p_round_sid      IN     NUMBER DEFAULT NULL
                            , p_storage_sid    IN     NUMBER DEFAULT NULL
                            , p_og_full        IN     NUMBER DEFAULT NULL);

   PROCEDURE setIndicatorData(o_res               OUT NUMBER
                            , p_app_id         IN     VARCHAR2
                            , p_country_id     IN     VARCHAR2
                            , p_indicator_ids  IN     CORE_COMMONS.VARCHARARRAY
                            , p_provider_id    IN     VARCHAR2
                            , p_periodicity_id IN     VARCHAR2
                            , p_scale_id       IN     VARCHAR2
                            , p_start_year     IN     NUMBER
                            , p_time_series    IN     CORE_COMMONS.VARCHARARRAY
                            , p_user           IN     VARCHAR
                            , p_add_missing    IN     NUMBER DEFAULT NULL
                            , p_round_sid      IN     NUMBER DEFAULT NULL
                            , p_storage_sid    IN     NUMBER DEFAULT NULL
                            , p_og_full        IN     NUMBER DEFAULT NULL);

   PROCEDURE getProviderIndicators(p_provider_id IN VARCHAR2, o_cur OUT SYS_REFCURSOR);

   PROCEDURE transferAmecoToScopax(p_round_sid   IN     NUMBER
                                 , p_storage_sid IN     NUMBER
                                 , o_res            OUT NUMBER);

   PROCEDURE getIndicatorScales(o_cur               OUT SYS_REFCURSOR
                              , p_provider_id    IN     VARCHAR2
                              , p_periodicity_id IN     VARCHAR2
                              , p_indicator_ids  IN     CORE_COMMONS.VARCHARARRAY
                              , p_country_ids    IN     CORE_COMMONS.VARCHARARRAY);

   PROCEDURE getCtyIndicatorScales(o_cur               OUT SYS_REFCURSOR
                                 , p_provider_id    IN     VARCHAR2);

   PROCEDURE getIndicatorsMappings(o_cur               OUT SYS_REFCURSOR
                                 , p_provider_id    IN     VARCHAR2);

   PROCEDURE setIndicatorCodes(o_res      OUT NUMBER
                              ,p_sid IN     NUMBER
                              ,p_descr        IN     VARCHAR2
                              ,p_forecast     IN     NUMBER );
END;
