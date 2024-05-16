CREATE OR REPLACE PACKAGE GD_GETTERS
AS
   /******************************************************************************
      NAME:       GD_GETTERS
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        29/05/2019  rokosra          1. Created this package.
   ******************************************************************************/

   PROCEDURE getCtyDefaultLevels (p_cty_grid_sid   IN     NUMBER
,                                 o_cur               OUT SYS_REFCURSOR);

   PROCEDURE getCtyGrid (p_round_sid    IN     NUMBER
,                        p_grid_id      IN     VARCHAR2
,                        p_country_id   IN     VARCHAR2
,                        p_version      IN     NUMBER
,                        o_cur             OUT SYS_REFCURSOR);

   FUNCTION getCtyGridRoundSid (p_cty_grid_sid IN NUMBER)
      RETURN NUMBER;

   PROCEDURE getCtyVersions (p_country_id   IN     VARCHAR2
,                            p_round_sid    IN     NUMBER
,                            o_cur             OUT SYS_REFCURSOR);

   FUNCTION getCountryVersion (p_country_id   IN VARCHAR2
,                              p_round_sid    IN NUMBER)
      RETURN NUMBER;

   PROCEDURE getCurrentCtyVersion (p_country_id   IN     VARCHAR2
,                                  p_app_id       IN     VARCHAR2
,                                  o_res             OUT NUMBER);

   FUNCTION getCountryVersionSid (p_country_id   IN VARCHAR2
,                                 p_round_sid    IN NUMBER)
      RETURN NUMBER;

   PROCEDURE getGridCols (p_round_grid_sid   IN     NUMBER
,                         o_cur                 OUT SYS_REFCURSOR);

   PROCEDURE getGridLineByRatsId (p_rats_id     IN     VARCHAR2
,                                 p_round_sid   IN     NUMBER
,                                 o_cur            OUT SYS_REFCURSOR);

   PROCEDURE getGridLines (p_round_grid_sid   IN     NUMBER
,                          o_cur                 OUT SYS_REFCURSOR);

   PROCEDURE getGrids (p_round_sid IN NUMBER, o_cur OUT SYS_REFCURSOR);

   PROCEDURE getGridsCols (p_round_grid_sids   IN     CORE_COMMONS.SIDSARRAY
,                          o_cur                  OUT SYS_REFCURSOR);

   PROCEDURE getGridsLines (p_round_grid_sids   IN     CORE_COMMONS.SIDSARRAY
,                           o_cur                  OUT SYS_REFCURSOR);

   PROCEDURE getGridTypeInfo (p_cty_grid_sid   IN     NUMBER
,                             o_cur               OUT SYS_REFCURSOR);

   PROCEDURE getOptionalCells (o_cur OUT SYS_REFCURSOR);

   PROCEDURE getRoundsLines (p_round_sids    IN       CORE_COMMONS.SIDSARRAY
,                            o_cur              OUT   SYS_REFCURSOR
,                            p_all_columns   IN       NUMBER DEFAULT NULL);
   PROCEDURE getDataTypes(o_cur  OUT   SYS_REFCURSOR);

   PROCEDURE getCtyRoundScale(p_cty_id       IN VARCHAR2,
                              p_round_sid    IN NUMBER,
                              p_cty_version  IN NUMBER,
                              o_cur             OUT SYS_REFCURSOR);

   PROCEDURE getCtyRoundScaleByCtyGrid(p_cty_grid_sid    IN    NUMBER,
                                       o_cur                OUT SYS_REFCURSOR);

END GD_GETTERS;
/