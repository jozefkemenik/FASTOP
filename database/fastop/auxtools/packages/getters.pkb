CREATE OR REPLACE PACKAGE BODY AUXTOOLS_GETTERS
AS
   ----------------------------------------------------------------------------
   -- @name getCurrentAppSid
   ----------------------------------------------------------------------------
   FUNCTION getCurrentAppSid
      RETURN NUMBER
   IS
   BEGIN
      RETURN CORE_GETTERS.getApplicationSid(AUXTOOLS_GETTERS.APP_ID);
   END getCurrentAppSid;

END AUXTOOLS_GETTERS;
/