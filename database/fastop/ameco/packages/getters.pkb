CREATE OR REPLACE PACKAGE BODY AMECO_GETTERS
AS
   ----------------------------------------------------------------------------
   -- @name getCurrentAppSid
   ----------------------------------------------------------------------------
   FUNCTION getCurrentAppSid
      RETURN NUMBER
   IS
   BEGIN
      RETURN CORE_GETTERS.getApplicationSid(AMECO_GETTERS.APP_ID);
   END getCurrentAppSid;

   ----------------------------------------------------------------------------
   -- @name getProviderSid
   ----------------------------------------------------------------------------
   FUNCTION getProviderSid(p_provider_id IN VARCHAR2)
      RETURN NUMBER
   IS
      l_provider_sid AMECO_PROVIDERS.PROVIDER_SID%TYPE;
   BEGIN
      SELECT PROVIDER_SID
        INTO l_provider_sid
        FROM AMECO_PROVIDERS
       WHERE UPPER(PROVIDER_ID) = UPPER(p_provider_id);

      RETURN l_provider_sid;
   END getProviderSid;

   ----------------------------------------------------------------------------
   -- @name getIndicatorSid
   ----------------------------------------------------------------------------
   FUNCTION getIndicatorSid(p_indicator_id   IN VARCHAR2
                          , p_provider_id    IN VARCHAR2
                          , p_periodicity_id IN VARCHAR2 DEFAULT 'A' )
      RETURN NUMBER
   IS
      l_indicator_sid NUMBER;
   BEGIN
      SELECT INDICATOR_SID
        INTO l_indicator_sid
        FROM VW_AMECO_INDICATORS
       WHERE UPPER(PROVIDER_ID) = UPPER(p_provider_id)
         AND UPPER(INDICATOR_ID) = UPPER(p_indicator_id)
         AND PERIODICITY_ID = p_periodicity_id;

      RETURN l_indicator_sid;
   END getIndicatorSid;

END AMECO_GETTERS;
/
