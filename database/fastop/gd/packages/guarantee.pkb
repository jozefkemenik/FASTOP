/* Formatted on 30/03/2022 11:59:44 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY GD_GUARANTEE
AS
   ----------------------------------------------------------------------------
   -- @name getGuarantee
   -- @return guarantee
   ----------------------------------------------------------------------------
   PROCEDURE getGuarantee(p_guarantee_sid IN     NUMBER
                        , p_country_id    IN     VARCHAR2
                        , o_cur              OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR SELECT g.GUARANTEE_SID
                          , g.COUNTRY_ID
                          , g.DESCR
                          , g.REASON_SID
                          , g.ADOPT_DATE_YR
                          , COALESCE(g.ADOPT_DATE_MH, -1) adopt_date_mh
                          , g.MAX_CONTINGENT_LIAB
                          , g.ESTIMATED_TAKE_UP
                       FROM VW_GD_GUARANTEES g
                      WHERE g.GUARANTEE_SID = p_guarantee_sid AND g.country_id = p_country_id;
   END;

   ----------------------------------------------------------------------------
   -- @name getGuarantees
   -- @return list of guarantees
   ----------------------------------------------------------------------------
   PROCEDURE getGuarantees(p_app_id     IN     VARCHAR2
                         , p_country_id IN     VARCHAR2
                         , o_cur           OUT SYS_REFCURSOR
                         , p_round_sid  IN     NUMBER DEFAULT NULL
                         , p_version    IN     NUMBER DEFAULT NULL)
   IS
      l_round_sid ROUNDS.ROUND_SID%TYPE := p_round_sid;
   BEGIN
      IF l_round_sid IS NULL THEN
         l_round_sid := CORE_GETTERS.getCurrentRoundSid(p_app_id);
      END IF;

      OPEN o_cur FOR
           SELECT g.GUARANTEE_SID
                , g.COUNTRY_ID
                , g.DESCR
                , g.REASON_SID
                , g.ADOPT_DATE_YR
                , COALESCE(g.ADOPT_DATE_MH, -1) adopt_date_mh
                , g.MAX_CONTINGENT_LIAB
                , g.ESTIMATED_TAKE_UP
             FROM VW_GD_GUARANTEES g
            WHERE (p_country_id IS NULL OR g.country_id = p_country_id)
              AND g.ROUND_SID = l_round_sid
              AND g.VERSION =
                  COALESCE(p_version, GD_GETTERS.getCountryVersion(g.country_id, l_round_sid))
         ORDER BY g.country_id, g.reason_sid, g.guarantee_sid;
   END;

   ----------------------------------------------------------------------------
   -- @name getGuaranteeReasons
   ----------------------------------------------------------------------------
   PROCEDURE getGuaranteeReasons(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR   SELECT r.REASON_SID sid, r.DESCR description
                         FROM gd_guarantee_reasons r
                     ORDER BY r.ORDER_BY;
   END;

   ----------------------------------------------------------------------------
   -- @name deleteGuarantee
   -- @return number of rows deleted
   ----------------------------------------------------------------------------
   PROCEDURE deleteGuarantee(p_app_id        IN     VARCHAR2
                           , p_guarantee_sid IN     NUMBER
                           , p_country_id    IN     VARCHAR2
                           , o_res              OUT NUMBER)
   IS
      l_cty_version_sid GD_GUARANTEES.CTY_VERSION_SID%TYPE
         := GD_GETTERS.getCountryVersionSid(p_country_id
                                          , CORE_GETTERS.GETCURRENTROUNDSID(p_app_id));
   BEGIN
      DELETE FROM GD_guarantees
            WHERE guarantee_sid = p_guarantee_sid AND cty_version_sid = l_cty_version_sid;

      o_res := SQL%ROWCOUNT;
   END;

   ----------------------------------------------------------------------------
   -- @name saveGuarantee
   -- @return guarantee_sid of saved/new guarantee
   ----------------------------------------------------------------------------
   PROCEDURE saveGuarantee(p_app_id IN VARCHAR2, p_guarantee IN GUARANTEEOBJECT, o_res OUT NUMBER)
   IS
      l_adopt_date_mh   GD_GUARANTEES.ADOPT_DATE_MH%TYPE;
      l_round_sid       ROUNDS.ROUND_SID%TYPE := CORE_GETTERS.GETCURRENTROUNDSID(p_app_id);
      l_cty_version_sid GD_GUARANTEES.CTY_VERSION_SID%TYPE
                           := GD_GETTERS.getCountryVersionSid(p_guarantee.country_id, l_round_sid);
   BEGIN
      IF p_guarantee.adopt_date_mh = -1 THEN
         l_adopt_date_mh := NULL;
      ELSE
         l_adopt_date_mh := p_guarantee.adopt_date_mh;
      END IF;

      o_res := 0;

      IF p_guarantee.guarantee_sid > 0 THEN
         UPDATE GD_guarantees
            SET reason_sid          = p_guarantee.reason_sid
              , descr               = p_guarantee.descr
              , adopt_date_yr       = p_guarantee.adopt_date_yr
              , adopt_date_mh       = l_adopt_date_mh
              , max_contingent_liab = p_guarantee.max_contingent_liab
              , estimated_take_up   = p_guarantee.estimated_take_up
          WHERE guarantee_sid = p_guarantee.guarantee_sid
            AND round_sid = l_round_sid
            AND cty_version_sid = l_cty_version_sid;

         IF SQL%ROWCOUNT > 0 THEN
            o_res := p_guarantee.guarantee_sid;
         END IF;
      ELSE
         INSERT INTO GD_guarantees(cty_version_sid
                                 , round_sid
                                 , reason_sid
                                 , descr
                                 , adopt_date_yr
                                 , adopt_date_mh
                                 , max_contingent_liab
                                 , estimated_take_up)
              VALUES (l_cty_version_sid
                    , l_round_sid
                    , p_guarantee.reason_sid
                    , p_guarantee.descr
                    , p_guarantee.adopt_date_yr
                    , l_adopt_date_mh
                    , p_guarantee.max_contingent_liab
                    , p_guarantee.estimated_take_up)
           RETURNING guarantee_sid
                INTO o_res;
      END IF;
   END;

   ----------------------------------------------------------------------------
   -- @name saveGuarantees
   -- @return number of records updated/inserted
   ----------------------------------------------------------------------------
   PROCEDURE saveGuarantees(p_app_id IN VARCHAR2, p_guarantees IN GUARANTEEARRAY, o_res OUT NUMBER)
   IS
      e_error         EXCEPTION;
      l_guarantee_sid GD_GUARANTEES.GUARANTEE_SID%TYPE;
   BEGIN
      o_res := 0;

      FOR i IN 1 .. p_guarantees.COUNT LOOP
         saveGuarantee(p_app_id, p_guarantees(i), l_guarantee_sid);

         IF l_guarantee_sid < 0 THEN
            RAISE e_error;
         END IF;

         o_res := o_res + 1;
      END LOOP;
   END saveGuarantees;
END;
/