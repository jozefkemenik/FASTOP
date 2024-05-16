/* Formatted on 10-09-2020 17:01:13 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY CORE_ERROR
AS
   PROCEDURE sendErrorEmail(p_env        IN VARCHAR2
                          , p_app_id     IN VARCHAR2
                          , p_message    IN VARCHAR2
                          , p_recipients IN CORE_COMMONS.VARCHARARRAY)
   IS
      l_subject VARCHAR2(64) := p_app_id || ' error on ' || p_env;
   BEGIN
      FOR i IN 1 .. p_recipients.COUNT LOOP
         sendmail(NULL, p_recipients(i), l_subject, p_message);
      END LOOP;
   END sendErrorEmail;
END CORE_ERROR;
/