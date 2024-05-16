CREATE OR REPLACE PACKAGE AUXTOOLS_HICP
AS
   FUNCTION getDataTypeFromDataset(p_dataset IN VARCHAR2)
       RETURN VARCHAR2;

   PROCEDURE getEurostatCodes(o_cur            OUT SYS_REFCURSOR);

   PROCEDURE saveIndicatorsData(
             p_indicator_sids     IN OUT CORE_COMMONS.SIDSARRAY
           , p_country_ids        IN     CORE_COMMONS.VARCHARARRAY
           , p_start_years        IN     CORE_COMMONS.SIDSARRAY
           , p_time_series        IN     CORE_COMMONS.VARCHARARRAY
           , p_user               IN     VARCHAR
           , o_res                   OUT NUMBER
   );

    PROCEDURE getUserCategories(p_user IN     VARCHAR
                              , o_cur     OUT SYS_REFCURSOR);

    -- @Deprecated
    PROCEDURE getCountries(o_cur OUT SYS_REFCURSOR);

    -- @Deprecated
    PROCEDURE getDatasetData(o_cur               OUT SYS_REFCURSOR
                           , p_dataset        IN     VARCHAR2
                           , p_country_id     IN     VARCHAR2);

    -- @Deprecated
    PROCEDURE getData(o_cur               OUT SYS_REFCURSOR
                    , p_country_id     IN     VARCHAR2
                    , p_data_type      IN     VARCHAR2
                    , p_indicator_ids  IN     CORE_COMMONS.VARCHARARRAY);

    -- @Deprecated
    PROCEDURE getExcelDatasetData(o_cur               OUT SYS_REFCURSOR
                                , p_dataset        IN     VARCHAR2
                                , p_country_id     IN     VARCHAR2
                                , p_indicator_ids  IN     CORE_COMMONS.VARCHARARRAY);

    PROCEDURE getIndicatorCodes(o_cur OUT SYS_REFCURSOR);

    PROCEDURE getIndicators(p_data_type IN     VARCHAR2
                          , o_cur          OUT SYS_REFCURSOR);

    PROCEDURE getAnomaliesStartYear(o_res  OUT NUMBER);

    PROCEDURE getAnomaliesEndYear(o_res  OUT NUMBER);

    PROCEDURE insertCategory(p_category_id       IN     VARCHAR2
                           , p_descr             IN     VARCHAR2
                           , p_root_indicator_id IN     VARCHAR2
                           , p_base_indicator_id IN     VARCHAR2
                           , p_indicator_ids     IN     CORE_COMMONS.VARCHARARRAY
                           , p_owner             IN     VARCHAR2
                           , o_res                  OUT NUMBER);

    PROCEDURE updateCategory(p_category_sid      IN     NUMBER
                           , p_category_id       IN     VARCHAR2
                           , p_descr             IN     VARCHAR2
                           , p_root_indicator_id IN     VARCHAR2
                           , p_base_indicator_id IN     VARCHAR2
                           , p_indicator_ids     IN     CORE_COMMONS.VARCHARARRAY
                           , p_owner             IN     VARCHAR2
                           , o_res                  OUT NUMBER);

   PROCEDURE deleteCategory(p_category_sid      IN     NUMBER
                          , p_owner             IN     VARCHAR2
                          , o_res                  OUT NUMBER);

END;
