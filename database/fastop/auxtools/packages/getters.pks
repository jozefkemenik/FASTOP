CREATE OR REPLACE PACKAGE AUXTOOLS_GETTERS
AS
   /******************************************************************************
                               CONSTANTS
   ******************************************************************************/
   APP_ID CONSTANT VARCHAR2(4) := 'AUXTOOLS';

   /****************************************************************************/

   FUNCTION getCurrentAppSid
      RETURN NUMBER;

END AUXTOOLS_GETTERS;
/