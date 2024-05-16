CREATE OR REPLACE PACKAGE NOTIFICATION_LOG
AS
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
                               , p_sender_app       IN      VARCHAR2 DEFAULT NULL);
END NOTIFICATION_LOG;
/
