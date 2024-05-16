/* Formatted on 12/2/2019 17:11:45 (QP5 v5.252.13127.32847) */
CREATE OR REPLACE PACKAGE BODY GD_LINK_TABLES
AS
   /**************************************************************************
    *********************** PRIVATE SECTION **********************************
    **************************************************************************/

   LINKED_TABLES_TEMPLATE_ID   CONSTANT VARCHAR2 (16) := 'LINKED_TABLES';

   /**************************************************************************
    *********************** PUBLIC SECTION ***********************************
    **************************************************************************/

   PROCEDURE getLinkedTablesUploadedData (o_cur             OUT SYS_REFCURSOR
,                                         p_country_id   IN     VARCHAR2
,                                         p_round_sid    IN     NUMBER)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT I.INDICATOR_ID AS "indicatorId"
,                 I.SOURCE AS "source"
,                 D.VECTOR AS "vector"
,                 D.START_YEAR AS "startYear"
,                 CASE
                     WHEN D.LAST_CHANGE_DATE IS NOT NULL
                     THEN
                        TO_CHAR (D.LAST_CHANGE_DATE, 'YYYY/MM/DD hh24:mi')
                     ELSE
                        NULL
                  END
                     AS "lastChangeDate"
,                 I.AMECO_CODE AS "amecoCode"
,                 D.COUNTRY_ID AS "countryCd"
             FROM CALCULATED_INDIC_DATA D
                  JOIN INDICATOR_LISTS L ON L.INDICATOR_SID = D.INDICATOR_SID
                  JOIN WORKBOOK_GROUPS W
                     ON L.WORKBOOK_GROUP_SID = W.WORKBOOK_GROUP_SID
                  JOIN INDICATORS I ON L.INDICATOR_SID = I.INDICATOR_SID
            WHERE     W.WORKBOOK_GROUP_ID = 'linked_tables'
                  AND I.SOURCE = 'uploaded'
                  AND D.COUNTRY_ID = p_country_id
                  AND D.ROUND_SID = p_round_sid
         ORDER BY LOWER ("indicatorId");
   END getLinkedTablesUploadedData;

   PROCEDURE getLinkedTablesAmecoData (o_cur             OUT SYS_REFCURSOR
,                                      p_country_id   IN     VARCHAR2
,                                      p_round_sid    IN     NUMBER)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT D.VECTOR AS "vector"
,                 D.COUNTRY_ID AS "countryCd"
,                 NVL (D.START_YEAR, 2010) AS "startYear"
,                 I.INDICATOR_ID AS "indicatorId"
,                 I.AMECO_CODE AS "amecoCode"
,                 NVL (I.SOURCE, 'EMPTY') AS "source"
,                 SUBSTR (I.AMECO_CODE, INSTR (I.AMECO_CODE, '.', -1) + 1)
                     AS "variable"
,                 CASE
                     WHEN D.LAST_CHANGE_DATE IS NOT NULL
                     THEN
                        TO_CHAR (D.LAST_CHANGE_DATE, 'YYYY/MM/DD hh24:mi')
                     ELSE
                        NULL
                  END
                     AS "lastChangeDate"
             FROM AMECO_INDIC_DATA D
                  RIGHT OUTER JOIN INDICATORS I
                     ON     I.INDICATOR_SID = D.INDICATOR_SID
                        AND D.COUNTRY_ID = p_country_id
                        AND D.ROUND_SID = p_round_sid
            WHERE     I.INDICATOR_SID IN (SELECT L.INDICATOR_SID
                                            FROM INDICATOR_LISTS L
                                                 JOIN WORKBOOK_GROUPS W
                                                    ON L.WORKBOOK_GROUP_SID =
                                                          W.WORKBOOK_GROUP_SID
                                           WHERE W.WORKBOOK_GROUP_ID =
                                                    'linked_tables')
                  AND I.SOURCE = 'AMECO'
         ORDER BY LOWER ("variable");
   END getLinkedTablesAmecoData;

   PROCEDURE getLinkedTablesLevelsData (o_cur             OUT SYS_REFCURSOR
,                                       p_country_id   IN     VARCHAR2
,                                       p_round_sid    IN     NUMBER)
   IS
      l_version   NUMBER (4)
         := GD_GETTERS.getCountryVersion (p_country_id, p_round_sid);
   BEGIN
      OPEN o_cur FOR
           SELECT CTY_GRID_SID || '_' || LINE_SID AS "key"
