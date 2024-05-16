/* Formatted on 19-08-2020 19:38:43 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY ST_MAIL
AS
   /**************************************************************************
    *********************** PRIVATE SECTION **********************************
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name getActionSid
   ----------------------------------------------------------------------------
   FUNCTION getActionSid(p_old_status_id IN VARCHAR2, p_new_status_id IN VARCHAR2)
      RETURN NUMBER
   IS
      l_sid NUMBER(8);
   BEGIN
      BEGIN
         SELECT A.ACTION_SID
           INTO l_sid
           FROM ST_ACTIONS  A
                JOIN ST_ACTION_ALLOWED_STATUSES S ON S.ACTION_SID = A.ACTION_SID
                JOIN ST_STATUS_REPO OLD ON OLD.STATUS_SID = S.STATUS_SID
                JOIN ST_STATUS_REPO NEW ON NEW.STATUS_SID = A.RESULT_STATUS_SID
          WHERE OLD.STATUS_ID = p_old_status_id AND NEW.STATUS_ID = p_new_status_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_sid := 0;
      END;

      RETURN l_sid;
   END getActionSid;

   ----------------------------------------------------------------------------
   -- @name getRecipients
   ----------------------------------------------------------------------------
   PROCEDURE getRecipients(p_app_id         IN     VARCHAR2
                         , p_country_id     IN     VARCHAR2
                         , p_action_sid     IN     NUMBER
                         , p_with_inherited IN     NUMBER -- 0: no inherited, 1: all, 2: only inherited
                         , o_cur               OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT R.RECIPIENT_EMAIL
             FROM VW_ST_MAIL_RECIPIENTS R
            WHERE R.APP_ID = p_app_id
              AND ((R.COUNTRY_ID IS NULL AND (p_country_id IS NULL OR p_with_inherited > 0))
                OR R.COUNTRY_ID = p_country_id)
              AND R.ACTION_SID = p_action_sid
              AND (p_with_inherited != 2 OR (R.COUNTRY_ID IS NULL AND p_country_id IS NOT NULL))
         ORDER BY R.RECIPIENT_EMAIL;
   END getRecipients;

   ----------------------------------------------------------------------------
   -- @name getMailNotificationSid
   ----------------------------------------------------------------------------
   FUNCTION getMailNotificationSid(p_app_id         IN VARCHAR2
                                 , p_country_id     IN VARCHAR2
                                 , p_action_sid     IN NUMBER
                                 , p_create_missing IN NUMBER DEFAULT 0)
      RETURN NUMBER
   IS
      l_sid ST_MAIL_NOTIFICATIONS.MAIL_NOTIFICATION_SID%TYPE;
   BEGIN
      BEGIN
         SELECT DISTINCT R.MAIL_NOTIFICATION_SID
           INTO l_sid
           FROM VW_ST_MAIL_RECIPIENTS R
          WHERE R.APP_ID = p_app_id
            AND ((R.COUNTRY_ID IS NULL AND p_country_id IS NULL) OR R.COUNTRY_ID = p_country_id)
            AND R.ACTION_SID = p_action_sid;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            IF p_create_missing = 1 THEN
               INSERT INTO ST_MAIL_NOTIFICATIONS(APP_SID, COUNTRY_ID, ACTION_SID)
                    VALUES ((SELECT A.APP_SID
                               FROM APPLICATIONS A
                              WHERE A.APP_ID = p_app_id)
                          , p_country_id
                          , p_action_sid)
                 RETURNING MAIL_NOTIFICATION_SID
                      INTO l_sid;
            ELSE
               l_sid := 0;
            END IF;
      END;

      RETURN l_sid;
   END getMailNotificationSid;

   /**************************************************************************
    *********************** PUBLIC SECTION ***********************************
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name getMailRecipients
   ----------------------------------------------------------------------------
   PROCEDURE getMailRecipients(p_app_id        IN     VARCHAR2
                             , p_country_id    IN     VARCHAR2
                             , p_action_sid    IN     NUMBER
                             , o_cur              OUT SYS_REFCURSOR
                             , o_inherited_cur    OUT SYS_REFCURSOR)
   IS
   BEGIN
      getRecipients(p_app_id
                  , p_country_id
                  , p_action_sid
                  , 0
                  , o_cur);

      getRecipients(p_app_id
                  , p_country_id
                  , p_action_sid
                  , 2
                  , o_inherited_cur);
   END getMailRecipients;

   ----------------------------------------------------------------------------
   -- @name addMailRecipient
   ----------------------------------------------------------------------------
   PROCEDURE addMailRecipient(p_app_id     IN     VARCHAR2
                            , p_country_id IN     VARCHAR2
                            , p_action_sid IN     NUMBER
                            , p_email      IN     VARCHAR2
                            , o_res           OUT NUMBER)
   IS
      l_sid ST_MAIL_NOTIFICATIONS.MAIL_NOTIFICATION_SID%TYPE
               := getMailNotificationSid(p_app_id, p_country_id, p_action_sid, 1);
   BEGIN
      INSERT INTO ST_MAIL_RECIPIENTS(MAIL_NOTIFICATION_SID, RECIPIENT_EMAIL)
           VALUES (l_sid, p_email);

      o_res := SQL%ROWCOUNT;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         o_res := -1;
   END addMailRecipient;

   ----------------------------------------------------------------------------
   -- @name deleteMailRecipient
   ----------------------------------------------------------------------------
   PROCEDURE deleteMailRecipient(p_app_id     IN     VARCHAR2
                               , p_country_id IN     VARCHAR2
                               , p_action_sid IN     NUMBER
                               , p_email      IN     VARCHAR2
                               , o_res           OUT NUMBER)
   IS
      l_sid ST_MAIL_NOTIFICATIONS.MAIL_NOTIFICATION_SID%TYPE
               := getMailNotificationSid(p_app_id, p_country_id, p_action_sid);
   BEGIN
      IF l_sid > 0 THEN
         DELETE FROM ST_MAIL_RECIPIENTS R
               WHERE R.MAIL_NOTIFICATION_SID = l_sid AND R.RECIPIENT_EMAIL = p_email;

         o_res := SQL%ROWCOUNT;
      ELSE
         o_res := 0;
      END IF;
   END deleteMailRecipient;

   ----------------------------------------------------------------------------
   -- @name updateMailRecipient
   ----------------------------------------------------------------------------
   PROCEDURE updateMailRecipient(p_app_id     IN     VARCHAR2
                               , p_country_id IN     VARCHAR2
                               , p_action_sid IN     NUMBER
                               , p_email      IN     VARCHAR2
                               , p_new_email  IN     VARCHAR2
                               , o_res           OUT NUMBER)
   IS
      l_sid ST_MAIL_NOTIFICATIONS.MAIL_NOTIFICATION_SID%TYPE
               := getMailNotificationSid(p_app_id, p_country_id, p_action_sid, 1);
   BEGIN
      UPDATE ST_MAIL_RECIPIENTS
         SET RECIPIENT_EMAIL = p_new_email
       WHERE MAIL_NOTIFICATION_SID = l_sid AND RECIPIENT_EMAIL = p_email;

      o_res := SQL%ROWCOUNT;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         o_res := -1;
   END updateMailRecipient;

   ----------------------------------------------------------------------------
   -- @name sendMailNotification
   ----------------------------------------------------------------------------
   PROCEDURE sendMailNotification(p_app_id        IN     VARCHAR2
                                , p_country_id    IN     VARCHAR2
                                , p_old_status_id IN     VARCHAR2
                                , p_new_status_id IN     VARCHAR2
                                , o_res              OUT NUMBER)
   IS
      l_cur       SYS_REFCURSOR;
      l_recipient ST_MAIL_RECIPIENTS.RECIPIENT_EMAIL%TYPE;
      l_country   GEO_AREAS.DESCR%TYPE;
   BEGIN
      SELECT C.DESCR
        INTO l_country
        FROM COUNTRIES C
       WHERE C.COUNTRY_ID = p_country_id;

      getRecipients(p_app_id
                  , p_country_id
                  , getActionSid(p_old_status_id, p_new_status_id)
                  , 1
                  , l_cur);
      o_res := 0;

      LOOP
         FETCH l_cur INTO l_recipient;

         EXIT WHEN l_cur%NOTFOUND;
         sendmail(
            ''
          , l_recipient
          , p_app_id || ': ' || l_country || ' status change notification'
          ,    p_app_id
            || ': '
            || l_country
            || ' status has changed from '
            || p_old_status_id
            || ' to '
            || p_new_status_id
            || '.'
         );
         o_res := o_res + 1;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         o_res := -1;
   END sendMailNotification;
END ST_MAIL;
/