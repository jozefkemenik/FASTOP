/* Formatted on 03-09-2021 18:56:19 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY DFM_MEASURE
AS
   /******************************************************************************
      NAME:      DFM_MEASURE
      PURPOSE:   Measure accessors
   ******************************************************************************/

   ----------------------------------------------------------------------------
   -- @name deleteMeasure
   -- @return number of rows deleted
   ----------------------------------------------------------------------------
   PROCEDURE deleteMeasure(p_measure_sid IN NUMBER, p_country_id IN VARCHAR2, o_res OUT NUMBER)
   IS
   BEGIN
      DELETE FROM dfm_measures
            WHERE measure_sid = p_measure_sid AND country_id = p_country_id;

      o_res := SQL%ROWCOUNT;
   END;

   ----------------------------------------------------------------------------
   -- @name getAllMeasures
   -- @return list of aggregated measures
   ----------------------------------------------------------------------------
   PROCEDURE getAllMeasures(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT m.country_id
                , dfm_commons.tabagg(CAST(COLLECT(m.data) AS VARCHARLIST)) AS data
                , COALESCE(m.esa95_sid, -1)                              esa_sid
                , COALESCE(m.status_sid, -1)                             status_sid
                , COALESCE(m.need_research_sid, -1)                      need_research_sid
                , COALESCE(m.one_off_sid, -1)                            one_off_sid
                , COALESCE(m.one_off_type_sid, -1)                       one_off_type_sid
                , COALESCE(m.one_off_disagree_sid, -1)                   one_off_disagree_sid
                , CASE WHEN m.year > 0 THEN m.year END                   year
                , CASE WHEN m.start_year > 0 THEN m.start_year END       start_year
                , CASE WHEN m.adopt_date_yr > 0 THEN m.adopt_date_yr END adopt_date_yr
             FROM country_groups cg INNER JOIN dfm_measures m ON cg.country_id = m.country_id
            WHERE cg.country_group_id = 'EU'
         GROUP BY m.country_id
                , esa95_sid
                , status_sid
                , need_research_sid
                , one_off_sid
                , one_off_type_sid
                , one_off_disagree_sid
                , year
                , start_year
                , adopt_date_yr;
   END;

   ----------------------------------------------------------------------------
   -- @name getAllMeasuresArchived
   -- @return list of aggregated archived measures
   ----------------------------------------------------------------------------
   PROCEDURE getAllMeasuresArchived(p_round_sid     IN OUT NUMBER
                                  , p_storage_sid   IN OUT NUMBER
                                  , p_cust_text_sid IN     NUMBER
                                  , p_storage_id    IN     VARCHAR2
                                  , o_cur              OUT SYS_REFCURSOR)
   IS
   BEGIN
      IF p_storage_id IS NOT NULL THEN
         dfm_getters.getRoundStorage(p_storage_id, p_round_sid, p_storage_sid);
      END IF;

      OPEN o_cur FOR
           SELECT m.country_id
                , dfm_commons.tabagg(CAST(COLLECT(m.data) AS VARCHARLIST)) AS data
                , COALESCE(m.esa_sid, -1)                                esa_sid
                , COALESCE(m.status_sid, -1)                             status_sid
                , COALESCE(m.need_research_sid, -1)                      need_research_sid
                , COALESCE(m.one_off_sid, -1)                            one_off_sid
                , COALESCE(m.one_off_type_sid, -1)                       one_off_type_sid
                , COALESCE(m.one_off_disagree_sid, -1)                   one_off_disagree_sid
                , CASE WHEN m.year > 0 THEN m.year END                   year
                , CASE WHEN m.start_year > 0 THEN m.start_year END       start_year
                , CASE WHEN m.adopt_date_yr > 0 THEN m.adopt_date_yr END adopt_date_yr
             FROM country_groups cg
                  INNER JOIN dfm_archived_measures m ON cg.country_id = m.country_id
            WHERE cg.country_group_id = 'EU'
              AND m.round_sid = p_round_sid
              AND M.STORAGE_SID = p_storage_sid
              AND (M.CUST_TEXT_SID IS NULL OR M.CUST_TEXT_SID = p_cust_text_sid)
         GROUP BY m.country_id
                , esa_sid
                , status_sid
                , need_research_sid
                , one_off_sid
                , one_off_type_sid
                , one_off_disagree_sid
                , year
                , start_year
                , adopt_date_yr;
   END;

   ----------------------------------------------------------------------------
   -- @name getCountryMeasures
   -- @return list of measures
   ----------------------------------------------------------------------------
   PROCEDURE getCountryMeasures(p_country_id IN VARCHAR2, o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR SELECT m.measure_sid
                          , m.title
                          , m.data
                          , m.country_id
                          , m.short_descr                                    descr
                          , COALESCE(m.esa95_sid, -1)                        esa_sid
                          , COALESCE(m.status_sid, -1)                       status_sid
                          , COALESCE(m.one_off_sid, -1)                      one_off_sid
                          , COALESCE(m.one_off_type_sid, -1)                 one_off_type_sid
                          , CASE WHEN m.start_year > 0 THEN m.start_year END start_year
                       FROM dfm_measures m
                      WHERE m.country_id = p_country_id;
   END;

   ----------------------------------------------------------------------------
   -- @name getCountryMeasuresArchived
   -- @return list of archived measures
   ----------------------------------------------------------------------------
   PROCEDURE getCountryMeasuresArchived(p_round_sid     IN OUT NUMBER
                                      , p_storage_sid   IN OUT NUMBER
                                      , p_cust_text_sid IN     NUMBER
                                      , p_storage_id    IN     VARCHAR2
                                      , p_country_id    IN     VARCHAR2
                                      , o_cur              OUT SYS_REFCURSOR)
   IS
   BEGIN
      IF p_storage_id IS NOT NULL THEN
         dfm_getters.getRoundStorage(p_storage_id, p_round_sid, p_storage_sid);
      END IF;

      OPEN o_cur FOR
         SELECT m.measure_sid
              , m.title
              , m.data
              , m.country_id
              , m.short_descr                                    descr
              , COALESCE(m.esa_sid, -1)                          esa_sid
              , COALESCE(m.status_sid, -1)                       status_sid
              , COALESCE(m.one_off_sid, -1)                      one_off_sid
              , COALESCE(m.one_off_type_sid, -1)                 one_off_type_sid
              , CASE WHEN m.start_year > 0 THEN m.start_year END start_year
           FROM dfm_archived_measures m
          WHERE m.country_id = p_country_id
            AND m.round_sid = p_round_sid
            AND M.STORAGE_SID = p_storage_sid
            AND (M.CUST_TEXT_SID IS NULL OR M.CUST_TEXT_SID = p_cust_text_sid);
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
      OPEN o_cur FOR
           SELECT m.measure_sid
                , m.title
                , m.comments
                , m.short_descr                                               descr
                , m.info_src
                , m.esa95_comments                                            esa_comments
                , m.one_off_comments
                , m.quant_comments
                , m.data
                , m.country_id
                , COALESCE(m.esa95_sid, -1)                                   esa_sid
                , COALESCE(m.status_sid, -1)                                  status_sid
                , COALESCE(m.need_research_sid, -1)                           need_research_sid
                , COALESCE(m.one_off_sid, -1)                                 one_off_sid
                , COALESCE(m.one_off_type_sid, -1)                            one_off_type_sid
                , COALESCE(m.one_off_disagree_sid, -1)                        one_off_disagree_sid
                , COALESCE(m.oo_principle_sid, -1)                            oo_principle_sid
                , CASE WHEN m.year > 0 THEN m.year END                        year
                , CASE WHEN m.start_year > 0 THEN m.start_year END            start_year
                , CASE WHEN m.adopt_date_yr > 0 THEN m.adopt_date_yr END      adopt_date_yr
                , COALESCE(m.adopt_date_mh, -1)                               adopt_date_mh
                , COALESCE(m.is_eu_funded_sid, -1)                            is_eu_funded_sid
                , COALESCE(m.eu_fund_sid, -1)                                 eu_fund_sid
                , LISTAGG(l.label_sid, ',') WITHIN GROUP (ORDER BY l.label_sid) label_sids
             FROM dfm_measures m LEFT JOIN dfm_measure_labels l ON l.MEASURE_SID = m.MEASURE_SID
            WHERE m.measure_sid = p_measure_sid AND M.COUNTRY_ID = p_country_id
         GROUP BY m.measure_sid
                , m.title
                , m.comments
                , m.short_descr
                , m.info_src
                , m.esa95_comments
                , m.one_off_comments
                , m.quant_comments
                , m.data
                , m.country_id
                , m.esa95_sid
                , m.status_sid
                , m.need_research_sid
                , m.one_off_sid
                , m.one_off_type_sid
                , m.one_off_disagree_sid
                , m.oo_principle_sid
                , m.year
                , m.start_year
                , m.adopt_date_yr
                , m.adopt_date_mh
                , m.is_eu_funded_sid
                , m.eu_fund_sid;
   END;

   ----------------------------------------------------------------------------
   -- @name getMeasureDetailsArchived
   -- @return archived measure details
   ----------------------------------------------------------------------------
   PROCEDURE getMeasureDetailsArchived(p_round_sid     IN OUT NUMBER
                                     , p_storage_sid   IN OUT NUMBER
                                     , p_cust_text_sid IN     NUMBER
                                     , p_storage_id    IN     VARCHAR2
                                     , p_measure_sid   IN     NUMBER
                                     , p_country_id    IN     VARCHAR2
                                     , o_cur              OUT SYS_REFCURSOR)
   IS
   BEGIN
      IF p_storage_id IS NOT NULL THEN
         dfm_getters.getRoundStorage(p_storage_id, p_round_sid, p_storage_sid);
      END IF;

      OPEN o_cur FOR
           SELECT m.measure_sid
                , m.title
                , m.comments
                , m.short_descr                                               descr
                , m.info_src
                , m.esa_comments
                , m.one_off_comments
                , m.quant_comments
                , m.data
                , m.country_id
                , COALESCE(m.esa_sid, -1)                                     esa_sid
                , COALESCE(m.status_sid, -1)                                  status_sid
                , COALESCE(m.need_research_sid, -1)                           need_research_sid
                , COALESCE(m.one_off_sid, -1)                                 one_off_sid
                , COALESCE(m.one_off_type_sid, -1)                            one_off_type_sid
                , COALESCE(m.one_off_disagree_sid, -1)                        one_off_disagree_sid
                , COALESCE(m.oo_principle_sid, -1)                            oo_principle_sid
                , CASE WHEN m.year > 0 THEN m.year END                        year
                , CASE WHEN m.start_year > 0 THEN m.start_year END            start_year
                , CASE WHEN m.adopt_date_yr > 0 THEN m.adopt_date_yr END      adopt_date_yr
                , COALESCE(m.adopt_date_mh, -1)                               adopt_date_mh
                , COALESCE(m.is_eu_funded_sid, -1)                            is_eu_funded_sid
                , COALESCE(m.eu_fund_sid, -1)                                 eu_fund_sid
                , LISTAGG(l.label_sid, ',') WITHIN GROUP (ORDER BY l.label_sid) label_sids
             FROM dfm_archived_measures m
                  LEFT JOIN dfm_measure_labels l ON l.MEASURE_SID = m.MEASURE_SID
            WHERE m.measure_sid = p_measure_sid
              AND M.COUNTRY_ID = p_country_id
              AND m.round_sid = p_round_sid
              AND M.STORAGE_SID = p_storage_sid
              AND (M.CUST_TEXT_SID IS NULL OR M.CUST_TEXT_SID = p_cust_text_sid)
         GROUP BY m.measure_sid
                , m.title
                , m.comments
                , m.short_descr
                , m.info_src
                , m.esa_comments
                , m.one_off_comments
                , m.quant_comments
                , m.data
                , m.country_id
                , m.esa_sid
                , m.status_sid
                , m.need_research_sid
                , m.one_off_sid
                , m.one_off_type_sid
                , m.one_off_disagree_sid
                , m.oo_principle_sid
                , m.year
                , m.start_year
                , m.adopt_date_yr
                , m.adopt_date_mh
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
      OPEN o_cur FOR
           SELECT m.measure_sid
                , m.adopt_date_yr
                , COALESCE(m.adopt_date_mh, -1)                               adopt_date_mh
                , m.comments
                , m.country_id
                , m.data
                , m.esa95_comments                                            esa_comments
                , m.info_src
                , m.is_public
                , m.one_off_comments
                , m.quant_comments
                , m.short_descr                                               descr
                , m.start_year
                , m.year
                , m.title
                , COALESCE(m.esa95_sid, -1)                                   esa_sid
                , COALESCE(m.status_sid, -1)                                  status_sid
                , COALESCE(m.need_research_sid, -1)                           need_research_sid
                , COALESCE(m.one_off_sid, -1)                                 one_off_sid
                , COALESCE(m.one_off_disagree_sid, -1)                        one_off_disagree_sid
                , COALESCE(m.one_off_type_sid, -1)                            one_off_type_sid
                , COALESCE(m.oo_principle_sid, -1)                            oo_principle_sid
                , COALESCE(m.rev_exp_sid, -1)                                 rev_exp_sid
                , COALESCE(m.is_eu_funded_sid, -1)                            is_eu_funded_sid
                , COALESCE(m.eu_fund_sid, -1)                                 eu_fund_sid
                , LISTAGG(l.label_sid, ',') WITHIN GROUP (ORDER BY l.label_sid) label_sids
             FROM dfm_measures m LEFT JOIN dfm_measure_labels l ON l.MEASURE_SID = m.MEASURE_SID
            WHERE p_country_id IS NULL OR m.country_id = p_country_id
         GROUP BY m.measure_sid
                , m.adopt_date_yr
                , m.adopt_date_mh
                , m.comments
                , m.country_id
                , m.data
                , m.esa95_comments
                , m.info_src
                , m.is_public
                , m.one_off_comments
                , m.quant_comments
                , m.short_descr
                , m.start_year
                , m.year
                , m.title
                , m.esa95_sid
                , m.status_sid
                , m.need_research_sid
                , m.one_off_sid
                , m.one_off_disagree_sid
                , m.one_off_type_sid
                , m.oo_principle_sid
                , m.rev_exp_sid
                , m.is_eu_funded_sid
                , m.eu_fund_sid
         ORDER BY m.country_id, m.measure_sid;
   END;

   ----------------------------------------------------------------------------
   -- @name getMeasuresArchived
   -- @return list of archived measures
   ----------------------------------------------------------------------------
   PROCEDURE getMeasuresArchived(p_round_sid     IN OUT NUMBER
                               , p_storage_sid   IN OUT NUMBER
                               , p_cust_text_sid IN     NUMBER
                               , p_storage_id    IN     VARCHAR2
                               , p_country_id    IN     VARCHAR2
                               , o_cur              OUT SYS_REFCURSOR)
   IS
   BEGIN
      IF p_storage_id IS NOT NULL THEN
         dfm_getters.getRoundStorage(p_storage_id, p_round_sid, p_storage_sid);
      END IF;

      OPEN o_cur FOR
           SELECT m.measure_sid
                , m.adopt_date_yr
                , COALESCE(m.adopt_date_mh, -1)                               adopt_date_mh
                , m.archived_measure_sid
                , m.comments
                , m.country_id
                , m.data
                , m.esa_comments
                , m.info_src
                , CASE WHEN is_public <= 0 THEN 0 ELSE 1 END                  is_public
                , m.log_date
                , m.one_off_comments
                , m.quant_comments
                , m.round_sid
                , m.short_descr                                               descr
                , m.start_year
                , m.year
                , m.title
                , COALESCE(m.esa_sid, -1)                                     esa_sid
                , COALESCE(m.status_sid, -1)                                  status_sid
                , COALESCE(m.need_research_sid, -1)                           need_research_sid
                , COALESCE(m.one_off_sid, -1)                                 one_off_sid
                , COALESCE(m.one_off_disagree_sid, -1)                        one_off_disagree_sid
                , COALESCE(m.one_off_type_sid, -1)                            one_off_type_sid
                , COALESCE(m.oo_principle_sid, -1)                            oo_principle_sid
                , COALESCE(m.rev_exp_sid, -1)                                 rev_exp_sid
                , COALESCE(m.is_eu_funded_sid, -1)                            is_eu_funded_sid
                , COALESCE(m.eu_fund_sid, -1)                                 eu_fund_sid
                , LISTAGG(l.label_sid, ',') WITHIN GROUP (ORDER BY l.label_sid) label_sids
             FROM dfm_archived_measures m
                  LEFT JOIN dfm_measure_labels l ON l.MEASURE_SID = m.MEASURE_SID
            WHERE (p_country_id IS NULL OR m.country_id = p_country_id)
              AND m.round_sid = p_round_sid
              AND M.STORAGE_SID = p_storage_sid
              AND (M.CUST_TEXT_SID IS NULL OR M.CUST_TEXT_SID = p_cust_text_sid)
         GROUP BY m.measure_sid
                , m.adopt_date_yr
                , m.adopt_date_mh
                , m.archived_measure_sid
                , m.comments
                , m.country_id
                , m.data
                , m.esa_comments
                , m.info_src
                , m.is_public
                , m.log_date
                , m.one_off_comments
                , m.quant_comments
                , m.round_sid
                , m.short_descr
                , m.start_year
                , m.year
                , m.title
                , m.esa_sid
                , m.status_sid
                , m.need_research_sid
                , m.one_off_sid
                , m.one_off_disagree_sid
                , m.one_off_type_sid
                , m.oo_principle_sid
                , m.rev_exp_sid
                , m.is_eu_funded_sid
                , m.eu_fund_sid
         ORDER BY m.country_id, m.measure_sid;
   END;

   ----------------------------------------------------------------------------
   -- @name getTransparencyReportMeasures
   -- @return list of transparency report measures (revenue measures archived in FINAL storage)
   ----------------------------------------------------------------------------
   PROCEDURE getTransparencyReportMeasures(o_cur           OUT SYS_REFCURSOR
                                         , p_country_id IN     VARCHAR2
                                         , p_round_sid  IN     NUMBER DEFAULT NULL)
   IS
      l_round_sid   ROUNDS.ROUND_SID%TYPE;
      l_storage_sid STORAGES.STORAGE_SID%TYPE;
   BEGIN
      dfm_getters.getRoundStorage(CORE_GETTERS.FINAL_STORAGE_ID, l_round_sid, l_storage_sid);

      IF p_round_sid IS NOT NULL THEN
         l_round_sid := p_round_sid;
      END IF;

      OPEN o_cur FOR
           SELECT m.measure_sid
                , m.adopt_date_yr
                , COALESCE(m.adopt_date_mh, -1)                               adopt_date_mh
                , m.archived_measure_sid
                , m.comments
                , m.country_id
                , m.data
                , m.esa_comments
                , m.info_src
                , CASE WHEN m.is_public <= 0 THEN 0 ELSE 1 END                is_public
                , m.log_date
                , m.one_off_comments
                , m.quant_comments
                , m.round_sid
                , m.short_descr                                               descr
                , m.start_year
                , m.year
                , m.title
                , COALESCE(m.esa_sid, -1)                                     esa_sid
                , COALESCE(m.status_sid, -1)                                  status_sid
                , COALESCE(m.need_research_sid, -1)                           need_research_sid
                , COALESCE(m.one_off_sid, -1)                                 one_off_sid
                , COALESCE(m.one_off_disagree_sid, -1)                        one_off_disagree_sid
                , COALESCE(m.one_off_type_sid, -1)                            one_off_type_sid
                , COALESCE(m.oo_principle_sid, -1)                            oo_principle_sid
                , COALESCE(m.rev_exp_sid, -1)                                 rev_exp_sid
                , COALESCE(m.is_eu_funded_sid, -1)                            is_eu_funded_sid
                , COALESCE(m.eu_fund_sid, -1)                                 eu_fund_sid
                , LISTAGG(l.label_sid, ',') WITHIN GROUP (ORDER BY l.label_sid) label_sids
             FROM VW_DFM_ARCHIVE_MEASURES m
                  LEFT JOIN dfm_measure_labels l ON l.MEASURE_SID = m.MEASURE_SID
            WHERE M.COUNTRY_ID = p_country_id
              AND M.ROUND_SID = l_round_sid
              AND M.STORAGE_SID = l_storage_sid
              AND M.REV_EXP_ID = 'REV'
              AND M.STATUS_ID = 'ACTIVE'
         GROUP BY m.measure_sid
                , m.adopt_date_yr
                , m.adopt_date_mh
                , m.archived_measure_sid
                , m.comments
                , m.country_id
                , m.data
                , m.esa_comments
                , m.info_src
                , m.is_public
                , m.log_date
                , m.one_off_comments
                , m.quant_comments
                , m.round_sid
                , m.short_descr
                , m.start_year
                , m.year
                , m.title
                , m.esa_sid
                , m.status_sid
                , m.need_research_sid
                , m.one_off_sid
                , m.one_off_disagree_sid
                , m.one_off_type_sid
                , m.oo_principle_sid
                , m.rev_exp_sid
                , m.is_eu_funded_sid
                , m.eu_fund_sid;
   END;

   ----------------------------------------------------------------------------
   -- @name saveMeasureDetails
   -- @return measure sid of saved/new measure
   ----------------------------------------------------------------------------
   PROCEDURE saveMeasureDetails(p_measure_sid          IN     NUMBER
                              , p_country_id           IN     VARCHAR2
                              , p_status_sid           IN     NUMBER
                              , p_need_research_sid    IN     NUMBER
                              , p_title                IN     VARCHAR2
                              , p_descr                IN     VARCHAR2
                              , p_info_src             IN     VARCHAR2
                              , p_adopt_date_yr        IN     NUMBER
                              , p_adopt_date_mh        IN     NUMBER
                              , p_comments             IN     VARCHAR2
                              , p_rev_exp_sid          IN     NUMBER
                              , p_esa_sid              IN     NUMBER
                              , p_esa_comments         IN     VARCHAR2
                              , p_one_off_sid          IN     NUMBER
                              , p_one_off_type_sid     IN     NUMBER
                              , p_one_off_disagree_sid IN     NUMBER
                              , p_one_off_comments     IN     VARCHAR2
                              , p_quant_comments       IN     VARCHAR2
                              , p_oo_principle_sid     IN     NUMBER
                              , p_label_sids           IN     SIDSLIST
                              , p_is_eu_funded_sid     IN     NUMBER
                              , p_eu_fund_sid          IN     NUMBER
                              , p_is_uploaded          IN     VARCHAR2 DEFAULT NULL
                              , o_res                     OUT NUMBER)
   IS
      l_status_sid           DFM_MEASURES.STATUS_SID%TYPE;
      l_need_research_sid    DFM_MEASURES.NEED_RESEARCH_SID%TYPE;
      l_adopt_date_yr        DFM_MEASURES.ADOPT_DATE_YR%TYPE;
      l_adopt_date_mh        DFM_MEASURES.ADOPT_DATE_MH%TYPE;
      l_rev_exp_sid          DFM_MEASURES.REV_EXP_SID%TYPE;
      l_esa_sid              DFM_MEASURES.ESA95_SID%TYPE;
      l_one_off_sid          DFM_MEASURES.ONE_OFF_SID%TYPE;
      l_one_off_type_sid     DFM_MEASURES.ONE_OFF_TYPE_SID%TYPE;
      l_one_off_disagree_sid DFM_MEASURES.ONE_OFF_DISAGREE_SID%TYPE;
      l_oo_principle_sid     DFM_MEASURES.OO_PRINCIPLE_SID%TYPE;
      l_is_eu_funded_sid     DFM_MEASURES.IS_EU_FUNDED_SID%TYPE;
      l_eu_fund_sid          DFM_MEASURES.EU_FUND_SID%TYPE;
   BEGIN
      IF p_status_sid = -1 THEN
         l_status_sid := NULL;
      ELSE
         l_status_sid := p_status_sid;
      END IF;

      IF p_need_research_sid = -1 THEN
         l_need_research_sid := NULL;
      ELSE
         l_need_research_sid := p_need_research_sid;
      END IF;

      IF p_adopt_date_yr = -1 THEN
         l_adopt_date_yr := NULL;
      ELSE
         l_adopt_date_yr := p_adopt_date_yr;
      END IF;

      IF p_adopt_date_mh = -1 THEN
         l_adopt_date_mh := NULL;
      ELSE
         l_adopt_date_mh := p_adopt_date_mh;
      END IF;

      IF p_rev_exp_sid = -1 THEN
         l_rev_exp_sid := NULL;
      ELSE
         l_rev_exp_sid := p_rev_exp_sid;
      END IF;

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

      IF p_one_off_disagree_sid = -1 THEN
         l_one_off_disagree_sid := NULL;
      ELSE
         l_one_off_disagree_sid := p_one_off_disagree_sid;
      END IF;

      IF p_oo_principle_sid = -1 THEN
         l_oo_principle_sid := NULL;
      ELSE
         l_oo_principle_sid := p_oo_principle_sid;
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

      IF p_measure_sid > 0 THEN
         UPDATE dfm_measures
            SET status_sid           = l_status_sid
              , need_research_sid    = l_need_research_sid
              , title                = p_title
              , short_descr          = p_descr
              , info_src             = p_info_src
              , adopt_date_yr        = l_adopt_date_yr
              , adopt_date_mh        = l_adopt_date_mh
              , comments             = p_comments
              , rev_exp_sid          = l_rev_exp_sid
              , esa95_sid            = l_esa_sid
              , esa95_comments       = p_esa_comments
              , one_off_sid          = l_one_off_sid
              , one_off_type_sid     = l_one_off_type_sid
              , one_off_disagree_sid = l_one_off_disagree_sid
              , one_off_comments     = p_one_off_comments
              , quant_comments       = p_quant_comments
              , oo_principle_sid     = l_oo_principle_sid
              , is_uploaded          = p_is_uploaded
              , is_eu_funded_sid     = l_is_eu_funded_sid
              , eu_fund_sid          = l_eu_fund_sid
          WHERE measure_sid = p_measure_sid AND country_id = p_country_id;

         IF SQL%ROWCOUNT > 0 THEN
            o_res := p_measure_sid;
         END IF;
      ELSE
         INSERT INTO dfm_measures(country_id
                                , status_sid
                                , need_research_sid
                                , title
                                , short_descr
                                , info_src
                                , adopt_date_yr
                                , adopt_date_mh
                                , comments
                                , rev_exp_sid
                                , esa95_sid
                                , esa95_comments
                                , one_off_sid
                                , one_off_type_sid
                                , one_off_disagree_sid
                                , one_off_comments
                                , quant_comments
                                , oo_principle_sid
                                , is_uploaded
                                , is_eu_funded_sid
                                , eu_fund_sid)
              VALUES (p_country_id
                    , l_status_sid
                    , l_need_research_sid
                    , p_title
                    , p_descr
                    , p_info_src
                    , l_adopt_date_yr
                    , l_adopt_date_mh
                    , p_comments
                    , l_rev_exp_sid
                    , l_esa_sid
                    , p_esa_comments
                    , l_one_off_sid
                    , l_one_off_type_sid
                    , l_one_off_disagree_sid
                    , p_one_off_comments
                    , p_quant_comments
                    , l_oo_principle_sid
                    , p_is_uploaded
                    , l_is_eu_funded_sid
                    , l_eu_fund_sid)
           RETURNING measure_sid
                INTO o_res;
      END IF;

      DELETE FROM DFM_MEASURE_LABELS
            WHERE measure_sid = o_res;

      INSERT INTO DFM_MEASURE_LABELS(measure_sid, label_sid)
         SELECT o_res, l.*
           FROM TABLE(p_label_sids) l;
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
   BEGIN
      UPDATE dfm_measures
         SET data = p_values, year = p_year, start_year = p_start_year
       WHERE measure_sid = p_measure_sid AND country_id = p_country_id;

      o_res := SQL%ROWCOUNT;
   END;


   ----------------------------------------------------------------------------
   -- @name saveTransparencyReport
   -- @return number of rows updated
   ----------------------------------------------------------------------------
   PROCEDURE saveTransparencyReport(p_country_id   IN     VARCHAR2
                                  , p_measure_sids IN     NUMBERSTABLE
                                  , o_res             OUT NUMBER)
   IS
      l_round_sid   ROUNDS.ROUND_SID%TYPE;
      l_storage_sid STORAGES.STORAGE_SID%TYPE;
   BEGIN
      o_res := 0;

      dfm_getters.getRoundStorage(CORE_GETTERS.FINAL_STORAGE_ID, l_round_sid, l_storage_sid);

      -- uncheck not selected
      UPDATE DFM_ARCHIVED_MEASURES
         SET IS_PUBLIC = 0
       WHERE COUNTRY_ID = p_country_id
         AND ROUND_SID = l_round_sid
         AND STORAGE_SID = l_storage_sid
         AND IS_PUBLIC = 1;

      o_res := SQL%ROWCOUNT;

      -- check selected
      FOR i IN 1 .. p_measure_sids.COUNT LOOP
         UPDATE DFM_ARCHIVED_MEASURES
            SET IS_PUBLIC = 1
          WHERE COUNTRY_ID = p_country_id
            AND ROUND_SID = l_round_sid
            AND STORAGE_SID = l_storage_sid
            AND MEASURE_SID = p_measure_sids(i);

         o_res := o_res + SQL%ROWCOUNT;
      END LOOP;
   END saveTransparencyReport;

   PROCEDURE uploadWizardMeasures(p_country_id IN     VARCHAR2
                                , p_scale_sid  IN     NUMBER
                                , p_measures   IN     MEASUREARRAY
                                , o_res           OUT NUMBER)
   IS
      e_error       EXCEPTION;
      l_measure_sid DFM_MEASURES.MEASURE_SID%TYPE;
      l_res         NUMBER(8);
      l_m           MEASUREOBJECT;
   BEGIN
      o_res := 0;

      FOR i IN 1 .. p_measures.COUNT LOOP
         l_m   := p_measures(i);

         saveMeasureDetails(l_m.UPLOADED_MEASURE_SID
                          , p_country_id
                          , l_m.STATUS_SID
                          , l_m.NEED_RESEARCH_SID
                          , l_m.TITLE
                          , l_m.SHORT_DESCR
                          , l_m.INFO_SRC
                          , l_m.ADOPT_DATE_YR
                          , l_m.ADOPT_DATE_MH
                          , l_m.COMMENTS
                          , l_m.REV_EXP_SID
                          , l_m.ESA_SID
                          , l_m.ESA_COMMENTS
                          , l_m.ONE_OFF_SID
                          , l_m.ONE_OFF_TYPE_SID
                          , l_m.ONE_OFF_DISAGREE_SID
                          , l_m.ONE_OFF_COMMENTS
                          , l_m.QUANT_COMMENTS
                          , l_m.OO_PRINCIPLE_SID
                          , l_m.LABEL_SIDS
                          , l_m.IS_EU_FUNDED_SID
                          , l_m.EU_FUND_SID
                          , 'Y'
                          , l_measure_sid);

         IF l_measure_sid < 0 THEN
            RAISE e_error;
         END IF;

         setMeasureValues(l_measure_sid
                        , p_country_id
                        , l_m.YEAR
                        , l_m.START_YEAR
                        , l_m.DATA
                        , l_res);

         IF l_res < 0 THEN
            RAISE e_error;
         END IF;

         o_res := o_res + 1;
      END LOOP;
   END uploadWizardMeasures;
END DFM_MEASURE;
/