,                 COUNTRY_ID AS "countryCd"
,                 LINE_ID AS "lineId"
,                 YEAR + YEAR_VALUE AS "year"
,                 VALUE_CD AS "value"
             FROM VW_GD_CELLS
            WHERE     ROUND_SID = p_round_sid
                  AND COUNTRY_ID = p_country_id
                  AND VERSION = l_version
                  AND IN_LT = 'Y'
                  AND LINE_TYPE_ID IN ('LINE', 'CALCULATION')
                  AND IS_ABSOLUTE = 0
                  AND DATA_TYPE_ID = 'LEVELS'
         ORDER BY GRID_ID, LINE_ID, COL_SID;
   END getLinkedTablesLevelsData;

   PROCEDURE getLinkedTablesCalculatedData (o_cur             OUT SYS_REFCURSOR
,                                           p_country_id   IN     VARCHAR2
,                                           p_round_sid    IN     NUMBER)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT I.INDICATOR_ID AS "indicatorId"
,                 I.SOURCE AS "source"
,                 D.VECTOR AS "vector"
,                 D.START_YEAR AS "startYear"
,                 CASE
                     WHEN D.LAST_CHANGE_DATE IS NOT NULL
                     THEN
                        TO_CHAR (D.LAST_CHANGE_DATE, 'YYYY/MM/DD hh24:mi')
                     ELSE
                        NULL
                  END
                     AS "lastChangeDate"
,                 D.COUNTRY_ID AS "countryCd"
             FROM CALCULATED_INDIC_DATA D
                  JOIN INDICATOR_LISTS L ON L.INDICATOR_SID = D.INDICATOR_SID
                  JOIN WORKBOOK_GROUPS W
                     ON L.WORKBOOK_GROUP_SID = W.WORKBOOK_GROUP_SID
                  JOIN INDICATORS I ON L.INDICATOR_SID = I.INDICATOR_SID
            WHERE     W.WORKBOOK_GROUP_ID = 'linked_tables'
                  AND I.SOURCE IN ('ecfin'
,                                  'calculated'
,                                  'C1'
,                                  'RATS')
                  AND D.COUNTRY_ID = p_country_id
                  AND D.ROUND_SID = p_round_sid
         ORDER BY LOWER ("indicatorId");
   END getLinkedTablesCalculatedData;

   PROCEDURE getLinkedTablesGrowthData (o_cur             OUT SYS_REFCURSOR
,                                       p_country_id   IN     VARCHAR2
,                                       p_round_sid    IN     NUMBER)
   IS
      l_version   NUMBER (4)
         := GD_GETTERS.getCountryVersion (p_country_id, p_round_sid);
   BEGIN
      OPEN o_cur FOR
           SELECT CTY_GRID_SID || '_' || LINE_SID AS "key"
,                 COUNTRY_ID AS "countryCd"
,                 LINE_ID AS "lineId"
,                 (CASE IS_ABSOLUTE WHEN 0 THEN YEAR + YEAR_VALUE ELSE YEAR_VALUE END) AS "year"
,                 VALUE_CD AS "valueCd"
,                 VALUE_P AS "valueP"
             FROM VW_GD_CELLS
            WHERE     ROUND_SID = p_round_sid
                  AND COUNTRY_ID = p_country_id
                  AND VERSION = l_version
                  AND IN_LT = 'Y'
                  AND LINE_TYPE_ID IN ('LINE', 'CALCULATION')
                  AND (DATA_TYPE_ID IS NULL OR DATA_TYPE_ID != 'LEVELS')
         ORDER BY GRID_ID, LINE_ID, COL_SID;
   END getLinkedTablesGrowthData;

   PROCEDURE getCountryData (o_cur             OUT SYS_REFCURSOR
,                            p_country_id   IN     VARCHAR2)
   IS
   BEGIN
      OPEN o_cur FOR
         SELECT C.COUNTRY_ID AS "countryId"
