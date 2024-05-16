/* Formatted on 10-09-2020 17:02:02 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE CORE_ERROR
AS
   PROCEDURE sendErrorEmail(p_env        IN VARCHAR2
                          , p_app_id     IN VARCHAR2
                          , p_message    IN VARCHAR2
                          , p_recipients IN CORE_COMMONS.VARCHARARRAY);
END CORE_ERROR;
/