/* Formatted on 14-05-2020 20:42:04 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE SCP_GETTERS
AS
   /******************************************************************************
      NAME:       SCP_GETTERS
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0       27/03/2019    lubiesz        1. Created this package body.
   ******************************************************************************/

   /******************************************************************************
                               CONSTANTS
   ******************************************************************************/
   APP_ID CONSTANT VARCHAR2(3) := 'SCP';

   /****************************************************************************/

   PROCEDURE getCtyGrid(p_grid_id    IN     VARCHAR2
                      , p_country_id IN     VARCHAR2
                      , o_cur           OUT SYS_REFCURSOR
                      , p_round_sid  IN     NUMBER DEFAULT NULL
                      , p_version    IN     NUMBER DEFAULT NULL);

   FUNCTION getCurrentAppSid
      RETURN NUMBER;

   PROCEDURE getGrids(o_cur OUT SYS_REFCURSOR, p_round_sid IN NUMBER DEFAULT NULL);
END SCP_GETTERS;