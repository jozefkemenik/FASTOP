/* Formatted on 23-09-2021 10:32:22 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE DBP_GETTERS
AS
   /******************************************************************************
      NAME:       DBP_GETTERS
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0       27/03/2019    lubiesz        1. Created this package body.
   ******************************************************************************/

   /******************************************************************************
                               CONSTANTS
   ******************************************************************************/
   APP_ID CONSTANT VARCHAR2(3) := 'DBP';

   /****************************************************************************/

   PROCEDURE getExercises(o_cur OUT SYS_REFCURSOR);

   PROCEDURE getDbpSources(o_cur OUT SYS_REFCURSOR);

   PROCEDURE getESACodes(o_cur OUT SYS_REFCURSOR);

   PROCEDURE getDbpEsaRevenueCodes(o_cur OUT SYS_REFCURSOR);

   PROCEDURE getDbpEsaExpenditureCodes(o_cur OUT SYS_REFCURSOR);

   PROCEDURE getDbpAccountingPrinciples(o_cur OUT SYS_REFCURSOR);

   PROCEDURE getDbpAdoptionStatuses(o_cur OUT SYS_REFCURSOR);

   PROCEDURE getScale(p_country_id  IN     VARCHAR2
                    , p_version     IN     NUMBER DEFAULT NULL
                    , p_round_sid   IN     NUMBER
                    , o_scale_sid      OUT NUMBER
                    , o_scale_descr    OUT VARCHAR2);

   FUNCTION getCurrentAppSid
      RETURN NUMBER;

   FUNCTION getExerciseSid(p_exercise_id IN VARCHAR2)
      RETURN NUMBER;

   PROCEDURE getGrids(o_cur OUT SYS_REFCURSOR, p_round_sid IN NUMBER DEFAULT NULL);

   PROCEDURE getCtyGrid(p_grid_id    IN     VARCHAR2
                      , p_country_id IN     VARCHAR2
                      , o_cur           OUT SYS_REFCURSOR
                      , p_round_sid  IN     NUMBER DEFAULT NULL
                      , p_version    IN     NUMBER DEFAULT NULL);

   PROCEDURE getCountryCurrency(p_country_id IN     VARCHAR2
                              , p_version    IN     NUMBER DEFAULT NULL
                              , p_round_sid  IN     NUMBER DEFAULT NULL
                              , o_cur           OUT SYS_REFCURSOR);
END DBP_GETTERS;