/* Formatted on 11/29/2019 13:48:30 (QP5 v5.252.13127.32847) */
CREATE OR REPLACE PACKAGE BODY CORE_TEMPLATES
AS
   FUNCTION getTemplateTypeSid (p_template_type_id IN VARCHAR2)
      RETURN NUMBER
   IS
      l_tpl_type_sid   NUMBER;
   BEGIN
      BEGIN
         SELECT TEMPLATE_TYPE_SID
           INTO l_tpl_type_sid
           FROM TEMPLATE_TYPES
          WHERE TEMPLATE_TYPE_ID = p_template_type_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_tpl_type_sid := NULL;
      END;

      RETURN l_tpl_type_sid;
   END getTemplateTypeSid;

   PROCEDURE getActiveTemplate (o_cur                   OUT SYS_REFCURSOR
,                               p_app_id             IN     VARCHAR2
,                               p_template_type_id   IN     VARCHAR2)
   IS
      l_app_sid   NUMBER := CORE_GETTERS.getApplicationSid (p_app_id);
   BEGIN
      OPEN o_cur FOR
         SELECT T.TITLE AS "fileName"
,               T.CONTENT AS "content"
,               T.CONTENT_TYPE AS "contentType"
           FROM TEMPLATE_FILES T
                JOIN TEMPLATE_TYPES S
                   ON T.TEMPLATE_TYPE_SID = S.TEMPLATE_TYPE_SID
          WHERE     S.TEMPLATE_TYPE_ID = p_template_type_id
                AND T.APP_SID = l_app_sid
                AND T.IS_ACTIVE = 1;
   END getActiveTemplate;


   PROCEDURE checkActiveTemplate (o_res                   OUT    NUMBER
,                                 p_app_id                IN     VARCHAR2
,                                 p_template_type_id      IN     VARCHAR2)
   IS
      l_app_sid   NUMBER := CORE_GETTERS.getApplicationSid (p_app_id);
   BEGIN
      SELECT COUNT(*)
        INTO o_res
        FROM TEMPLATE_FILES T
        JOIN TEMPLATE_TYPES S
          ON T.TEMPLATE_TYPE_SID = S.TEMPLATE_TYPE_SID
       WHERE S.TEMPLATE_TYPE_ID = p_template_type_id
         AND T.APP_SID = l_app_sid
         AND T.IS_ACTIVE = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN o_res := 0;
   END checkActiveTemplate;

   PROCEDURE getAllTemplates (o_cur                   OUT SYS_REFCURSOR
,                             p_app_id             IN     VARCHAR2
,                             p_template_type_id   IN     VARCHAR2)
   IS
      l_app_sid   NUMBER := CORE_GETTERS.getApplicationSid (p_app_id);
   BEGIN
      OPEN o_cur FOR
         SELECT T.TEMPLATE_SID AS "templateSid"
,               T.TITLE AS "fileName"
,               T.IS_ACTIVE AS "isActive"
,               T.DESCR AS "descr"
,               T.LAST_CHANGE_DATE AS "lastChangeDate"
,               T.LAST_CHANGE_USER AS "lastChangeUser"
           FROM TEMPLATE_FILES T
                JOIN TEMPLATE_TYPES S
                   ON T.TEMPLATE_TYPE_SID = S.TEMPLATE_TYPE_SID
          WHERE     S.TEMPLATE_TYPE_ID = p_template_type_id
                AND T.APP_SID = l_app_sid;
   END getAllTemplates;

   PROCEDURE getTemplate (o_cur OUT SYS_REFCURSOR, p_template_sid IN NUMBER)
   IS
   BEGIN
      OPEN o_cur FOR
         SELECT T.TITLE AS "fileName"
