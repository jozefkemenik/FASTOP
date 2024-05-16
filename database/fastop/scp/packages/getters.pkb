/* Formatted on 14-05-2020 20:42:31 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY SCP_GETTERS
AS
   /******************************************************************************
      NAME:       SCP_GETTERS
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0       27/03/2019    lubiesz        1. Created this package body.
   ******************************************************************************/

   PROCEDURE getCtyGrid(p_grid_id    IN     VARCHAR2
                      , p_country_id IN     VARCHAR2
                      , o_cur           OUT SYS_REFCURSOR
                      , p_round_sid  IN     NUMBER DEFAULT NULL
                      , p_version    IN     NUMBER DEFAULT NULL)
   IS
      l_round_sid NUMBER(8);
   BEGIN
      IF p_round_sid IS NULL THEN
         l_round_sid := CORE_GETTERS.getCurrentRoundSid(APP_ID);
      ELSE
         l_round_sid := p_round_sid;
      END IF;

      GD_GETTERS.getCtyGrid(l_round_sid
                          , p_grid_id
                          , p_country_id
                          , p_version
                          , o_cur);
   END;

   FUNCTION getCurrentAppSid
      RETURN NUMBER
   IS
   BEGIN
      RETURN CORE_GETTERS.getApplicationSid(APP_ID);
   END getCurrentAppSid;

   PROCEDURE getGrids(o_cur OUT SYS_REFCURSOR, p_round_sid IN NUMBER DEFAULT NULL)
   IS
      l_round_sid NUMBER(8);
   BEGIN
      IF p_round_sid IS NULL THEN
         l_round_sid := CORE_GETTERS.getCurrentRoundSid(APP_ID);
      ELSE
         l_round_sid := p_round_sid;
      END IF;

      GD_GETTERS.getGrids(l_round_sid, o_cur);
   END;
END SCP_GETTERS;