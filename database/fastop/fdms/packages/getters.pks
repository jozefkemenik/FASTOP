/* Formatted on 27-11-2020 14:05:13 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE FDMS_GETTERS
AS
   /******************************************************************************
                               CONSTANTS
   ******************************************************************************/
   APP_ID CONSTANT VARCHAR2(4) := 'FDMS';

   /****************************************************************************/

   PROCEDURE getCtyScale(p_country_id IN     VARCHAR2
                       , o_scale_id      OUT VARCHAR2
                       , o_descr         OUT VARCHAR2
                       , o_exponent      OUT NUMBER);

   FUNCTION getCurrentAppSid
      RETURN NUMBER;

   PROCEDURE getScales(o_cur OUT SYS_REFCURSOR);

   FUNCTION getCurrentStorageSid
      RETURN NUMBER;

   FUNCTION isCurrentStorage(p_round_sid IN NUMBER, p_storage_sid IN NUMBER)
      RETURN NUMBER;

   FUNCTION isCurrentStorageFinal
      RETURN NUMBER;

   PROCEDURE getProviders(o_cur OUT SYS_REFCURSOR, p_app_id IN VARCHAR2);

   PROCEDURE getProviderDataLocation(p_provider_id IN VARCHAR2, o_res OUT VARCHAR2);

   FUNCTION getProviderSid(p_provider_id IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION getIndicatorSid(p_indicator_id   IN VARCHAR2
                          , p_provider_id    IN VARCHAR2
                          , p_periodicity_id IN VARCHAR2 DEFAULT 'A' )
      RETURN NUMBER;

   PROCEDURE getIndicatorGeoAreas(p_app_id IN     VARCHAR2
                                , o_cur       OUT SYS_REFCURSOR );

   PROCEDURE getProviderCountries(p_provider_ids IN      CORE_COMMONS.VARCHARARRAY
                                , o_cur             OUT  SYS_REFCURSOR );

   PROCEDURE getProviderIndicators(p_provider_ids    IN     CORE_COMMONS.VARCHARARRAY
                                 , p_periodicity_id  IN     VARCHAR2
                                 , o_cur                OUT SYS_REFCURSOR );

   PROCEDURE getProviderIndicatorsMappings(p_provider_ids    IN     CORE_COMMONS.VARCHARARRAY
                                         , p_periodicity_id  IN     VARCHAR2
                                         , o_cur                OUT SYS_REFCURSOR );

   PROCEDURE getIndicatorsTree(o_cur OUT SYS_REFCURSOR);

   PROCEDURE getProviderPeriodicityIndCode(o_pro OUT SYS_REFCURSOR
                                          ,o_per OUT SYS_REFCURSOR
                                          ,o_ind OUT SYS_REFCURSOR);
   PROCEDURE getIndicatorCodesByIds(p_indicator_sids    IN      CORE_COMMONS.SIDSARRAY
                                    ,p_forecast  IN NUMBER
                                    ,o_cur                OUT  SYS_REFCURSOR );


   PROCEDURE getIndicatorsBySidProviderPeriodicity(p_indicator_sids    IN      CORE_COMMONS.SIDSARRAY
                                   , p_periodicity_ids    IN      CORE_COMMONS.VARCHARARRAY
                                   , p_provider_sids    IN      CORE_COMMONS.SIDSARRAY
                                   , o_cur                OUT  SYS_REFCURSOR );


END FDMS_GETTERS;
/
