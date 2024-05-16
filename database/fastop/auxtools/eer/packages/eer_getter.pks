CREATE OR REPLACE PACKAGE AUXTOOLS_EER_GETTERS
AS
   /******************************************************************************
                               CONSTANTS
   ******************************************************************************/
   BASE_YEAR_PARAM CONSTANT VARCHAR2(15) := 'EER_BASE_YEAR';

   /****************************************************************************/

   FUNCTION getIndicatorSid(p_indicator_id    IN       VARCHAR2
                          , p_provider_id     IN       VARCHAR2
                          , p_periodicity_id  IN       VARCHAR2)
      RETURN NUMBER;

   FUNCTION getGeoGroupSid(p_geo_grp_id  IN     VARCHAR2
                         , p_active_only IN     NUMBER DEFAULT 1)
      RETURN NUMBER;

   FUNCTION getProviderSid(p_provider_id IN VARCHAR2)
      RETURN NUMBER;

   PROCEDURE getEerGeoGroupsWithMembers(o_cur            OUT SYS_REFCURSOR
                                      , p_active_only IN     NUMBER DEFAULT 1);

   PROCEDURE getEerGeoGroups(o_cur            OUT SYS_REFCURSOR
                           , p_active_only IN     NUMBER DEFAULT 1);

   PROCEDURE getBaseYear(o_res OUT  NUMBER);

   PROCEDURE getNeerCountries(o_cur OUT SYS_REFCURSOR);

   PROCEDURE isCalculated(p_provider_id IN      VARCHAR2
                        , o_res            OUT  NUMBER);
                        
   PROCEDURE setBaseYear(p_year  IN      NUMBER
                       , o_res      OUT  NUMBER);
END;
