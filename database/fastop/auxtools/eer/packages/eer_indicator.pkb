CREATE OR REPLACE PACKAGE BODY AUXTOOLS_EER_INDICATOR
AS
   /**************************************************************************
    *********************** PUBLIC SECTION ***********************************
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name getIndicatorData
   ----------------------------------------------------------------------------
   PROCEDURE getIndicatorData(o_cur                  OUT SYS_REFCURSOR
                            , p_provider_id       IN     VARCHAR2
                            , p_group_id          IN     VARCHAR2 DEFAULT NULL
                            , p_periodicity_id    IN     VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT PERIODICITY_ID AS "periodicityId"
                , INDICATOR_ID   AS "indicatorId"
                , COUNTRY_ID     AS "countryId"
                , START_YEAR     AS "startYear"
                , TIMESERIE_DATA AS "timeserieData"
                , GEO_GROUP_ID   AS "geoGroupId"
            FROM VW_EER_INDICATORS_DATA
           WHERE PROVIDER_ID = upper(p_provider_id)
             AND (p_group_id IS NULL OR GEO_GROUP_ID = p_group_id)
             AND (p_periodicity_id IS NULL OR PERIODICITY_ID = p_periodicity_id);
   END getIndicatorData;

END AUXTOOLS_EER_INDICATOR;
/
