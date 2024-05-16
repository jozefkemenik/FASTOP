CREATE OR REPLACE PACKAGE BODY AUXTOOLS_EER_MATRIX
AS
   /**************************************************************************
    *********************** PRIVATE SECTION **********************************
    **************************************************************************/

   /**************************************************************************
    *********************** PUBLIC SECTION ***********************************
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name getMatrixData
   ----------------------------------------------------------------------------
   PROCEDURE getMatrixData(o_cur            OUT SYS_REFCURSOR
                         , p_provider_id IN     VARCHAR2
                         , p_group_id    IN     VARCHAR2               DEFAULT NULL
                         , p_years       IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY))
   IS
      l_years             SIDSLIST := CORE_COMMONS.arrayToSidsList(p_years);
      l_years_count       NUMBER(8) := p_years.COUNT;
   BEGIN
      OPEN o_cur FOR
           SELECT IMPORTER_CTY_ID AS "impCtyId"
                , EXPORTER_CTY_ID AS "expCtyId"
                , YEAR            AS "year"
                , VALUE           AS "value"
                , GEO_GROUP_ID    AS "geoGroupId"
            FROM VW_EER_MATRIX_DATA
           WHERE PROVIDER_ID = upper(p_provider_id)
             AND (p_group_id IS NULL OR GEO_GROUP_ID = p_group_id)
             AND (l_years_count = 0 OR YEAR IN (SELECT * FROM TABLE(l_years)));
   END getMatrixData;

   ----------------------------------------------------------------------------
   -- @name getMatrixYears
   ----------------------------------------------------------------------------
   PROCEDURE getMatrixYears(p_provider_id IN     VARCHAR2
                          , o_cur            OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT DISTINCT M.YEAR
            FROM EER_MATRIX_DATA M
            JOIN EER_PROVIDERS P
              ON M.PROVIDER_SID = P.PROVIDER_SID
           WHERE P.PROVIDER_ID = upper(p_provider_id)
        ORDER BY M.YEAR DESC;
   END getMatrixYears;

END AUXTOOLS_EER_MATRIX;
/
