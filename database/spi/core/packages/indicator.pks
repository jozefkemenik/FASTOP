CREATE OR REPLACE PACKAGE CORE_INDICATOR
AS
   PROCEDURE getIndicatorsSTRUCTURE(
      o_cur                    OUT SYS_REFCURSOR
    , p_indicator_ids       IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                        NULL AS CORE_COMMONS.VARCHARARRAY
                                                                     )
    , p_country_ids         IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_destor_ids          IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature_codes  IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature        IN     VARCHAR2);

   PROCEDURE getIndicatorsCOMPETITION(
      o_cur                    OUT SYS_REFCURSOR
    , p_indicator_ids       IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                        NULL AS CORE_COMMONS.VARCHARARRAY
                                                                     )
    , p_country_ids         IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_destor_ids          IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature_codes  IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature        IN     VARCHAR2);

   PROCEDURE getIndicatorsCOUNTRY(
      o_cur                    OUT SYS_REFCURSOR
    , p_indicator_ids       IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                        NULL AS CORE_COMMONS.VARCHARARRAY
                                                                     )
    , p_country_ids         IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_destor_ids          IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature_codes  IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature        IN     VARCHAR2);

   PROCEDURE getIndicatorsDOMESTIC(
      o_cur                    OUT SYS_REFCURSOR
    , p_indicator_ids       IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                        NULL AS CORE_COMMONS.VARCHARARRAY
                                                                     )
    , p_country_ids         IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_destor_ids          IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature_codes  IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature        IN     VARCHAR2);

   PROCEDURE getIndicatorsEXTERNAL(
      o_cur                    OUT SYS_REFCURSOR
    , p_indicator_ids       IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                        NULL AS CORE_COMMONS.VARCHARARRAY
                                                                     )
    , p_country_ids         IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_destor_ids          IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature_codes  IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature        IN     VARCHAR2);

   PROCEDURE getIndicatorsEXTERNALGEO(
      o_cur                    OUT SYS_REFCURSOR
    , p_indicator_ids       IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                        NULL AS CORE_COMMONS.VARCHARARRAY
                                                                     )
    , p_country_ids         IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_destor_ids          IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature_codes  IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature        IN     VARCHAR2);

   PROCEDURE getIndicatorsKNOWLEDGE(
      o_cur                    OUT SYS_REFCURSOR
    , p_indicator_ids       IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                        NULL AS CORE_COMMONS.VARCHARARRAY
                                                                     )
    , p_country_ids         IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_destor_ids          IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature_codes  IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature        IN     VARCHAR2);

   PROCEDURE getIndicatorsSKILLTECH(
      o_cur                    OUT SYS_REFCURSOR
    , p_indicator_ids       IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                        NULL AS CORE_COMMONS.VARCHARARRAY
                                                                     )
    , p_country_ids         IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_destor_ids          IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature_codes  IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature        IN     VARCHAR2);

   PROCEDURE getIndicatorsTRADE(
      o_cur                    OUT SYS_REFCURSOR
    , p_indicator_ids       IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                        NULL AS CORE_COMMONS.VARCHARARRAY
                                                                     )
    , p_country_ids         IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_destor_ids          IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature_codes  IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature        IN     VARCHAR2);

   PROCEDURE getIndicatorsTRADEGEO(
      o_cur                    OUT SYS_REFCURSOR
    , p_indicator_ids       IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                        NULL AS CORE_COMMONS.VARCHARARRAY
                                                                     )
    , p_country_ids         IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_destor_ids          IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature_codes  IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature        IN     VARCHAR2);

    PROCEDURE getIndicatorDownloadDate(
      o_res                    OUT DATE
    , p_domain              IN     VARCHAR2);

   PROCEDURE getMatrix(
      o_cur                    OUT SYS_REFCURSOR
    , p_indicator_id        IN     VARCHAR2
    , p_country_ids         IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_products_ids        IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_years               IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_start_year          IN     NUMBER
    , p_end_year            IN     NUMBER
   );

END CORE_INDICATOR;
/
