CREATE OR REPLACE PACKAGE BODY NOTIFICATION_TEMPLATE
AS
   ----------------------------------------------------------------------------
   -- @name getTemplate
   ----------------------------------------------------------------------------
   PROCEDURE getTemplate(p_template_id   IN      VARCHAR2
                       , o_cur               OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT TEMPLATE_ID    AS "templateId"
                , RECIPIENTS     AS "recipients"
                , CC_RECIPIENTS  AS "ccRecipients"
                , BCC_RECIPIENTS AS "bccRecipients"
                , SUBJECT        AS "subject"
                , BODY           AS "body"
             FROM NOTIFICATION_TEMPLATES
            WHERE UPPER(TEMPLATE_ID) = UPPER(p_template_id);
   END getTemplate;

END NOTIFICATION_TEMPLATE;
/
