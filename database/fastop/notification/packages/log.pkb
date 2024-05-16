CREATE OR REPLACE PACKAGE BODY NOTIFICATION_LOG
AS
   ----------------------------------------------------------------------------
   -- @name logNotificationSent
   ----------------------------------------------------------------------------
   PROCEDURE logNotificationSent(o_res                 OUT  NUMBER
                               , p_provider         IN      VARCHAR2
                               , p_recipients       IN      VARCHAR2
                               , p_cc_recipients    IN      VARCHAR2
                               , p_bcc_recipients   IN      VARCHAR2
                               , p_subject          IN      VARCHAR2
                               , p_body             IN      VARCHAR2
                               , p_user_id          IN      VARCHAR2
                               , p_result           IN      CLOB
                               , p_failed           IN      NUMBER
                               , p_sender_app       IN      VARCHAR2 DEFAULT NULL)
   IS
      l_app_sid     APPLICATIONS.APP_SID%TYPE;
      l_app_id      APPLICATIONS.APP_ID%TYPE := UPPER(p_sender_app);
      l_round_sid   ROUNDS.ROUND_SID%TYPE;
      l_storage_sid STORAGES.STORAGE_SID%TYPE;
   BEGIN
      o_res := -1;

      l_app_sid := CORE_GETTERS.getApplicationSid(l_app_id);
      IF l_app_sid IS NULL
      THEN
        l_app_id := NULL;
      END IF;

      l_round_sid := CORE_GETTERS.getCurrentRoundSid(l_app_id);
      l_storage_sid := CORE_GETTERS.getCurrentStorageSid(l_app_id);

      INSERT INTO NOTIFICATION_LOGS(SENDER_APP
                                  , PROVIDER
                                  , RECIPIENTS
                                  , CC_RECIPIENTS
                                  , BCC_RECIPIENTS
                                  , SUBJECT
                                  , BODY
                                  , ROUND_SID
                                  , STORAGE_SID
                                  , USER_ID
                                  , RESULT
                                  , FAILED)
           VALUES (UPPER(p_sender_app)
                 , UPPER(p_provider)
                 , p_recipients
                 , p_cc_recipients
                 , p_bcc_recipients
                 , p_subject
                 , p_body
                 , l_round_sid
                 , l_storage_sid
                 , UPPER(p_user_id)
                 , p_result
                 , p_failed);

      o_res := SQL%ROWCOUNT;
   END logNotificationSent;

END NOTIFICATION_LOG;
/
