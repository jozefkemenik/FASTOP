/* Formatted on 12/2/2019 17:12:58 (QP5 v5.252.13127.32847) */
CREATE OR REPLACE PACKAGE GD_LINK_TABLES
AS
   /******************************************************************************
      NAME:    IDR_LINK_TABLES
      PURPOSE: Linked tables getters
   ******************************************************************************/

   PROCEDURE getLinkedTablesUploadedData (o_cur             OUT SYS_REFCURSOR
,                                         p_country_id   IN     VARCHAR2
,                                         p_round_sid    IN     NUMBER);

   PROCEDURE getLinkedTablesAmecoData (o_cur             OUT SYS_REFCURSOR
,                                      p_country_id   IN     VARCHAR2
,                                      p_round_sid    IN     NUMBER);

   PROCEDURE getLinkedTablesLevelsData (o_cur             OUT SYS_REFCURSOR
,                                       p_country_id   IN     VARCHAR2
,                                       p_round_sid    IN     NUMBER);

   PROCEDURE getLinkedTablesCalculatedData (o_cur             OUT SYS_REFCURSOR
,                                           p_country_id   IN     VARCHAR2
,                                           p_round_sid    IN     NUMBER);

   PROCEDURE getLinkedTablesGrowthData (o_cur             OUT SYS_REFCURSOR
,                                       p_country_id   IN     VARCHAR2
,                                       p_round_sid    IN     NUMBER);

   PROCEDURE getCountryData (o_cur             OUT SYS_REFCURSOR
,                            p_country_id   IN     VARCHAR2);

   PROCEDURE getActiveTemplate (o_cur         OUT SYS_REFCURSOR
,                               p_app_id   IN     VARCHAR2);

   PROCEDURE checkActiveTemplate (o_res         OUT    NUMBER
,                                 p_app_id      IN     VARCHAR2);

   PROCEDURE getAllTemplates (o_cur OUT SYS_REFCURSOR, p_app_id IN VARCHAR2);

   PROCEDURE uploadTemplate (o_res                   OUT NUMBER
,                            p_app_id             IN     VARCHAR2
,                            p_title              IN     VARCHAR2
,                            p_content_type       IN     VARCHAR2
,                            p_content            IN     BLOB
,                            p_descr              IN     VARCHAR2
,                            p_last_change_user   IN     VARCHAR2);

   PROCEDURE activateTemplate (o_res               OUT NUMBER
,                              p_app_id         IN     VARCHAR2
,                              p_template_sid   IN     NUMBER);

   FUNCTION getActiveTemplateDate (p_app_id IN VARCHAR2)
      RETURN DATE;

   PROCEDURE getRequiredLinesForWorkbook (
      o_cur              OUT SYS_REFCURSOR
,     p_workbook_id   IN     VARCHAR2
,     p_round_sid     IN     NUMBER DEFAULT NULL);

   PROCEDURE getGridLinesForLinkedTables (
      o_cur             OUT SYS_REFCURSOR
,     p_country_id   IN     VARCHAR2
,     p_round_sid    IN     NUMBER DEFAULT NULL
,     p_line_ids     IN     CORE_COMMONS.VARCHARARRAY);
END GD_LINK_TABLES;
