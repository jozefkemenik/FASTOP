CREATE OR REPLACE PACKAGE AUXTOOLS_EER_UPLOAD
AS
    PROCEDURE setDataUpload(p_provider_id  IN      VARCHAR2
                          , p_user         IN      VARCHAR2
                          , o_res             OUT  NUMBER);

   PROCEDURE getUploads(o_cur OUT SYS_REFCURSOR);

   PROCEDURE getProviderUpload(p_provider_id IN       VARCHAR2
                             , o_cur            OUT   SYS_REFCURSOR);

   PROCEDURE setIndicatorData(p_provider_id     IN       VARCHAR2
                            , p_indicator_id    IN       VARCHAR2
                            , p_periodicity_id  IN       VARCHAR2
                            , p_start_year      IN       NUMBER
                            , p_country_ids     IN       CORE_COMMONS.VARCHARARRAY
                            , p_time_series     IN       CLOBLIST
                            , p_geo_grp_id      IN       VARCHAR2
                            , p_user            IN       VARCHAR2
                            , o_res                 OUT  NUMBER);

   PROCEDURE setMatrixData(p_provider_id        IN       VARCHAR2
                         , p_year               IN       NUMBER
                         , p_importers          IN       CORE_COMMONS.VARCHARARRAY
                         , p_exporters          IN       CORE_COMMONS.VARCHARARRAY
                         , p_values             IN       CORE_COMMONS.VARCHARARRAY
                         , p_geo_grp_id         IN       VARCHAR2
                         , p_user               IN       VARCHAR2
                         , o_res                   OUT   NUMBER);

END;
