/* Formatted on 12-Apr-23 11:50:25 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY DRM_MEASURE
AS
   /******************************************************************************
      NAME:      DRM_MEASURE
      PURPOSE:   Measure accessors
   ******************************************************************************/

   /**************************************************************************
    *********************** PRIVATE SECTION **********************************
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name getExerciseTypeId
   ----------------------------------------------------------------------------
   FUNCTION getExerciseTypeId(p_exercise_sid IN NUMBER)
      RETURN VARCHAR2
   IS
      l_ret  DBP_EXERCISES.EXERCISE_ID%TYPE;
   BEGIN
      BEGIN
         SELECT EXERCISE_ID
           INTO l_ret
           FROM DBP_EXERCISES
          WHERE EXERCISE_SID = p_exercise_sid;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_ret := NULL;
      END;

      RETURN l_ret;
   END getExerciseTypeId;

   ----------------------------------------------------------------------------
   -- @name getLatestRoundWithMeasures
   ----------------------------------------------------------------------------
   FUNCTION getLatestRoundWithMeasures(p_country_id IN VARCHAR2, p_round_sid IN NUMBER, p_history_offset IN NUMBER)
      RETURN NUMBER
   IS
      l_count      NUMBER(8);
      l_round_sid  ROUNDS.ROUND_SID%TYPE
                      := CORE_GETTERS.getLatestApplicationRound(DRM_GETTERS.APP_ID, p_round_sid, p_history_offset);
      l_offset     NUMBER(8) := p_history_offset;
   BEGIN
      WHILE l_round_sid != p_round_sid LOOP
         SELECT COUNT(*)
           INTO l_count
           FROM DRM_ARCHIVED_MEASURES M
          WHERE M.COUNTRY_ID = p_country_id AND M.ROUND_SID = l_round_sid;

         EXIT WHEN l_count > 0;
         l_offset := l_offset + 1;
         l_round_sid := CORE_GETTERS.getLatestApplicationRound(DRM_GETTERS.APP_ID, p_round_sid, l_offset);
      END LOOP;

      RETURN l_round_sid;
   END;

   /**************************************************************************
    *********************** PUBLIC SECTION ***********************************
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name copyPreviousRoundMeasures
   -- @return number of rows inserted
   ----------------------------------------------------------------------------
   PROCEDURE copyPreviousRoundMeasures(p_country_id IN VARCHAR2, p_round_sid IN NUMBER, o_res OUT NUMBER)
   IS
      l_previous_round  ROUNDS.ROUND_SID%TYPE := getLatestRoundWithMeasures(p_country_id, p_round_sid, 1);
   BEGIN
      DELETE FROM DRM_MEASURES
            WHERE COUNTRY_ID = p_country_id;

      INSERT INTO DRM_MEASURES(MEASURE_SID
                             , COUNTRY_ID
                             , TITLE
                             , DESCR
                             , ESA_SID
                             , ACC_PRINCIP_SID
                             , ADOPT_STATUS_SID
                             , DATA
                             , START_YEAR
                             , ONE_OFF_SID
                             , ONE_OFF_TYPE_SID
                             , IS_EU_FUNDED_SID
                             , EU_FUND_SID
                             , YEAR)
         SELECT AM.MEASURE_SID
              , AM.COUNTRY_ID
              , AM.TITLE
              , AM.DESCR
              , AM.ESA_SID
              , AM.ACC_PRINCIP_SID
              , AM.ADOPT_STATUS_SID
              , AM.DATA
              , AM.START_YEAR
              , AM.ONE_OFF_SID
              , AM.ONE_OFF_TYPE_SID
              , AM.IS_EU_FUNDED_SID
              , AM.EU_FUND_SID
              , AM.YEAR
           FROM DRM_ARCHIVED_MEASURES AM
          WHERE AM.ROUND_SID = l_previous_round AND AM.COUNTRY_ID = p_country_id;

      o_res := SQL%ROWCOUNT;
   END copyPreviousRoundMeasures;

   ----------------------------------------------------------------------------
   -- @name deleteMeasure
   -- @return number of rows deleted
   ----------------------------------------------------------------------------
   PROCEDURE deleteMeasure(p_measure_sid IN NUMBER, p_country_id IN VARCHAR2, o_res OUT NUMBER)
   IS
   BEGIN
      DELETE FROM drm_measures
            WHERE measure_sid = p_measure_sid AND country_id = p_country_id;

      o_res := SQL%ROWCOUNT;
   END;

   ----------------------------------------------------------------------------
   -- @name getWizardMeasures
   -- @return list of measures
   ----------------------------------------------------------------------------
   PROCEDURE getWizardMeasures(p_country_id IN VARCHAR2, o_cur OUT SYS_REFCURSOR)
   IS
      l_drm_exercise_sid  NUMBER := DBP_GETTERS.getExerciseSid('DRM');
   BEGIN
      OPEN o_cur FOR   SELECT l_drm_exercise_sid                                          exercise_sid
                            , m.measure_sid
                            , -1                                                          round_sid
                            , m.country_id
                            , m.title
                            , m.descr
                            , -1                                                          dbp_source_sid
                            , COALESCE(m.esa_sid, -1)                                     esa_sid
                            , COALESCE(m.acc_princip_sid, -1)                             acc_princip_sid
                            , COALESCE(m.adopt_status_sid, -1)                            adopt_status_sid
                            , m.data
                            , m.start_year
                            , COALESCE(m.one_off_sid, -1)                                 one_off_sid
                            , COALESCE(m.one_off_type_sid, -1)                            one_off_type_sid
                            , m.year
                            , COALESCE(e.rev_exp_sid, 1)                                  rev_exp_sid
                            , COALESCE(m.is_eu_funded_sid, -1)                            is_eu_funded_sid
                            , COALESCE(m.eu_fund_sid, -1)                                 eu_fund_sid
                            , LISTAGG(l.label_sid, ',') WITHIN GROUP (ORDER BY l.label_sid) label_sids
                         FROM drm_measures m
                              LEFT JOIN dbp_esa e ON m.esa_sid = e.esa_sid
                              LEFT JOIN drm_measure_labels l ON l.MEASURE_SID = m.MEASURE_SID
                        WHERE m.country_id = p_country_id
                     GROUP BY m.measure_sid
                            , m.country_id
                            , m.title
                            , m.descr
                            , m.esa_sid
                            , m.acc_princip_sid
                            , m.adopt_status_sid
                            , m.data
                            , m.start_year
                            , m.one_off_sid
                            , m.one_off_type_sid
                            , m.year
                            , e.rev_exp_sid
                            , m.is_eu_funded_sid
                            , m.eu_fund_sid;
   END getWizardMeasures;

   ----------------------------------------------------------------------------
   -- @name getWizardArchivedMeasures
   -- @return list of measures
   ----------------------------------------------------------------------------
   PROCEDURE getWizardArchivedMeasures(p_country_id      IN     VARCHAR2
                                     , o_cur                OUT SYS_REFCURSOR
                                     , p_round_sid       IN     NUMBER
                                     , p_history_offset  IN     NUMBER)
   IS
      l_drm_exercise_sid  NUMBER := DBP_GETTERS.getExerciseSid('DRM');
      l_round_sid         ROUNDS.ROUND_SID%TYPE
                             := getLatestRoundWithMeasures(p_country_id, p_round_sid, p_history_offset);
   BEGIN
      OPEN o_cur FOR   SELECT l_drm_exercise_sid                                          exercise_sid
                            , m.measure_sid
                            , -1                                                          round_sid
                            , m.country_id
                            , m.title
                            , m.descr
                            , -1                                                          dbp_source_sid
                            , COALESCE(m.esa_sid, -1)                                     esa_sid
                            , COALESCE(m.acc_princip_sid, -1)                             acc_princip_sid
                            , COALESCE(m.adopt_status_sid, -1)                            adopt_status_sid
                            , m.data
                            , m.start_year
                            , COALESCE(m.one_off_sid, -1)                                 one_off_sid
                            , COALESCE(m.one_off_type_sid, -1)                            one_off_type_sid
                            , m.year
                            , COALESCE(e.rev_exp_sid, 1)                                  rev_exp_sid
                            , COALESCE(m.is_eu_funded_sid, -1)                            is_eu_funded_sid
                            , COALESCE(m.eu_fund_sid, -1)                                 eu_fund_sid
                            , LISTAGG(l.label_sid, ',') WITHIN GROUP (ORDER BY l.label_sid) label_sids
                         FROM drm_archived_measures m
                              LEFT JOIN dbp_esa e ON m.esa_sid = e.esa_sid
                              LEFT JOIN drm_measure_labels l ON l.MEASURE_SID = m.MEASURE_SID
                        WHERE m.ROUND_SID = l_round_sid AND m.country_id = p_country_id
                     GROUP BY m.measure_sid
                            , m.country_id
                            , m.title
                            , m.descr
                            , m.esa_sid
                            , m.acc_princip_sid
                            , m.adopt_status_sid
                            , m.data
                            , m.start_year
                            , m.one_off_sid
                            , m.one_off_type_sid
                            , m.year
                            , e.rev_exp_sid
                            , m.is_eu_funded_sid
                            , m.eu_fund_sid;
   END getWizardArchivedMeasures;

   ----------------------------------------------------------------------------
   -- @name getMeasureDetails
   -- @return measure details
   ----------------------------------------------------------------------------
   PROCEDURE getMeasureDetails(p_measure_sid IN NUMBER, p_country_id IN VARCHAR2, o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR   SELECT m.measure_sid
                            , m.country_id
                            , m.data
                            , m.descr
                            , m.title
                            , COALESCE(m.esa_sid, -1)                                     esa_sid
                            , COALESCE(m.one_off_sid, -1)                                 one_off_sid
                            , COALESCE(m.one_off_type_sid, -1)                            one_off_type_sid
                            , COALESCE(m.acc_princip_sid, -1)                             acc_princip_sid
                            , COALESCE(m.adopt_status_sid, -1)                            adopt_status_sid
                            , CASE WHEN m.year > 0 THEN m.year END                        "YEAR"
                            , CASE WHEN m.start_year > 0 THEN m.start_year END            start_year
                            , COALESCE(m.is_eu_funded_sid, -1)                            is_eu_funded_sid
                            , COALESCE(m.eu_fund_sid, -1)                                 eu_fund_sid
                            , LISTAGG(l.label_sid, ',') WITHIN GROUP (ORDER BY l.label_sid) label_sids
                         FROM drm_measures m LEFT JOIN drm_measure_labels l ON l.MEASURE_SID = m.MEASURE_SID
                        WHERE m.measure_sid = p_measure_sid AND M.COUNTRY_ID = p_country_id
                     GROUP BY m.measure_sid
                            , m.country_id
                            , m.data
                            , m.descr
                            , m.title
                            , m.esa_sid
                            , m.one_off_sid
                            , m.one_off_type_sid
                            , m.acc_princip_sid
                            , m.adopt_status_sid
                            , m.year
                            , m.start_year
                            , m.is_eu_funded_sid
                            , m.eu_fund_sid;
   END;

   ----------------------------------------------------------------------------
   -- @name getMeasureDetailsArchived
   -- @return archived measure details
   ----------------------------------------------------------------------------
   PROCEDURE getMeasureDetailsArchived(p_round_sid      IN     NUMBER
                                     , p_storage_sid    IN     NUMBER
                                     , p_cust_text_sid  IN     NUMBER
                                     , p_storage_id     IN     VARCHAR2
                                     , p_measure_sid    IN     NUMBER
                                     , p_country_id     IN     VARCHAR2
                                     , o_cur               OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR   SELECT m.measure_sid
                            , m.country_id
                            , m.data
                            , m.descr
                            , m.title
                            , COALESCE(m.esa_sid, -1)                                     esa_sid
                            , COALESCE(m.one_off_sid, -1)                                 one_off_sid
                            , COALESCE(m.one_off_type_sid, -1)                            one_off_type_sid
                            , COALESCE(m.acc_princip_sid, -1)                             acc_princip_sid
                            , COALESCE(m.adopt_status_sid, -1)                            adopt_status_sid
                            , CASE WHEN m.year > 0 THEN m.year END                        "YEAR"
                            , CASE WHEN m.start_year > 0 THEN m.start_year END            start_year
                            , COALESCE(m.is_eu_funded_sid, -1)                            is_eu_funded_sid
                            , COALESCE(m.eu_fund_sid, -1)                                 eu_fund_sid
                            , LISTAGG(l.label_sid, ',') WITHIN GROUP (ORDER BY l.label_sid) label_sids
                         FROM drm_archived_measures m LEFT JOIN drm_measure_labels l ON l.MEASURE_SID = m.MEASURE_SID
                        WHERE m.measure_sid = p_measure_sid AND M.COUNTRY_ID = p_country_id AND m.round_sid = p_round_sid
                     GROUP BY m.measure_sid
                            , m.country_id
                            , m.data
                            , m.descr
                            , m.title
                            , m.esa_sid
                            , m.one_off_sid
                            , m.one_off_type_sid
                            , m.acc_princip_sid
                            , m.adopt_status_sid
                            , m.year
                            , m.start_year
                            , m.is_eu_funded_sid
                            , m.eu_fund_sid;
   END;

   ----------------------------------------------------------------------------
   -- @name getMeasures
   -- @return list of measures
   ----------------------------------------------------------------------------
   PROCEDURE getMeasures(p_country_id IN VARCHAR2, o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR   SELECT m.measure_sid
                            , m.country_id
                            , m.data
                            , m.descr
                            , m.start_year
                            , m.year
                            , m.title
                            , COALESCE(m.esa_sid, -1)                                     esa_sid
                            , COALESCE(m.one_off_sid, -1)                                 one_off_sid
                            , COALESCE(m.one_off_type_sid, -1)                            one_off_type_sid
                            , COALESCE(m.acc_princip_sid, -1)                             acc_princip_sid
                            , COALESCE(m.adopt_status_sid, -1)                            adopt_status_sid
                            , COALESCE(m.is_eu_funded_sid, -1)                            is_eu_funded_sid
                            , COALESCE(m.eu_fund_sid, -1)                                 eu_fund_sid
                            , LISTAGG(l.label_sid, ',') WITHIN GROUP (ORDER BY l.label_sid) label_sids
                         FROM drm_measures m LEFT JOIN drm_measure_labels l ON l.MEASURE_SID = m.MEASURE_SID
                        WHERE p_country_id IS NULL OR m.country_id = p_country_id
                     GROUP BY m.measure_sid
                            , m.country_id
                            , m.data
                            , m.descr
                            , m.start_year
                            , m.year
                            , m.title
                            , m.esa_sid
                            , m.one_off_sid
                            , m.one_off_type_sid
                            , m.acc_princip_sid
                            , m.adopt_status_sid
                            , m.is_eu_funded_sid
                            , m.eu_fund_sid
                     ORDER BY m.country_id, m.measure_sid;
   END;

   ----------------------------------------------------------------------------
   -- @name getMeasuresArchived
   -- @return list of archived measures
   ----------------------------------------------------------------------------
   PROCEDURE getMeasuresArchived(p_round_sid      IN     NUMBER
                               , p_storage_sid    IN     NUMBER
                               , p_cust_text_sid  IN     NUMBER
                               , p_storage_id     IN     VARCHAR2
                               , p_country_id     IN     VARCHAR2
                               , o_cur               OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR   SELECT m.measure_sid
                            , m.archived_measure_sid
                            , m.country_id
                            , m.data
                            , m.log_date
                            , m.round_sid
                            , m.descr
                            , m.start_year
                            , m.year
                            , m.title
                            , COALESCE(m.esa_sid, -1)                                     esa_sid
                            , COALESCE(m.one_off_sid, -1)                                 one_off_sid
                            , COALESCE(m.one_off_type_sid, -1)                            one_off_type_sid
                            , COALESCE(m.acc_princip_sid, -1)                             acc_princip_sid
                            , COALESCE(m.adopt_status_sid, -1)                            adopt_status_sid
                            , COALESCE(m.is_eu_funded_sid, -1)                            is_eu_funded_sid
                            , COALESCE(m.eu_fund_sid, -1)                                 eu_fund_sid
                            , LISTAGG(l.label_sid, ',') WITHIN GROUP (ORDER BY l.label_sid) label_sids
                         FROM drm_archived_measures m LEFT JOIN drm_measure_labels l ON l.MEASURE_SID = m.MEASURE_SID
                        WHERE (p_country_id IS NULL OR m.country_id = p_country_id) AND m.round_sid = p_round_sid
                     GROUP BY m.measure_sid
                            , m.archived_measure_sid
                            , m.country_id
                            , m.data
                            , m.log_date
                            , m.round_sid
                            , m.descr
                            , m.start_year
                            , m.year
                            , m.title
                            , m.esa_sid
                            , m.one_off_sid
                            , m.one_off_type_sid
                            , m.acc_princip_sid
                            , m.adopt_status_sid
                            , m.is_eu_funded_sid
                            , m.eu_fund_sid
                     ORDER BY m.country_id, m.measure_sid;
   END;

   ----------------------------------------------------------------------------
   -- @name saveMeasureDetails
   -- @return measure sid of saved/new measure
   ----------------------------------------------------------------------------
   PROCEDURE saveMeasureDetails(p_measure_sid       IN     NUMBER
                              , p_country_id        IN     VARCHAR2
                              , p_title             IN     VARCHAR2
                              , p_descr             IN     VARCHAR2
                              , p_esa_sid           IN     NUMBER
                              , p_one_off_sid       IN     NUMBER
                              , p_one_off_type_sid  IN     NUMBER
                              , p_acc_princip_sid   IN     NUMBER
                              , p_adopt_status_sid  IN     NUMBER
                              , p_label_sids        IN     SIDSLIST
                              , p_is_eu_funded_sid  IN     NUMBER
                              , p_eu_fund_sid       IN     NUMBER
                              , o_res                  OUT NUMBER
                              , p_force_insert      IN     NUMBER DEFAULT 0)
   IS
      l_esa_sid           DRM_MEASURES.ESA_SID%TYPE;
      l_one_off_sid       DRM_MEASURES.ONE_OFF_SID%TYPE;
      l_one_off_type_sid  DRM_MEASURES.ONE_OFF_TYPE_SID%TYPE;
      l_acc_princip_sid   DRM_MEASURES.ACC_PRINCIP_SID%TYPE;
      l_adopt_status_sid  DRM_MEASURES.ADOPT_STATUS_SID%TYPE;
      l_is_eu_funded_sid  DRM_MEASURES.IS_EU_FUNDED_SID%TYPE;
      l_eu_fund_sid       DRM_MEASURES.EU_FUND_SID%TYPE;
   BEGIN
      IF p_esa_sid = -1 THEN
         l_esa_sid := NULL;
      ELSE
         l_esa_sid := p_esa_sid;
      END IF;

      IF p_one_off_sid = -1 THEN
         l_one_off_sid := NULL;
      ELSE
         l_one_off_sid := p_one_off_sid;
      END IF;

      IF p_one_off_type_sid = -1 THEN
         l_one_off_type_sid := NULL;
      ELSE
         l_one_off_type_sid := p_one_off_type_sid;
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

      IF p_is_eu_funded_sid = -1 THEN
         l_is_eu_funded_sid := NULL;
      ELSE
         l_is_eu_funded_sid := p_is_eu_funded_sid;
      END IF;

      IF p_eu_fund_sid = -1 OR NOT p_is_eu_funded_sid = DFM_GETTERS.getOneOffYesSid THEN
         l_eu_fund_sid := NULL;
      ELSE
         l_eu_fund_sid := p_eu_fund_sid;
      END IF;

      o_res := 0;

      IF p_measure_sid > 0 AND p_force_insert = 0 THEN
         UPDATE drm_measures
            SET title = p_title
              , descr = p_descr
              , esa_sid = l_esa_sid
              , one_off_sid = l_one_off_sid
              , one_off_type_sid = l_one_off_type_sid
              , acc_princip_sid = l_acc_princip_sid
              , adopt_status_sid = l_adopt_status_sid
              , is_eu_funded_sid = l_is_eu_funded_sid
              , eu_fund_sid = l_eu_fund_sid
          WHERE measure_sid = p_measure_sid AND country_id = p_country_id;

         IF SQL%ROWCOUNT > 0 THEN
            o_res := p_measure_sid;
         END IF;
      ELSE
         INSERT INTO drm_measures(measure_sid
                                , country_id
                                , title
                                , descr
                                , esa_sid
                                , one_off_sid
                                , one_off_type_sid
                                , acc_princip_sid
                                , adopt_status_sid
                                , is_eu_funded_sid
                                , eu_fund_sid)
              VALUES (CASE WHEN p_measure_sid > 0 THEN p_measure_sid END
                    , p_country_id
                    , p_title
                    , p_descr
                    , l_esa_sid
                    , l_one_off_sid
                    , l_one_off_type_sid
                    , l_acc_princip_sid
                    , l_adopt_status_sid
                    , l_is_eu_funded_sid
                    , l_eu_fund_sid)
           RETURNING measure_sid
                INTO o_res;
      END IF;

      DELETE FROM DRM_MEASURE_LABELS
            WHERE measure_sid = o_res;

      INSERT INTO DRM_MEASURE_LABELS(measure_sid, label_sid)
         SELECT o_res, l.*
           FROM TABLE(p_label_sids) l;
   END;

   ----------------------------------------------------------------------------
   -- @name setMeasureValues
   -- @return number of rows updated
   ----------------------------------------------------------------------------
   PROCEDURE setMeasureValues(p_measure_sid  IN     NUMBER
                            , p_country_id   IN     VARCHAR2
                            , p_year         IN     NUMBER
                            , p_start_year   IN     NUMBER
                            , p_values       IN     VARCHAR2
                            , o_res             OUT NUMBER)
   IS
   BEGIN
      UPDATE drm_measures
         SET data = p_values, year = p_year, start_year = p_start_year
       WHERE measure_sid = p_measure_sid AND country_id = p_country_id;

      o_res := SQL%ROWCOUNT;
   END;

   ----------------------------------------------------------------------------
   -- @name saveMeasureScale
   -- @return number of rows updated/inserted
   ----------------------------------------------------------------------------
   PROCEDURE saveMeasureScale(p_country_id IN VARCHAR2, p_scale_sid IN NUMBER, o_res OUT NUMBER)
   IS
   BEGIN
      o_res := 0;

      IF p_scale_sid != -1 THEN
         UPDATE DRM_CTY_SCALES
            SET SCALE_SID = p_scale_sid
          WHERE COUNTRY_ID = p_country_id;

         o_res := SQL%ROWCOUNT;

         IF o_res = 0 THEN
            INSERT INTO DRM_CTY_SCALES(COUNTRY_ID, SCALE_SID)
                 VALUES (p_country_id, p_scale_sid);

            o_res := SQL%ROWCOUNT;
         END IF;
      END IF;
   END saveMeasureScale;

   ----------------------------------------------------------------------------
   -- @name uploadWizardMeasures
   -- @return number of rows inserted
   ----------------------------------------------------------------------------
   PROCEDURE uploadWizardMeasures(p_country_id  IN     VARCHAR2
                                , p_scale_sid   IN     NUMBER
                                , p_measures    IN     MEASUREARRAY
                                , o_res            OUT NUMBER)
   IS
      e_error            EXCEPTION;
      l_measure_sid      DRM_MEASURES.MEASURE_SID%TYPE;
      l_res              NUMBER(8);
      l_m                MEASUREOBJECT;
      l_exercise_id      DBP_EXERCISES.EXERCISE_ID%TYPE;
      l_is_dbp_in_round  NUMBER(2)
                            := CORE_COMMONS.isApplicationInRound(DBP_GETTERS.APP_ID, CORE_GETTERS.getCurrentRoundSid());
      l_dbp_cleaned      NUMBER(1) := 0;
      l_dbp_round_sid    NUMBER(8) := CORE_GETTERS.getCurrentRoundSid(DBP_GETTERS.APP_ID);
   BEGIN
      o_res := 0;

      DELETE FROM DRM_MEASURES
            WHERE COUNTRY_ID = p_country_id;

      IF p_scale_sid != -1 THEN
         saveMeasureScale(p_country_id, p_scale_sid, l_res);

         IF l_res > 0 THEN
            o_res := o_res + 1;
         END IF;

         IF l_is_dbp_in_round = 1 THEN
            -- This is wrong, it creates tight coupling. DRM must not depend on any DBP package
            DBP_MEASURE.saveMeasureScale(p_country_id, p_scale_sid, l_res);

            IF l_res > 0 THEN
               o_res := o_res + 1;
            END IF;
         END IF;
      END IF;

      FOR i IN 1 .. p_measures.COUNT LOOP
         l_m := p_measures(i);
         l_exercise_id := getExerciseTypeId(l_m.EXERCISE_SID);

         IF l_exercise_id = 'DRM' OR l_exercise_id = 'BOTH' THEN
            l_res := 0;
            saveMeasureDetails(l_m.UPLOADED_MEASURE_SID
                             , p_country_id
                             , l_m.TITLE
                             , l_m.SHORT_DESCR
                             , l_m.ESA_SID
                             , l_m.ONE_OFF_SID
                             , l_m.ONE_OFF_TYPE_SID
                             , l_m.ACC_PRINCIP_SID
                             , l_m.ADOPT_STATUS_SID
                             , l_m.LABEL_SIDS
                             , l_m.IS_EU_FUNDED_SID
                             , l_m.EU_FUND_SID
                             , l_measure_sid
                             , 1);

            IF l_measure_sid < 0 THEN
               RAISE e_error;
            END IF;

            setMeasureValues(l_measure_sid, p_country_id, l_m.YEAR, l_m.START_YEAR, l_m.DATA, l_res);

            IF l_res < 0 THEN
               RAISE e_error;
            END IF;

            o_res := o_res + l_res;
         END IF;

         IF l_is_dbp_in_round = 1 AND (l_exercise_id = 'DBP' OR l_exercise_id = 'BOTH') THEN
            l_res := 0;

            -- This is wrong, it creates tight coupling. DRM must not depend on any DBP package
            IF l_dbp_cleaned = 0 THEN
               DBP_MEASURE.deleteMeasures(p_country_id, l_dbp_round_sid, l_res);
               o_res := o_res + l_res;
               l_dbp_cleaned := 1;
            END IF;

            DBP_MEASURE.saveMeasure(p_country_id
                                  , l_m.TITLE
                                  , l_m.SHORT_DESCR
                                  , l_m.SOURCE_SID
                                  , l_m.ESA_SID
                                  , l_m.ACC_PRINCIP_SID
                                  , l_m.ADOPT_STATUS_SID
                                  , l_m.DATA
                                  , l_m.START_YEAR
                                  , l_m.YEAR
                                  , -1
                                  , l_res);
            o_res := o_res + l_res;
         END IF;
      END LOOP;
   END uploadWizardMeasures;
END;
/