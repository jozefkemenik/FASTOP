/* Formatted on 11/29/2019 13:43:18 (QP5 v5.252.13127.32847) */
CREATE OR REPLACE PACKAGE CORE_HELP
AS
   /******************************************************************************
      NAME:       CORE_HELP
      PURPOSE:
   ******************************************************************************/
   PROCEDURE saveHelpMessage (p_help_msg_sid       IN     NUMBER
,                             p_help_msg_type_id   IN     VARCHAR2
,                             p_descr              IN     VARCHAR2
,                             p_mess               IN     VARCHAR2
,                             o_res                OUT    NUMBER);

END CORE_HELP;
/
