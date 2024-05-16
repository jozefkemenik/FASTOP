/* Formatted on 11/29/2019 13:48:15 (QP5 v5.252.13127.32847) */
CREATE OR REPLACE PACKAGE CORE_TEMPLATES
AS
   /******************************************************************************
         NAME:       CORE_TEMPLATES
         PURPOSE:    Common global template related functionality
    ******************************************************************************/

   FUNCTION getTemplateTypeSid (p_template_type_id IN VARCHAR2)
      RETURN NUMBER;

   PROCEDURE getActiveTemplate (o_cur                   OUT SYS_REFCURSOR
,                               p_app_id             IN     VARCHAR2
,                               p_template_type_id   IN     VARCHAR2);

   PROCEDURE checkActiveTemplate (o_res                   OUT    NUMBER
,                                 p_app_id                IN     VARCHAR2
,                                 p_template_type_id      IN     VARCHAR2);

   PROCEDURE getAllTemplates (o_cur                   OUT SYS_REFCURSOR
,                             p_app_id             IN     VARCHAR2
,                             p_template_type_id   IN     VARCHAR2);

   PROCEDURE getTemplate (o_cur OUT SYS_REFCURSOR, p_template_sid IN NUMBER);

   PROCEDURE uploadTemplate (o_res                   OUT NUMBER
,                            p_app_id             IN     VARCHAR2
,                            p_template_type_id   IN     VARCHAR2
,                            p_title              IN     VARCHAR2
,                            p_content_type       IN     VARCHAR2
,                            p_content            IN     BLOB
,                            p_descr              IN     VARCHAR2
,                            p_last_change_user   IN     VARCHAR2);

   PROCEDURE activateTemplate (o_res                   OUT NUMBER
,                              p_app_id             IN     VARCHAR2
,                              p_template_type_id   IN     VARCHAR2
,                              p_template_sid       IN     NUMBER);

   FUNCTION getActiveTemplateDate (p_app_id             IN VARCHAR2
,                                  p_template_type_id   IN VARCHAR2)
      RETURN DATE;

   PROCEDURE deleteTemplate (o_res OUT NUMBER, p_template_sid IN NUMBER);
END CORE_TEMPLATES;
