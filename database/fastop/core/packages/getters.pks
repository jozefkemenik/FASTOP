/* Formatted on 07-07-2021 13:59:17 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE CORE_GETTERS
AS
   /******************************************************************************
      NAME:       CORE_GETTERS
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        27/03/2019   lubiesz       1. Created this package.
   ******************************************************************************/

   /******************************************************************************
                               CONSTANTS
   ******************************************************************************/
   CURRENT_STORAGE_PARAM CONSTANT VARCHAR2(15) := 'CURRENT_STORAGE';
   FINAL_STORAGE_ID      CONSTANT VARCHAR2(5) := 'FINAL';

   /******************************************************************************/

   FUNCTION currentOrPassedRound(p_round_sid IN NUMBER, p_app_id IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION getApplicationSid(p_app_id IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION getApplicationStatus(p_app_id IN VARCHAR2)
      RETURN VARCHAR2;

   PROCEDURE getApplicationStatus(p_app_id IN VARCHAR2, o_status_id OUT VARCHAR2);

   PROCEDURE getCountries(p_country_ids IN CORE_COMMONS.VARCHARARRAY, o_cur OUT SYS_REFCURSOR);

   PROCEDURE getCountries(cur              OUT SYS_REFCURSOR
                        , p_app_id      IN     VARCHAR2 DEFAULT NULL
                        , p_active_only IN     NUMBER DEFAULT 1);

   PROCEDURE getCountryGroupCountries(p_country_group_id IN     VARCHAR2
                                    , o_cur                 OUT SYS_REFCURSOR
                                    , p_active_only      IN     NUMBER DEFAULT 1);

   PROCEDURE getGeoAreasByCountryGroup(p_country_group_id IN     VARCHAR2
                                     , o_cur                 OUT SYS_REFCURSOR
                                     , p_active_only      IN     NUMBER DEFAULT 1);

   PROCEDURE getCurrentRound(p_app_id IN VARCHAR2 DEFAULT NULL, o_cur OUT SYS_REFCURSOR);

   FUNCTION getCurrentRoundSid(p_app_id IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION getCurrentStorageSid(p_app_id IN VARCHAR2)
      RETURN NUMBER;

   PROCEDURE getEU27CountryCodes(o_cur OUT SYS_REFCURSOR);

   PROCEDURE getGeoAreas(o_cur OUT SYS_REFCURSOR);

   FUNCTION getLatestApplicationRound(p_app_id         IN VARCHAR2
                                    , p_round_sid      IN NUMBER
                                    , p_history_offset IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   PROCEDURE getLatestApplicationRound(o_res          OUT NUMBER
                                     , p_app_id    IN     VARCHAR2
                                     , p_round_sid IN     NUMBER);

   FUNCTION getParameter(p_param_id IN VARCHAR2)
      RETURN VARCHAR2;

   PROCEDURE getParameter(p_param_id IN     VARCHAR2
                        , o_descr       OUT VARCHAR2
                        , o_value       OUT VARCHAR2);

   PROCEDURE getRoundInfo(o_round_sid    OUT NUMBER
                        , o_year         OUT NUMBER
                        , o_descr        OUT VARCHAR2
                        , o_period       OUT VARCHAR2
                        , o_period_id    OUT VARCHAR2
                        , o_version      OUT NUMBER
                        , p_app_id    IN     VARCHAR2 DEFAULT NULL
                        , p_round_sid IN     NUMBER DEFAULT NULL);

   PROCEDURE getRounds(o_cur OUT SYS_REFCURSOR, p_app_id IN VARCHAR2 DEFAULT NULL);

   PROCEDURE getRoundYear(p_round_sid IN NUMBER, o_res OUT NUMBER);

   PROCEDURE getRoundSid(p_year    IN      NUMBER
                       , p_period  IN      VARCHAR2
                       , p_version IN      NUMBER
                       , o_res        OUT  NUMBER);

   PROCEDURE getScales(o_cur OUT SYS_REFCURSOR);

   FUNCTION getStatusSid(p_status_id IN VARCHAR2)
      RETURN NUMBER;

   PROCEDURE getStorageInfo(o_storage_sid    OUT NUMBER
                          , o_descr          OUT VARCHAR2
                          , o_storage_id     OUT VARCHAR2
                          , p_app_id      IN     VARCHAR2
                          , p_storage_sid IN     NUMBER DEFAULT NULL);

   PROCEDURE getStorages(p_app_id IN VARCHAR2, o_cur OUT SYS_REFCURSOR);

   FUNCTION getStorageSid(p_storage_id IN VARCHAR2)
      RETURN NUMBER;

   PROCEDURE getStorageSid(p_storage_id IN VARCHAR2, o_res OUT NUMBER);

   FUNCTION isCurrentStorage(p_app_id IN VARCHAR2, p_round_sid IN NUMBER, p_storage_sid IN NUMBER)
      RETURN NUMBER;

   FUNCTION isCurrentStorageFinal(p_app_id IN VARCHAR2)
      RETURN NUMBER;

   PROCEDURE getYearsRange(p_app_id IN VARCHAR2, o_res OUT NUMBER);

   PROCEDURE getGeoAreaMappings(o_cur            OUT SYS_REFCURSOR
                              , p_mapping_ids IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               ));

   PROCEDURE getRoundStorageInfo(o_round_sid          OUT NUMBER
                               , o_round_id           OUT VARCHAR2
                               , o_storage_sid        OUT NUMBER
                               , o_storage_id         OUT VARCHAR2
                               , o_cust_text_sid      OUT NUMBER
                               , o_cust_text_id       OUT VARCHAR2
                               , p_round_sid      IN      NUMBER
                               , p_storage_sid    IN      NUMBER
                               , p_cust_text_sid  IN      NUMBER DEFAULT NULL);

   PROCEDURE getApplicationCountries(p_app_id IN     VARCHAR2
                                   , o_cur       OUT SYS_REFCURSOR);

   PROCEDURE getCurrency(p_geo_area_id IN    VARCHAR2
                       , o_currency      OUT VARCHAR2);

END CORE_GETTERS;
/
