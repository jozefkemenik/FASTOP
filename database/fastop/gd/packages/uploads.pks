/* Formatted on 04/03/2021 20:34:29 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE GD_UPLOADS
AS
   /******************************************************************************
      NAME:       GD_UPLOADS
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        12/06/2019  lubiesz          1. Created this package.
   ******************************************************************************/

   PROCEDURE getTemplateGrids(p_grid_id   IN     VARCHAR2
                            , p_app_id    IN     VARCHAR2
                            , p_ro_grids  IN     NUMBER DEFAULT 0
                            , o_cur          OUT SYS_REFCURSOR
                            , p_round_sid IN     NUMBER DEFAULT NULL);

   PROCEDURE getCountryGrids(p_grid_id    IN     VARCHAR2
                           , p_app_id     IN     VARCHAR2
                           , p_country_id IN     VARCHAR2
                           , o_cur           OUT SYS_REFCURSOR);

   PROCEDURE getDivergenceCtyGridSids(p_round_sid  IN     NUMBER
                                    , p_country_id IN     VARCHAR2
                                    , p_grid_id    IN     VARCHAR2
                                    , p_version    IN     NUMBER
                                    , o_cur           OUT SYS_REFCURSOR);
END GD_UPLOADS;