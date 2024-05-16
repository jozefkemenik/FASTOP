/* Formatted on 11/29/2019 13:43:46 (QP5 v5.252.13127.32847) */
CREATE OR REPLACE PACKAGE BODY CORE_HELP
AS
   /******************************************************************************
      NAME:       CORE_HELP
      PURPOSE:

   ******************************************************************************/

   PROCEDURE saveHelpMessage (p_help_msg_sid       IN     NUMBER
,                             p_help_msg_type_id   IN     VARCHAR2
,                             p_descr              IN     VARCHAR2
,                             p_mess               IN     VARCHAR2
,                             o_res                OUT    NUMBER)
   IS
   BEGIN
      UPDATE HELP_MSGS
         SET DESCR = p_descr
,            MESS = p_mess
       WHERE HELP_MSG_SID = p_help_msg_sid
         AND HELP_MSG_TYPE_ID = p_help_msg_type_id
   RETURNING HELP_MSG_SID
        INTO o_res;

      IF SQL%ROWCOUNT = 0
      THEN
         INSERT
           INTO HELP_MSGS (DESCR, MESS, HELP_MSG_TYPE_ID)
         VALUES (p_descr, p_mess, p_help_msg_type_id)
      RETURNING HELP_MSG_SID
           INTO o_res;
      END IF;

   END saveHelpMessage;
END CORE_HELP;
/
