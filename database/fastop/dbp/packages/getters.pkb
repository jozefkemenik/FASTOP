/* Formatted on 23-09-2021 10:31:56 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY DBP_GETTERS
AS
   /******************************************************************************
      NAME:       DBP_GETTERS
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0       27/03/2019    lubiesz        1. Created this package body.
   ******************************************************************************/

   PROCEDURE getExercises(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
         SELECT exercise_sid AS sid, exercise_id AS pid, descr AS description FROM dbp_exercises
         UNION ALL
         SELECT -1, NULL, '< not set >'
           FROM DUAL;
   END;

   PROCEDURE getDbpSources(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR SELECT source_sid AS sid, descr AS description FROM dbp_sources
                     UNION ALL
                     SELECT -1, '< not set >'
                       FROM DUAL;
   END;

   PROCEDURE getDbpAccountingPrinciples(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR SELECT acc_princip_sid AS sid, descr AS description FROM dbp_acc_princip
                     UNION ALL
                     SELECT -1, '< not set >'
                       FROM DUAL;
   END;

   PROCEDURE getDbpAdoptionStatuses(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR SELECT adopt_status_sid AS sid, descr AS description FROM dbp_adopt_status
                     UNION ALL
                     SELECT -1, '< not set >'
                       FROM DUAL;
   END;

   PROCEDURE getESACodes(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR SELECT esa_sid, esa_id, descr, rev_exp_sid FROM DBP_ESA
                     UNION ALL
                     SELECT -1, NULL, '< not set >', -1
                       FROM DUAL;
   END;

   PROCEDURE getDbpEsaRevenueCodes(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR   SELECT *
                         FROM (SELECT esa_sid AS sid, descr AS description
                                 FROM dbp_esa
                                WHERE rev_exp_sid = 1
                               UNION ALL
                               SELECT -1, '< not set >'
                                 FROM DUAL)
                     ORDER BY description;
   END;

   PROCEDURE getDbpEsaExpenditureCodes(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR   SELECT *
                         FROM (SELECT esa_sid AS sid, descr AS description
                                 FROM dbp_esa
                                WHERE rev_exp_sid = 2
                               UNION ALL
                               SELECT -1, '< not set >'
                                 FROM DUAL)
                     ORDER BY description;
   END;

   PROCEDURE getScale(p_country_id  IN     VARCHAR2
                    , p_version     IN     NUMBER DEFAULT NULL
                    , p_round_sid   IN     NUMBER
                    , o_scale_sid      OUT NUMBER
                    , o_scale_descr    OUT VARCHAR2)
   IS
      l_version GD_CTY_VERSIONS.VERSION%TYPE := p_version;
   BEGIN
      IF p_version IS NULL THEN
         l_version := GD_GETTERS.getCountryVersion(p_country_id, p_round_sid);
      END IF;

      SELECT S.scale_sid, S.descr
        INTO o_scale_sid, o_scale_descr
        FROM dbp_cty_round_scales  D
             JOIN gd_cty_versions V ON V.CTY_VERSION_SID = D.CTY_VERSION_SID
             LEFT JOIN scales S ON D.scale_sid = S.scale_sid
       WHERE V.country_id = p_country_id AND V.VERSION = l_version AND D.round_sid = p_round_sid;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         o_scale_sid   := NULL;
         o_scale_descr := NULL;
   END getScale;

   FUNCTION getCurrentAppSid
      RETURN NUMBER
   IS
   BEGIN
      RETURN CORE_GETTERS.getApplicationSid(APP_ID);
   END getCurrentAppSid;

   FUNCTION getExerciseSid(p_exercise_id IN VARCHAR2)
      RETURN NUMBER
   IS
      l_exercise_sid NUMBER := NULL;
   BEGIN
      BEGIN
         SELECT exercise_sid
           INTO l_exercise_sid
           FROM DBP_EXERCISES
          WHERE exercise_id = p_exercise_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_exercise_sid := NULL;
      END;

      RETURN l_exercise_sid;
   END getExerciseSid;

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

   PROCEDURE getCountryCurrency(p_country_id IN     VARCHAR2
                              , p_version    IN     NUMBER DEFAULT NULL
                              , p_round_sid  IN     NUMBER DEFAULT NULL
                              , o_cur           OUT SYS_REFCURSOR)
   IS
      l_round_sid NUMBER(8);
      l_version   GD_CTY_VERSIONS.VERSION%TYPE := p_version;
   BEGIN
      IF p_round_sid IS NULL THEN
         l_round_sid := CORE_GETTERS.getCurrentRoundSid(APP_ID);
      ELSE
         l_round_sid := p_round_sid;
      END IF;

      IF p_version IS NULL THEN
         l_version := GD_GETTERS.getCountryVersion(p_country_id, l_round_sid);
      END IF;

      OPEN o_cur FOR
         SELECT D.SCALE_SID AS "sid", S.DESCR AS "descr", S.SCALE_ID AS "id"
           FROM DBP_CTY_ROUND_SCALES  D
                JOIN gd_cty_versions V ON V.CTY_VERSION_SID = D.CTY_VERSION_SID
                JOIN SCALES S ON D.SCALE_SID = S.SCALE_SID
          WHERE V.COUNTRY_ID = p_country_id AND V.VERSION = l_version AND D.ROUND_SID = l_round_sid;
   END getCountryCurrency;
END DBP_GETTERS;