/* Formatted on 04/03/2021 20:32:11 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY GD_UPLOADS
AS
   /******************************************************************************
      NAME:       GD_UPLOADS
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        12/06/2019  lubiesz          1. Created this package.
   ******************************************************************************/

   -------------------------------------------------------------------------------
   -- @name getTemplateGrids gets grid(s) for current round.
   -- If grid_id is not provided then return all exportable grids.
   -------------------------------------------------------------------------------
   PROCEDURE getTemplateGrids(p_grid_id   IN     VARCHAR2
                            , p_app_id    IN     VARCHAR2
                            , p_ro_grids  IN     NUMBER DEFAULT 0
                            , o_cur          OUT SYS_REFCURSOR
                            , p_round_sid IN     NUMBER DEFAULT NULL)
   IS
      l_round_sid NUMBER := CORE_GETTERS.currentOrPassedRound(p_round_sid, p_app_id);
   BEGIN
      OPEN o_cur FOR
           SELECT G.ROUND_GRID_SID
                , G.GRID_SID
                , G.GRID_ID
                , G.DESCR
                , G.YEAR
                , G.GRID_TYPE_ID
             FROM VW_GD_GRIDS G
            WHERE G.ROUND_SID = l_round_sid
              AND ((p_ro_grids = 1 AND G.GRID_TYPE_ID IN ('NORMAL', 'AGGREGATE', 'DIVERGENCE'))
                OR (p_ro_grids = 0 AND G.GRID_TYPE_ID IN ('NORMAL')))
              AND (p_grid_id IS NULL OR G.GRID_ID = p_grid_id)
         ORDER BY G.ORDER_BY;
   END getTemplateGrids;


   ----------------------------------------------------------------------------
   -- @name getCountryGrids gets grid(s) for current round.
   -- If grid_id is not provided then return all exportable grids.
   ----------------------------------------------------------------------------
   PROCEDURE getCountryGrids(p_grid_id    IN     VARCHAR2
                           , p_app_id     IN     VARCHAR2
                           , p_country_id IN     VARCHAR2
                           , o_cur           OUT SYS_REFCURSOR)
   IS
      l_round_sid NUMBER := CORE_GETTERS.getCurrentRoundSid(p_app_id);
      l_version   NUMBER(4) := GD_GETTERS.getCountryVersion(p_country_id, l_round_sid);
   BEGIN
      OPEN o_cur FOR
           SELECT CG.CTY_GRID_SID
                , CG.ROUND_GRID_SID
                , CG.GRID_SID
                , CG.GRID_ID
                , CG.DESCR
                , CG.YEAR
                , CG.GRID_TYPE_ID
                , CG.ORDER_BY
             FROM VW_GD_CTY_GRIDS CG
            WHERE CG.ROUND_SID = l_round_sid
              AND CG.GRID_TYPE_ID = 'NORMAL'
              AND CG.COUNTRY_ID = p_country_id
              AND CG.VERSION = l_version
              AND (p_grid_id IS NULL OR CG.GRID_ID = p_grid_id)
         ORDER BY CG.ORDER_BY;
   END getCountryGrids;

   ----------------------------------------------------------------------------
   -- @name getDivergenceCtyGridSids get country grid sids for 'DIVERGENCE' grids
   ----------------------------------------------------------------------------
   PROCEDURE getDivergenceCtyGridSids(p_round_sid  IN     NUMBER
                                    , p_country_id IN     VARCHAR2
                                    , p_grid_id    IN     VARCHAR2
                                    , p_version    IN     NUMBER
                                    , o_cur           OUT SYS_REFCURSOR)
   IS
      l_version NUMBER(4);
   BEGIN
      IF p_version = 0 THEN
         l_version := GD_GETTERS.getCountryVersion(p_country_id, p_round_sid);
      ELSE
         l_version := p_version;
      END IF;

      OPEN o_cur FOR
         SELECT CTY_GRID_SID AS "ctyGridSid"
           FROM VW_GD_CTY_GRIDS
          WHERE ROUND_SID = p_round_sid
            AND COUNTRY_ID = p_country_id
            AND VERSION = l_version
            AND GRID_TYPE_ID = 'DIVERGENCE'
            AND (p_grid_id IS NULL OR grid_id = p_grid_id);
   END getDivergenceCtyGridSids;
END GD_UPLOADS;
/