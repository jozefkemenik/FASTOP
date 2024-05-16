/* Formatted on 18/08/2020 13:28:33 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE ST_MAIL
AS
   PROCEDURE getMailRecipients(p_app_id        IN     VARCHAR2
                             , p_country_id    IN     VARCHAR2
                             , p_action_sid    IN     NUMBER
                             , o_cur              OUT SYS_REFCURSOR
                             , o_inherited_cur    OUT SYS_REFCURSOR);

   PROCEDURE addMailRecipient(p_app_id     IN     VARCHAR2
                            , p_country_id IN     VARCHAR2
                            , p_action_sid IN     NUMBER
                            , p_email      IN     VARCHAR2
                            , o_res           OUT NUMBER);

   PROCEDURE deleteMailRecipient(p_app_id     IN     VARCHAR2
                               , p_country_id IN     VARCHAR2
                               , p_action_sid IN     NUMBER
                               , p_email      IN     VARCHAR2
                               , o_res           OUT NUMBER);

   PROCEDURE updateMailRecipient(p_app_id     IN     VARCHAR2
                               , p_country_id IN     VARCHAR2
                               , p_action_sid IN     NUMBER
                               , p_email      IN     VARCHAR2
                               , p_new_email  IN     VARCHAR2
                               , o_res           OUT NUMBER);

   PROCEDURE sendMailNotification(p_app_id        IN     VARCHAR2
                                , p_country_id    IN     VARCHAR2
                                , p_old_status_id IN     VARCHAR2
                                , p_new_status_id IN     VARCHAR2
                                , o_res              OUT NUMBER);
END ST_MAIL;
/