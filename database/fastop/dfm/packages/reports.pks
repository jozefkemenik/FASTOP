CREATE OR REPLACE PACKAGE DFM_REPORTS
AS
   /******************************************************************************
      NAME:      DFM_REPORTS
      PURPOSE:   Procedures used for generating DFM reports

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        10/11/2017  rokosra          1. Created this package.
   ******************************************************************************/

   PROCEDURE getAdditionalImpactAll(
      o_cur                  OUT SYS_REFCURSOR
    , p_adopt_years       IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_adopt_months      IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_label_sids        IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_is_eu_funded_sids IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_country_id        IN     VARCHAR2 DEFAULT NULL
    , p_one_off_sid       IN     NUMBER DEFAULT NULL
   );

   PROCEDURE getAdditionalImpactAllArchived(
      p_round_sid         IN OUT NUMBER
    , p_storage_sid       IN OUT NUMBER
    , p_cust_text_sid     IN     NUMBER
    , p_storage_id        IN     VARCHAR2
    , o_cur                  OUT SYS_REFCURSOR
    , p_adopt_years       IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_adopt_months      IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_label_sids        IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_is_eu_funded_sids IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_country_id        IN     VARCHAR2 DEFAULT NULL
   );

   PROCEDURE getAdditionalImpactOO(
      o_cur                  OUT SYS_REFCURSOR
    , p_adopt_years       IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_adopt_months      IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_label_sids        IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_is_eu_funded_sids IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_country_id        IN     VARCHAR2 DEFAULT NULL
   );

   PROCEDURE getAdditionalImpactOOArchived(
      p_round_sid         IN OUT NUMBER
    , p_storage_sid       IN OUT NUMBER
    , p_cust_text_sid     IN     NUMBER
    , p_storage_id        IN     VARCHAR2
    , o_cur                  OUT SYS_REFCURSOR
    , p_adopt_years       IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_adopt_months      IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_label_sids        IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_is_eu_funded_sids IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_country_id        IN     VARCHAR2 DEFAULT NULL
   );

   PROCEDURE getReportMeasures(o_cur OUT SYS_REFCURSOR, p_country_id IN VARCHAR2);

   PROCEDURE getCountryMultiplier(o_cur OUT SYS_REFCURSOR);
END;
/