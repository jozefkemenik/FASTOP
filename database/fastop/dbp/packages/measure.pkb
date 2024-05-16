/* Formatted on 17/08/2021 10:30:36 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY DBP_MEASURE
AS
   /******************************************************************************
      NAME:      DBP_MEASURE
      PURPOSE:   Measure accessors
   ******************************************************************************/

   ----------------------------------------------------------------------------
   -- @name getMeasures
   -- @return list of measures
   ----------------------------------------------------------------------------
   PROCEDURE getMeasures(p_country_id IN     VARCHAR2
                       , o_cur           OUT SYS_REFCURSOR
                       , p_round_sid  IN     NUMBER DEFAULT NULL
                       , p_version    IN     NUMBER DEFAULT NULL)
   IS
      l_round_sid ROUNDS.ROUND_SID%TYPE := p_round_sid;
   BEGIN
      IF l_round_sid IS NULL THEN
         l_round_sid := CORE_GETTERS.getCurrentRoundSid(DBP_GETTERS.APP_ID);
      END IF;

      OPEN o_cur FOR
           SELECT m.measure_sid
                , m.country_id
                , m.data
                , m.descr
                , m.start_year
                , m.title
                , COALESCE(m.esa_sid, -1)        esa_sid
                , COALESCE(m.source_sid, -1)     source_sid
                , COALESCE(m.acc_princip_sid, -1) acc_princip_sid
                , COALESCE(m.adopt_status_sid, -1) adopt_status_sid
             FROM VW_DBP_MEASURES m
            WHERE (p_country_id IS NULL OR m.country_id = p_country_id)
              AND M.ROUND_SID = l_round_sid
              AND M.VERSION =
                  COALESCE(p_version, GD_GETTERS.getCountryVersion(m.country_id, l_round_sid))
         ORDER BY m.country_id, m.measure_sid;
   END;

   ----------------------------------------------------------------------------
   -- @name getMeasureDetails
   -- @return measure details
   ----------------------------------------------------------------------------
   PROCEDURE getMeasureDetails(p_measure_sid IN     NUMBER
                             , p_country_id  IN     VARCHAR2
                             , o_cur            OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR SELECT m.measure_sid
                          , m.country_id
                          , m.data
                          , m.descr
                          , m.start_year
                          , m.title
                          , COALESCE(m.esa_sid, -1)          esa_sid
                          , COALESCE(m.source_sid, -1)       source_sid
                          , COALESCE(m.acc_princip_sid, -1)  acc_princip_sid
                          , COALESCE(m.adopt_status_sid, -1) adopt_status_sid
                       FROM VW_DBP_MEASURES m
                      WHERE m.measure_sid = p_measure_sid AND m.country_id = p_country_id;
   END;

   ----------------------------------------------------------------------------
   -- @name setMeasureValues
   -- @return number of rows updated
   ----------------------------------------------------------------------------
   PROCEDURE setMeasureValues(p_measure_sid IN     NUMBER
                            , p_country_id  IN     VARCHAR2
                            , p_year        IN     NUMBER
                            , p_start_year  IN     NUMBER
                            , p_values      IN     VARCHAR2
                            , o_res            OUT NUMBER)
   IS
      l_res NUMBER;
   BEGIN
      UPDATE DBP_MEASURES
         SET DATA = p_values, START_YEAR = p_start_year
       WHERE MEASURE_SID = (SELECT MEASURE_SID
                              FROM VW_DBP_MEASURES
                             WHERE MEASURE_SID = p_measure_sid AND COUNTRY_ID = p_country_id);

      o_res := SQL%ROWCOUNT;

      IF o_res > 0 THEN
         DBP_GRID_DATA.calculateTable5AMeasures(p_country_id, NULL, NULL, l_res);
      END IF;
   END;

   ----------------------------------------------------------------------------
   -- @name saveMeasureDetails
   -- @return measure sid of saved/new measure
   ----------------------------------------------------------------------------

   PROCEDURE saveMeasureDetails(p_measure_sid      IN     NUMBER
                              , p_country_id       IN     VARCHAR2
                              , p_title            IN     VARCHAR2
                              , p_descr            IN     VARCHAR2
                              , p_esa_sid          IN     NUMBER
                              , p_source_sid       IN     NUMBER
                              , p_acc_princip_sid  IN     NUMBER
                              , p_adopt_status_sid IN     NUMBER
                              , o_res                 OUT NUMBER)
   IS
      l_esa_sid          NUMBER;
      l_source_sid       NUMBER;
      l_acc_princip_sid  NUMBER;
      l_adopt_status_sid NUMBER;
      l_round_sid        ROUNDS.ROUND_SID%TYPE;
      l_cty_version_sid  NUMBER;
      l_changed          NUMBER := 0;
   BEGIN
      IF p_esa_sid = -1 THEN
         l_esa_sid := NULL;
      ELSE
         l_esa_sid := p_esa_sid;
      END IF;

      IF p_source_sid = -1 THEN
         l_source_sid := NULL;
      ELSE
         l_source_sid := p_source_sid;
      END IF;

      IF p_acc_princip_sid = -1 THEN
         l_acc_princip_sid := NULL;
      ELSE
         l_acc_princip_sid := p_acc_princip_sid;
      END IF;

      IF p_adopt_status_sid = -1 THEN
         l_adopt_status_sid := NULL;
      ELSE
         l_adopt_status_sid := p_adopt_status_sid;
      END IF;

      o_res := 0;

      IF p_measure_sid > 0 THEN
         BEGIN
            SELECT CASE WHEN ESA_SID = l_esa_sid THEN 0 ELSE 1 END
              INTO l_changed
              FROM VW_DBP_MEASURES
             WHERE MEASURE_SID = p_measure_sid AND COUNTRY_ID = p_country_id;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               l_changed := 0;
         END;

         UPDATE dbp_measures
            SET title            = p_title
              , descr            = p_descr
              , esa_sid          = l_esa_sid
              , source_sid       = l_source_sid
              , acc_princip_sid  = l_acc_princip_sid
              , adopt_status_sid = l_adopt_status_sid
          WHERE measure_sid = (SELECT measure_sid
                                 FROM VW_DBP_MEASURES
                                WHERE measure_sid = p_measure_sid AND country_id = p_country_id);

         IF SQL%ROWCOUNT > 0 THEN
            o_res := p_measure_sid;

            IF l_changed = 1 THEN
               DBP_GRID_DATA.calculateTable5AMeasures(p_country_id, NULL, NULL, l_changed);
            END IF;
         END IF;
      ELSE
         l_round_sid       := CORE_GETTERS.GETCURRENTROUNDSID(DBP_GETTERS.APP_ID);
         l_cty_version_sid := GD_GETTERS.getCountryVersionSid(p_country_id, l_round_sid);

         INSERT INTO dbp_measures(cty_version_sid
                                , round_sid
                                , title
                                , descr
                                , esa_sid
                                , source_sid
                                , acc_princip_sid
                                , adopt_status_sid)
              VALUES (l_cty_version_sid
                    , l_round_sid
                    , p_title
                    , p_descr
                    , l_esa_sid
                    , l_source_sid
                    , l_acc_princip_sid
                    , l_adopt_status_sid)
           RETURNING measure_sid
                INTO o_res;
      END IF;
   END;

   ----------------------------------------------------------------------------
   -- @name deleteMeasure
   -- @return number of rows deleted
   ----------------------------------------------------------------------------
   PROCEDURE deleteMeasure(p_measure_sid IN NUMBER, p_country_id IN VARCHAR2, o_res OUT NUMBER)
   IS
      l_res NUMBER := 0;
   BEGIN
      DELETE FROM dbp_measures
            WHERE measure_sid = (SELECT measure_sid
                                   FROM VW_DBP_MEASURES
                                  WHERE measure_sid = p_measure_sid AND country_id = p_country_id);

      o_res := SQL%ROWCOUNT;

      IF o_res > 0 THEN
         DBP_GRID_DATA.calculateTable5AMeasures(p_country_id, NULL, NULL, l_res);
      END IF;
   END;

   ----------------------------------------------------------------------------
   -- @name deleteMeasures
   -- @return number of rows deleted
   ----------------------------------------------------------------------------
   PROCEDURE deleteMeasures(p_country_id IN VARCHAR2, p_round_sid IN NUMBER, o_res OUT NUMBER)
   IS
   BEGIN
      IF p_round_sid = CORE_GETTERS.GETCURRENTROUNDSID(DBP_GETTERS.APP_ID) THEN
         DELETE FROM dbp_measures
               WHERE round_sid = p_round_sid
                 AND cty_version_sid = GD_GETTERS.getCountryVersionSid(p_country_id, p_round_sid);

         o_res := SQL%ROWCOUNT;
      END IF;
   END;

   PROCEDURE saveMeasureScale(p_country_id IN VARCHAR2, p_scale_sid IN NUMBER, o_res OUT NUMBER)
   IS
      l_round_sid       ROUNDS.ROUND_SID%TYPE;
      l_cty_version_sid GD_CTY_VERSIONS.CTY_VERSION_SID%TYPE;
   BEGIN
      o_res := 0;

      IF p_scale_sid != -1 THEN
         l_round_sid       := CORE_GETTERS.GETCURRENTROUNDSID(DBP_GETTERS.APP_ID);
         l_cty_version_sid := GD_GETTERS.getCountryVersionSid(P_COUNTRY_ID, l_ROUND_SID);

         UPDATE DBP_CTY_ROUND_SCALES
            SET SCALE_SID = p_scale_sid
          WHERE CTY_VERSION_SID = l_cty_version_sid AND ROUND_SID = l_round_sid;

         o_res             := SQL%ROWCOUNT;

         IF o_res = 0 THEN
            INSERT INTO DBP_CTY_ROUND_SCALES(CTY_VERSION_SID, ROUND_SID, SCALE_SID)
                 VALUES (l_cty_version_sid, l_round_sid, p_scale_sid);

            o_res := SQL%ROWCOUNT;
         END IF;
      END IF;
   END saveMeasureScale;


   PROCEDURE getWizardMeasures(p_country_id IN     VARCHAR2
                             , p_round_sid  IN     NUMBER
                             , o_cur           OUT SYS_REFCURSOR)
   IS
      l_version GD_CTY_VERSIONS.VERSION%TYPE
                   := GD_GETTERS.getCountryVersion(p_country_id, p_round_sid);
   BEGIN
      OPEN o_cur FOR
         SELECT m.measure_sid
              , m.round_sid
              , m.country_id
              , m.title
              , m.descr
              , COALESCE(m.source_sid, -1)       dbp_source_sid
              , COALESCE(m.esa_sid, -1)          esa_sid
              , COALESCE(m.acc_princip_sid, -1)  acc_princip_sid
              , COALESCE(m.adopt_status_sid, -1) adopt_status_sid
              , m.data
              , m.start_year
              , COALESCE(e.rev_exp_sid, 1)       rev_exp_sid
           FROM VW_DBP_MEASURES m LEFT OUTER JOIN dbp_esa e ON m.esa_sid = e.esa_sid
          WHERE m.country_id = p_country_id AND m.round_sid = p_round_sid AND m.VERSION = l_version;
   END getWizardMeasures;

   PROCEDURE saveMeasure(p_country_id           IN     VARCHAR2
                       , p_title                IN     VARCHAR2
                       , p_descr                IN     VARCHAR2
                       , p_source_sid           IN     NUMBER
                       , p_esa_sid              IN     NUMBER
                       , p_acc_princip_sid      IN     NUMBER
                       , p_adopt_status_sid     IN     NUMBER
                       , p_data                 IN     VARCHAR2
                       , p_start_year           IN     NUMBER
                       , p_year                 IN     NUMBER
                       , p_uploaded_measure_sid IN     NUMBER
                       , o_res                     OUT NUMBER)
   IS
      e_error       EXCEPTION;
      l_measure_sid NUMBER;
   BEGIN
      saveMeasureDetails(p_uploaded_measure_sid
                       , p_country_id
                       , p_title
                       , p_descr
                       , p_esa_sid
                       , p_source_sid
                       , p_acc_princip_sid
                       , p_adopt_status_sid
                       , l_measure_sid);

      IF l_measure_sid < 0 THEN
         RAISE e_error;
      END IF;

      o_res := 0;
      setMeasureValues(l_measure_sid
                     , p_country_id
                     , p_year
                     , p_start_year
                     , p_data
                     , o_res);

      IF o_res < 0 THEN
         RAISE e_error;
      END IF;

      o_res := 1;
   END saveMeasure;

   PROCEDURE uploadWizardMeasures(p_country_id IN     VARCHAR2
                                , p_scale_sid  IN     NUMBER
                                , p_measures   IN     MEASUREARRAY
                                , o_res           OUT NUMBER)
   IS
      e_error       EXCEPTION;
      l_measure_sid NUMBER;
      l_res         NUMBER;
      l_m           MEASUREOBJECT;
   BEGIN
      o_res := 0;

      IF p_scale_sid != -1 THEN
         saveMeasureScale(p_country_id, p_scale_sid, l_res);
      END IF;

      IF l_res > 0 THEN
         o_res := 1;
      END IF;

      FOR i IN 1 .. p_measures.COUNT LOOP
         l_m   := p_measures(i);

         l_res := 0;
         saveMeasure(p_country_id
                   , l_m.TITLE
                   , l_m.SHORT_DESCR
                   , l_m.SOURCE_SID
                   , l_m.ESA_SID
                   , l_m.ACC_PRINCIP_SID
                   , l_m.ADOPT_STATUS_SID
                   , l_m.DATA
                   , l_m.START_YEAR
                   , l_m.YEAR
                   , l_m.UPLOADED_MEASURE_SID
                   , l_res);
         o_res := o_res + l_res;
      END LOOP;
   END uploadWizardMeasures;
END;
/