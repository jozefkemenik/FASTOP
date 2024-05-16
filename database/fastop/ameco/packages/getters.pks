CREATE OR REPLACE PACKAGE AMECO_GETTERS
AS
   /******************************************************************************
                               CONSTANTS
   ******************************************************************************/
   APP_ID CONSTANT VARCHAR2(5) := 'AMECO';

   /****************************************************************************/

   FUNCTION getCurrentAppSid
      RETURN NUMBER;


   FUNCTION getProviderSid(p_provider_id IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION getIndicatorSid(p_indicator_id   IN VARCHAR2
                          , p_provider_id    IN VARCHAR2
                          , p_periodicity_id IN VARCHAR2 DEFAULT 'A' )
      RETURN NUMBER;

END AMECO_GETTERS;
/