,               C.DESCR AS "countryDesc"
,               (SELECT COUNT (*)
                   FROM COUNTRIES C1
                        JOIN COUNTRY_GROUPS CG
                           ON CG.COUNTRY_ID = C1.COUNTRY_ID
                  WHERE     C1.COUNTRY_ID = C.COUNTRY_ID
                        AND CG.COUNTRY_GROUP_ID = 'EA')
                   AS "isInEAGroup"
           FROM COUNTRIES C
          WHERE C.COUNTRY_ID = p_country_id;
   END getCountryData;

   PROCEDURE getActiveTemplate (o_cur         OUT SYS_REFCURSOR
,                               p_app_id   IN     VARCHAR2)
   IS
   BEGIN
      CORE_TEMPLATES.getActiveTemplate (o_cur
,                                       p_app_id
,                                       LINKED_TABLES_TEMPLATE_ID);
   END getActiveTemplate;

   PROCEDURE checkActiveTemplate (o_res         OUT    NUMBER
,                                 p_app_id      IN     VARCHAR2)
   IS
   BEGIN
      CORE_TEMPLATES.checkActiveTemplate (o_res
,                                         p_app_id
,                                         LINKED_TABLES_TEMPLATE_ID);
   END checkActiveTemplate;

   PROCEDURE getAllTemplates (o_cur OUT SYS_REFCURSOR, p_app_id IN VARCHAR2)
   IS
   BEGIN
      CORE_TEMPLATES.getAllTemplates (o_cur
,                                     p_app_id
,                                     LINKED_TABLES_TEMPLATE_ID);
   END getAllTemplates;

   PROCEDURE uploadTemplate (o_res                   OUT NUMBER
,                            p_app_id             IN     VARCHAR2
,                            p_title              IN     VARCHAR2
,                            p_content_type       IN     VARCHAR2
,                            p_content            IN     BLOB
,                            p_descr              IN     VARCHAR2
,                            p_last_change_user   IN     VARCHAR2)
   IS
   BEGIN
      CORE_TEMPLATES.uploadTemplate (o_res
,                                    p_app_id
,                                    LINKED_TABLES_TEMPLATE_ID
,                                    p_title
,                                    p_content_type
,                                    p_content
,                                    p_descr
,                                    p_last_change_user);
   END uploadTemplate;

   PROCEDURE activateTemplate (o_res               OUT NUMBER
,                              p_app_id         IN     VARCHAR2
,                              p_template_sid   IN     NUMBER)
   IS
   BEGIN
      CORE_TEMPLATES.activateTemplate (o_res
,                                      p_app_id
,                                      LINKED_TABLES_TEMPLATE_ID
,                                      p_template_sid);
   END activateTemplate;

   FUNCTION getActiveTemplateDate (p_app_id IN VARCHAR2)
      RETURN DATE
   IS
   BEGIN
      RETURN CORE_TEMPLATES.getActiveTemplateDate (p_app_id
,                                                  LINKED_TABLES_TEMPLATE_ID);
   END getActiveTemplateDate;

   ----------------------------------------------------------------------------
   -- @name getRequiredLinesForWorkbook
   ----------------------------------------------------------------------------
   PROCEDURE getRequiredLinesForWorkbook (
      o_cur              OUT SYS_REFCURSOR
,     p_workbook_id   IN     VARCHAR2
,     p_round_sid     IN     NUMBER DEFAULT NULL)
   IS
      l_stmt   VARCHAR2 (1024);
   BEGIN
      IF p_workbook_id = 'linked_tables'
      THEN
         l_stmt := 'V.IN_LT = ''Y''';
      ELSIF p_workbook_id = 'aggregates'
      THEN
         l_stmt := 'V.IN_AGG = ''Y''';
      ELSIF p_workbook_id = 'debt_dynamics'
      THEN
         l_stmt := 'V.IN_DD = ''Y''';
      ELSIF p_workbook_id = 'expenditure_benchmark'
      THEN
         l_stmt :=
            'V.EB_ID IS NOT NULL AND V.EB_ID NOT IN (''NLB_GDP.ms'',''GDR.ms'',''PB_GDP.ms'',''nGDP_growth.ms'')';
      END IF;

      OPEN o_cur FOR
            'SELECT '
         || ' V.LINE_ID AS "lineId",'
         || ' V.DESCR AS "lineDesc" '
         || ' FROM VW_GD_ROUND_GRID_LINES V JOIN GD_ROUND_GRIDS G ON V.ROUND_GRID_SID = G.ROUND_GRID_SID '
         || ' WHERE V.LINE_TYPE_ID = ''LINE'' '
         || ' AND V.LINE_ID IS NOT NULL '
         || ' AND G.ROUND_SID = :roundSid '
         || ' AND '
         || l_stmt
         USING p_round_sid;
   END getRequiredLinesForWorkbook;

   PROCEDURE getGridLinesForLinkedTables (
      o_cur             OUT SYS_REFCURSOR
,     p_country_id   IN     VARCHAR2
,     p_round_sid    IN     NUMBER DEFAULT NULL
,     p_line_ids     IN     CORE_COMMONS.VARCHARARRAY)
   IS
      l_line_ids   VARCHARLIST := CORE_COMMONS.arrayToList (p_line_ids);
   BEGIN
      OPEN o_cur FOR
         SELECT DISTINCT LINE_ID
           FROM VW_GD_CELLS V
          WHERE     ROUND_SID = p_round_sid
                AND COUNTRY_ID = p_country_id
                AND LINE_ID IN (SELECT * FROM TABLE (l_line_ids))
                AND 0 =
                       (SELECT COUNT (*)
                          FROM VW_GD_CELLS
                         WHERE     ROUND_SID = p_round_sid
                               AND COUNTRY_ID = p_country_id
                               AND LINE_ID = V.LINE_ID
                               AND (   VALUE_CD IS NULL
                                    OR LOWER (VALUE_CD) IN ('n.a.', 'na'))
                               AND YEAR_VALUE <= 3);
   END getGridLinesForLinkedTables;
END GD_LINK_TABLES;