,               T.CONTENT AS "content"
,               T.CONTENT_TYPE AS "contentType"
           FROM TEMPLATE_FILES T
          WHERE T.TEMPLATE_SID = p_template_sid;
   END getTemplate;

   PROCEDURE uploadTemplate (o_res                   OUT NUMBER
,                            p_app_id             IN     VARCHAR2
,                            p_template_type_id   IN     VARCHAR2
,                            p_title              IN     VARCHAR2
,                            p_content_type       IN     VARCHAR2
,                            p_content            IN     BLOB
,                            p_descr              IN     VARCHAR2
,                            p_last_change_user   IN     VARCHAR2)
   IS
      l_app_sid        NUMBER := CORE_GETTERS.getApplicationSid (p_app_id);
      l_tpl_type_sid   NUMBER := getTemplateTypeSid (p_template_type_id);
   BEGIN
      o_res := 0;

      IF l_tpl_type_sid > 0
      THEN
         UPDATE TEMPLATE_FILES
            SET IS_ACTIVE = 0
          WHERE APP_SID = l_app_sid AND TEMPLATE_TYPE_SID = l_tpl_type_sid;

         INSERT INTO TEMPLATE_FILES (APP_SID
,                                    TEMPLATE_TYPE_SID
,                                    TITLE
,                                    CONTENT_TYPE
,                                    CONTENT
,                                    DESCR
,                                    IS_ACTIVE
,                                    LAST_CHANGE_USER)
              VALUES (l_app_sid
,                     l_tpl_type_sid
,                     p_title
,                     p_content_type
,                     p_content
,                     p_descr
,                     1
,                     p_last_change_user);

         o_res := SQL%ROWCOUNT;
      END IF;
   END uploadTemplate;

   PROCEDURE activateTemplate (o_res                   OUT NUMBER
,                              p_app_id             IN     VARCHAR2
,                              p_template_type_id   IN     VARCHAR2
,                              p_template_sid       IN     NUMBER)
   IS
      l_app_sid        NUMBER := CORE_GETTERS.getApplicationSid (p_app_id);
      l_tpl_type_sid   NUMBER := getTemplateTypeSid (p_template_type_id);
      l_template_sid   NUMBER;
   BEGIN
      o_res := 0;

      BEGIN
         SELECT TEMPLATE_SID
           INTO l_template_sid
           FROM TEMPLATE_FILES
          WHERE     APP_SID = l_app_sid
                AND TEMPLATE_TYPE_SID = l_tpl_type_sid
                AND TEMPLATE_SID = p_template_sid;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_template_sid := 0;
      END;

      IF l_template_sid > 0
      THEN
         UPDATE TEMPLATE_FILES
            SET IS_ACTIVE = 0
          WHERE APP_SID = l_app_sid AND TEMPLATE_TYPE_SID = l_tpl_type_sid;

         UPDATE TEMPLATE_FILES
            SET IS_ACTIVE = 1
          WHERE     APP_SID = l_app_sid
                AND TEMPLATE_TYPE_SID = l_tpl_type_sid
                AND TEMPLATE_SID = l_template_sid;

         o_res := SQL%ROWCOUNT;
      END IF;
   END activateTemplate;

   FUNCTION getActiveTemplateDate (p_app_id             IN VARCHAR2
,                                  p_template_type_id   IN VARCHAR2)
      RETURN DATE
   IS
      l_app_sid            NUMBER := CORE_GETTERS.getApplicationSid (p_app_id);
      l_last_change_date   DATE;
   BEGIN
      SELECT F.LAST_CHANGE_DATE
        INTO l_last_change_date
        FROM TEMPLATE_FILES F
             JOIN TEMPLATE_TYPES T
                ON T.TEMPLATE_TYPE_SID = F.TEMPLATE_TYPE_SID
       WHERE     F.APP_SID = l_app_sid
             AND T.TEMPLATE_TYPE_ID = p_template_type_id
             AND F.IS_ACTIVE = 1;

      RETURN l_last_change_date;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END getActiveTemplateDate;

   PROCEDURE deleteTemplate (o_res OUT NUMBER, p_template_sid IN NUMBER)
   IS
   BEGIN
      DELETE FROM TEMPLATE_FILES
            WHERE TEMPLATE_SID = p_template_sid;

      o_res := SQL%ROWCOUNT;
   END deleteTemplate;
END CORE_TEMPLATES;
/
