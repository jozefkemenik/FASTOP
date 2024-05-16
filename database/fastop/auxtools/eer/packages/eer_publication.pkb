CREATE OR REPLACE PACKAGE BODY AUXTOOLS_EER_PUBLICATION
AS
   /**************************************************************************
    *********************** PUBLIC SECTION ***********************************
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name getWeights
   ----------------------------------------------------------------------------
   PROCEDURE getWeights(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT IMPORTER_CTY_ID AS "impCtyId"
                , EXPORTER_CTY_ID AS "expCtyId"
                , YEAR            AS "year"
                , VALUE           AS "value"
                , GEO_GROUP_ALIAS AS "geoGroupAlias"
            FROM VW_EER_MATRIX_DATA
           WHERE PROVIDER_ID = 'WEIGHTS_RSLT'
             AND GEO_GROUP_ACTIVE = 1;
   END getWeights;

   ----------------------------------------------------------------------------
   -- @name getNeer
   ----------------------------------------------------------------------------
   PROCEDURE getNeer(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT PERIODICITY_ID AS "periodicityId"
                , PROVIDER_ID    AS "providerId"
                , COUNTRY_ID     AS "countryId"
                , START_YEAR     AS "startYear"
                , TIMESERIE_DATA AS "timeserieData"
                , GEO_GROUP_ALIAS AS "geoGroupAlias"
            FROM VW_EER_INDICATORS_DATA
           WHERE PROVIDER_ID = 'NEER'
             AND GEO_GROUP_ACTIVE = 1;
   END getNeer;

   ----------------------------------------------------------------------------
   -- @name getReer
   ----------------------------------------------------------------------------
   PROCEDURE getReer(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT PERIODICITY_ID AS "periodicityId"
                , PROVIDER_ID    AS "providerId"
                , COUNTRY_ID     AS "countryId"
                , START_YEAR     AS "startYear"
                , TIMESERIE_DATA AS "timeserieData"
                , GEO_GROUP_ALIAS AS "geoGroupAlias"
             FROM VW_EER_INDICATORS_DATA
            WHERE ((PROVIDER_ID IN ('REER_HICP', 'REER_GDP', 'REER_XPI', 'REER_ULC') AND PERIODICITY_ID IN ('A', 'Q'))
                  OR
                  (PROVIDER_ID = 'REER_HICP' AND PERIODICITY_ID = 'M'))
              AND GEO_GROUP_ACTIVE = 1;
   END getReer;

   ----------------------------------------------------------------------------
   -- @name getEerGeoColumns
   ----------------------------------------------------------------------------
   PROCEDURE getEerGeoColumns(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT P.GROUP_ALIAS  AS "groupAlias"
                , P.GEO_GROUP_ID AS "groupId"
                , P.DESCR        AS "descr"
                , P.GEO_AREA_ID  AS "geoAreaId"
                , P.ORDER_BY     AS "orderBy"
             FROM VW_EER_PUBLICATION_GEO_AREAS P
         ORDER BY P.GROUP_ALIAS, P.ORDER_BY;
   END getEerGeoColumns;

   ----------------------------------------------------------------------------
   -- @name getWeightGeoColumns
   ----------------------------------------------------------------------------
   PROCEDURE getWeightGeoColumns(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT P.GROUP_ALIAS  AS "groupAlias"
                , P.GEO_GROUP_ID AS "groupId"
                , P.DESCR        AS "descr"
                , P.GEO_AREA_ID  AS "geoAreaId"
                , P.ORDER_BY     AS "orderBy"
             FROM VW_EER_GEO_GROUPS G
             JOIN VW_EER_PUBLICATION_GEO_AREAS P
               ON G.GEO_GROUP_ID = P.GEO_GROUP_ID
              AND G.GEO_MEMBER = P.GEO_AREA_ID
         ORDER BY P.GROUP_ALIAS, P.ORDER_BY;
   END getWeightGeoColumns;

END AUXTOOLS_EER_PUBLICATION;
/
